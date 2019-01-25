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

#import "ClearScene.h"

#import "IntermediateScene.h"

#import "AppAnalytics.h"

#import "AdManager.h"

// For game center integration
#import "NetworkPackets.h"
#import "GameState.h"
#import "DemoManager.h"
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
-(void) showMatchMaker;
- (void) sendPosition:(CGPoint)playerPos;
- (void) finishStageWithMessage:(NSString*)message stageCleared:(BOOL)clearedCurrentStage;
- (void) decideTouchTutorEnabled;
@end

// HelloWorld implementation
@implementation StageScene

@synthesize car;
@synthesize hero;

static StageScene* instanceOfStageScene;
+(StageScene*) sharedStageScene
{
//	NSAssert(instanceOfStageScene != nil, @"StageScene instance not yet initialized!");
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
    
	svgLoader * loader = [[[svgLoader alloc] initWithWorld:world andStaticBody:groundBody andLayer:self widgets:NULL terrains:terrains gameObjects:gameObjectContainer scoreBoard:self tutorialBoard:self] autorelease];
    
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
    
	return loader;
}
/** @brief Read attribute values from the stage SVG file. 
 */
-(void) readAttributesFromSVG:(NSString*) svgFilePath
{
    // Load attributes from the svg file.
    {
        NSData *data = [NSData dataWithContentsOfFile:svgFilePath]; 
        assert(data);
        CXMLDocument *svgDocument  = [[[CXMLDocument alloc] initWithData:data options:0 error:nil] autorelease];
        assert(svgDocument);
        CXMLElement * rootElement = [svgDocument rootElement];
        
        musicFileName = [[Util getStringValue:rootElement name:@"_backgroundMusic" defaultValue:nil] retain];
        backgroundImage = [[Util getStringValue:rootElement name:@"_backgroundImage" defaultValue:@"nosky.pvr"] retain];
        groundTexture = [[Util getStringValue:rootElement name:@"_groundTexture" defaultValue:@"noterrain.pvr"] retain];
        playTimeSec  = [Util getIntValue:rootElement name:@"_playTimeSec" defaultValue:60];
        
        //playTimeSec = 1000;
        if ( isHardMode ) {
            playTimeSec = playTimeSec * HARD_MODE_PLAY_TIME_FACTOR;
        }
        oneStarCount = [Util getIntValue:rootElement name:@"_oneStarCount" defaultValue:1];
        twoStarCount = [Util getIntValue:rootElement name:@"_twoStarCount" defaultValue:2];
        threeStarCount= [Util getIntValue:rootElement name:@"_threeStarCount" defaultValue:3];

        closingScene = [[Util getStringValue:rootElement name:@"_closingScene" defaultValue:nil] retain];

        NSString * stageName = [[Util getStringValue:rootElement name:@"_stageName" defaultValue:nil] retain];
        [playUI setStageName:stageName];
    }
}
/*
-(void) addTerrains {
    
    NSAutoreleasePool * autoPool = nil;
    int processingPoints = 0;

    for (Terrain * t in terrains) {
        if ( !autoPool ) {
            autoPool = [[NSAutoreleasePool alloc] init];
        }
        // Set the ground texture.
        t.textureFile = groundTexture;
        
        CCLOG(@"MID : BEGIN : prepareRendering");
        [t prepareRendering];
        CCLOG(@"MID : END : prepareRendering");

        [self addChild:t];
        
        processingPoints += [t borderPointCount];
        if ( processingPoints >= SVG_LOADER_SHAPE_POINTS_PER_AUTOPOOL ) {
            [autoPool drain];
            
            autoPool = [[NSAutoreleasePool alloc] init];
        }
    }
}
*/
-(void) addTerrains {
    CCSprite * groundSprite = [Terrain groundSprite:groundTexture];
    for (Terrain * t in terrains) {
        
        CCLOG(@"MID : BEGIN : prepareRendering");
        [t prepareRendering:groundSprite];
        CCLOG(@"MID : END : prepareRendering");
        
        [self addChild:t];
    }
}


// find out the maximum X of all terrains. If the hero goes beyond of it, the stage is cleared!
-(void) calcMaxTerrains 
{
    terrainMaxX = -kMAX_POSITION;
    for (Terrain * t in terrains) {
        if ( terrainMaxX < t.maxX )
        {
            terrainMaxX = t.maxX;
        }
    }
}

///////////////////////////////////////////////////////////////
// GameActivationProtocol

-(void) pauseGame {
    if ( ! isGamePaused )
    {
        // In Help menu in Pause Layer, we have animation to snow. If we pause the director, the animation won't be done.
        // So we don't pause the director, but unschedule the tick while the game is in pause mode.
        
        [self unschedule: @selector(tick:)];
        
        //[[CCDirector sharedDirector] pause];

        isGamePaused = YES;
    }
}

-(void) resumeGame {
    if ( isGamePaused ) 
    {
        // Users may have turned on or off touch Tutor.
        [self decideTouchTutorEnabled];
        if (!isTouchTutorEnabled) {
            [playUI showTouchTutor:NO];
        }
        
        // We need to schedule tick again in resumeGame, because scenes in PauseLayer can unschedule all selectors.
        // GeneralScene.onExit unschedules all selectors.
        [self schedule: @selector(tick:)];
        
        //[[CCDirector sharedDirector] resume];
        
        isGamePaused = NO;
    }
    /*
    [node resumeSchedulerAndActions];
    for (CCNode *child in [node children]) {
        [self resumeSchedulerAndActionsRecursive:child];
    }*/
}

