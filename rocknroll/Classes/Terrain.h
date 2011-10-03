#import "cocos2d.h"
#import "Box2D.h"

#define kMaxBorderVertices 5000

// How many vertical segments for each point on the border for filling the terrain?
#define kTerrainVerticalSegments 1

#define kMaxHillVertices kMaxBorderVertices * (kTerrainVerticalSegments+1) * 2

#define kHillSegmentWidth 15

@interface Terrain : CCNode {
    // Arguments passed on the initializer 
    NSArray * borderPoints;
    int canvasHeight;
    float xOffset;
    float yOffset;
    
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
}
@property (nonatomic, retain) CCSprite *stripes;


// When rendering terrains, render up-side of the border line, not the down-side of the border line.
@property (nonatomic, assign) BOOL renderUpside;

// The thickness of the terrain to draw (in pixcels) below the border drawn in svg files.
@property (nonatomic, assign) float thickness;

+ (id) terrainWithWorld:(b2World*)w borderPoints:(NSArray*)borderPoints canvasHeight:(int)canvasHeight xOffset:(float)xOffset yOffset:(float)yOffset;
- (id) initWithWorld:(b2World*)w borderPoints:(NSArray*)borderPoints canvasHeight:(int)canvasHeight xOffset:(float)xOffset yOffset:(float)yOffset;

- (void) setHeroX:(float)offsetX withCameraY:(float)cameraOffsetY;

- (float) calcBorderMinY;

- (void) reset;

- (void) prepareRendering;

@end
