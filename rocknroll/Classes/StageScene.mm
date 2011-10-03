// Import the interfaces
#import "StageScene.h"
#import "TouchXML.h"
#import "JointDeclaration.h"

#import "BodyInfo.h"
#include "GameConfig.h"
#include "Util.h"
#include "GeneralScene.h"

#include "InputLayer.h"
#include "b2WorldEx.h"

#import "Terrain.h"
#import "AKHelpers.h"

#import "Sky.h"

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
@synthesize hero;

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
    
    terrains = [[NSMutableArray array] retain];
    
    NSString *filePath = [Util getResourcePath:svgFileName];
    
	svgLoader * loader = [[[svgLoader alloc] initWithWorld:world andStaticBody:groundBody andLayer:self terrains:terrains gameObjects:&gameObjectContainer scoreBoard:self] autorelease];
    
    // Set the class dictionary to the loader, so that it can initiate objects of classes defined in "classes.svg" file. 
    // In that file, a class is defined within a layer.
    ClassDictionary * classDict = [[ClassDictionary alloc] init];
    NSString *classFilePath = [Util getResourcePath:@"game_classes.svg"];
    [classDict loadClassesFrom:classFilePath];
    loader.classDict = classDict;
    [classDict release];
    
	[loader instantiateObjectsIn:filePath];
	return loader;
}

-(void) addTerrains {
    for (Terrain * t in terrains) {
        [self addChild:t];
    }
}

-(void) increaseScore:(int) scoreDiff
{
    int newScore = scoreLabel.getTargetCount() + scoreDiff;
    scoreLabel.setTargetCount(newScore);
}

-(void) increaseWaterDrops:(int) waterDropsDiff
{
    int newDrops = waterDropsLabel.getTargetCount() + waterDropsDiff;
    waterDropsLabel.setTargetCount(newDrops);
}

- (void) showMessage:(NSString*) message {
    [Util showMessage:message inLayer:(CCLayer*)self];
}


-(void) initScoreLabels {
    static CGSize screenSize = [[CCDirector sharedDirector] winSize];
    static float SCORE_VERT_CENTER_Y = screenSize.height - screenSize.height/8;
    static float HORIZONTAL_MARGIN = screenSize.width/32;
    // The margin between the water drop sprite and the counter.
    static float WATER_DROP_MARGIN = HORIZONTAL_MARGIN/2;
    // Water Drop sprite and count
    {
        CCSprite * waterDropSprite = [CCSprite spriteWithSpriteFrameName:@"WaterDrop00.png"]; 
        assert(waterDropSprite);
        
        [spriteSheet addChild:waterDropSprite];
        waterDropSprite.anchorPoint = ccp(0, waterDropSprite.anchorPoint.y);
        // Y : +5 is required to move the sprite to the top of the screen by 5 pixcels because the water drop sprite have margin space on top of it.
        waterDropSprite.position = ccp(HORIZONTAL_MARGIN, SCORE_VERT_CENTER_Y+5);

        
        CCLabelBMFont *label = waterDropsLabel.getLabel();
        
        label.anchorPoint = ccp(0, label.anchorPoint.y);
        
        label.position = ccp(waterDropSprite.position.x + waterDropSprite.contentSize.width + WATER_DROP_MARGIN, 
                             SCORE_VERT_CENTER_Y);

        [self addChild:label];
    }

    
    // Score
    {
        CCLabelBMFont *label = scoreLabel.getLabel();
        
        label.anchorPoint = ccp(label.anchorPoint.x*2, label.anchorPoint.y);
        
        label.position = ccp(screenSize.width - HORIZONTAL_MARGIN, SCORE_VERT_CENTER_Y);
        
        [self addChild:label];
    }
    
}


