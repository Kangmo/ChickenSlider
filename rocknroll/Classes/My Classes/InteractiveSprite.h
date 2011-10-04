#import <Foundation/Foundation.h>
#import "BodyInfo.h"
#import "cocos2d.h"

typedef enum body_touch_action_t
{
    BTA_NONE = 0,
    BTA_SCENE_TRANSITION = 1
} body_touch_action_t;

typedef enum body_hover_action_t
{
    BHA_NONE = 0,
    BHA_SHOW_IMAGE = 1
} body_hover_action_t;

@interface InteractiveSprite : CCSprite<CCTargetedTouchDelegate> {
    /** @brief The action type and descriptors for touch action.
     */
    body_touch_action_t touchActionType_;
    NSDictionary* touchActionDescs_;
    /** @brief The action type and descriptors for hover action.
     */
    body_hover_action_t hoverActionType_;
    NSDictionary* hoverActionDescs_;

    /** @brief The bottom left corner of the AABB of this interactive body : Y increases as the point moves up within the screen.
     */
    CGPoint bottomLeftCorner_;
    /** @brief The size the AABB of this interactive body : Unit : pixels
     */
    CGSize nodeSize_;
    /** @brief The scale. This is for future usage. Currently it is 1.0 
     */
    CGFloat scale_;
    
}
@property(assign, nonatomic) CGPoint bottomLeftCorner;
@property(assign, nonatomic) CGSize nodeSize;
@property(assign, nonatomic) CGFloat scale;
@property(assign, nonatomic) CCLayer * layer;

@property(assign, nonatomic, readonly) NSDictionary * touchActionDescs;


-(id)initWithFile:(NSString*)fileName;

-(void)setTouchAction:(body_touch_action_t)actionType actionDescs:(NSDictionary*)actionDescs;

-(void)setHoverAction:(body_hover_action_t)actionType actionDescs:(NSDictionary*)actionDescs;

-(void)removeFromTouchDispatcher;

@end
