//
// Demo of calling integrating Box2D physics engine with cocos2d AtlasSprites
// a cocos2d example
// http://code.google.com/p/cocos2d-iphone
//
// by Steve Oldmeadow
//

// Import the interfaces
#import "StageScene.h"
#import "TouchXML.h"
#import "JointDeclaration.h"

#import "SpriteManager.h"
#import "BodyInfo.h"
#include "GameConfig.h"
#include "Util.h"
#include "GeneralScene.h"

#include "InputLayer.h"

//Pixel to metres ratio. Box2D uses metres as the unit for measurement.
//This ratio defines how many pixels correspond to 1 Box2D "metre"
//Box2D is optimized for objects of 1x1 metre therefore it makes sense
//to define the ratio so that your most common object type is 1x1 metre.
//#define PTM_RATIO 32

//#define WORLD_HEIGHT 1000
// enums that will be used as tags
enum {
	kTagTileMap = 1,
   	kTagBatchNode = 1,
	kTagAnimation1 = 1,
};



// HelloWorld implementation
@implementation StageScene

@synthesize car;

static StageScene* instanceOfStageScene;
+(StageScene*) sharedStageScene
{
	NSAssert(instanceOfStageScene != nil, @"StageScene instance not yet initialized!");
	return instanceOfStageScene;
}


-(svgLoader*) initGeometry:(NSString *)svgFileName
{
	// Define the ground body.
	b2BodyDef groundBodyDef;
	groundBodyDef.position.Set(0, 0); // bottom-left corner
	// load geometry from file
	b2Body* groundBody = world->CreateBody(&groundBodyDef);
    
    NSString *filePath = [Util getResourcePath:svgFileName];
    
	svgLoader * loader = [[[svgLoader alloc] initWithWorld:world andStaticBody:groundBody andLayer:self] autorelease];
	[loader parseFile:filePath];
	return loader;
}


// initialize your instance here
-(id) initWithLevel:(NSString*)levelStr
{
	if( (self=[super init])) 
	{
		// enable touches
		self.isTouchEnabled = YES;
		
		// enable accelerometer
		self.isAccelerometerEnabled = YES;

		// The SVG file for the given level.
        NSString * svgFileName = [NSString stringWithFormat:@"StageScene_%@.svg", levelStr];

		// Define the gravity vector.
		b2Vec2 gravity;
		gravity.Set(0.0f, -100.0f);
		
		// Do we want to let bodies sleep?
		bool doSleep = true;
		// Construct a world object, which will hold and simulate the rigid bodies.
		world = new b2World(gravity, doSleep);
		world->SetContinuousPhysics(true);
		
		FollowCamera * followCam = [[FollowCamera alloc] init];
        cam = followCam;
		
		// Debug Draw functions
		m_debugDraw = new GLESDebugDraw( followCam.ptmRatio ); //PTM RATIO

		world->SetDebugDraw(m_debugDraw);
		uint32 flags = 0;
		flags += b2DebugDraw::e_shapeBit;
		flags += b2DebugDraw::e_jointBit;
		//flags += b2DebugDraw::e_aabbBit;
		flags += b2DebugDraw::e_pairBit;
		flags += b2DebugDraw::e_centerOfMassBit;
		m_debugDraw->SetFlags(flags);		
		
		
		
		//init stuff from svg file
		svgLoader* loader = [self initGeometry:svgFileName];
		spriteManager = [[SpriteManager alloc] initWithNode:self z:10];
		[spriteManager parsePlistFile:@"levin.plist"];
		
		[loader assignSpritesFromManager:spriteManager];
		
		car = new Car( [loader getBodyByName:@"bober"] );
        
		[followCam follow:car->getBody()];
		
		[cam ZoomToObject:car->getBody() screenPart:0.15];
		
		
		CCMenuItemFont * mi = [CCMenuItemFont itemFromString:@"Menu" target:self selector:@selector(onReset:)];
		
		CCMenu * m = [CCMenu menuWithItems:mi,nil];
		[self addChild:m z:500];
		m.position = CGPointMake(430, 320 - 30);
		
		arrow = [CCSprite spriteWithFile:@"arrow.png"];
		arrow.anchorPoint = CGPointMake(0, 2.5);
		arrow.scaleX = 3;
		[self addChild:arrow z:100 tag:0x777888];
		
		st =0;
		
        instanceOfStageScene = self;
        
		[self schedule: @selector(tick:)];
		
	}
	return self;
}


+(id)nodeWithLevel:(NSString*)levelStr
{
    return [[[StageScene alloc] initWithLevel:levelStr] autorelease];
}


