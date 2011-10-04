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

        touchActionType_ = BTA_NONE;
        touchActionDescs_ = nil;
        hoverActionType_ = BHA_NONE;
        hoverActionDescs_ = nil;
        scale_ = 1.0;
        bottomLeftCorner_ = CGPointMake(-1,-1);
        nodeSize_ = CGSizeMake(-1,-1);
        
        // The CCSprite itself is a hovering image. Don't show the hovering image at first.
        self.visible = NO;
    }
    
    return self;
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
            
            CCScene * newScene;
            if ( [sceneName isEqualToString:@"StageScene"] )
            {
                // The string uniquly identifying level of stage.
                NSString * mapNameAttr = [touchActionDescs_ valueForKey:@"Arg1"];
                assert(mapNameAttr);
                
                // The string uniquly identifying level of stage.
                NSString * levelNumAttr = [touchActionDescs_ valueForKey:@"Arg2"];
                assert(levelNumAttr);
                
                int levelNum = [levelNumAttr intValue];

                newScene = [StageScene sceneInMap:mapNameAttr levelNum:levelNum];
            }
            else if ( [sceneName isEqualToString:@"LevelMapScene"] )
            {
                newScene = [LevelMapScene sceneWithName:sceneName];
            }
            else
            {
                newScene = [GeneralScene sceneWithName:sceneName];
            }
            [[CCDirector sharedDirector] replaceScene: newScene];
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
        [self handleHoverAction];
        return YES;
    }
    return NO;
}

-(void)ccTouchMoved:(UITouch*)touch withEvent:(UIEvent *)event {
    CGPoint touchPoint = [touch locationInView:[touch view]];
    touchPoint = [[CCDirector sharedDirector] convertToGL:touchPoint ];
//    CCLOG(@"InteractiveBodyNode : Touch Moved=>%f,%f", touchPoint.x, touchPoint.y );
}

-(void)ccTouchEnded:(UITouch*)touch withEvent:(UIEvent *)event {
    CGPoint touchPoint = [touch locationInView:[touch view]];
    touchPoint = [[CCDirector sharedDirector] convertToGL:touchPoint ];
//    CCLOG(@"InteractiveBodyNode : Touch Ended=>%f,%f", touchPoint.x, touchPoint.y );
    if ([self isTouchOnNode:touchPoint]) {
        [self handleTouchAction];
    }
    
    // Do not show the hovering sprite.
    self.visible = NO;
}

@end
