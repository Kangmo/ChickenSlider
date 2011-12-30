#import "InteractiveSprite.h"
#import "StageScene.h"
#import "GeneralScene.h"
#import "LevelMapScene.h"
#import "ProgressCircle.h"
#import "ClipFactory.h"
#import "GeneralMessageProtocol.h"
#import "OptionScene.h"
#import "IntermediateScene.h"
#import "AppDelegate.h"
#include "AppAnalytics.h"
#include "ParticleManager.h"
@implementation InteractiveSprite

@synthesize bottomLeftCorner = bottomLeftCorner_;
@synthesize nodeSize = nodeSize_;
@synthesize scale = scale_;
@synthesize layer = layer_;
@synthesize touchActionDescs = touchActionDescs_;

/** @brief Convert the touch action type in SVG file into body_touch_action_t enumeration 
 */
+(body_touch_action_t)getTouchAction:(NSString*)actionName {
    body_touch_action_t touchAction = BTA_NULL;
    
    if ( [actionName isEqualToString:@"SceneTransition"] ) // Cocos2d: Replace Scene
    {
        touchAction = BTA_SCENE_TRANSITION;
    }
    else if ( [actionName isEqualToString:@"PushScene"] ) // Cocos2d: Push Scene
    {
        touchAction = BTA_PUSH_SCENE;
    }
    else if ( [actionName isEqualToString:@"AddLayer"] )
    {
        touchAction = BTA_ADD_LAYER; // Give up the current stage, move to the map scene where this stage exists.
    }
    else if ( [actionName isEqualToString:@"OpenURL"] )
    {
        touchAction = BTA_OPEN_URL; // Open URL. This is for opening Facebook, Twitter, G+.
    }
    else if ( [actionName isEqualToString:@"None"] )
    {
        touchAction = BTA_NONE; // Do nothing. But process some optional actions specified "Option" field in the action descs.
    }
    return touchAction;
}

/** @brief Override init to receive touch events. 
 */
