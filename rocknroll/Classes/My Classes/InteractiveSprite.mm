#import "InteractiveSprite.h"
#import "StageScene.h"
#import "GeneralScene.h"
#import "LevelMapScene.h"
#import "ProgressCircle.h"
#import "ClipFactory.h"
#import "GeneralMessageProtocol.h"
#import "OptionScene.h"
#import "OnlineScene.h"
#import "IntermediateScene.h"
#import "AppDelegate.h"
#include "AppAnalytics.h"
#include "ParticleManager.h"

#import "GameState.h"
#import "DemoManager.h"
#import "GeneralScene.h"
@interface InteractiveSprite() 
-(void) onTouchMenu:(id)sender;
@end

@implementation InteractiveSprite

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
    else if ( [actionName isEqualToString:@"ReplaceLayer"] ) // Cocos2d: Replace Menu Layer
    {
        touchAction = BTA_REPLACE_LAYER;
    }
    else if ( [actionName isEqualToString:@"PushLayer"] ) // Cocos2d: Replace Menu Layer
    {
        touchAction = BTA_PUSH_LAYER;
    }
    else if ( [actionName isEqualToString:@"PopLayer"] ) // Cocos2d: Replace Menu Layer
    {
        touchAction = BTA_POP_LAYER;
    }
    else if ( [actionName isEqualToString:@"PopAndDiscardLayer"] ) // Cocos2d: Replace Menu Layer
    {
        touchAction = BTA_POP_AND_DISCARD_LAYER;
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

/** @brief Convert the start action type in SVG file into body_start_action_t enumeration 
 */
+(body_start_end_action_t)getStartEndAction:(NSString*)actionName {
    body_start_end_action_t touchAction = BSEA_NULL;
    
    if ( [actionName isEqualToString:@"SlideIn"] ) // Cocos2d: Replace Scene
    {
        touchAction = BSEA_SLIDE_IN;
    }
    else if ( [actionName isEqualToString:@"SlideOut"] ) // Cocos2d: Push Scene
    {
        touchAction = BSEA_SLIDE_OUT;
    }
    
    return touchAction;
}
    
/** @brief Override init to receive touch events. 
 */
-(id)initWithFile:(NSString*)fileName {
    
    if ( (self = [super init]) )
    {
        CCMenuItem * menuItem = [CCMenuItemImage itemFromNormalImage:fileName selectedImage:fileName target:self selector:@selector(onTouchMenu:)];

        // The default anchorPoint of CCNode is (0,0). Change the anchor point to (0.5, 0.5);
        self.anchorPoint = ccp(0.5, 0.5);
        self.contentSize = menuItem.contentSize;
        [self addChildAtCenter:[CCMenu menuWithItems:menuItem, nil] z:0];
        
        touchActionType_ = BTA_NULL;
        touchActionDescs_ = nil;
        startActionType_ = BSEA_NULL;
        startActionDescs_ = nil;
        endActionType_ = BSEA_NULL;
        endActionDescs_ = nil;

        
        lockSprite_ = nil;
        
        //tickScheduled_ = NO;
        //tickAccDT_ = 0;
        progressCircle_ = [[ProgressCircle alloc] init];
    }
    
    return self;
}

+(id)spriteWithTouchAction:(NSString*)objectTouchAction 
               startAction:(NSString*)objectStartAction 
                 endAction:(NSString*)objectEndAction 
           backgroundImage:(NSString*)backgroundImage {
    
    // Set start action.
    NSMutableDictionary * startActionDescs = StringParser::getDictionary(objectStartAction);
    body_start_end_action_t startAction = BSEA_NULL;
    NSString * startActionName = [startActionDescs valueForKey:@"Action"];
    if (startActionName) {
        startAction = [InteractiveSprite getStartEndAction:startActionName];
    }

    // Set end action.
    NSMutableDictionary * endActionDescs = StringParser::getDictionary(objectEndAction);
    body_start_end_action_t endAction = BSEA_NULL;
    NSString * endActionName = [endActionDescs valueForKey:@"Action"];
    if (endActionName) {
        endAction = [InteractiveSprite getStartEndAction:endActionName];
    }

    if (!backgroundImage) {
        // Use transparent dummy sprite if no background image is given.
        backgroundImage = @"Dummy.png";
    }
    
    // Set touch action.
    NSMutableDictionary * touchActionDescs = StringParser::getDictionary(objectTouchAction);
    body_touch_action_t touchAction = BTA_NULL;
    NSString * actionName = [touchActionDescs valueForKey:@"Action"];
    touchAction = [InteractiveSprite getTouchAction:actionName];

    
    InteractiveSprite * intrSprite = [[[InteractiveSprite alloc] initWithFile:backgroundImage] autorelease];
    assert(intrSprite);
    
    [intrSprite setStartAction:startAction actionDescs:startActionDescs ];
    [intrSprite setEndAction:endAction actionDescs:endActionDescs ];
    [intrSprite setTouchAction:touchAction actionDescs:touchActionDescs ];
    
    return intrSprite;
}

-(void) addChildAtCenter:(CCNode*)node z:(int)z {
    [self addChild:node z:z];
    
    CGSize nodeSize = [self contentSize];
    // The child(progressCircle_) position is relative to bottom left corner of the parent(self)
    // The lock sprite has the same position. 
    node.position = ccp(nodeSize.width*0.5, nodeSize.height*0.5);
}

-(void) startProgress {
    if ( [progressCircle_ parent] == nil )
    {
        [self addChildAtCenter:progressCircle_ z:2000];

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
        [self removeChild:progressCircle_ cleanup:NO];
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
        // Should not lock twice
        assert( ! [self isLocked] );
        lockSprite_ = [[CCSprite spriteWithSpriteFrameName:spriteFrameName] retain];
        assert(lockSprite_);
        
        [self addChildAtCenter:lockSprite_ z:1000];

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
-(void)setStartAction:(body_start_end_action_t)actionType actionDescs:(NSDictionary*)actionDescs
{
    startActionType_ = actionType;
    startActionDescs_ = [actionDescs retain];
}

/** @brief Set the action type and data
 *
 */
-(void)setEndAction:(body_start_end_action_t)actionType actionDescs:(NSDictionary*)actionDescs
{
    endActionType_ = actionType;
    endActionDescs_ = [actionDescs retain];
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
    [startActionDescs_ release];
    [endActionDescs_ release];

    [super dealloc];
}

/** @brief Handles touch action based on the action type and descriptor.
 */
-(void)handleTouchAction
{
    assert(touchActionType_);
    assert(touchActionDescs_);
    
    // BUGBUG : We need isTouchHandling_ at the LevelMapScene
    
    GeneralScene * owningLayer = (GeneralScene*)[self parent];
    assert(owningLayer);
    assert([owningLayer isKindOfClass:[GeneralScene class]] );

    BOOL pushScene = NO;
    NSString * layerName = nil;
    
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
        assert( owningLayer.actionListener );
        
        // Send action to the action listener.
        [owningLayer.actionListener onMessage:actionMessage];
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
            [runningScene addChild:confirmQuitLayer z:200 tag:GeneralSceneLayerTagMenu];
        }
        break;
            
        case BTA_POP_AND_DISCARD_LAYER:
        {
            // Simply remove the layer
            [[DemoManager sharedDemoManager] popLayerName];
            break;
        }
        case BTA_POP_LAYER:
        {
            layerName = [[DemoManager sharedDemoManager] popLayerName];
            if ( !layerName ) // Users may click the back button twice. Process it only if the popped layer name is not nil. 
                break;
            NSAssert(layerName, @"The popped layer is NULL.");
            // fall through
        }
        case BTA_PUSH_LAYER :
        case BTA_REPLACE_LAYER : 
        {
            GeneralScene * newLayer = nil;
            if ( !layerName ) {
                layerName = [touchActionDescs_ valueForKey:@"SceneName"];
            }
            
            // Push the current layer name so that we can come back .
            if ( touchActionType_ == BTA_PUSH_LAYER ) {
                id parent = self.parent;
                NSAssert2( [parent isKindOfClass:[GeneralScene class]], @"Parent(%@) of InteractiveSprite(%@) is not a kind of GeneralScene", parent, self);
                GeneralScene * generalScene = (GeneralScene*) parent;
                [[DemoManager sharedDemoManager] pushLayerName:generalScene.layerName];
            }
            
            // If the scene name starts with "MAP", we instantiate LevelMapScene.
            if ( [[layerName substringWithRange:NSMakeRange(0,3)] isEqualToString:@"MAP"] )
            {
                newLayer = [LevelMapScene nodeWithSceneName:layerName];
            }
            else if ( [layerName isEqualToString:@"OptionScene"] )
            {
                newLayer = [OptionScene nodeWithSceneName:layerName];
            }
            else if ( [layerName isEqualToString:@"OnlineScene"] )
            {
                newLayer = [OnlineScene nodeWithSceneName:layerName];
            }
            else
            {
                newLayer = [GeneralScene nodeWithSceneName:layerName];
            }
            
            // The new layer sends message to the same action listener.
            // Ex> PauseLayer's action listener is StageScene. When the user hits on the "Quit" button in the PauseLayer, "ConfirmQuitLayer" is pushed. In this case, ConfirmQuitLayer's OK button will send "Quit" message to StageScene.
            newLayer.actionListener = owningLayer.actionListener;
            
            [[DemoManager sharedDemoManager] reserveReplacingMenuLayer:newLayer];
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

                GamePlayerFlag playerFlag = GF_SingleInitiator;
                
                if ( [Util loadPlayMode] ) { // The multiplay toggle is turned on in the stage selection scene.
                    playerFlag = GF_MultiplayInitiator;
                }
                
                [GameState sharedGameState].playerFlag = playerFlag;
                
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
                } else {
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

-(void) onTouchMenu:(id)sender {
    if ( [self isLocked] )
    {
        // BUGBUG : play some sound
        [self tryUnlockWithIAP];
        
        return;
    }
    
    [self handleTouchAction];
}

-(void) applyStartEndAction:(body_start_end_action_t)action descs:(NSDictionary*)descs {
    if ( action == BSEA_SLIDE_IN ) {
        static CGSize winSize = [[CCDirector sharedDirector] winSize];
        
        float initX = [[descs valueForKey:@"InitX"] floatValue];
        float initY = [[descs valueForKey:@"InitY"] floatValue];
        float duration = [[descs valueForKey:@"Duration"] floatValue];
        float period = [[descs valueForKey:@"Period"] floatValue];
        
        float adjustAmountX = winSize.width * initX;
        float adjustAmountY = winSize.height * initY;
        
        [self stopAllActions];
        
        self.position = ccpAdd(self.position, ccp(adjustAmountX, adjustAmountY));
        
        CCActionInterval * moveBy = [CCMoveBy actionWithDuration:duration
                                                        position:ccp( adjustAmountX * -1, adjustAmountY * -1)];
        
        CCEaseElasticOut * easeOut = [CCEaseElasticOut actionWithAction:moveBy
                                                                 period:period];
        
        CCDelayTime * delay = [CCDelayTime actionWithDuration:2.0f];
        
        CCActionInterval * moveDown = [CCMoveBy actionWithDuration:0.3
                                                          position:ccp( 0, -5)];
        CCActionInterval * moveUp = [CCMoveBy actionWithDuration:0.3
                                                        position:ccp( 0, 30)];
        CCActionInterval * moveDownAgain = [CCMoveBy actionWithDuration:0.3
                                                               position:ccp( 0, -25)];
        CCSequence * moveSequence = [CCSequence actions:moveDown, moveUp, moveDownAgain, nil];
        CCEaseElasticInOut * easeOutMoveUp = [CCEaseElasticInOut actionWithAction:moveSequence
                                                                           period:1.0f];
        
        CCSequence * repeatSequence = [CCSequence actions:delay,easeOutMoveUp,nil];
        
        CCSequence * sequence = [CCSequence actions:easeOut,repeatSequence,repeatSequence,repeatSequence,repeatSequence,repeatSequence,repeatSequence,repeatSequence,repeatSequence,repeatSequence,repeatSequence,repeatSequence,repeatSequence,repeatSequence,repeatSequence,repeatSequence,repeatSequence,repeatSequence,repeatSequence,repeatSequence,repeatSequence,repeatSequence,repeatSequence,repeatSequence,repeatSequence,repeatSequence,repeatSequence,repeatSequence,repeatSequence,repeatSequence,repeatSequence,repeatSequence,repeatSequence,nil];
        [self runAction:sequence];
    }
    
    if ( action == BSEA_SLIDE_OUT ) {
        static CGSize winSize = [[CCDirector sharedDirector] winSize];
        
        float targetX = [[descs valueForKey:@"TargetX"] floatValue];
        float targetY = [[descs valueForKey:@"TargetY"] floatValue];
        float sleepSeconds = [[descs valueForKey:@"Sleep"] floatValue];
        float duration = [[descs valueForKey:@"Duration"] floatValue];
        float period = [[descs valueForKey:@"Period"] floatValue];
        
        float adjustAmountX = winSize.width * targetX;
        float adjustAmountY = winSize.height * targetY;
        
        [self stopAllActions];
        
        CCActionInterval * moveBy = [CCMoveBy actionWithDuration:duration
                                                        position:ccp( adjustAmountX, adjustAmountY)];
        
        CCEaseElasticIn * easeIn = [CCEaseElasticIn actionWithAction:moveBy
                                                                 period:period];
        
        CCDelayTime * delay = [CCDelayTime actionWithDuration:sleepSeconds];
        
        CCSequence * sequence = [CCSequence actions:delay,easeIn,nil];
        
        [self runAction:sequence];
    }
}

- (void) onEnter {
    [super onEnter];
    [self applyStartEndAction:startActionType_ descs:startActionDescs_];
}

- (void) runEndAction {
    [self applyStartEndAction:endActionType_ descs:endActionDescs_];
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
