
//
//  GeneralScene.m
//  rocknroll
//
//  Created by 강모 김 on 11. 7. 22..
//  Copyright 2011 강모소프트. All rights reserved.
//

#import "GeneralScene.h"
#import "svgLoader.h"
#import "Util.h"
#import "RetainCountTrace.h"
#import "b2WorldEx.h"

@implementation GeneralScene

// initialize your instance here
-(id) initWithSceneName:(NSString*)sceneName
{
	if( (self=[super init])) 
	{
        NSString * svgFileName = [sceneName stringByAppendingString:@".svg"];
        NSString * backgroundFileName = [sceneName stringByAppendingString:@".png"];
    
        // ask director the the window size
        CGSize size = [[CCDirector sharedDirector] winSize];
        
        // Set background
        {
            
            CCSprite * bg = [CCSprite spriteWithFile:backgroundFileName];
            
            // position the label on the center of the screen
            bg.position =  ccp( size.width /2 , size.height/2 );
            
            [self addChild:bg z:0];
 
        }
        
        // Parse svg file
        {
            // Define the gravity vector.
            b2Vec2 gravity;
            gravity.Set(0.0f, -100.0f);
            
            // Do we want to let bodies sleep?
            bool doSleep = true;
            // Construct a world object, which will hold and simulate the rigid bodies.
            world_ = new b2WorldEx(gravity, doSleep);

            // Define the ground body.
            b2BodyDef groundBodyDef;
            groundBodyDef.position.Set(0, 0); // bottom-left corner
            // load geometry from file
            b2Body* groundBody = world_->CreateBody(&groundBodyDef);
            
            NSString *filePath = [Util getResourcePath:svgFileName];
            
            svgLoader * loader = [[svgLoader alloc] initWithWorld:world_ andStaticBody:groundBody andLayer:self];

            [loader parseFile:filePath];
            
            [loader release];
        }
    
    }
    
    return self;
}

+(id)nodeWithSceneName:(NSString*)sceneName
{
    return [[[GeneralScene alloc] initWithSceneName:sceneName] autorelease];
}

+(CCScene*)sceneWithName:(NSString*)sceneName
{
    // 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	GeneralScene *layer = [GeneralScene nodeWithSceneName:sceneName];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
    CCLOG(@"GeneralScene:dealloc");

	// in case you have something to dealloc, do it in this method
    // remove all body nodes attached to b2Body in the b2World.
    Helper::removeAttachedBodyNodes(world_);
    
	delete world_;
	world_ = NULL;
    
	// don't forget to call "super dealloc"
	[super dealloc];
}

//SYNTESIZE_TRACE(GeneralScene)

@end