-(void) giveUpGame:(NSString*)message {
    if (!gaveUpStage)
    {
        gaveUpStage = YES;
        // "PauseLayer.svg" sets this flag if the user touches "Give Up" button.
        if ( ! stageCleared && ! hero.isDead ) {
            [self finishStageWithMessage:message stageCleared:NO];
        }
    }
}
///////////////////////////////////////////////////////////////
// ScoreBoardProtocol
// Ex> Increase the speed by 10% => sppedRatioDiff=0.1f
-(void) increaseSpeedRatio:(float) speedRatioDiff
{
    float newSpeedRatio = sbSpeedRatio + speedRatioDiff;
    // BUGBUG : Need to get MAX_FRAME_SPEED_RATIO from FloatLabel in GamePlayLayer.svg?
    if ( newSpeedRatio <= MAX_FRAME_SPEED_RATIO )
    {
        sbSpeedRatio = newSpeedRatio;
        [playUI setSpeedRatio:newSpeedRatio];
    }
}

-(void) setSpeedRatio:(float) speedRatio
{
    sbSpeedRatio = speedRatio;
    [playUI setSpeedRatio:speedRatio];
}

-(void) increaseScore:(int) scoreDiff
{
    sbScore = sbScore + scoreDiff;
    [playUI setScore:sbScore];
}

-(void) increaseKeys:(int) keysDiff
{
    sbKeys = sbKeys + keysDiff;
    [playUI setKeys:sbKeys];
}

-(int) getKeys
{
    return sbKeys;
}

-(void) setKeys:(int)keys
{
    sbKeys = keys;
    [playUI setKeys:sbKeys];
}

-(void) increaseChicks:(int) chicksDiff
{
    sbChicks = sbChicks + chicksDiff;
    [playUI setChicks:sbChicks];
}

-(int) getChicks
{
    return sbChicks;
}

-(void) setChicks:(int)chicks
{
    sbChicks = chicks;
    [playUI setChicks:sbChicks];
}

-(void) setSecondsLeft:(float)secondsLeft
{
    [playUI setSecondsLeft:secondsLeft];
}

/*
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
*/

- (void) showMessage:(NSString*) message {
    [playUI showMessage:message];
}

-(void) showCombo:(int)combo
{
    if ( maxComboCount < combo )
        maxComboCount = combo;
    [playUI showCombo:combo];
}

///////////////////////////////////////////////////////////////
-(void) onPausePressed
{
    // BUGBUG : How about not playing the background music during the pause scene?
    // Get the parent Scene that has the current layer.

    // 'layer' is an autorelease object.
	GeneralScene *pauseLayer = [GeneralScene nodeWithSceneName:@"PauseLayer"];

    pauseLayer.actionListener = self;

    // BUGBUG make the current layer darker.
    
    // BUGBUG Disable touch on the current layer.
    
	// add layer as a child to scene
    [[DemoManager sharedDemoManager] replaceMenuLayer:pauseLayer];
    
    [self pauseGame];
}

///////////////////////////////////////////////////////////////
// TutorialBoardProtocol

-(void) showTutorialText:(NSString*) tutorialText
{
    assert(tutorialText);
    
    // Weak Ref
	tutorialLabel = [CCLabelBMFont labelWithString:tutorialText fntFile:@"yellow34.fnt"];
    assert(tutorialLabel);
    
	tutorialLabel.position = ccp(screenSize.width * 0.5, screenSize.height * 0.5);

	[self addChild:tutorialLabel];

    // blink the health bar. Blink three times a second.
    [tutorialLabel runAction:[CCBlink actionWithDuration:1000 blinks:3000]];

    [self pauseGame];
}

-(void)retryGame {
    // Move the hero to the new level and start the new level stage
    CCScene * newScene = [GeneralScene loadingSceneOfMap:mapName levelNum:level];
    [[CCDirector sharedDirector] replaceScene:[Util defaultSceneTransition:newScene] ];
}

///////////////////////////////////////////////////////////////
// GeneralMessageProtocol
-(void)onMessage:(NSString*) message
{
    // Resume : Sent by PauseLayer.svg
    if ( [message isEqualToString:@"Resume"] )
    {
        // Hide AD for the game Play.
        [[AdManager sharedAdManager] setVisible:NO];
        
        [self resumeGame];
    }
    
    if ( [message isEqualToString:@"Retry"] )
    {
        [self resumeGame];
        [self retryGame];
    }

    // Quit : Sent by PauseLayer.svg
    if ( [message isEqualToString:@"Quit"] )
    {
        [self resumeGame];
        [self giveUpGame:@"_giveup_"];
    }

    // PausePressed : Sent by GamePlayLayer.svg
    if ( [message isEqualToString:@"PausePressed"] )
    {
        // Show AD for the pause Scene.
        [[AdManager sharedAdManager] setVisible:YES];

        [self onPausePressed];
    }
    
    AppAnalytics::sharedAnalytics().beginEventProperty();
    AppAnalytics::sharedAnalytics().addStageNameEventProperty(mapName, level);
    AppAnalytics::sharedAnalytics().endEventProperty();
    
    AppAnalytics::sharedAnalytics().logEvent( "StageScene:"+[Util toStdString:message] );
}

///////////////////////////////////////////////////////////////

/** @brief If there is no playUI, it is in demo mode
 */
-(BOOL) isDemoMode {
    return playUI?NO:YES;
}


/** @brief See if we need to enable touch tutor. Touch tutor can be enabled only in level 1,2,3,4 in MAP01.
 Users can choose to enable or disable it in the Options menu.
*/
 
