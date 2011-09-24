//
//  svgLoader.h
//  svgParser
//
//  Created by Skeeet on 10/20/09.
//  Copyright 2009 Munky Interactive / munkyinteractive.com. All rights reserved.
//
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
    
	float worldWidth;
	float worldHeight;
	float scaleFactor; // used for debug rendering and physycs creation from svg only
    ClassDictionary * classDict;
}
//@property float scaleFactor; 
@property (nonatomic, retain) ClassDictionary * classDict;
           
//-(id) initWithWorld:(b2World*) w andStaticBody:(b2Body*)sb andLayer:(CCLayer*)l andSpriteSheet:(CCSpriteBatchNode*)ss;
-(id) initWithWorld:(b2World*) w andStaticBody:(b2Body*)sb andLayer:(CCLayer*)l;

-(void) instantiateObjectsIn:(NSString*)filename;
-(void) instantiateObjects:(CXMLElement*)svgLayer namePrefix:(NSString*)objectNamePrefix xOffset:(float)xOffset yOffset:(float)yOffset;
-(b2Body*) getBodyByName:(NSString*) bodyName;
//-(void) assignSpritesFromManager:(SpriteManager*)manager;
-(void) assignSpritesFromSheet:(CCSpriteBatchNode*)spriteSheet;

-(void) doCleanupShapes;

@end
