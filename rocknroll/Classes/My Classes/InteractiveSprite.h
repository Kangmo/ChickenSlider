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
    BTA_ADD_LAYER = 3, // Give up the current stage, go to the level map scene.
    BTA_NONE = 4
} body_touch_action_t;

typedef enum body_hover_action_t
{
    BHA_NULL = 0,
    BHA_SHOW_IMAGE = 1,
    BHA_SHOW_PARTICLE = 2
} body_hover_action_t;

@interface InteractiveSprite : CCSprite<CCTargetedTouchDelegate, IAPDelegate> {
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
    /** @brief Indicates if the touch is being handled. Need this to prohibit multiple execution of touch handler.
     */
    BOOL isTouchHandling_;
    
    /** @brief Is this interactive sprite is locked, lockSprite is not nil, and shown on the screen.
     */
    CCSprite *lockSprite_;
    
    /** @brief The particle emitter that shows particles while hovering.
     */
    CCParticleSystemQuad * particleEmitter_;
    
    /** @brief The sound effect played when the interactive sprite is touched 
     */
    CDSoundSource * soundEffect_;
    
    /** @brief The progress timer to show while the IAP is in progress
     */
    ProgressCircle * progressCircle_;

    /** @brief Is tick scheduled?
     */
    //BOOL tickScheduled_;
    
    /** @brief the delta time accumulated in tick method. This is required to check if the feature is purchased every 1/8 second
     */
    //ccTime tickAccDT_;
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

-(void) setLocked:(BOOL)locked;
-(BOOL) isLocked;

@end
