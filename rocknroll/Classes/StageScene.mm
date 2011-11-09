// Import the interfaces
#import "StageScene.h"
#import "TouchXML.h"
#import "JointDeclaration.h"

#import "BodyInfo.h"
#include "GameConfig.h"
#include "Util.h"
#include "GeneralScene.h"
#import "LevelMapScene.h"

#include "InputLayer.h"
#include "b2WorldEx.h"

#import "Terrain.h"
#import "AKHelpers.h"

#import "Sky.h"
#import "Profiler.h"


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

const float backgroundImageWidth = 1024;
const float backgroundImageHeight = 512;


@interface StageScene() 
- (void) finishStageWithMessage:(NSString*)message stageCleared:(BOOL)clearedCurrentStage;
@end

// HelloWorld implementation
@implementation StageScene

@synthesize car;
@synthesize hero;
@synthesize giveUpStage;

static StageScene* instanceOfStageScene;
+(StageScene*) sharedStageScene
{
	NSAssert(instanceOfStageScene != nil, @"StageScene instance not yet initialized!");
	return instanceOfStageScene;
}

-(void) visit
{
PROF_BEGIN(cocos2d_layer_visit);    
    [super visit];
PROF_END(cocos2d_layer_visit);    
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
    
	svgLoader * loader = [[[svgLoader alloc] initWithWorld:world andStaticBody:groundBody andLayer:self terrains:terrains gameObjects:&gameObjectContainer scoreBoard:self tutorialBoard:self] autorelease];
    
    // Set the class dictionary to the loader, so that it can initiate objects of classes defined in "classes.svg" file. 
    // In that file, a class is defined within a layer.
    ClassDictionary * classDict = [[ClassDictionary alloc] init];
    NSString *classFilePath = [Util getResourcePath:@"game_classes.svg"];
    [classDict loadClassesFrom:classFilePath];
    loader.classDict = classDict;
    [classDict release];
    
    CCLOG(@"BEGIN : Loading SVG :%@", filePath);
	[loader instantiateObjectsIn:filePath];
    CCLOG(@"END : Loading SVG :%@", filePath);
    
    // find out the maximum X of all terrains. If the hero goes beyond of it, the stage is cleared!
    terrainMaxX = -kMAX_POSITION;
    for (Terrain * t in terrains) {
        if ( terrainMaxX < t.maxX )
        {
            terrainMaxX = t.maxX;
        }
    }

	return loader;
}

-(void) addTerrains {
    for (Terrain * t in terrains) {
        [self addChild:t];
    }
}

///////////////////////////////////////////////////////////////
// GameActivationProtocol

-(void) pauseGame {
    isGamePaused = YES;
}

-(void) resumeGame {
    isGamePaused = NO;
}

///////////////////////////////////////////////////////////////
// ScoreBoardProtocol
// Ex> Increase the speed by 10% => sppedRatioDiff=0.1f
-(void) increaseSpeedRatio:(float) speedRatioDiff
{
    float newSpeedRatio = speedRatioLabel->getTargetValue() + speedRatioDiff;
    if ( newSpeedRatio <= MAX_FRAME_SPEED_RATIO )
    {
        speedRatioLabel->setTargetValue(newSpeedRatio);
    }
}

-(void) setSpeedRatio:(float) speedRatio
{
    speedRatioLabel->setTargetValue(speedRatio);
}

-(void) increaseScore:(int) scoreDiff
{
    int newScore = scoreLabel.getTargetCount() + scoreDiff;
    scoreLabel.setTargetCount(newScore);
}

-(void) increaseFeathers:(int) feathersDiff
{
    int newFeathers = feathersLabel.getTargetCount() + feathersDiff;
    feathersLabel.setTargetCount(newFeathers);
}

-(void) increaseLife:(float)lifePercentDiff
{
    float newLife = healthBar.getTargetPercent() + lifePercentDiff;
    if ( newLife > 100 )
    {
        newLife = 100;
    }
    healthBar.setTargetPercent( newLife );
    
    // More than 25% left for the life...
    if ( newLife > HEALTH_BAR_BLINKING_THRESHOLD )
    {
        // stop all actions to get rid of the blinking effect on the health bar
        [healthBar.getProgressTimer() stopAllActions];
    }
}