-(void) decideTouchTutorEnabled
{
    isTouchTutorEnabled = NO;
    if (![self isDemoMode] ) { // It is not a demo mode and
        if ([mapName isEqualToString:@"MAP01"] && level <=4 ) {
            isTouchTutorEnabled = [Util loadTouchTutor] ? YES:NO;
        }
    }
}

// initialize your instance here
-(id) initInMap:(NSString*)aMapName levelNum:(int)aLevel playUI:(GamePlayLayer*)aPlayUI
{
	if( (self=[super init])) 
	{
        // Disable refreshing ADs for the best performance.
        //[[AdManager sharedAdManager] disableRefresh];

        PROF_RESET_ALL();
        
        assert(aMapName);
        assert(aLevel>0);
        
        mapName = [aMapName retain];
        level = aLevel;
        playUI = [aPlayUI retain];
        
        gameObjectContainer = new GameObjectContainer();
        screenSize = [CCDirector sharedDirector].winSize;

        ticks = 0;
        
        isTouchTutorShown = NO;

        totalFrameCount = 0;
        
        isHardMode = [Util loadDifficulty] ? YES:NO;
        if ( [self isDemoMode] ) {
            // Make it run faster in demo mode by switching to hard mode.
            isHardMode = YES;
        }

        closingScene = nil;

        prevMapPosition_heroX = 0;
        
        sbChicks = 0;
        sbScore = 0;
        sbKeys = 0;
        // BUGBUG, this is the InitValue of the TxFloatLabel in GamePlayLayer.svg. Do we need to get it from there?
        sbSpeedRatio = 1.0;
        
        // initialize variables
        maxComboCount = 0;
        isGamePaused = NO;
        tutorialLabel = nil;
        worldGroundY = 0.0f;
        heroXatZ1_ofLastGameObjectRemoval = 0.0f;
        
        terrains = nil;
        
        stageCleared = NO;
        
        if (![self isDemoMode]) {
            // enable touches
            self.isTouchEnabled = YES;

            // enable accelerometer
            self.isAccelerometerEnabled = YES;
            [[UIAccelerometer sharedAccelerometer] setUpdateInterval:1/60];
        }
        
        int highScore = [Util loadHighScore:aMapName level:aLevel];
        [playUI setHighScore:highScore];

        assert( aLevel < MAX_LEVELS_PER_MAP );
        assert( MAX_LEVELS_PER_MAP < 99 );

        [self decideTouchTutorEnabled]; // Needs mapName and level.

        // The SVG file for the given level.
        NSString * svgFileName = [NSString stringWithFormat:@"StageScene_%@_%02d.svg", mapName, level];

        NSString * svgFilePath = [Util getResourcePath:svgFileName];
        
        // Read attributes from SVG file
        [self readAttributesFromSVG:svgFilePath];
        if ( [self isDemoMode] ) {
            playTimeSec = DEMO_MODE_PLAY_TIME_SEC;
        }
        // Assign the play time read from SVG file to the sbSecondsLeft variable that we decrease within tick function.
        sbSecondsLeft = (float)playTimeSec;
        sbRecentSecond = playTimeSec + 1; // To show playTimeSec on the score board, sbRecentSecond should be greater than playTimeSec.
        
        assert ( backgroundImage );
        sky = [[Sky skyWithTexture:backgroundImage size:CGSizeMake(backgroundImageWidth,backgroundImageHeight)] retain];
        [self addChild:sky];
        
        spriteSheet = [CCSpriteBatchNode batchNodeWithFile:@"sprites.pvr"];
        [self addChild:spriteSheet];

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
        [self calcMaxTerrains];
        
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
            
            // Attributes in the Bird layer in game_classes.svg are all set inside heroWithWorld
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

        // Initialize game kit
        GameKitHelper* gkHelper = [GameKitHelper sharedGameKitHelper];
		gkHelper.delegate = self;
        gkHelper.commDelegate = self;
        
        [playUI setHeroAlias:@"Me"];
        /*
        NSString * heroAlias = gkHelper.localPlayerAlias;
        if (heroAlias)
            [playUI setHeroAlias:heroAlias];
        */
        // Initialize score labels. (Requires spriteSheet);
        //[self initScoreLabels];
        
        [self schedule: @selector(tick:)];
	}
	return self;
}