// initialize your instance here
-(id) initWithLevel:(NSString*)levelStr
{
	if( (self=[super init])) 
	{
        // initialize variables
        terrains = nil;
        
		// enable touches
		self.isTouchEnabled = YES;
		
		// enable accelerometer
		self.isAccelerometerEnabled = YES;

        sky = [[Sky skyWithTextureSize:512] retain];
		[self addChild:sky];
        
        // Load the sprite frames.
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"sprites.plist" textureFile:@"sprites.png"];
        
        spriteSheet = [CCSpriteBatchNode batchNodeWithFile:@"sprites.png"];
        [self addChild:spriteSheet];

		// The SVG file for the given level.
        NSString * svgFileName = [NSString stringWithFormat:@"StageScene_%@.svg", levelStr];

		// Define the gravity vector.
		b2Vec2 gravity;
		gravity.Set(0.0f, -9.8);
		
		// Construct a world object, which will hold and simulate the rigid bodies.
		world = new b2WorldEx(gravity);
		world->SetContinuousPhysics(true);
		
		FollowCamera * followCam = [[FollowCamera alloc] init];
        cam = followCam;
		
		// Debug Draw functions
		m_debugDraw = new GLESDebugDraw( followCam.ptmRatio ); //PTM RATIO

		world->SetDebugDraw(m_debugDraw);
		uint32 flags = 0;
        
		flags += b2Draw::e_shapeBit;
		flags += b2Draw::e_jointBit;
		//flags += b2DebugDraw::e_aabbBit;
		//flags += b2Draw::e_pairBit;
		flags += b2Draw::e_centerOfMassBit;
        // ver 2.1.2
/*        
		flags += b2DebugDraw::e_shapeBit;
		flags += b2DebugDraw::e_jointBit;
		//flags += b2DebugDraw::e_aabbBit;
		flags += b2DebugDraw::e_pairBit;
		flags += b2DebugDraw::e_centerOfMassBit;
*/ 
		m_debugDraw->SetFlags(flags);		
		
		//init stuff from svg file
		svgLoader* loader = [self initGeometry:svgFileName];
        [loader assignSpritesFromSheet:spriteSheet];
       
        [self addTerrains];
        
        b2Body * playerBody = [loader getBodyByName:@"MyCar_CarMainBody"];
        if ( playerBody ) 
        {
            car = new Car( playerBody );
        }
        else
        {
            playerBody = [loader getBodyByName:@"MyBird_BirdMainBody"];
            
            assert(playerBody);
            playerBody->SetLinearDamping(0.05f);
            self.hero = [Hero heroWithWorld:world heroBody:playerBody camera:cam scoreBoard:self];
        }
        
		[followCam follow:playerBody];
		
		[cam ZoomToObject:playerBody screenPart:0.15];
		[cam ZoomTo:INIT_ZOOM_RATIO];
		
		CCMenuItemFont * mi = [CCMenuItemFont itemFromString:@"Menu" target:self selector:@selector(onReset:)];
		
		CCMenu * m = [CCMenu menuWithItems:mi,nil];
		[self addChild:m z:500];
		m.position = CGPointMake(430, 30);
		
		arrow = [CCSprite spriteWithFile:@"arrow.png"];
		arrow.anchorPoint = CGPointMake(0, 2.5);
		arrow.scaleX = 3;
		[self addChild:arrow z:100 tag:0x777888];
		
		st =0;
		
        instanceOfStageScene = self;
        
        // Initialize score labels. (Requires spriteSheet);
        [self initScoreLabels];
        
		[self schedule: @selector(tick:)];
        
        // playbackground music
        [[CDAudioManager sharedManager] playBackgroundMusic:@"summer_smile-stephen_burns.mp3" loop:YES];
        [CDAudioManager sharedManager].backgroundMusic.numberOfLoops = 100;//To loop 3 times
	}
	return self;
}


+(id)nodeWithLevel:(NSString*)levelStr
{
    return [[[StageScene alloc] initWithLevel:levelStr] autorelease];
}

/** @brief Does the game scene require joystick?
 */
-(BOOL) needJoystick
{
    if ( [self car] )
        return YES;
    return NO;
}

