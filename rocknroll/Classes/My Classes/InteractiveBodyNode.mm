//
//  InteractiveBodyNode.m
//  rocknroll
//
//  Created by 강모 김 on 11. 7. 21..
//  Copyright 2011 강모소프트. All rights reserved.
//

#import "InteractiveBodyNode.h"
#import "StageScene.h"
#import "GeneralScene.h"

@implementation InteractiveBodyNode

@synthesize bottomLeftCorner = bottomLeftCorner_;
@synthesize nodeSize = nodeSize_;
@synthesize scale = scale_;
@synthesize layer = layer_;

/** @brief Override init to receive touch events. 
 */
-(id)init {
    if ( (self = [super init]) )
    {
        [[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];

        touchActionType_ = BTA_NONE;
        touchActionDescs_ = nil;
        hoverActionType_ = BHA_NONE;
        hoverActionDescs_ = nil;
        scale_ = 1.0;
        bottomLeftCorner_ = CGPointMake(-1,-1);
        nodeSize_ = CGSizeMake(-1,-1);
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
                // BUGBUG : TODO : play sound file
            }
            
            CCScene * newScene;
            if ( [sceneName isEqualToString:@"StageScene"] )
            {
                // The string uniquly identifying level of stage.
                NSString * levelStr = [touchActionDescs_ valueForKey:@"Arg1"];
                assert(levelStr);
                // The stage scene is totally large, we can't use the scene.
                newScene = [StageScene sceneWithLevel:levelStr];
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
            NSString * imageFileName = [hoverActionDescs_ valueForKey:@"ImageFile"];
            assert(imageFileName);
            
            NSString * soundFileName = [hoverActionDescs_ valueForKey:@"Sound"];
            if ( soundFileName) {
                // BUGBUG : TODO : play sound file
            }

            hoverSprite_ = [CCSprite spriteWithFile:imageFileName];
            NSAssert1(hoverSprite_, @"The hovering image file(%@) does not exist.", imageFileName);
            
            // position the hovering image on the center of original box.
            hoverSprite_.position =  ccp( bottomLeftCorner_.x + nodeSize_.width * 0.5 , bottomLeftCorner_.y + nodeSize_.height * 0.5 );
            
            assert(layer_);
            [layer_ addChild:hoverSprite_ z:0];
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
/*    
    if(CGRectContainsPoint(CGRectMake(self.topLeftCorner.x - ((self.nodeSize.width*0.5)*self.scale), self.topLeftCorner.y - ((self.nodeSize.height*0.5)*self.scale), self.nodeSize.width*self.scale, self.nodeSize.height*self.scale), touch))
        return YES;
    else 
        return NO;
*/ 
    if(CGRectContainsPoint(CGRectMake(self.bottomLeftCorner.x, self.bottomLeftCorner.y, self.nodeSize.width*self.scale, self.nodeSize.height*self.scale), touch))
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

    assert( hoverSprite_ );
    
    // remove the hovering sprite from the layer. 
    [hoverSprite_ removeFromParentAndCleanup:NO];
    hoverSprite_ = nil;
}

@end