-(void) decreaseLife:(float)lifePercentDiff
{
    float newLife = healthBar.getTargetPercent() - lifePercentDiff;
    if ( newLife < 0 )
    {
        newLife = 0;
    }
    healthBar.setTargetPercent( newLife );
    
    // Only 50% left for the life...
    if ( newLife <= HEALTH_BAR_BLINKING_THRESHOLD )
    {
        // blink the health bar. Blink twice a second.
        [healthBar.getProgressTimer() runAction:[CCBlink actionWithDuration:3600 blinks:7200]];
    }
    
    // No more life...
    if ( newLife <= 0 )
    {
        if ( hero.hasWings )
        {
            [hero dropWings];
            [self finishStageWithMessage:@"Failed~" stageCleared:NO];
        }
    }
}

- (void) showMessage:(NSString*) message {
    [Util showMessage:message inLayer:(CCLayer*)self adHeight:LANDSCAPE_AD_HEIGHT];
}
///////////////////////////////////////////////////////////////
// TutorialBoardProtocol

-(void) showTutorialText:(NSString*) tutorialText
{
    assert(tutorialText);
    
    // Weak Ref
	tutorialLabel = [CCLabelBMFont labelWithString:tutorialText fntFile:@"punkboy.fnt"];
    assert(tutorialLabel);
    
	tutorialLabel.position = ccp(super.screenSize.width * 0.5, super.screenSize.height * 0.5);

	[self addChild:tutorialLabel];

    // blink the health bar. Blink three times a second.
    [tutorialLabel runAction:[CCBlink actionWithDuration:1000 blinks:3000]];

    [self pauseGame];
}
///////////////////////////////////////////////////////////////

-(void) onPushPauseScene:(id) sender
{
    // BUGBUG : How about not playing the background music during the pause scene?
    
    CCScene * pauseScene = [GeneralScene sceneWithName:@"PauseScene" previousLayer:self];
    
    [[CCDirector sharedDirector] pushScene:pauseScene];
}


-(void) initScoreLabels {
    float AD_SIZE_HEIGHT = super.enableAD ? LANDSCAPE_AD_HEIGHT : 0;    
    float SCORE_VERT_CENTER_Y = super.screenSize.height - super.screenSize.height/14 - AD_SIZE_HEIGHT;
    static float HORIZONTAL_MARGIN = super.screenSize.width/32;
    // The margin between the water drop sprite and the counter.
    static float FEATHER_MARGIN = HORIZONTAL_MARGIN/2;
    // Water Drop sprite and count
    CCLabelBMFont *keysLabel = nil;
    {
        CCSprite * featherSprite = [CCSprite spriteWithSpriteFrameName:@"feather00.png"]; 
        assert(featherSprite);
        
        [spriteSheet addChild:featherSprite];
        featherSprite.anchorPoint = ccp(0, featherSprite.anchorPoint.y);
        // Y : +5 is required to move the sprite to the top of the screen by 5 pixcels because the water drop sprite have margin space on top of it.
        featherSprite.position = ccp(HORIZONTAL_MARGIN, SCORE_VERT_CENTER_Y+5);

        
        keysLabel = feathersLabel.getLabel();
        
        keysLabel.anchorPoint = ccp(0, keysLabel.anchorPoint.y);
        
        keysLabel.position = ccp(featherSprite.position.x + featherSprite.contentSize.width + FEATHER_MARGIN, 
                             SCORE_VERT_CENTER_Y);

        [self addChild:keysLabel];
    }

    // Score
    {
        CCLabelBMFont *label = scoreLabel.getLabel();
        
        label.anchorPoint = ccp(label.anchorPoint.x*2, label.anchorPoint.y);
        
        label.position = ccp(super.screenSize.width - HORIZONTAL_MARGIN, SCORE_VERT_CENTER_Y);
        
        [self addChild:label];
    }

    // Speed Ratio
    {
        speedRatioLabel =  new FloatLabel(MIN_FRAME_SPEED_RATIO,  /* initialValue */
                                          STEP_FRAME_SPEED_RATIO, /* stepValue */
                                          MIN_FRAME_SPEED_RATIO,  /* minValue */
                                          MAX_FRAME_SPEED_RATIO  /* float maxValue */ );
        CCLabelBMFont *label = speedRatioLabel->getLabel();
        
//        label.anchorPoint = ccp(0, label.anchorPoint.y);
//        label.position = ccp(keysLabel.position.x + FEATHER_MARGIN, SCORE_VERT_CENTER_Y);
        label.position = ccp(super.screenSize.width * 0.5, SCORE_VERT_CENTER_Y);
        
        [self addChild:label];
    }

    // Life Bar
    {
        /*
        CCProgressTimer * healthBarProgress = healthBar.getProgressTimer();

        healthBarProgress.position = ccp(super.screenSize.width * 0.5, SCORE_VERT_CENTER_Y);
        
        [self addChild:healthBarProgress];
         */
    }
    

    CCMenuItemFont * mi = [CCMenuItemFont itemFromString:@"Pause" target:self selector:@selector(onPushPauseScene:)];
    
    CCMenu * m = [CCMenu menuWithItems:mi,nil];
    [self addChild:m z:500];
    m.position = CGPointMake(430, SCORE_VERT_CENTER_Y - 30);

}