+(CCScene*) sceneWithLevel:(NSString*)levelStr
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	StageScene *layer = [StageScene nodeWithLevel:levelStr];
	
	// add layer as a child to scene
	[scene addChild:layer z:0 tag:StageSceneLayerTagStage];

    if ( [layer needJoystick] )
    {
        // add the input layer that has a joystick and buttons
        InputLayer * inputLayer = [InputLayer node];
        [scene addChild:inputLayer z:1 tag:StageSceneLayerTagInput];
    }
    
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
#if defined(BOX2D_DEBUG_DRAW)    
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
#endif
}


/** @brief Adjust the zoom level so that both the ground and the hero are shown in the screen regardless of how far the hero jumped!
 */
-(void) adjustZoomWithGroundY:(float)worldGroundY
{
    
    static float minHeightMeters = 0.0f;
    if (!minHeightMeters) 
    {
        CGSize screenSize = [[CCDirector sharedDirector] winSize];
        float maxHeroY = screenSize.height * HERO_MAX_YPOS_RATIO;
		minHeightMeters = maxHeroY / INIT_PTM_RATIO;
    }
    
    static float targetZoom = 0.0f;
    if ( targetZoom == 0.0f )
    {
        targetZoom = cam.zoom;
    }
    
    if (hero)
    {
        float32 worldHeightToShow = hero.body->GetPosition().y - worldGroundY;
        
        if (worldHeightToShow < minHeightMeters) {
            worldHeightToShow = minHeightMeters;
        }
        float targetZoom = minHeightMeters / worldHeightToShow;
        
        //CCLOG(@"worldHeightToShow:%f, ground:%f targetZoom:%f\n", worldHeightToShow, groundY, targetZoom);
        
        // Zoom gradually to the target zoom value when Zooming ratio suddenly changes.
        // This is necessary because the hero hits on the ground suddenly making a sudden change of zoom.
        float zoomDiff = targetZoom - cam.zoom;
        zoomDiff = zoomDiff < 0 ? -zoomDiff : zoomDiff;
        
        float newZoom = targetZoom;
        // IS this making the zoom to change too slowly? Go directly to the targetZoom
        if ( zoomDiff / cam.zoom > ZOOM_DELTA_RATIO ) // more than 10% change in zoom?
        {
            // At most, allow 10% change of zoom
            if ( targetZoom > cam.zoom)
                newZoom = cam.zoom + cam.zoom * ZOOM_DELTA_RATIO;
            else
                newZoom = cam.zoom - cam.zoom * ZOOM_DELTA_RATIO;
        }
        
        [cam ZoomTo:newZoom];
    }
}

/** @brief Activate, move, scale terrains/sky based on the current hero position.
 */
-(float) adjustTerrainsAndSky {
    float groundY = kMAX_POSITION;
    
    if (hero)
    {
        /////////////////////////////////////////////
        // Step1 : Adjust Terrains
        float heroX_withoutZoom = hero.body->GetPosition().x * INIT_PTM_RATIO;
        // When the camera is above the sea level(y=0), cam.cameraPosition contains negative offsets to subtract from sprites position.
        // Convert it back to the y offset from sea level.
        float cameraY = -cam.cameraPosition.y;
        
        for (Terrain * t in terrains) {

            t.scale = cam.zoom;
            //t.scale = cam.ptmRatio / INIT_PTM_RATIO;

            [t setHeroX:heroX_withoutZoom withCameraY:cameraY];
            
            float borderMinY = [t calcBorderMinY];
            if ( borderMinY != kMAX_POSITION ) // The terrain is not drawn on the current screen.
            {
                if ( groundY > borderMinY )
                    groundY = borderMinY;
            }
        }
        
        /////////////////////////////////////////////
        // Step 2 : Adjust Sky
        [sky setOffsetX:heroX_withoutZoom*0.2f];
        [sky setScale:1.0f-(1.0f-cam.zoom)*0.75f];
    }
    
    return groundY;
}
/** @brief See if the hero collides any objects in the GameObjectContainer. Box2D objects are not included here.
 */
