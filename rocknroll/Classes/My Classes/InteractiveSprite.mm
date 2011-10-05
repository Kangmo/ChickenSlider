#import "InteractiveSprite.h"
#import "StageScene.h"
#import "GeneralScene.h"
#import "LevelMapScene.h"

@implementation InteractiveSprite

@synthesize bottomLeftCorner = bottomLeftCorner_;
@synthesize nodeSize = nodeSize_;
@synthesize scale = scale_;
@synthesize layer = layer_;
@synthesize touchActionDescs = touchActionDescs_;


/** @brief Override init to receive touch events. 
 */
-(id)initWithFile:(NSString*)fileName {
    if ( (self = [super initWithFile:fileName]) )
    {
        [[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
        isTouchHandling_ = NO;
        touchActionType_ = BTA_NONE;
        touchActionDescs_ = nil;
        hoverActionType_ = BHA_NONE;
        hoverActionDescs_ = nil;
        scale_ = 1.0;
        bottomLeftCorner_ = CGPointMake(-1,-1);
        nodeSize_ = CGSizeMake(-1,-1);
        
        // The CCSprite itself is a hovering image. Don't show the hovering image at first.
        self.visible = NO;
        
        lockSprite_ = nil;
    }
    
    return self;
}

-(BOOL) isLocked {
    return lockSprite_?YES:NO;
}

-(void) setLocked:(BOOL)locked
{
    CCNode * parent = [self parent];
    
    if (locked)
    {
        // Should not lock twice
        assert( ! [self isLocked] );
        lockSprite_ = [[CCSprite spriteWithSpriteFrameName:@"Locked.png"] retain];
        assert(lockSprite_);
        
        [parent addChild:lockSprite_];
        // The lock sprite has the same position.
        lockSprite_.position = self.position;
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

-(void)dealloc
{
    CCLOG(@"Interactive Body Node : dealloc");
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
    
    // BUGBUG : We need this flag at the LevelMapScene
    if (isTouchHandling_) {
        return;
    }
    
    switch(touchActionType_)
    {
        case BTA_SCENE_TRANSITION : 
        {
            NSString * sceneName = [touchActionDescs_ valueForKey:@"SceneName"];
            assert(sceneName);

            NSString * soundFileName = [hoverActionDescs_ valueForKey:@"Sound"];
            if ( soundFileName) {
                [[[SimpleAudioEngine sharedEngine] soundSourceForFile:soundFileName] play];
            }
            
            CCScene * newScene = nil;
            if ( [sceneName isEqualToString:@"StageScene"] )
            {
                CCNode * parent = [self parent];
                // StageScene can be run only from the LevelMapScene 
                assert( [parent isKindOfClass:[LevelMapScene class]] );
                
                // The string uniquly identifying level of stage.
                NSString * mapNameAttr = [touchActionDescs_ valueForKey:@"Arg1"];
                assert(mapNameAttr);
                
                // The string uniquly identifying level of stage.
                NSString * levelNumAttr = [touchActionDescs_ valueForKey:@"Arg2"];
                assert(levelNumAttr);
                
                int levelNum = [levelNumAttr intValue];

                LevelMapScene * levelMapScene = (LevelMapScene*) parent;

                // Move the hero to the new level and start the new level stage
                [levelMapScene playLevel:levelNum ofMap:mapNameAttr];
            }
            // If the scene name starts with "MAP", we instantiate LevelMapScene.
            else if ( [[sceneName substringWithRange:NSMakeRange(0,3)] isEqualToString:@"MAP"] )
            {
                newScene = [LevelMapScene sceneWithName:sceneName];
            }
            else
            {
                newScene = [GeneralScene sceneWithName:sceneName];
            }
            
            if (newScene)
                [[CCDirector sharedDirector] replaceScene: newScene];
            
            isTouchHandling_ = YES;
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
        case BHA_SHOW_IMAGE : 
        {
            NSString * soundFileName = [hoverActionDescs_ valueForKey:@"Sound"];
            if ( soundFileName) {
                [[[SimpleAudioEngine sharedEngine] soundSourceForFile:soundFileName] play];
            }

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
            // BUGBUG : play some sound
            return YES;
        }
        if ( hoverActionType_ != BHA_NONE ) // Handle the hovering action if it is specified.
        {
            [self handleHoverAction];
        }
        return YES;
    }
    return NO;
}

-(void)ccTouchMoved:(UITouch*)touch withEvent:(UIEvent *)event {
}

-(void)ccTouchEnded:(UITouch*)touch withEvent:(UIEvent *)event {

    // Do not show the hovering sprite.
    self.visible = NO;


    CGPoint touchPoint = [touch locationInView:[touch view]];
    touchPoint = [[CCDirector sharedDirector] convertToGL:touchPoint ];
//    CCLOG(@"InteractiveBodyNode : Touch Ended=>%f,%f", touchPoint.x, touchPoint.y );
    if ([self isTouchOnNode:touchPoint]) {
        if ( [self isLocked] )
        {
            // BUGBUG : play some sound
            return;
        }
        
        [self handleTouchAction];
    }
}

@end
