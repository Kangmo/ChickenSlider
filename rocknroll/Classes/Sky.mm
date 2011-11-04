#import "Sky.h"
#import "GameConfig.h"

@interface Sky()
- (CCSprite*) generateSprite;
- (CCTexture2D*) generateTexture;
@end

@implementation Sky

@synthesize sprite = _sprite;
@synthesize offsetX = _offsetX;
@synthesize scale = _scale;

+ (id) skyWithTextureSize:(CGSize)ts {
	return [[[self alloc] initWithTextureSize:ts] autorelease];
}

- (id) initWithTextureSize:(CGSize)ts {
	
	if ((self = [super init])) {
		
		textureSize = ts;

		CGSize screenSize = [[CCDirector sharedDirector] winSize];
		screenW = screenSize.width;
		screenH = screenSize.height;
		
		self.sprite = [self generateSprite];
		[self addChild:_sprite];
	}
	return self;
}

- (void) dealloc {
	self.sprite = nil;
	[super dealloc];
}

- (CCSprite*) generateSprite {
	CCSprite *s = [CCSprite spriteWithFile:@"sky2.png"];
	//[s setBlendFunc:(ccBlendFunc){GL_DST_COLOR, GL_ZERO}];
    s.anchorPoint = ccp(HERO_XPOS_RATIO, 0);
	s.position = ccp(screenW * HERO_XPOS_RATIO, 0);
	s.scale = 1;
    return s;
	/*
	CCTexture2D *texture = [self generateTexture];
    // By kmkim : Don't iterate the texture.
	//float w = (float)screenW/(float)screenH*textureSize.height;
	float w = textureSize.width;
    float h = textureSize.height;
    
	CGRect rect = CGRectMake(0, 0, w, h);
	
	CCSprite *sprite = [CCSprite spriteWithTexture:texture rect:rect];
    
    
//	ccTexParams tp = {GL_LINEAR, GL_LINEAR, GL_REPEAT, GL_REPEAT};
	ccTexParams tp = {GL_NEAREST, GL_NEAREST, GL_REPEAT, GL_REPEAT};
	[sprite.texture setTexParameters:&tp];
 
	sprite.anchorPoint = ccp(1.0f/8.0f, 0);
	sprite.position = ccp(screenW/8, 0);

	return sprite;
     */
}

- (CCTexture2D*) generateTexture {

	CCRenderTexture *rt = [CCRenderTexture renderTextureWithWidth:textureSize.width height:textureSize.height];
	
	ccColor3B c = (ccColor3B){140, 205, 221};
	ccColor4F cf = ccc4FFromccc3B(c);
	
	[rt beginWithClear:cf.r g:cf.g b:cf.b a:cf.a];

	// layer 1: gradient
/*
	float gradientAlpha = 0.3f;
	
	glDisable(GL_TEXTURE_2D);
	glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	
	CGPoint vertices[4];
	ccColor4F colors[4];
	int nVertices = 0;
	
	vertices[nVertices] = ccp(0, 0);
	colors[nVertices++] = (ccColor4F){1, 1, 1, 0};
	vertices[nVertices] = ccp(textureSize, 0);
	colors[nVertices++] = (ccColor4F){1, 1, 1, 0};
	
	vertices[nVertices] = ccp(0, textureSize);
	colors[nVertices++] = (ccColor4F){1, 1, 1, gradientAlpha};
	vertices[nVertices] = ccp(textureSize, textureSize);
	colors[nVertices++] = (ccColor4F){1, 1, 1, gradientAlpha};
	
	glVertexPointer(2, GL_FLOAT, 0, vertices);
	glColorPointer(4, GL_FLOAT, 0, colors);
	glBlendFunc(GL_SRC_ALPHA, GL_ONE);
	glDrawArrays(GL_TRIANGLE_STRIP, 0, (GLsizei)nVertices);
	
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	glEnable(GL_TEXTURE_2D);
*/
    
	// layer 2: noise
	CCSprite *s = [CCSprite spriteWithFile:@"sky2.png"];
	[s setBlendFunc:(ccBlendFunc){GL_DST_COLOR, GL_ZERO}];
	s.position = ccp(textureSize.width/2, textureSize.height/2);
	s.scale = 1;
	//s.scale = (float)textureSize/512.0f;
	glColor4f(1,1,1,1);
	[s visit];
	
	[rt end];
	
	return rt.sprite.texture;
}

- (void) setOffsetX:(float)offsetX {
	if (_offsetX != offsetX) {
        if (offsetX < 0)
            offsetX = 0;
		_offsetX = offsetX;
		CGSize size = _sprite.textureRect.size;
		_sprite.textureRect = CGRectMake(_offsetX, 0, size.width, size.height);
	}
}

- (void) setScale:(float)scale {
	if (_scale != scale) {
		const float minScale = (float)screenH / (float)textureSize.height;
		if (scale < minScale) {
			_scale = minScale;
		} else {
			_scale = scale;
		}
		_sprite.scale = _scale;
	}
}

@end