// initialize your instance here
-(id) initInMap:(NSString*)aMapName levelNum:(int)aLevel
{
	if( (self=[super init])) 
	{
        // Show AD only if nothing is purchased
        if ( ! [Util didPurchaseAny] )
        {
            super.enableAD = YES;
        }

        // Load water drop count
        int featherCount = [Util loadFeatherCount];
        feathersLabel.setCount( featherCount );
        
        // initialize variables
        isGamePaused = NO;
        tutorialLabel = nil;
        worldGroundY = 0.0f;
        heroXatZ1_ofLastGameObjectRemoval = 0.0f;
        
        terrains = nil;
        
        stageCleared = NO;
        
        mapName = [aMapName retain];
        level = aLevel;
        assert( aLevel < MAX_LEVELS_PER_MAP );
        assert( MAX_LEVELS_PER_MAP < 99 );
        
		// enable touches
		self.isTouchEnabled = YES;
		
		// enable accelerometer
		self.isAccelerometerEnabled = YES;

        sky = [[Sky skyWithTextureSize:CGSizeMake(backgroundImageWidth,backgroundImageHeight)] retain];
		[self addChild:sky];
        
        spriteSheet = [CCSpriteBatchNode batchNodeWithFile:@"sprites.pvr"];
        [self addChild:spriteSheet];

		// The SVG file for the given level.
        NSString * svgFileName = [NSString stringWithFormat:@"StageScene_%@_%02d.svg", mapName, level];

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
		
		/*
		arrow = [CCSprite spriteWithFile:@"arrow.png"];
		arrow.anchorPoint = CGPointMake(0, 2.5);
		arrow.scaleX = 3;
		[self addChild:arrow z:100 tag:0x777888];
		*/
		st =0;
		
        instanceOfStageScene = self;

        // Initialize score labels. (Requires spriteSheet);
        [self initScoreLabels];
        
        [self schedule: @selector(tick:)];
	}
	return self;
}


+(id)nodeInMap:(NSString*)mapName levelNum:(int)level
{
    return [[[StageScene alloc] initInMap:mapName levelNum:level] autorelease];
}

/** @brief Does the game scene require joystick?
 */
-(BOOL) needJoystick
{
    if ( [self car] )
        return YES;
    return NO;
}

