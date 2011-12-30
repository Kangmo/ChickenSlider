#import "cocos2d.h"
#import "Box2D.h"
#include "CppInfra.h"
#include "StringParser.h"

// How many vertical segments for each point on the border for filling the terrain?
#define kTerrainVerticalSegments 1

#define HILL_VERTICES(BORDER_VERTICES) ((BORDER_VERTICES) * ((kTerrainVerticalSegments)+1) * 2)

#define kHillSegmentWidth 15

@interface Terrain : CCNode {
    // Objective-C++ can't deallocate C++ instances such as shared_ptr. So we define it as a pointer.
    REF(PointVector) * borderPoints;

    // Arguments passed on the initializer 
    int canvasHeight;
    float xOffset;
    float yOffset;
    
    // The the range of border indexes to borderVertices array to draw on screen. Both start/end indexes are inclusive.
	int startBorderIndex;
	int endBorderIndex;
    int rightBeforeHeroIndex;
	CGPoint * hillVertices;
	CGPoint * hillTexCoords;
	int nHillVertices;      // The count of CGPoint we use
    int nMaxHillVertices;   // The count of CGPoint allocated
	CGPoint * borderVertices;
	int nBorderVertices;    // The count of CGPoint we use
    int nMaxBorderVertices; // The count of CGPoint allocated
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

// The maximum X position of the terrain.
@property (nonatomic, readonly, assign) float maxX;

+ (id) terrainWithWorld:(b2World*)w borderPoints:(REF(PointVector)) borderPoints canvasHeight:(int)canvasHeight xOffset:(float)xOffset yOffset:(float)yOffset;

- (id) initWithWorld:(b2World*)w borderPoints:(REF(PointVector))bp canvasHeight:(int)ch xOffset:(float)xo yOffset:(float)yo;

// Set the heroX, position of the terrain, the area of window that can be drawn on screen.
- (void) setHeroX:(float)offsetX position:(CGPoint)position windowLeftX:(int)windowLeftX windowRightX:(int)windowRightX;

- (float) borderMinX;
- (float) borderMaxX;

- (float) calcBorderMinY;

- (BOOL) isBelowHero:(float)heroY_withoutZoom;

- (void) reset;

- (void) prepareRendering:(CCSprite*)groundSprite;

+ (CCSprite*) groundSprite:(NSString*) textureFile;

- (BOOL) isDownHill:(int)lookAheadIndex ;

- (BOOL) terrainYatHero:(float*)y ;

@end
