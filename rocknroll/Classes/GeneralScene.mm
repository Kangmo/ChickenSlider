#import "GeneralScene.h"
#import "svgLoader.h"
#import "Util.h"
#import "RetainCountTrace.h"
#import "b2WorldEx.h"
#import "InteractiveSprite.h"
#import "StageScene.h"
//#import "RetainCountTrace.h"

@implementation GeneralScene

@synthesize actionListener;
@synthesize loadingLevel;
@synthesize loadingLevelMapName;

//SYNTESIZE_TRACE(GeneralScene)

#define SCROLL_FACTOR (10.0f)

// initialize your instance here
-(id) initWithSceneName:(NSString*)sceneName
{
	if( (self=[super init])) 
	{
        sceneName_ = [sceneName retain];
        
        NSString * svgFileName = [sceneName stringByAppendingString:@".svg"];
        NSString * svgFilePath = [Util getResourcePath:svgFileName];

        NSString * backgroundFileName = [sceneName stringByAppendingString:@".png"];
    
        // ask director the the window size
        CGSize size = [[CCDirector sharedDirector] winSize];
        
        // Set background
        {
            
            CCSprite * bg = [CCSprite spriteWithFile:backgroundFileName];
            
            // Some layers such as GamePlayLayer does not have the background image file.
            if (bg)
            {
                // position the label on the center of the screen
                bg.position =  ccp( size.width /2 , size.height/2 );
                
                [self addChild:bg z:0];
            }
 
        }
        
        // Parse svg file
        {
            svgLoader * loader = [[svgLoader alloc] initWithWorld:nil andStaticBody:nil andLayer:self widgets:&widgetContainer_ terrains:nil gameObjects:NULL scoreBoard:nil tutorialBoard:nil];

            [loader instantiateObjectsIn:svgFilePath];
            
            [loader release];
        }
        
        NSString * backgroundImageFile = nil;
        // Load attributes from the svg file.
        {
            NSData *data = [NSData dataWithContentsOfFile:svgFilePath]; 
            assert(data);
            CXMLDocument *svgDocument  = [[[CXMLDocument alloc] initWithData:data options:0 error:nil] autorelease];
            assert(svgDocument);
            CXMLElement * rootElement = [svgDocument rootElement];
            
            backgroundMusic_ = [[Util getStringValue:rootElement name:@"_backgroundMusic" defaultValue:nil] retain];
            backgroundImageFile = [[Util getStringValue:rootElement name:@"_backgroundImage" defaultValue:nil] retain];
            NSString * scrollbackgroundOnce = [[Util getStringValue:rootElement name:@"_scrollBackgroundOnce" defaultValue:nil] retain];
            
            if (scrollbackgroundOnce)
                loopParallax_ = NO;
            else
                loopParallax_ = YES;
        }

        if (backgroundImageFile) // If the background image file is specified, do infinite scrolling
        {
            parallaxNode_ = [CCParallaxNode node];
            parallexPosition_ = CGPointZero;
            
            CCSprite * backgroundSprite = [CCSprite spriteWithFile:backgroundImageFile];
            backgroundSprite.anchorPoint = ccp(0,0);
            [parallaxNode_ addChild:backgroundSprite z:-1 parallaxRatio:ccp(1/SCROLL_FACTOR,1/SCROLL_FACTOR) positionOffset:CGPointZero];
            [self addChild:parallaxNode_ z:-1 tag:0];
            [self schedule:@selector(step:)];
        }

        self.actionListener = nil;
        
        self.loadingLevel = 0;
        self.loadingLevelMapName = nil;
        loadingProgress_ = nil;
        didStartLoading_ = NO;
    }
    return self;
}

- (void) step:(ccTime)dt {
    
    if (loopParallax_)
    {
        // BUGBUG : iPad : Change 480 to 1024
        if (parallexPosition_.x < -480*SCROLL_FACTOR ) // Reached half of the image?
        {
            // Go back to start.
            parallexPosition_.x = 0;
        }
        else
        {
            parallexPosition_.x -= dt*16*SCROLL_FACTOR; // 16 pixcels per second
        }
    }
    else
    {
        // Scroll only once.
        // BUGBUG : iPad : Change 480 to 1024
        if (parallexPosition_.x >= -480*SCROLL_FACTOR )
        {
            parallexPosition_.x -= dt*16*SCROLL_FACTOR; // 16 pixcels per second
        }
    }
    
    [parallaxNode_ setPosition: parallexPosition_];
}