+(CCScene*) sceneInMap:(NSString*)mapName levelNum:(int)level
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	StageScene *layer = [StageScene nodeInMap:mapName levelNum:level];
	
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
-(void) adjustZoomWithGroundY:(float)groundY_worldSystem
{
    // For optimization, we have static variable here rather than using super.screenSize
    static CGSize theScreenSize = [[CCDirector sharedDirector] winSize];
    static float minHeightMeters = 0.0f;
    if (!minHeightMeters) 
    {
        float maxHeroY = theScreenSize.height * HERO_MAX_YPOS_RATIO;
		minHeightMeters = maxHeroY / INIT_PTM_RATIO;
    }
    
    static float targetZoom = 0.0f;
    if ( targetZoom == 0.0f )
    {
        targetZoom = cam.zoom;
    }
    
    if (hero)
    {
        float32 worldHeightToShow = hero.body->GetPosition().y - groundY_worldSystem;
        
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

/** @brief Activate, move, scale sky based on the current hero position.
 */
-(void) adjustSky:(float)heroX_withoutZoom {
    
    if (hero)
    { 
        /////////////////////////////////////////////
        // Step 2 : Adjust Sky
        // BUGBUG : Screen : Change to screen width & height
        static float onScreenBackgroundImageWidth = backgroundImageHeight*super.screenSize.width/super.screenSize.height;
        // -50 is an workaround for not showing the outside area of the right border of the background image.
        static float maxOffsetX = (backgroundImageWidth - onScreenBackgroundImageWidth) - 50;
        static float heroOffsetOnScreen = super.screenSize.width * HERO_XPOS_RATIO;
        // The hero can go three screens further from the last terrain. 
        static float maxHeroX_withoutZoom = (terrainMaxX + super.screenSize.width * 3);
        float offsetX = (heroX_withoutZoom-heroOffsetOnScreen)/maxHeroX_withoutZoom * maxOffsetX;
        
        [sky setOffsetX:offsetX];
        [sky setScale:1.0f-(1.0f-cam.zoom)*0.75f];
    }
}

/** @brief Activate, move, scale terrains based on the current hero position.
 */
-(float) adjustTerrains:(float)heroX_withoutZoom {
    float groundY = kMAX_POSITION;
    
    if (hero)
    {
        /////////////////////////////////////////////
        // Step1 : Adjust Terrains
        // When the camera is above the sea level(y=0), cam.cameraPosition contains negative offsets to subtract from sprites position.
        // Convert it back to the y offset from sea level.
        
        float cameraY = -cam.cameraPosition.y;
        for (Terrain * t in terrains) {
            t.scale = cam.zoom;
PROF_BEGIN(temp1);
            [t setHeroX:heroX_withoutZoom withCameraY:cameraY];
PROF_END(temp1);
    
PROF_BEGIN(temp2);
            float borderMinY = [t calcBorderMinY];
PROF_END(temp2);
            
            if ( borderMinY != kMAX_POSITION ) // The terrain is not drawn on the current screen.
            {
                if ( groundY > borderMinY )
                    groundY = borderMinY;
            }
        }
    }
    
    return groundY;
}
/** @brief See if the hero collides any objects in the GameObjectContainer. Box2D objects are not included here.
 */
-(void) checkCollisions4GameObjects {
    // Optimization : Check collision once per 2 frames
    {
        static unsigned int lastCheckedTS=0; // TS = timestamp
        static unsigned int TS=0;
        if (++TS - lastCheckedTS < 2 )
            return;
        lastCheckedTS = TS;
    }
    
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
            
            refGameObject->onCollideWithHero( hero );
        }
    }
}

-(void) gotoLevelMap:(BOOL)clearedCurrentStage
{
    CCLOG(@"gotoLevelMap:%@", clearedCurrentStage?@"YES":@"NO");

    // Save the number of water drops persistenlty.
    int feathers = feathersLabel.getCount();
    [Util saveFeatherCount:feathers];

    // IF the level is cleared, the next level is unlocked.
    // IF the level is not cleared(the Hero is dead), go back to level map scene.
    CCScene * levelMapScene = [LevelMapScene sceneWithName:mapName level:level cleared:clearedCurrentStage];
    assert(levelMapScene);
    
    [[CCDirector sharedDirector] replaceScene:levelMapScene];

    CCLOG(@"gotoLevelMap:end");
}

-(void)gotoLevelMapCallback:(id)sender data:(void*)callbackData 
{
    BOOL clearedCurrentStage = (BOOL)(int)callbackData;
    
    CCLOG(@"gotoLevelMapCallback:%@, %p", clearedCurrentStage?@"YES":@"NO", callbackData);

    [self gotoLevelMap:clearedCurrentStage];
    
    CCLOG(@"gotoLevelMapCallback:end");
}

/** @brief Show a big title on the center of the screen for 2 seconds, switch back to level map scene.
 */
- (void) finishStageWithMessage:(NSString*)message stageCleared:(BOOL)clearedCurrentStage{
    
	CCLabelBMFont *label = [CCLabelBMFont labelWithString:message fntFile:@"punkboy.fnt"];
	label.position = ccp(super.screenSize.width/2, super.screenSize.height/2);
    label.scale = 1.0;

	[label runAction:[CCSequence actions:
                      [CCScaleTo actionWithDuration:2.0f scale:4.0f],
                      [CCCallFuncND actionWithTarget:self selector:@selector(gotoLevelMapCallback:data:) data:(void*)clearedCurrentStage],
					  [CCCallFuncND actionWithTarget:label selector:@selector(removeFromParentAndCleanup:) data:(void*)YES],
					  nil]];
    
	[self addChild:label];
    
    PROF_PRINT_RESULT();
}

/** @brief check if the Hero is dead. The hero is dead if he is below the ground level.
 */