+(id)nodeInMap:(NSString*)mapName levelNum:(int)level playUI:(GamePlayLayer*)playUI
{
    return [[[StageScene alloc] initInMap:mapName levelNum:level playUI:playUI] autorelease];
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

    AppAnalytics::sharedAnalytics().beginTimedEvent( "StageScene:Load");

    GamePlayLayer * gamePlayLayer = [GamePlayLayer layerWithSceneName:@"GamePlayLayer"];
    
	// 'layer' is an autorelease object.
	StageScene *stageLayer = [StageScene nodeInMap:mapName levelNum:level playUI:gamePlayLayer];
	
    // GamePlayLayer sends "PausePressed" message when users touch the sand clock in it.
    gamePlayLayer.actionListener = stageLayer;
    
	// add layer as a child to scene
	[scene addChild:stageLayer z:0 tag:StageSceneLayerTagStage];

    // add game play UI layer
	[scene addChild:gamePlayLayer z:1 tag:StageSceneLayerTagGamePlayUI];
    
    if ( [stageLayer needJoystick] )
    {
        // add the input layer that has a joystick and buttons
        InputLayer * inputLayer = [InputLayer node];
        [scene addChild:inputLayer z:2 tag:StageSceneLayerTagInput];
    }

    AppAnalytics::sharedAnalytics().beginEventProperty();
    AppAnalytics::sharedAnalytics().addStageNameEventProperty(mapName, level);
    AppAnalytics::sharedAnalytics().endEventProperty();
    
    AppAnalytics::sharedAnalytics().endTimedEvent( "StageScene:Load");

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

-(void) accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration {
    static int shakeCount = 0;
    
    if (acceleration.x > SHAKE_DEVICE_ACC_THRESHOLD || acceleration.x < -SHAKE_DEVICE_ACC_THRESHOLD || 
        acceleration.y > SHAKE_DEVICE_ACC_THRESHOLD || acceleration.y < -SHAKE_DEVICE_ACC_THRESHOLD ||
        acceleration.z > SHAKE_DEVICE_ACC_THRESHOLD || acceleration.z < -SHAKE_DEVICE_ACC_THRESHOLD) {
        
        if (shakeCount == 0) {
            if (sbChicks > 0) {
                // Boost the speed of Hero
                [hero boostSpeed];
                
                // Decrease the number of chicks saved
                sbChicks--;
                [playUI setChicks:sbChicks];
                
                // Show particle
                [hero addSaveChickParticle];
            }
            shakeCount ++;
        }
    }
    else {
        shakeCount = 0;
    }
}

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
    // For optimization, we have static variable here rather than using screenSize
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
            {
                newZoom = cam.zoom + cam.zoom * ZOOM_DELTA_RATIO;
                // the new zoom should not go beyond the target zoom
                assert( targetZoom >= newZoom );
            }
            else
            {
                newZoom = cam.zoom - cam.zoom * ZOOM_DELTA_RATIO;
                // the new zoom should not go beyond the target zoom
                assert( targetZoom <= newZoom);
            }
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
        static float onScreenBackgroundImageWidth = backgroundImageHeight*screenSize.width/screenSize.height;
        // -50 is an workaround for not showing the outside area of the right border of the background image.
        static float maxOffsetX = (backgroundImageWidth - onScreenBackgroundImageWidth) - 50;
        static float heroOffsetOnScreen = screenSize.width * HERO_XPOS_RATIO;
        // The hero can go three screens further from the last terrain. 
        static float maxHeroX_withoutZoom = (terrainMaxX + screenSize.width * 3);
        float offsetX = (heroX_withoutZoom-heroOffsetOnScreen)/maxHeroX_withoutZoom * maxOffsetX;
        
        [sky setOffsetX:offsetX];
        [sky setScale:1.0f-(1.0f-cam.zoom)*0.30f];
    }
}

// Convert the distance between the Hero and terrain to the border vertice index in terrain.
// The higher the Hero, we need to look ahead more, because the Hero is likely to land further.
#define HERO_HEIGHT (30)
// The X distance between border vertices in level svg file.
#define TERRAIN_BORDER_INDEX_DIST_IN_PIXCELS (40)
// The hero can land on the ground by going to x axis by 15% of it's distance from terrain
#define HERO_DROP_X_PER_Y_RATIO (0.15)
//#define TERRAIN_BORDER_INDEX_DIST_IN_METERS ((TERRAIN_BORDER_INDEX_DIST_IN_PIXCELS)/(INIT_PTM_RATIO))
#define HERO_DISTANCE_TO_LOOKAHEAD_INDEX(HeroDist) ((HeroDist) * HERO_DROP_X_PER_Y_RATIO / (TERRAIN_BORDER_INDEX_DIST_IN_PIXCELS))

/** @brief process to see if we need to show touch tutor.
 */
-(void) processTouchTutor:(Terrain*)t heroY:(float)heroY_withoutZoom autoPlay:(BOOL)autoPlay{
    // Calculate the distance between the hero and the terrain (in meters).
    float terrainY;
    if ( [t terrainYatHero:&terrainY] ) {
        float heroDistence = heroY_withoutZoom - HERO_HEIGHT - terrainY;
        if (heroDistence < 0.0f)
            heroDistence = 0.0;

        int lookAheadIndex = (int) HERO_DISTANCE_TO_LOOKAHEAD_INDEX(heroDistence);
        
//        CCLOG(@"HeroY=%f, terrainY:%f, dist=%f, lookAheadIndex=%d", heroY_withoutZoom, terrainY, heroDistence, lookAheadIndex);
        
        if ( heroDistence < 10 ) { // BUGBUG : Currently we show touch tutor only when the Hero is on the ground.
            if ([t isDownHill:lookAheadIndex]) {
                if ( ! isTouchTutorShown ) {
                    [playUI showTouchTutor:YES];
                    
                    isTouchTutorShown = YES;
                }
                
                if (autoPlay && !self.hero.diving)
                    self.hero.diving = YES;
            }
            else {
                if ( isTouchTutorShown ) {
                    [playUI showTouchTutor:NO];
                    isTouchTutorShown = NO;
                }
                
                if (autoPlay && self.hero.diving)
                    self.hero.diving = NO;
            }
        }
    }
}
/** @brief Activate, move, scale terrains based on the current hero position.
 */
