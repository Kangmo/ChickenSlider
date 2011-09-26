#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Box2D.h"
#import "JointDeclaration.h"
#import "TouchXML.h"
#import "GrahamScanConvexHull.h"
#include <vector>

@class ClassDictionary;

@interface svgLoader : NSObject 
{
	b2World* world;
	b2Body* staticBody;
    CCLayer * layer;
//	CCSpriteBatchNode * spriteSheet;
    
    float svgCanvasHeight; // svg canvas height
	float worldWidth; // svg canvas width / PTM_RATIO
	float worldHeight;// svg canvas height / PTM_RATIO

	float scaleFactor; // used for debug rendering and physycs creation from svg only
    ClassDictionary * classDict;
    
    NSMutableArray * terrains; // indicates if we need to load terrain. For menu screens we don't need to load terrain.
}
//@property float scaleFactor; 
@property (nonatomic, retain) ClassDictionary * classDict;
           
-(id) initWithWorld:(b2World*) w andStaticBody:(b2Body*) sb andLayer:(CCLayer*)l terrains:(NSMutableArray*)t;

-(void) instantiateObjectsIn:(NSString*)filename;
-(void) instantiateObjects:(CXMLElement*)svgLayer namePrefix:(NSString*)objectNamePrefix xOffset:(float)xOffset yOffset:(float)yOffset;
-(b2Body*) getBodyByName:(NSString*) bodyName;
//-(void) assignSpritesFromManager:(SpriteManager*)manager;
-(void) assignSpritesFromSheet:(CCSpriteBatchNode*)spriteSheet;

-(void) doCleanupShapes;

@end