-(void) checkCollisions4GameObjects {
    if ( hero )
    {
        ////////////////////////////////////////////////////////////////////////////////
        // Step 1 : Get the screen position of Hero without considering zoom. 
        // Objects in the gameObjectContainer are having positions at zoom ratio 1.0.
        ////////////////////////////////////////////////////////////////////////////////
        //get position in physycs coords
        CGPoint screenCoordPos = CGPointMake( hero.body->GetPosition().x , hero.body->GetPosition().y);

        //map it to scren coords using the initial PTM ratio (which means zoom ratio 1.0)
        screenCoordPos = ccpMult(screenCoordPos, INIT_PTM_RATIO);
        
        // screenCoordPos is the center of the body. We need to get the bounding rectangle from it.
        // BUGBUG : Get Hero width and height from SVG file.
#define INIT_RADIUS  (24)
        box_t heroContentBox = box_t(point_t(screenCoordPos.x-INIT_RADIUS, screenCoordPos.y-INIT_RADIUS), 
                                     point_t(screenCoordPos.x+INIT_RADIUS, screenCoordPos.y+INIT_RADIUS));

        ////////////////////////////////////////////////////////////////////////////////
        // Step 2 : Get all game objects colliding with the bounding rectangle of Hero. 
        ////////////////////////////////////////////////////////////////////////////////
        std::deque<REF(GameObject)> v;
        v = gameObjectContainer.getCollidingObjects(heroContentBox);
        
        for (std::deque<REF(GameObject)>::iterator it = v.begin(); it != v.end(); it++)
        {
            REF(GameObject) refGameObject = *it;
            
            refGameObject->onCollideWithHero();
        }
    }
}

-(void) gotoLevelMap
{
    // IF the hero is already dead, go back to level map scene.
    [[CCDirector sharedDirector] replaceScene:[GeneralScene sceneWithName:@"LevelMapScene"]];
}
/** @brief check if the Hero is dead. The hero is dead if he is below the ground level.
 */
-(void) checkHeroDead:(float)worldGroundY {
    if ( hero.body->GetPosition().y < worldGroundY - HERO_DEAD_GAP_WORLD_Y ) {
        if ( ! hero.isDead )
        {
            // Show that the hero is dead (Jump like mario!)
            [hero dead];
            
            // The player is dead!
            [self showMessage:@"Dead!"];
            
            CCSprite * heroSprite = [hero getSprite];
            
            [heroSprite runAction:[CCScaleTo actionWithDuration:2.0f scale:2.0f]];
            [heroSprite runAction:[CCSequence actions:
                              [CCFadeOut actionWithDuration:2.0f],
                              [CCCallFuncND actionWithTarget:self selector:@selector(gotoLevelMap) data:(void*)nil],
                              nil]];
        }
    }
}

/** @brief update GameObject(s) for each tick. Box2D objects are not included here.
 */