-(float) adjustTerrains:(float)heroX_withoutZoom heroY:(float)heroY_withoutZoom{
    static int screenW = [CCDirector sharedDirector].winSize.width;
    float groundY = kMAX_POSITION;
    // The MAX(borderMinY) where the terrain is below the hero and the hero is within the drawing range of the terrain.
    float maxTerrainY_belowHero = -kMAX_POSITION;
    
    
    //if (hero)
    {
        /////////////////////////////////////////////
        // Step1 : Adjust Terrains
        // When the camera is above the sea level(y=0), cam.cameraPosition contains negative offsets to subtract from sprites position.
        // Convert it back to the y offset from sea level.
        float cameraOffsetY = -cam.cameraPosition.y;
        
        static float heroOffsetX_atZoom1 = screenW * HERO_XPOS_RATIO;
        // key points interval for drawing
        // _offsetX seems to be Hero's offset which is on the left side of the screen by 1/8 of screen width
        // The left side that went out of screen can come back to screen when the screen is zoomed out quickly. 
        // So we don't use self.scale but use MIN_ZOOM_RATIO to calculate the left side to draw
        float leftSideX = heroX_withoutZoom - heroOffsetX_atZoom1 / MIN_ZOOM_RATIO;
        
        static float rightSideFromHero = screenW*(1.0f - HERO_XPOS_RATIO);
        
        float rightSideX = heroX_withoutZoom + rightSideFromHero / cam.zoom;
        
        // Don't scale cameraOffsetY, because it is for shifting camera offset.
        CGPoint terrainPosition = ccp( -heroX_withoutZoom*cam.zoom + heroOffsetX_atZoom1, -cameraOffsetY /* Caution: should not scale cameraOffsetY */);
        
        for(Terrain * t in terrains) {
            // Skip terrains that are not shown at all.
            if ( [t borderMaxX] < leftSideX ||
                 [t borderMinX] > rightSideX )
                continue;
            
            t.scale = cam.zoom;
            
            [t setHeroX:heroX_withoutZoom position:terrainPosition windowLeftX:leftSideX windowRightX:rightSideX];
            
            float borderMinY = [t calcBorderMinY];
                
            if ( [t isBelowHero:heroY_withoutZoom] )
            {
                if ( maxTerrainY_belowHero < borderMinY)
                    maxTerrainY_belowHero = borderMinY;

                if (isTouchTutorEnabled) {
                    [self processTouchTutor:t heroY:heroY_withoutZoom autoPlay:NO];
                }
                // BUGBUG : Not using isDemoMode for performance optimization not to send messages to self.
                if ( !playUI) {
                    [self processTouchTutor:t heroY:heroY_withoutZoom autoPlay:YES];                    
                }
            }
                
            if ( borderMinY != kMAX_POSITION ) // The terrain is drawn on the current screen.
            {
                if ( groundY > borderMinY )
                    groundY = borderMinY;
            }
        }
    }

    // Is the hero on a terrain which is far enough from the ground?
    if ( maxTerrainY_belowHero > groundY + GROUND_TO_NEWGROUND_GAP )
        return maxTerrainY_belowHero;

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
        std::deque<GameObject*> v;
        v = gameObjectContainer->getCollidingObjects(heroContentBox);
        
        for (std::deque<GameObject*>::iterator it = v.begin(); it != v.end(); it++)
        {
            GameObject * refGameObject = *it;
            
            refGameObject->onCollideWithHero( hero );
        }
    }
}

-(void) gotoLevelMapWithFail
{
    // IF the level is cleared, the next level is unlocked.
    // IF the level is not cleared(the Hero is dead), go back to level map scene.
    CCScene * levelMapScene = [LevelMapScene sceneWithName:mapName level:level cleared:NO];
    assert(levelMapScene);
    
    [[CCDirector sharedDirector] replaceScene:[Util defaultSceneTransition:levelMapScene]];

    CCLOG(@"gotoLevelMap:end");
}

/** @brief push the "Stage Clear" scene.
 */
-(void)onStageFail:(id)sender data:(void*)callbackData 
{

    [self gotoLevelMapWithFail];
    
    CCLOG(@"onStageFail:data");
}

/** @brief Calculate the number of stars based on the chicks saved in the stage and star counts defined in the level svg file 
 */
-(int)calcStars {
    int stars = 0;
    if (sbScore >= threeStarCount)
    {
        stars = 3;
    }
    else if (sbScore >= twoStarCount)
    {
        stars = 2;
    }
    else if (sbScore >= oneStarCount)
    {
        stars = 1;
    }
    return stars;
}

/** @brief Replace to the "Stage Clear" scene.
 */
-(void)onStageClear:(id)sender data:(void*)callbackData 
{
    
    BOOL isLastStage = closingScene?YES:NO;
    
    // Convert time left(seconds) to score only in the Hard Mode.
    if ( [Util loadDifficulty] ) // Difficulty == 1 means Hard
    {
        // Increase score
        sbScore += ((int)sbSecondsLeft)*SCORE_PER_SECOND_FOR_HARD_MODE;
    }
    else
    {
        // Increase score
        sbScore += ((int)sbSecondsLeft)*SCORE_PER_SECOND_FOR_EASY_MODE;
    }
    
    int stars = [self calcStars];
    
    // 'layer' is an autorelease object.
	CCScene *nextScene = [ClearScene sceneWithMap:mapName 
                                             level:level 
                                         lastStage:isLastStage
                                             score:sbScore 
                                              keys:sbKeys 
                                            chicks:sbChicks 
                                             stars:stars 
                                          maxCombo:maxComboCount
                                         timeSpent:(playTimeSec-sbSecondsLeft)
                                          timeLeft:sbSecondsLeft];
    
//    [self checkAchieve
    
    if ( closingScene )
    {
        CCScene * theClosingScene = [IntermediateScene sceneWithName:closingScene nextScene:nextScene];
        nextScene = theClosingScene; 
    }
    
    [[CCDirector sharedDirector] replaceScene:nextScene];

    CCLOG(@"onStageClear:data");
}


