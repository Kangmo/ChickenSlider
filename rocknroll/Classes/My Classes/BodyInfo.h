#pragma once
@interface BodyInfo : NSObject 
{
	CGSize rect;
	id data;
	NSString * name;
	NSString * textureName;
	NSString * spriteName;
	CGPoint spriteOffset;
}
@property(nonatomic,retain) id data;
@property(nonatomic,retain) NSString * name;
@property(nonatomic,retain) NSString * textureName;
@property(nonatomic,retain) NSString * spriteName;
@property CGSize rect;
@property CGPoint spriteOffset;
@end