-(id)initWithFile:(NSString*)fileName {
    if ( (self = [super initWithFile:fileName]) )
    {
        [[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
        touchActionType_ = BTA_NULL;
        touchActionDescs_ = nil;
        hoverActionType_ = BHA_NULL;
        hoverActionDescs_ = nil;
        scale_ = 1.0;
        bottomLeftCorner_ = CGPointMake(-1,-1);
        nodeSize_ = CGSizeMake(-1,-1);
        
        // The CCSprite itself is a hovering image. Don't show the hovering image at first.
        self.visible = NO;
        particleEmitter_ = nil;
        
        lockSprite_ = nil;
        
        //tickScheduled_ = NO;
        //tickAccDT_ = 0;
        progressCircle_ = [[ProgressCircle alloc] init];
    }
    
    return self;
}

-(void) startProgress {
    if ( [progressCircle_ parent] == nil )
    {
        [[self parent] addChild:progressCircle_];
        // The progress node has the same position.
        progressCircle_.position = self.position;
        
        // Show that IAP is on progress
        // start the progress circle.
        [progressCircle_ start];
    }
}

-(void) stopProgress {
    if ( [progressCircle_ parent] )
    {
        // Stop the progress circle.
        [progressCircle_ stop];
        
        // Remove the progress circle.
        [[self parent] removeChild:progressCircle_ cleanup:NO];
    }
}

-(BOOL) isLocked {
    return lockSprite_?YES:NO;
}

-(void) setLocked:(BOOL)locked spriteFrameName:(NSString*)spriteFrameName
{
    
    if (locked)
    {
#if ! defined(UNLOCK_LEVELS_FOR_TEST)        
        CCNode * parent = [self parent];
        
        // Should not lock twice
        assert( ! [self isLocked] );
        lockSprite_ = [[CCSprite spriteWithSpriteFrameName:spriteFrameName] retain];
        assert(lockSprite_);
        
        [parent addChild:lockSprite_];
        // The lock sprite has the same position.
        lockSprite_.position = self.position;
#endif /*UNLOCK_LEVELS_FOR_TEST*/
    }
    else
    {
        // Should not unlock twice
        assert( [self isLocked] );
        [lockSprite_ release];
        
        [lockSprite_ runAction:[CCScaleTo actionWithDuration:1.0f scale:2.0f]];
        [lockSprite_ runAction:[CCSequence actions:
                               [CCFadeOut actionWithDuration:1.0f],
                               [CCCallFuncND actionWithTarget:lockSprite_ selector:@selector(removeFromParentAndCleanup:) data:(void*)YES/*failed*/],
                               nil]];
        lockSprite_ = nil;
    }
}

-(void) setLocked:(BOOL)locked 
{
    [self setLocked:locked spriteFrameName:@"Locked.png"];
}

/** @brief Set the action type and data
 *
 */
-(void)setTouchAction:(body_touch_action_t)actionType actionDescs:(NSDictionary*)actionDescs
{
    touchActionType_ = actionType;
    touchActionDescs_ = [actionDescs retain];
}

/** @brief Set the action type and data
 *
 */
-(void)setHoverAction:(body_hover_action_t)actionType actionDescs:(NSDictionary*)actionDescs
{
    hoverActionType_ = actionType;
    hoverActionDescs_ = [actionDescs retain];
}

/** @brief Remove this object from touch dispatcher 
 */
-(void)removeFromTouchDispatcher
{
    CCLOG(@"Interactive Body Node : removeFromTouchDispatcher");
    
    [[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
}

/** @brief called when IAP is done
 */
-(void)onFinishIAP:(NSString *)product
{
    // Common stuff to process
    NSString * unlockingProductName = [touchActionDescs_ valueForKey:@"UnlockingProductName"];
    assert(unlockingProductName);
    
    {    
        // Make sure that the feature is purchased.
        if ( [[IAP sharedIAP] isFeaturePurchased:unlockingProductName ] )
        {
            AppAnalytics::sharedAnalytics().logEvent( "IAP:CONFIRM_PURCHASED:"+[Util toStdString:unlockingProductName] );
            [self setLocked:NO];
        }
        
        AdManager * adManager = [AdManager sharedAdManager];
        if (adManager) { // If this is 2nd purchase, we don't have AdManager.
            if (adManager.hasAD) {
                [adManager removeAD];
            }
        }
    }
    
    [self stopProgress];
}

/** @brief called when IAP is canceled 
 */
-(void)onCancelIAP:(NSString *)product
{
    [self stopProgress];
}

-(void)dealloc
{
    CCLOG(@"Interactive Body Node : dealloc");
    // in case you have something to dealloc, do it in this method
    /*
    if (tickScheduled_)
    {
        [self unschedule: @selector(tick:)];
        tickScheduled_ = NO;
    }
    */
    [progressCircle_ stop];
    [progressCircle_ release];
    progressCircle_ = nil;

    // Don't notify me of any IAP purchse anymore, I am going to die!!
    [IAP sharedIAP].delegate = nil;

    if (lockSprite_)
    {
        [lockSprite_ release];
        lockSprite_ = nil;
    }
    [touchActionDescs_ release];
    [hoverActionDescs_ release];

    [super dealloc];
}

/** @brief Handles touch action based on the action type and descriptor.
 */
-(void)handleTouchAction
{
    assert(touchActionType_);
    assert(touchActionDescs_);
    
    // BUGBUG : We need isTouchHandling_ at the LevelMapScene
    
    CCLayer * owningLayer = (CCLayer*)[self parent];
    assert(owningLayer);
    assert([owningLayer isKindOfClass:[CCLayer class]] );

    BOOL pushScene = NO;

    NSString * soundFileName = [touchActionDescs_ valueForKey:@"Sound"];
    if ( soundFileName) {
        CDSoundSource * sound = [[ClipFactory sharedFactory] soundByFile:soundFileName];
        [sound play];
    }

    // See if there is any option that we need to process for all types of touch actions.
    NSString * actionMessage = [touchActionDescs_ valueForKey:@"ActionMessage"];
    if (actionMessage)
    {
        assert( [owningLayer isKindOfClass:[GeneralScene class]] );
        GeneralScene * generalScene = (GeneralScene*) owningLayer;
        assert( generalScene.actionListener );
        
        // Send action to the action listener.
        [generalScene.actionListener onMessage:actionMessage];
    }

    // See if there is any option that we need to process for all types of touch actions.
    NSString * option = [touchActionDescs_ valueForKey:@"Option"];
    if (option) 
    {
        if ( [option isEqualToString:@"PopCurrentScene"] )
        {
            // Pop the current scene. This is necessary if we pushed the current scene.
            // BUGBUG : Access Freed : "this" interactive sprite is owned by the popped scene. Is "this" interactive sprite deallocated?
            [[CCDirector sharedDirector] popScene];
            CCLOG(@"Option=PopCurrentScene. Popped current scene");
        }
        
        if ( [option isEqualToString:@"RemoveOwningLayer"] )
        {
            // Remove the owning layer of this interactive sprite.
            // BUGBUG : Access Freed : "this" interactive sprite is owned by the popped scene. Is "this" interactive sprite deallocated?

            CCScene * scene = (CCScene*)[owningLayer parent];
            assert(scene);
            assert([scene isKindOfClass:[CCScene class]] );
            
            [scene removeChild:owningLayer cleanup:YES];
            
            CCLOG(@"Option=RemoveOwningLayer. Removed owning layer of the interactive sprite");
        }
    }
    
    switch(touchActionType_)
    {
        case BTA_NONE : 
        {
            // Do Nothing.
        }
        break;
            
        case BTA_OPEN_URL : 
        {
            NSString * URLString = [touchActionDescs_ valueForKey:@"URL"];
            AppDelegate * appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
            [appDelegate openWebView:URLString];
        }
        break;
            
        case BTA_ADD_LAYER : 
        {
            // The running scene should be StageScene with a level svg file.
            CCScene * runningScene = [[CCDirector sharedDirector] runningScene];
            
            assert( [runningScene isKindOfClass:[CCScene class]] );
            
            // 'layer' is an autorelease object.
            GeneralScene *confirmQuitLayer = [GeneralScene nodeWithSceneName:@"ConfirmQuitLayer"];
            //[confirmQuitLayer swallowTouch];
            
            // The current layer (which owns this interactive sprite, IOW GeneralScene with PauseLayer.svg) becomes the action listener
            assert( [owningLayer conformsToProtocol:@protocol(GeneralMessageProtocol)] );
            id<GeneralMessageProtocol> messageProtocol = (id<GeneralMessageProtocol>) owningLayer;
            confirmQuitLayer.actionListener = messageProtocol;
            
            // add layer as a child to scene
            [runningScene addChild:confirmQuitLayer z:200 tag:GeneralSceneLayerTagMain];
        }
        break;
            
        case BTA_PUSH_SCENE : 
            pushScene = YES;
            // fall through...
        case BTA_SCENE_TRANSITION : 
        {
            NSString * sceneName = [touchActionDescs_ valueForKey:@"SceneName"];
            assert(sceneName);
            
            CCScene * newScene = nil;
            if ( [sceneName isEqualToString:@"StageScene"] )
            {
                // The string uniquly identifying the name of a map that has multiple stages.
                NSString * mapNameAttr = [touchActionDescs_ valueForKey:@"Arg1"];
                assert(mapNameAttr);
                
                // The string uniquly identifying level of stage.
                NSString * levelNumAttr = [touchActionDescs_ valueForKey:@"Arg2"];
                assert(levelNumAttr);
                
                int levelNum = [levelNumAttr intValue];

                // Move the hero to the new level and start the new level stage
                newScene = [GeneralScene loadingSceneOfMap:mapNameAttr levelNum:levelNum];
            }
            // If the scene name starts with "MAP", we instantiate LevelMapScene.
            else if ( [[sceneName substringWithRange:NSMakeRange(0,3)] isEqualToString:@"MAP"] )
            {
                newScene = [LevelMapScene sceneWithName:sceneName];
            }
            else if ( [sceneName isEqualToString:@"OptionScene"] )
            {
                newScene = [OptionScene sceneWithName:sceneName];
            }
            else
            {
                newScene = [GeneralScene sceneWithName:sceneName];
            }
            
            if (newScene)
            {
                if (pushScene) {
                    [[CCDirector sharedDirector] pushScene:newScene ];
                }
                else {
                    // Do we have a scene to show before starting the actual scene?
                    // Ex> Show opening scene before playing stage 1.
                    NSString * intermediateSceneName = [touchActionDescs_ valueForKey:@"IntermediateScene"];
                    if ( intermediateSceneName ) {
                        CCScene * intermediateScene = [IntermediateScene sceneWithName:intermediateSceneName 
                                                                                       nextScene:newScene];
                        // replace the scene with the intermediate scene.
                        newScene = intermediateScene;
                    } 
                    [[CCDirector sharedDirector] replaceScene:[Util defaultSceneTransition:newScene] ];
                }
            }
        }
        break;
            
        default:
        {
            NSAssert1(0, @"Unhandled touch action type found. %d", (int)touchActionType_);
        }
        break;
    }
}

/** @brief Handles hover action based on the action type and descriptor.
 */
-(void)handleHoverAction
{
    assert(hoverActionType_);
    assert(hoverActionDescs_);
    
    switch(hoverActionType_)
    {
        case BHA_SHOW_PARTICLE:
        {
            // Particle emitter. Emit partcles until the hovering is done. (3600 seconds means 1 hour)
            particleEmitter_ = ParticleManager::createParticleEmitter(@"stars.png", 30, 3600);
            
            [self addChild:particleEmitter_ z:10]; // adding the emitter
            
            // Show the hovering sprite.
            self.visible = YES;
        }
        break;
            
        case BHA_SHOW_IMAGE : 
        {
            // Show the hovering sprite.
            self.visible = YES;
        }
        break;
            
        default:
        {
            NSAssert1(0, @"Unhandled hover action type found. %d", (int)touchActionType_);
        }
        break;
    }

}

-(BOOL) isTouchOnNode:(CGPoint)touch{
    // Enlarge the touch area by INTERACTIVE_SPRITE_TOUCH_GAP pixcels on top/left/bottom/right to make the touch easier 
    if(CGRectContainsPoint(CGRectMake(self.bottomLeftCorner.x-INTERACTIVE_SPRITE_TOUCH_GAP, 
                                      self.bottomLeftCorner.y-INTERACTIVE_SPRITE_TOUCH_GAP, 
                                      self.nodeSize.width*self.scale + INTERACTIVE_SPRITE_TOUCH_GAP*2, 
                                      self.nodeSize.height*self.scale + INTERACTIVE_SPRITE_TOUCH_GAP *2), 
                           touch))
        return YES;
    else 
        return NO;
}

-(BOOL)ccTouchBegan:(UITouch*)touch withEvent:(UIEvent *)event {
    
    CGPoint touchPoint = [touch locationInView:[touch view]];
    touchPoint = [[CCDirector sharedDirector] convertToGL:touchPoint ];
//    CCLOG(@"InteractiveBodyNode : Touch Began=>%f,%f", touchPoint.x, touchPoint.y );
    if ([self isTouchOnNode:touchPoint]) {
        if ( [self isLocked] )
        {
            // Common stuff to process
            NSString * unlockingProductName = [touchActionDescs_ valueForKey:@"UnlockingProductName"];
            if (!unlockingProductName) // If it can't be unlocked by purchasing a product, don't show the hovering action. 
            {
                // BUGBUG : play some sound
                return YES;
            }
        }
        if ( hoverActionType_ != BHA_NULL ) // Handle the hovering action if it is specified.
        {
            [self handleHoverAction];
        }
        return YES;
    }
    return NO;
}

-(void)ccTouchMoved:(UITouch*)touch withEvent:(UIEvent *)event {
}



/** @brief Restore unfinished IAP transaction and finishe it 
 */
-(void) tryUnlockWithIAP
{
    // Common stuff to process
    NSString * unlockingProductName = [touchActionDescs_ valueForKey:@"UnlockingProductName"];
    
    if ( unlockingProductName) {
        [[IAP sharedIAP] tryPurchase:unlockingProductName];
        
        [self startProgress];
    }
}

-(void)ccTouchEnded:(UITouch*)touch withEvent:(UIEvent *)event {

    // Do not show the hovering sprite.
    self.visible = NO;
    if ( particleEmitter_ )
    {
        [particleEmitter_ removeFromParentAndCleanup:YES];
        particleEmitter_ = nil;
    }

    CGPoint touchPoint = [touch locationInView:[touch view]];
    touchPoint = [[CCDirector sharedDirector] convertToGL:touchPoint ];
//    CCLOG(@"InteractiveBodyNode : Touch Ended=>%f,%f", touchPoint.x, touchPoint.y );
    if ([self isTouchOnNode:touchPoint]) {
        if ( [self isLocked] )
        {
            // BUGBUG : play some sound
            [self tryUnlockWithIAP];
 
            return;
        }
        
        [self handleTouchAction];
    }
}

- (void) onEnterTransitionDidFinish {
    // Common stuff to process
    NSString * unlockingProductName = [touchActionDescs_ valueForKey:@"UnlockingProductName"];
    
    if ( unlockingProductName) {
        // The feature is not purchased. Lock the feature.
        if ( ! [[IAP sharedIAP] isFeaturePurchased:unlockingProductName] )
        {
            
            [self setLocked:YES];
            
            // Schedule tick to check if the feature is purchased. 
            // The tick method will detect that the feature is purchased to unlock the feature. 
            // Why do like this? IAP response is asynchronous.
            // Why do polling rather than notifying the purchase? The scene can be changed and this object might not exist, so we can't use notification. (Notification to non-existent object causes crash.)
            [IAP sharedIAP].delegate = self;
/*
            if (!tickScheduled_)
            {
                [self schedule: @selector(tick:)];
                tickScheduled_ = YES;
            }
*/
        }
        if ( [self isLocked] )
        {
            // However, if the player collected "UnlockingFeathers" number of water drops, 
            // Unlock the feature.
            // Load water drop count
            
            // Common stuff to process
            // BUGBUG : Change key to UnlockingChicks
            NSString * unlockingFeathers = [touchActionDescs_ valueForKey:@"UnlockingFeathers"];
            if ( unlockingFeathers )
            {
                int unlockingCount = [unlockingFeathers intValue];
                assert( unlockingCount>0 );
                // BUGBUG Need to change game UI to the number of UnlockingFeathers..
                int chickCount = [Util loadTotalChickCount];
                if ( chickCount > unlockingCount )
                {
                    [IAP sharedIAP].delegate = nil;
                    [self setLocked:NO];
                }
            }
            
#if defined(DISABLE_IAP)
            [IAP sharedIAP].delegate = nil;
            [self setLocked:NO];
#endif

        }
    }
    
    [super onEnterTransitionDidFinish];
}


@end