- (void) onEnterTransitionDidFinish {
    if ( backgroundMusic_ )
    {
        [Util playBGM:backgroundMusic_];
    }
    
    [super onEnterTransitionDidFinish];
}

// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
    CCLOG(@"GeneralScene:dealloc");

    // Do not stop music. 
    // Scenes that are replaced play music. If the music file is same, the same music is played continuously.
    // Scenes that are pushed does not play any music. This is not to start any music during "game pause", which pushes Scenes like "Options", or "Help". That's because we don't stop playing music when the scene is removed.
    
    [backgroundMusic_ release];

    [self unscheduleAllSelectors];
    
    [loadingProgress_ stop];
    [loadingProgress_ release];
    loadingProgress_ = nil;
    
    for (id child in self.children) {
        if ([child isKindOfClass:[InteractiveSprite class]])
        {
            InteractiveSprite * intrSprite = (InteractiveSprite*) child;
            [intrSprite removeFromTouchDispatcher];
        }
    }
    
    self.loadingLevelMapName = nil;
    [sceneName_ release];
    
	// don't forget to call "super dealloc"
	[super dealloc];
}

-(void)addLoadingProgress
{
    // should be called only once.
    assert(!loadingProgress_);
    
    loadingProgress_ = [[ProgressCircle alloc] init];
    assert(loadingProgress_);
    [self addChild:loadingProgress_];
    loadingProgress_.position = [Util getCenter:self]; 
    [loadingProgress_ start];
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
	[scene addChild:layer z:0 tag:GeneralSceneLayerTagMain];
	
	// return the scene
	return scene;
}

// Create a loading scene that will again replace the scene to a new StageScene with the given map and level.
+(CCScene*)loadingSceneOfMap:(NSString*)mapName levelNum:(int)level
{
    assert(mapName);
    assert(level>0);
    
    // 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	GeneralScene *layer = [GeneralScene nodeWithSceneName:@"LoadingScene"];
	layer.loadingLevelMapName = mapName;
    layer.loadingLevel = level;
    // Add the progress circle for loading scene.
    [layer addLoadingProgress];
    // Should wait a frame to get the loading scene displayed on the screen.
    [layer scheduleUpdate];
	// add layer as a child to scene
	[scene addChild:layer z:0 tag:GeneralSceneLayerTagMain];

	// return the scene
	return scene;
}

-(void) loadingThread:(id)unused
{
    // Arguments to the loading Scene should have been specified.
    assert ( self.loadingLevel > 0 );
    assert ( self.loadingLevelMapName );
    
    CCScene * newScene = [StageScene sceneInMap:self.loadingLevelMapName levelNum:self.loadingLevel];
    [[CCDirector sharedDirector] replaceScene:[Util defaultSceneTransition:newScene]];
}

-(void) update:(ccTime)delta
{
    // should not unschedule, because a child node, progress circle is running scheduled update.
    if ( ! didStartLoading_ )
    {
        // Start the loading thread
        //[NSThread detachNewThreadSelector:@selector(loadingThread:) toTarget:self withObject:nil];
        
        // Can' use multiple threads because OpenGL calls are not thread safe.
        [self loadingThread:nil];

        didStartLoading_ = YES;
    }
}

-(void) onMessage:(NSString*)message 
{
    // PauseLayer.svg receives "Quit" message from ConfirmQuitLayer.svg
    if ( [message isEqualToString:@"Quit"] )
    {
        assert(self.actionListener);
        
        // Relay the message to StageScene
        [self.actionListener onMessage:@"Quit"];

        // We need to remove current layer(pause layer) first.
        [self removeFromParentAndCleanup:YES];
    }
}

// Called by TxWidget when the value of the widget changes. 
// Ex> If the scene definition SVG contains TxToggleButton, this is called whenever the button is toggled. 
// Ex> If the scene definition SVG contains TxSlideBar, this is called whenever the sliding button is dragged. 
-(void)onWidgetAction:(TxWidget*)sender
{
    // By default, do nothing.
}

/** @brief Called by AD-Whirl. Simply do nothing for GeneralScene, which is a screen for showing menus.
 */
-(void) pauseGame {
}

/** @brief Called by AD-Whirl. Simply do nothing for GeneralScene, which is a screen for showing menus.
 */
-(void) resumeGame {
}
//SYNTESIZE_TRACE(GeneralScene)

@end
