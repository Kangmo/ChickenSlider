#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface AKHelpers : NSObject {

}

+ (CCSpriteFrame*)frameFromFile:(NSString*)file;
+ (NSArray*)imageFramesFromArray:(NSArray*)array;
+ (NSArray*)imageFramesFromPattern:(NSDictionary*)patternDict;
+ (NSArray*)imageFramesFromPlist:(NSString*)plistFile;
+ (NSDictionary*)animationSetFromDictionary:(NSDictionary*)animSetDict;
+ (NSDictionary*)animationSetFromPlist:(NSString*)plistFile;
+ (void)applyAnimation:(NSDictionary*)anim toNode:(CCNode*)node;
+ (void)applyAnimationWithName:(NSString*)animName fromSet:(NSDictionary*)animSet toNode:(CCNode*)node;
+ (CCAction*)actionForAnimation:(NSDictionary*)anim;
+ (CCAction*)actionForAnimationWithName:(NSString*)animName fromSet:(NSDictionary*)animSet;
+ (CCSpriteFrame*)initialFrameForAnimation:(NSDictionary*)anim;
+ (CCSpriteFrame*)initialFrameForAnimationWithName:(NSString*)animName fromSet:(NSDictionary*)animSet;
+ (CCSpriteFrame*)finalFrameForAnimation:(NSDictionary*)anim;
+ (CCSpriteFrame*)finalFrameForAnimationWithName:(NSString*)animName fromSet:(NSDictionary*)animSet;
+ (NSTimeInterval)durationOfAnimation:(NSDictionary*)anim;
+ (NSTimeInterval)durationOfAnimationWithName:(NSString*)animName fromSet:(NSDictionary*)animSet;

+ (NSDictionary*)clipItemWithDictionary:(NSDictionary*)clipItemDict;
+ (NSDictionary*)animationClipFromPlist:(NSString*)plistFile;
+ (CCAction*)actionForAnimationClipItem:(NSDictionary*)clipItemDict withAnimationSet:(NSDictionary*)animSet;
+ (CCAction*)actionForAnimationClip:(NSDictionary*)clip;
+ (void)applyAnimationClip:(NSDictionary*)clip toNode:(CCNode*)node;

+ (NSDictionary*)animationSetOfClip:(NSDictionary*)animClip;

+ (void)setTagDelegate:(id)tagDelegate;

@end