+(CCScene*) sceneWithLevel:(NSString*)levelStr
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	StageScene *layer = [StageScene nodeWithLevel:levelStr];
	
	// add layer as a child to scene
	[scene addChild:layer z:0 tag:StageSceneLayerTagStage];

    // add the input layer that has a joystick and buttons
    InputLayer * inputLayer = [InputLayer node];
	[scene addChild:inputLayer z:1 tag:StageSceneLayerTagInput];
    
	// return the scene
	return scene;
}


-(void) onReset:(id) sender
{
    [[CCDirector sharedDirector] replaceScene:[GeneralScene sceneWithName:@"MainMenuScene"]];
}

/*
-(void) draw
{	
	[super draw];
	glEnableClientState(GL_VERTEX_ARRAY);
	//world->DrawDebugData();
	b2Vec2 tmp = [cam b2vPosition];
	m_debugDraw->mRatio = cam.ptmRatio;

	//world->DrawDebugData(&tmp);
	world->DrawDebugData();
	glDisableClientState(GL_VERTEX_ARRAY);
	
}
*/

-(void) draw
{
	// Default GL states: GL_TEXTURE_2D, GL_VERTEX_ARRAY, GL_COLOR_ARRAY, GL_TEXTURE_COORD_ARRAY
	// Needed states:  GL_VERTEX_ARRAY, 
	// Unneeded states: GL_TEXTURE_2D, GL_COLOR_ARRAY, GL_TEXTURE_COORD_ARRAY
	glDisable(GL_TEXTURE_2D);
	glDisableClientState(GL_COLOR_ARRAY);
	glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	
	b2Vec2 tmp = [cam b2vPosition];
	m_debugDraw->mRatio = cam.ptmRatio;
	world->DrawDebugData(&tmp);
	//world->DrawDebugData();
	
	// restore default GL states
	glEnable(GL_TEXTURE_2D);
	glEnableClientState(GL_COLOR_ARRAY);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
    
}

-(void) tick: (ccTime) dt
{
//	st+=0.01;
//	float s = sin(st)*2.0f;
//	if(s<0) s*=-1.0f;
//	[cam ZoomTo: s +0.2f];

	[cam updateFollowPosition];
	int32 velocityIterations = 8;
    int32 positionIterations = 10;
    //	int32 positionIterations = 10;
	
	// Instruct the world to perform a single step of simulation. It is
	// generally best to keep the time step and iterations fixed.
	//world->Step(dt, velocityIterations, positionIterations);
	world->Step(1.0f/30.0f, velocityIterations, positionIterations);
	
	//Iterate over the bodies in the physics world
	for (b2Body* b = world->GetBodyList(); b; b = b->GetNext())
	{
		[cam updateSpriteFromBody:b];
	}
	
}
- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
// by kmkim    
	[cam eventBegan:touches];
    
//	//Add a new body/atlas sprite at the touched location
//	for( UITouch *touch in touches ) {
//		CGPoint location = [touch locationInView: [touch view]];
//		location = [[Director sharedDirector] convertToGL: location];
//		if([touches count]==1) [myCamera eventBegan:location];
//	}
//	isThrottleEnabled = YES;
//	
//	
}
- (void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
// by kmkim    
    [cam eventMoved:touches];
	
//	for( UITouch *touch in touches ) 
//	{
//		CGPoint location = [touch locationInView: [touch view]];
//		location = [[Director sharedDirector] convertToGL: location];
//		if([touches count]==1)[myCamera eventMoved:location];
//	}
}
- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
// by kmkim    
	[cam eventEnded:touches];
    
//	//Add a new body/atlas sprite at the touched location
//	for( UITouch *touch in touches ) 
//	{
//		CGPoint location = [touch locationInView: [touch view]];
//		location = [[Director sharedDirector] convertToGL: location];
//		
////		if([touches count]==1) [myCamera eventEnded:location];
////		else  //[self addNewSpriteWithCoords: location];
////		{
////			myCamera.zoomFactor*=0.5f;
////		}
//		
//	}
////	
////	b2Vec2 vel = carBox->GetLinearVelocity();
////	vel.Normalize();
////	vel*=100.0f;
////	carBox->ApplyImpulse(vel, b2Vec2_zero);
//	isThrottleEnabled = NO;
}

// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
    CCLOG(@"StageScene:dealloc");

	// in case you have something to dealloc, do it in this method
    [self unschedule: @selector(tick:)];

    delete car;
    
    // remove all body nodes attached to b2Body in the b2World.
    Helper::removeAttachedBodyNodes(world);
	delete world;
	world = NULL;
    
	//[spriteManager detachWithCleanup:YES];
    [spriteManager release];
    [cam release];
    
	delete m_debugDraw;

	// Reset the StageScene singleton.
    instanceOfStageScene = nil;
    
	// don't forget to call "super dealloc"
	[super dealloc];
}
@end