-(void) checkHeroDead:(float)groundY_worldSystem {
    // if the stage is cleared, don't check if the player is dead. We will advance to the next stage soon.
    if ( stageCleared) {
        return;
    }
    
    // if the user has given up the stage, don't check if the hero is dead.
    if (giveUpStage) {
        return;
    }
    
    if ( hero.body->GetPosition().y < groundY_worldSystem - HERO_DEAD_GAP_WORLD_Y ) {
        if ( ! hero.isDead )
        {
            // Show that the hero is dead (Jump like mario!)
            [hero dead];
            
            CCSprite * heroSprite = [hero getSprite];
            assert(heroSprite);
            
            [heroSprite stopAllActions];

            [heroSprite runAction:[CCSequence actions:
                                    [CCFadeOut actionWithDuration:2.0f], nil]];
            
            [self finishStageWithMessage:@"Failed~" stageCleared:NO];
        }
    }
}


/** @brief check if the Hero is dead. The hero is dead if he is below the ground level.
 */
-(void) checkStageClear:(float)heroX_withoutZoom {
    if ( hero.isDead )
        return;

    // if the user has given up the stage, don't check for stage clear.
    if (giveUpStage) {
        return;
    }

    if ( heroX_withoutZoom > terrainMaxX ) {
        if ( ! stageCleared )
        {
            CCLOG(@"Stage Cleared: begin");
            
            [self finishStageWithMessage:@"Cleared!" stageCleared:YES];
            stageCleared = YES;
            
            CCLOG(@"Stage Cleared: end");
        }
    }
}


- (void) onEnterTransitionDidFinish {
    if ( ! [[CDAudioManager sharedManager] isBackgroundMusicPlaying] )
    {
        // playbackground music
        [[CDAudioManager sharedManager] playBackgroundMusic:@"heart-of-the-sea.mp3" loop:YES];
        [CDAudioManager sharedManager].backgroundMusic.numberOfLoops = 1000;
        [CDAudioManager sharedManager].backgroundMusic.volume = 0.7;
    }

    // "ResumeScene.svg" of GeneralScene sets this flag if the user touches "Give Up" button.
    if (giveUpStage) {
        if ( ! stageCleared && ! hero.isDead ) {
            [self finishStageWithMessage:@"Give Up!" stageCleared:NO];
        }
    }

    [super onEnterTransitionDidFinish];
}

/** @brief update GameObject(s) for each tick. Box2D objects are not included here.
 */
-(void) removeUnusedGameObjects:(float)heroXatZ1 {
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // Step 1: Check if the hero forward enough. 
    // Why? For optimization. We check to remove game objects only if the Hero moved by enough margin.
    // Search game objects that are shown on the left of the left side of the screen at the minimum zoom level.
 
    if ( heroXatZ1 < heroXatZ1_ofLastGameObjectRemoval ) // The hero went backward. Do nothing.
        return;
    if ( heroXatZ1 - heroXatZ1_ofLastGameObjectRemoval < 240 ) // The hero went less than the half of the screen width. Do nothing.
        return;
    
    // Ok, the hero moved forward by enough margin. We need to remove unused game objects. 
    heroXatZ1_ofLastGameObjectRemoval = heroXatZ1;
    
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
}

/** @brief update GameObject(s) for each tick. Box2D objects are not included here.
 */