-(void)onDemoNextStage:(id)sender data:(void*)callbackData 
{
    
    [[DemoManager sharedDemoManager] runNextDemo];
    
    CCLOG(@"onDemoNextStage:data");
}


/** @brief Show a big title on the center of the screen for 2 seconds, switch back to level map scene.
 */
- (void) finishStageWithMessage:(NSString*)message stageCleared:(BOOL)clearedCurrentStage{
    // By default we wait for 3 seconds before switching to the next scene.
    float sceneTransitionWaitSec = 3.0f;
    
    if ( ! clearedCurrentStage ) {
        // Don't do any animation, but simply proceed with stage failure to go to map selection scene. 
        if ( [message isEqualToString:@"_giveup_"] ) {
            [self onStageFail:self data:nil];
            return;
        }
    }
    
    
	CCLabelBMFont *label = [CCLabelBMFont labelWithString:message fntFile:@"yellow34.fnt"];
	label.position = ccp(screenSize.width/2, screenSize.height/2);
    label.scale = 1.0;

    id lastAction = nil;
    if ( clearedCurrentStage )
    {
        // Instead of showing label, show stage clear animation
        [label setString:@""]; 
        if ( [self isDemoMode] ) {
            lastAction = [CCCallFuncND actionWithTarget:self selector:@selector(onDemoNextStage:data:) data:(void*)nil];
        }
        else
        {
            lastAction = [CCCallFuncND actionWithTarget:self selector:@selector(onStageClear:data:) data:(void*)nil];
            
            [playUI startStageClearAnim];
            
            // Wait more to show stars particle for longer time...
            sceneTransitionWaitSec = 6.0;
        }
    }
    else
    {
        if ( [message isEqualToString:@"_timeout_"] ) {
            // Instead of showing label, show stage timeout animation
            [label setString:@""]; 
            [playUI startStageTimeoutAnim];
        }
        
        if ( [self isDemoMode] ) {
            lastAction = [CCCallFuncND actionWithTarget:self selector:@selector(onDemoNextStage:data:) data:(void*)nil];
        } else {
            lastAction = [CCCallFuncND actionWithTarget:self selector:@selector(onStageFail:data:) data:(void*)nil];
            
            AppAnalytics::sharedAnalytics().beginEventProperty();
            AppAnalytics::sharedAnalytics().addStageNameEventProperty(mapName, level);
            AppAnalytics::sharedAnalytics().addDeviceProperties();
            float timeSpent = (playTimeSec-sbSecondsLeft);
            if (timeSpent) {
                float averageFPS = totalFrameCount/timeSpent;
                AppAnalytics::sharedAnalytics().addEventProperty("averageFPS", averageFPS);
                NSLog(@"averageFPS=%f\n", averageFPS);
            }
            AppAnalytics::sharedAnalytics().endEventProperty();
            
            AppAnalytics::sharedAnalytics().logEvent( "StageScene:Failed:"+[Util toStdString:message] );
        }
    }
    
	[label runAction:[CCSequence actions:
                      [CCScaleTo actionWithDuration:sceneTransitionWaitSec scale:2.0f],
                      [CCCallFuncND actionWithTarget:label selector:@selector(removeFromParentAndCleanup:) data:(void*)YES],
                      lastAction,
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
    if (gaveUpStage) {
        return;
    }
    
    float heroY;
    if (hero)
        heroY = hero.body->GetPosition().y;
    if (car)
        heroY = car->getBody()->GetPosition().y;
    
    if ( heroY < groundY_worldSystem - HERO_DEAD_GAP_WORLD_Y ) {
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
    if (gaveUpStage) {
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
    if ( [self isDemoMode] ) {
        // awake the hero if it is demo mode.
        [self.hero wake];
    }
    else {
        if (!didPlayMusic) // Play music only once. We need it because this function is called whenever OptionScene, HelpScene in PauseScene is popped. We don't want the music to play start again whenever the game resumes from the PauseScene.
        {
            if (musicFileName)
            {
                [Util playBGM:musicFileName];
            }
            didPlayMusic = YES;
        }

        // When the game is paused, we still show the AD. 
        // This function is called when the Option or Help scene is popped and came back to the StageScene to show the pause layer while to game is in puase.
        if (!isGamePaused) { 
            // Hide ADs during game play.
            [[AdManager sharedAdManager] setVisible:NO];
        }
    }
    
    [super onEnterTransitionDidFinish];
}

- (void) onExit {

    // Hide ADs during game play.
    [[AdManager sharedAdManager] setVisible:YES];

    [super onExit];
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
        gameObjectContainer->removeCollidingObjects(goneScreenBox);
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
        std::deque<GameObject*> v;
        v = gameObjectContainer->getCollidingObjects(commingScreenBox);
        
        for (std::deque<GameObject*>::iterator it = v.begin(); it != v.end(); it++)
        {
            GameObject* pGameObject = *it;
            
            // TutorialBox is an example of Passive Game Object : No need to update sprite position on screen. Nothing to animate
            if ( ! pGameObject->isPassive() )
            {
                // If it is not active yet, (It is the first time to come into the commingScreenBox)
                if ( ! pGameObject->isActivated() )
                {
                    // Activate it
                    pGameObject->activate( self );
                }

                // update the sprite position, scale, rotation based on the game object and camera position considering zoom level.
                [cam updateSpriteFromGameObject: pGameObject ];
            }
        }    
    }
}

/** @brief Show the time left, Decrease the time counter, Check if the time is up.
 */
-(void) checkTimeOut:(ccTime) dt
{
    if (sbRecentSecond > 0)
    {
        int newSecond = (int) sbSecondsLeft;
        if ( newSecond < sbRecentSecond )
        {
            if (newSecond < 0)
                newSecond = 0;
            sbRecentSecond = newSecond;
            [self setSecondsLeft:(float)sbRecentSecond];
        }
    }

    if ( !stageCleared) {
        sbSecondsLeft -= dt;
    }

    if ( sbSecondsLeft < 0.0f ) // Time is up!
    {
        [self giveUpGame:@"_timeout_"];
    }
}

/** Get the map progress percentage given the hero X position.
 */
-(int)getMapProgress:(float)heroX_withoutZoom {
    int mapProgress = (int) (heroX_withoutZoom * 100 / terrainMaxX);
    if (mapProgress > 100)
        mapProgress = 100;
    return mapProgress;
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

    // In the first frame, show match maker if in multiplay mode
    if (ticks == 0) {
        if ( [GameState sharedGameState].playerFlag == GF_MultiplayInitiator ) { // MultiPlay?
            [self showMatchMaker];
        }
    }
    ticks ++;

    // if the game is paused, dont' update the game frame. 
    assert (!isGamePaused);
    
PROF_BEGIN(stage_tick_adjustZoomWithGroundY);
    // TODO : Understaind why the terrain is not adjusted correctly if we adjust zoom when the hero is sleeping.
    if ( [hero awake] )
    {
        [self adjustZoomWithGroundY:worldGroundY];
    }
PROF_END(stage_tick_adjustZoomWithGroundY);

PROF_BEGIN(stage_tick_updateFollowPosition);
	[cam updateFollowPosition];
PROF_END(stage_tick_updateFollowPosition);

PROF_BEGIN(stage_tick_adjustTerrains);
    float heroX_withoutZoom;
    float heroY_withoutZoom;
    
    if (hero) {
        heroX_withoutZoom = hero.body->GetPosition().x * INIT_PTM_RATIO;
        heroY_withoutZoom = hero.body->GetPosition().y * INIT_PTM_RATIO;
    }
    if (car) {
        heroX_withoutZoom = car->getBody()->GetPosition().x * INIT_PTM_RATIO;
        heroY_withoutZoom = car->getBody()->GetPosition().y * INIT_PTM_RATIO;
    }

    // groundY will be used in the next tick to decide the zoom level.
    float screenGroundY_withoutZoom = [self adjustTerrains:heroX_withoutZoom heroY:heroY_withoutZoom];

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
    float worldStepTime ;
    if ( isHardMode)
        worldStepTime = sbSpeedRatio * HARD_MODE_FRAME_DURATION_SEC;
    else
        worldStepTime = sbSpeedRatio * EASY_MODE_FRAME_DURATION_SEC;
    
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
    [playUI update:dt];
    
    if ([hero awake]) { // start reducing the time left only if the hero is awake.
        // See if the time is up.
        [self checkTimeOut:dt];
        totalFrameCount++;
    }
    else {
        [self setSecondsLeft:(float)sbRecentSecond];
    }

    // Show the map position with 1/100 scale
    if ( heroX_withoutZoom - prevMapPosition_heroX > 100 )
    {
        int mapProgress =  [self getMapProgress:heroX_withoutZoom];
        
        // BUGBUG : DO OPT
//        prevMapPosition_heroX = heroX_withoutZoom;
        [playUI setMapProgress:mapProgress];
    }
PROF_END(stage_tick_update_labels);
    
    // Send position 4 times a second. 
    // (Send once per 16 frames. Assuming we are running 60 frames, we send the player position four times a sec.)  
    if ( (ticks & 0x0F) == 0 ) {
        [self sendPosition:ccp(heroX_withoutZoom,heroY_withoutZoom)];
//        [playUI updateMyProgress:mapProgress];
    }
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

// Called by TxWidget when the value of the widget changes. 
// Ex> If the scene definition SVG contains TxToggleButton, this is called whenever the button is toggled. 
// Ex> If the scene definition SVG contains TxSlideBar, this is called whenever the sliding button is dragged. 
-(void)onWidgetAction:(TxWidget*)sender
{
    // By default, do nothing.
}

#pragma mark GameKitHelper delegate methods
-(void) onLocalPlayerAuthenticationChanged
{
	GKLocalPlayer* localPlayer = [GKLocalPlayer localPlayer];
	CCLOG(@"LocalPlayer isAuthenticated changed to: %@", localPlayer.authenticated ? @"YES" : @"NO");
	
	if (localPlayer.authenticated)
	{
		GameKitHelper* gkHelper = [GameKitHelper sharedGameKitHelper];
		[gkHelper getLocalPlayerFriends];
        [playUI setHeroAlias:localPlayer.alias];
		//[gkHelper resetAchievements];
	}	
}

-(void) onFriendListReceived:(NSArray*)friends
{
	CCLOG(@"onFriendListReceived: %@", [friends description]);
	GameKitHelper* gkHelper = [GameKitHelper sharedGameKitHelper];
	[gkHelper getPlayerInfo:friends];
}

-(void) showMatchMaker {
	GameKitHelper* gkHelper = [GameKitHelper sharedGameKitHelper];
    
    GKMatchRequest* request = [[[GKMatchRequest alloc] init] autorelease];
	request.minPlayers = 2;
	request.maxPlayers = 4;
	
	//GameKitHelper* gkHelper = [GameKitHelper sharedGameKitHelper];
	[gkHelper showMatchmakerWithRequest:request];
	[gkHelper queryMatchmakingActivity];
}

-(void) onPlayerInfoReceived:(NSArray*)players
{
	CCLOG(@"onPlayerInfoReceived: %@", [players description]);
	//[gkHelper submitScore:1234 category:@"Playtime"];
	
	//[gkHelper showLeaderboard];
    
    // Don't show matchmaker.
    //[self showMatchMaker];
}

-(void) onScoresSubmitted:(bool)success
{
	CCLOG(@"onScoresSubmitted: %@", success ? @"YES" : @"NO");
}

-(void) onScoresReceived:(NSArray*)scores
{
	CCLOG(@"onScoresReceived: %@", [scores description]);
}

-(void) onAchievementReported:(GKAchievement*)achievement
{
	CCLOG(@"onAchievementReported: %@", achievement);
}

-(void) onAchievementsLoaded:(NSDictionary*)achievements
{
	CCLOG(@"onLocalPlayerAchievementsLoaded: %@", [achievements description]);
}

-(void) onResetAchievements:(bool)success
{
	CCLOG(@"onResetAchievements: %@", success ? @"YES" : @"NO");
}

-(void) onLeaderboardViewDismissed
{
	CCLOG(@"onLeaderboardViewDismissed");
}

-(void) onAchievementsViewDismissed
{
	CCLOG(@"onAchievementsViewDismissed");
}

-(void) onReceivedMatchmakingActivity:(NSInteger)activity
{
	CCLOG(@"receivedMatchmakingActivity: %i", activity);
}

-(void) onMatchFound:(GKMatch*)match
{
	CCLOG(@"onMatchFound: %@", match);
}

-(void) onPlayersAddedToMatch:(bool)success
{
	CCLOG(@"onPlayersAddedToMatch: %@", success ? @"YES" : @"NO");
}

-(void) onMatchmakingViewDismissed
{
	CCLOG(@"onMatchmakingViewDismissed");
}
-(void) onMatchmakingViewError
{
	CCLOG(@"onMatchmakingViewError");
}

-(void) onPlayerConnected:(NSString*)playerID
{
	CCLOG(@"onPlayerConnected: %@", playerID);
}

-(void) onPlayerDisconnected:(NSString*)playerID
{
	CCLOG(@"onPlayerDisconnected: %@", playerID);
}

-(void) onStartMatch
{
	CCLOG(@"onStartMatch");
}

// TM16: handles receiving of data, determines packet type and based on that executes certain code
-(void) onReceivedData:(NSData*)data fromPlayer:(NSString*)playerID
{
	SBasePacket* basePacket = (SBasePacket*)[data bytes];
	CCLOG(@"onReceivedData: %@ fromPlayer: %@ - Packet type: %i", data, playerID, basePacket->type);
    //BUGBUG : uncomment
/*	
	switch (basePacket->type)
	{
		case kPacketTypeScore:
		{
			SScorePacket* scorePacket = (SScorePacket*)basePacket;
			CCLOG(@"\tscore = %i", scorePacket->score);
			break;
		}
		case kPacketTypePosition:
		{
			SPositionPacket* positionPacket = (SPositionPacket*)basePacket;
			CCLOG(@"\tposition = (%.1f, %.1f)", positionPacket->position.x, positionPacket->position.y);
			
			// instruct remote players to move their tilemap layer to this position (giving the impression that the player has moved)
			// this is just to show that it's working by "magically" moving the other device's screen/player
			if (playerID != [GKLocalPlayer localPlayer].playerID)
			{
//                [self sendPosition:ccp(heroX_withoutZoom,heroY_withoutZoom)];
                int mapProgress =  [self getMapProgress:positionPacket->position.x];

                [playUI setProgress:mapProgress position:positionPacket->position player:(NSString*)playerID];
                
//				CCTMXTiledMap* tileMap = (CCTMXTiledMap*)[self getChildByTag:TileMapNode];
//				[self centerTileMapOnTileCoord:positionPacket->position tileMap:tileMap];
 
			}
			break;
		}
		default:
			CCLOG(@"unknown packet type %i", basePacket->type);
			break;
	}
 */
}

// TM16: send a bogus score (simply an integer increased every time it is sent)
-(void) sendScore
{
	if ([GameKitHelper sharedGameKitHelper].currentMatch != nil)
	{
/** // BUGBUG uncomment		
		SScorePacket packet;
		packet.type = kPacketTypeScore;
		packet.score = sbScore;
		
		[[GameKitHelper sharedGameKitHelper] sendDataToAllPlayers:&packet length:sizeof(packet)];
*/
    }
}

// TM16: send a tile coordinate
-(void) sendPosition:(CGPoint)playerPos
{
	if ([GameKitHelper sharedGameKitHelper].currentMatch != nil)
	{
		SPositionPacket packet;
		packet.type = kPacketTypePosition;
		packet.position = playerPos;
		
		[[GameKitHelper sharedGameKitHelper] sendDataToAllPlayers:&packet length:sizeof(packet)];
	}
}


// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
    CCLOG(@"StageScene:dealloc");
    
    GameKitHelper* gkHelper = [GameKitHelper sharedGameKitHelper];
    gkHelper.delegate = nil;
    gkHelper.commDelegate = [GameState sharedGameState];

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
// BUGBUG : Rethink if it is ok to comment this.
//    instanceOfStageScene = nil;
    
    [playUI release];
    [mapName release];
    [musicFileName release];
    [backgroundImage release];
    [groundTexture release];
    [closingScene release];

    delete gameObjectContainer;
    gameObjectContainer = NULL;
    
    // Enable refreshing ADs for the best performance.
    //[[AdManager sharedAdManager] enableRefresh];

	// don't forget to call "super dealloc"
	[super dealloc];
}


@end
