#import <Foundation/Foundation.h>
#import "BodyInfo.h"
#import "cocos2d.h"
#import "IAP.h"
#import "ProgressCircle.h"

typedef enum body_touch_action_t
{
    BTA_NULL = 0,
    BTA_SCENE_TRANSITION = 1,
    BTA_PUSH_SCENE = 2,
    BTA_REPLACE_LAYER = 3,
    BTA_PUSH_LAYER = 4,
    BTA_POP_LAYER = 5,
    BTA_POP_AND_DISCARD_LAYER = 6,
    BTA_ADD_LAYER = 7, // Give up the current stage, go to the level map scene.
    BTA_OPEN_URL = 8,
    BTA_NONE = 9,
} body_touch_action_t;

typedef enum body_start_end_action_t
{
    BSEA_NULL = 0,
    BSEA_SLIDE_IN = 1,
    BSEA_SLIDE_OUT = 2,
} body_start_end_action_t;

@interface InteractiveSprite : CCNode<IAPDelegate> {
    /** @brief The menu that this CCNode responds to 
     */
    CCMenu * menu;
    
    /** @brief The action type and descriptors for touch action.
     */
    body_touch_action_t touchActionType_;
    NSDictionary* touchActionDescs_;

    /** @brief The action type and descriptors for start action.
     */
    body_start_end_action_t startActionType_;
    NSDictionary* startActionDescs_;
    
    /** @brief The action type and descriptors for start action.
     */
    body_start_end_action_t endActionType_;
    NSDictionary* endActionDescs_;

    /** @brief The bottom left corner of the AABB of this interactive body : Y increases as the point moves up within the screen.
     */
    CGPoint bottomLeftCorner_;
    /** @brief The size the AABB of this interactive body : Unit : pixels
     */
    CGSize nodeSize_;
    /** @brief The scale. This is for future usage. Currently it is 1.0 
     */
    CGFloat scale_;
    /** @brief Indicates if the touch is being handled. Need this to prohibit multiple execution of touch handler.
     */
    BOOL isTouchHandling_;
    
    /** @brief Is this interactive sprite is locked, lockSprite is not nil, and shown on the screen.
     */
    CCSprite *lockSprite_;
    
    /** @brief The progress timer to show while the IAP is in progress
     */
    ProgressCircle * progressCircle_;
}

@property(assign, nonatomic, readonly) NSDictionary * touchActionDescs;


-(id)initWithFile:(NSString*)fileName;

+(id)spriteWithTouchAction:(NSString*)objectTouchAction 
               startAction:(NSString*)objectStartAction 
                 endAction:(NSString*)objectEndAction 
           backgroundImage:(NSString*)backgroundImage;


-(void)addChildAtCenter:(CCNode*)node z:(int)z;

-(void)setTouchAction:(body_touch_action_t)actionType actionDescs:(NSDictionary*)actionDescs;

-(void)setStartAction:(body_start_end_action_t)actionType actionDescs:(NSDictionary*)actionDescs;

-(void)setEndAction:(body_start_end_action_t)actionType actionDescs:(NSDictionary*)actionDescs;


-(void) setLocked:(BOOL)locked;
-(void) setLocked:(BOOL)locked spriteFrameName:(NSString*)spriteFrameName;
-(BOOL) isLocked;
-(void) runEndAction;

/** @brief Convert the touch action type in SVG file into body_touch_action_t enumeration 
 */
+(body_touch_action_t)getTouchAction:(NSString*)actionName;

@end
