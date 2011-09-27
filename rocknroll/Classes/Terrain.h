#import "cocos2d.h"
#import "Box2D.h"

#define kMaxBorderVertices 5000

// How many vertical segments for each point on the border for filling the terrain?
#define kTerrainVerticalSegments 1

#define kMaxHillVertices kMaxBorderVertices * (kTerrainVerticalSegments+1) * 2

#define kHillSegmentWidth 15

@interface Terrain : CCNode {
    // The the range of border indexes to borderVertices array to draw on screen. Both start/end indexes are inclusive.
	int startBorderIndex;
	int endBorderIndex;
	CGPoint hillVertices[kMaxHillVertices];
	CGPoint hillTexCoords[kMaxHillVertices];
	int nHillVertices;
	CGPoint borderVertices[kMaxBorderVertices];
	int nBorderVertices;
	CCSprite *_stripes;
	float _offsetX;
	b2World *world;
	b2Body *body;
	int screenW;
	int screenH;
	int textureSize;
    
    // When rendering terrains, render up-side of the border line, not the down-side of the border line.
    BOOL renderUpside;
}
@property (nonatomic, retain) CCSprite *stripes;

+ (id) terrainWithWorld:(b2World*)w borderPoints:(NSArray*)borderPoints canvasHeight:(int)canvasHeight xOffset:(float)xOffset yOffset:(float)yOffset renderUpside:(BOOL)renderUpside ;
- (id) initWithWorld:(b2World*)w borderPoints:(NSArray*)borderPoints canvasHeight:(int)canvasHeight xOffset:(float)xOffset yOffset:(float)yOffset renderUpside:(BOOL)renderUpside ;

- (void) setHeroX:(float)offsetX withCameraY:(float)cameraOffsetY;

- (float) calcBorderMinY;

- (void) reset;

@end
