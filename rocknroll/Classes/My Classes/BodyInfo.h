#pragma once
@interface BodyInfo : NSObject 
{
	CGSize rect;
	id data;
	NSString * name;
	NSString * textureName;
	NSString * spriteName;
	CGPoint spriteOffset;
    // The plist file name that contains the default animation clip.
    NSString * initClipFile;
    // The first frame of animation for creating the CCSprite of this body
    NSString * initFrameAnim;
    // The default animation clip action (created by loading initClipFile)
    CCAction * defaultAction;
}
@property(nonatomic,retain) id data;
@property(nonatomic,retain) NSString * name;
@property(nonatomic,retain) NSString * textureName;
@property(nonatomic,retain) NSString * spriteName;
@property(nonatomic,retain) NSString * initClipFile;
@property(nonatomic,retain) NSString * initFrameAnim;
@property(nonatomic,retain) CCAction * defaultAction;
@property CGSize rect;
@property CGPoint spriteOffset;
@end

