#import "cocos2d.h"

@interface Sky : CCNode {
	CCSprite *_sprite;
	float _offsetX;
	float _scale;
	CGSize textureSize;
	int screenW;
	int screenH;
}
@property (nonatomic, retain) CCSprite *sprite;
@property (nonatomic) float offsetX;
@property (nonatomic) float scale;

+ (id) skyWithTexture:(NSString*)fileName size:(CGSize)ts;
- (id) initWithTexture:(NSString*)fileName size:(CGSize)ts;

@end