-(void) updateGameObjects {

    // 100 : 
    // 550 : [60->38], [15->30]
    // Iterate over the game objects in the GameObjectContainer
//    GameObjectContainer::GameObjectSet gameObjects = gameObjectContainer.gameObjects();
//    for (GameObjectContainer::GameObjectSet::iterator it = gameObjects.begin(); it!= gameObjects.end(); it++)

    /////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // Step 1: Get the hero position X at zoom level 1.0 
    float heroXatZ1 = hero.body->GetPosition().x * INIT_PTM_RATIO;
    
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // Step 2: Remove gone game objects 
    // Search game objects that are shown on the left of the left side of the screen at the minimum zoom level.
    //
    {
        box_t goneScreenBox = [cam goneScreenRect:heroXatZ1];
        std::deque<REF(GameObject)> v;
        v = gameObjectContainer.getCollidingObjects(goneScreenBox);
        
        for (std::deque<REF(GameObject)>::iterator it = v.begin(); it != v.end(); it++)
        {
            REF(GameObject) refGameObject = *it;
            refGameObject->deactivate();
            refGameObject->removeSelf();
        }
    }
    
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // Step 3: Update comming game objects 
    // Search game objects that are shown in the screen and will be shown in the screen at the minimum zoom level.
    {
        box_t commingScreenBox = [cam commingScreenRect:heroXatZ1];
        std::deque<REF(GameObject)> v;
        v = gameObjectContainer.getCollidingObjects(commingScreenBox);
        
        for (std::deque<REF(GameObject)>::iterator it = v.begin(); it != v.end(); it++)
        {
            REF(GameObject) refGameObject = *it;
            
            // If it is not active yet, (It is the first time to come into the commingScreenBox)
            if ( ! refGameObject->isActivated() )
            {
                // Activate it
                refGameObject->activate( self );
            }
            
            // update the sprite position, scale, rotation based on the game object and camera position considering zoom level.
            [cam updateSpriteFromGameObject: refGameObject ];
        }    
    }
}

-(void) tick: (ccTime) dt
{
//	st+=0.01;
//	float s = sin(st)*2.0f;
//	if(s<0) s*=-1.0f;
//	[cam ZoomTo: s +0.2f];
    // TODO : Understand why adjusting terrain should come here.

    static float worldGroundY = 0.0f;
    [self adjustZoomWithGroundY:worldGroundY];

	[cam updateFollowPosition];

    // groundY will be used in the next tick to decide the zoom level.
    worldGroundY = [self adjustTerrainsAndSky] / INIT_PTM_RATIO;
    
    // To show bottom of terrains, lower the ground level. 
    worldGroundY -= MAX_WAVE_HEIGHT;
    
	int32 velocityIterations = 8;
    int32 positionIterations = 3;
    //	int32 positionIterations = 10;
	if (hero)
        [hero updatePhysics];
    
	// Instruct the world to perform a single step of simulation. It is
	// generally best to keep the time step and iterations fixed.
	world->Step(1.0f/60.0f, velocityIterations, positionIterations);

	if (hero)
        [hero updateNode];

	//Iterate over the bodies in the physics world
	for (b2Body* b = world->GetBodyList(); b; b = b->GetNext())
	{
		[cam updateSpriteFromBody:b];
	}

    // no change in performance.
    [self checkCollisions4GameObjects];

    [self checkHeroDead:worldGroundY];
    
    [self updateGameObjects];
    
    
    // Update counters to look like they are increasing by 1 until they reach the target count. 
    scoreLabel.update();
    waterDropsLabel.update();
}

- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    CCLOG(@"TouchesBegan");
// by kmkim    
//	[cam eventBegan:touches];
    
    self.hero.diving = YES;
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
//    [cam eventMoved:touches];
	
//	for( UITouch *touch in touches ) 
//	{
//		CGPoint location = [touch locationInView: [touch view]];
//		location = [[Director sharedDirector] convertToGL: location];
//		if([touches count]==1)[myCamera eventMoved:location];
//	}
}
- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    CCLOG(@"TouchesEnded");
// by kmkim    
//	[cam eventEnded:touches];

    self.hero.diving = NO;

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
    
    [[CDAudioManager sharedManager] stopBackgroundMusic];
    
	// in case you have something to dealloc, do it in this method
    [self unschedule: @selector(tick:)];

    if (car)
        delete car;

    [sky release];
    sky = nil;
    
    self.hero = nil;
    [terrains release];
    
    // remove all body nodes attached to b2Body in the b2World.
    Helper::removeAttachedBodyNodes(world);
	delete world;
	world = NULL;
    
    [cam release];
    
	delete m_debugDraw;

	// Reset the StageScene singleton.
    instanceOfStageScene = nil;
    
	// don't forget to call "super dealloc"
	[super dealloc];
}
@end