-(void) updateGameObjects:(float)heroXatZ1 {
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // Step 1: Update comming game objects 
    // Search game objects that are shown in the screen and will be shown in the screen at the minimum zoom level.
    {
        box_t commingScreenBox = [cam commingScreenRect:heroXatZ1];
        std::deque<REF(GameObject)> v;
        v = gameObjectContainer.getCollidingObjects(commingScreenBox);
        
        for (std::deque<REF(GameObject)>::iterator it = v.begin(); it != v.end(); it++)
        {
            REF(GameObject) refGameObject = *it;
            
            // TutorialBox is an example of Passive Game Object : No need to update sprite position on screen. Nothing to animate
            if ( ! refGameObject->isPassive() )
            {
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
}

-(void) tick: (ccTime) dt
{
/*    
    // Enable profiling only when the hero is not flying.
    if (hero.flying)
        PROF_DISABLE();
    else
        PROF_ENABLE();
*/
    // TODO : Understand why adjusting terrain should come here.

    // if the game is paused, dont' update the game frame. 
    if (isGamePaused)
    {    
        return;
    }
    
PROF_BEGIN(stage_tick_adjustZoomWithGroundY);
    [self adjustZoomWithGroundY:worldGroundY];
PROF_END(stage_tick_adjustZoomWithGroundY);

PROF_BEGIN(stage_tick_updateFollowPosition);
	[cam updateFollowPosition];
PROF_END(stage_tick_updateFollowPosition);

PROF_BEGIN(stage_tick_adjustTerrains);
    float heroX_withoutZoom = hero.body->GetPosition().x * INIT_PTM_RATIO;

  PROF_BEGIN(temp3);            
    // groundY will be used in the next tick to decide the zoom level.
    float screenGroundY_withoutZoom = [self adjustTerrains:heroX_withoutZoom];
  PROF_END(temp3);            
    worldGroundY = screenGroundY_withoutZoom / INIT_PTM_RATIO;
    // To show bottom of terrains, lower the ground level. 
    worldGroundY -= MAX_WAVE_HEIGHT;
    
PROF_END(stage_tick_adjustTerrains);
    //worldGroundY = -1000;
    // worldGroundY will be used in the next tick to decide the zoom level.
    
PROF_BEGIN(stage_tick_adjustSky);
    [self adjustSky:heroX_withoutZoom];
PROF_END(stage_tick_adjustSky);
/*
	int32 velocityIterations = 8;
    int32 positionIterations = 3;
*/
	int32 velocityIterations = 2;
    int32 positionIterations = 2;

PROF_BEGIN(stage_tick_hero_updatePhysics);
	if (hero)
        [hero updatePhysics];
PROF_END(stage_tick_hero_updatePhysics);
    
PROF_BEGIN(stage_tick_world_step);
    float worldStepTime = speedRatioLabel->getValue() * DEFAULT_FRAME_DURATION_SEC;
	// Instruct the world to perform a single step of simulation. It is
	// generally best to keep the time step and iterations fixed.
	//world->Step(1.0f/60.0f, velocityIterations, positionIterations);
	world->Step(worldStepTime, velocityIterations, positionIterations);
PROF_END(stage_tick_world_step);

PROF_BEGIN(stage_tick_hero_updateNode);
	if (hero)
        [hero updateNode];
PROF_END(stage_tick_hero_updateNode);

PROF_BEGIN(stage_tick_cam_updateSpriteFromBody);
	//Iterate over the bodies in the physics world
	for (b2Body* b = world->GetBodyList(); b; b = b->GetNext())
	{
		[cam updateSpriteFromBody:b];
	}
PROF_END(stage_tick_cam_updateSpriteFromBody);

PROF_BEGIN(stage_tick_checkCollisions4GameObjects);
    // no change in performance.
    [self checkCollisions4GameObjects];
PROF_END(stage_tick_checkCollisions4GameObjects);

PROF_BEGIN(stage_tick_checkStageClear);
    [self checkStageClear:heroX_withoutZoom];
PROF_END(stage_tick_checkStageClear);

PROF_BEGIN(stage_tick_checkHeroDead);
    [self checkHeroDead:worldGroundY];
PROF_END(stage_tick_checkHeroDead);
    
PROF_BEGIN(stage_tick_updateGameObjects);
    [self removeUnusedGameObjects:heroX_withoutZoom];
    [self updateGameObjects:heroX_withoutZoom];
PROF_END(stage_tick_updateGameObjects);
    
PROF_BEGIN(stage_tick_update_labels);
    // Update counters to look like they are increasing by 1 until they reach the target count. 
    scoreLabel.update();
    feathersLabel.update();
    speedRatioLabel->update();
    // Update the health bar so that they look like changing gradually.
    healthBar.update();
PROF_END(stage_tick_update_labels);
}

- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    CCLOG(@"TouchesBegan");
// by kmkim    
//	[cam eventBegan:touches];
    
    // IF tutorial is shown, resume the game, remove the tutorial text.
    if ( tutorialLabel )
    {
        // Weak Ref
        [tutorialLabel removeFromParentAndCleanup:YES];
        tutorialLabel = nil;
        
        assert(isGamePaused);
        [self resumeGame];
    }
    
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

// BUGBUG : Understand why this is called.
- (void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration {
    /*
    labelX.text = [NSString stringWithFormat:@"%@%f", @"X: ", acceleration.x];
    labelY.text = [NSString stringWithFormat:@"%@%f", @"Y: ", acceleration.y];
    labelZ.text = [NSString stringWithFormat:@"%@%f", @"Z: ", acceleration.z];
    
    self.progressX.progress = ABS(acceleration.x);
    self.progressY.progress = ABS(acceleration.y);
    self.progressZ.progress = ABS(acceleration.z);
    */
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
    
    [mapName release];
    
    assert(speedRatioLabel);
    delete speedRatioLabel;
    speedRatioLabel = NULL;
    
	// don't forget to call "super dealloc"
	[super dealloc];
}
@end
