#import "GeneralScene.h"
#import "svgLoader.h"
#import "Util.h"
#import "RetainCountTrace.h"
#import "b2WorldEx.h"
#import "InteractiveSprite.h"
#import "StageScene.h"
#include "AppAnalytics.h"
//#import "RetainCountTrace.h"
#include "AdManager.h"
#import "DemoManager.h"

@implementation GeneralScene

@synthesize actionListener;
@synthesize loadingLevel;
@synthesize loadingLevelMapName;
@synthesize layerName = sceneName_;

//SYNTESIZE_TRACE(GeneralScene)

#define SCROLL_FACTOR (10.0f)

// initialize your instance here
-(id) initWithSceneName:(NSString*)sceneName
{
	if( (self=[super init])) 
	{
        
        tryToRefreshAD_ = YES;
        
        widgetContainer_ = new TxWidgetContainer();

        const std::string sceneNameStdStr = [Util toStdString:sceneName]; 
        AppAnalytics::sharedAnalytics().logEvent( sceneNameStdStr );
        
        sceneName_ = [sceneName retain];
        
        NSString * svgFileName = [sceneName stringByAppendingString:@".svg"];
        NSString * svgFilePath = [Util getResourcePath:svgFileName];

        
        // Parse svg file
        {
            svgLoader * loader = [[svgLoader alloc] initWithWorld:nil andStaticBody:nil andLayer:self widgets:widgetContainer_ terrains:nil gameObjects:NULL scoreBoard:nil tutorialBoard:nil];

            [loader instantiateObjectsIn:svgFilePath];
            
            [loader release];
        }
        
        NSString * sceneImageFile = nil;
        NSString * backgroundImageFile = nil;
        // Load attributes from the svg file.
        {
            NSData *data = [NSData dataWithContentsOfFile:svgFilePath]; 
            assert(data);
            CXMLDocument *svgDocument  = [[[CXMLDocument alloc] initWithData:data options:0 error:nil] autorelease];
            assert(svgDocument);
            CXMLElement * rootElement = [svgDocument rootElement];
            
            showDemoStage_ =  [Util getStringValue:rootElement name:@"_showDemoStage" defaultValue:nil] ? YES : NO;
            backgroundMusic_ = [[Util getStringValue:rootElement name:@"_backgroundMusic" defaultValue:nil] retain];
            backgroundImageFile = [Util getStringValue:rootElement name:@"_backgroundImage" defaultValue:nil];
            sceneImageFile = [Util getStringValue:rootElement name:@"_sceneImage" defaultValue:nil];
            beforeScrollSleepSec_ = [Util getIntValue:rootElement name:@"_beforeScrollSleepSec" defaultValue:0];
            NSString * scrollbackgroundOnce = [[Util getStringValue:rootElement name:@"_scrollBackgroundOnce" defaultValue:nil] retain];
            
            if (scrollbackgroundOnce)
                loopParallax_ = NO;
            else
                loopParallax_ = YES;
        }

        
        // ask director the the window size
        CGSize size = [[CCDirector sharedDirector] winSize];
        // Set background
        {
         
            if ( ! sceneImageFile ) {
                sceneImageFile = [sceneName stringByAppendingString:@".png"]; // The default scene image file is same with the svg file.
            }
            CCSprite * bg = [CCSprite spriteWithFile:sceneImageFile];
            
            // Some layers such as GamePlayLayer does not have the background image file.
            if (bg)
            {
                // position the label on the center of the screen
                bg.position =  ccp( size.width /2 , size.height/2 );
                
                [self addChild:bg z:-1];
            }
        }
        

        backgroundWidth_ = 0;
        
        // Show the scrolling background only when we don't show the demo stage.
        if (backgroundImageFile) // If the background image file is specified, do infinite scrolling
        {
            parallaxNode_ = [CCParallaxNode node];
            parallexPosition_ = CGPointZero;
            
            CCSprite * backgroundSprite = [CCSprite spriteWithFile:backgroundImageFile];
            backgroundWidth_ = backgroundSprite.contentSize.width;
            backgroundSprite.anchorPoint = ccp(0,0);
            [parallaxNode_ addChild:backgroundSprite z:0 parallaxRatio:ccp(1/SCROLL_FACTOR,1/SCROLL_FACTOR) positionOffset:CGPointZero];
            [self addChild:parallaxNode_ z:-2 tag:0];
        }

        self.actionListener = nil;
        
        self.loadingLevel = 0;
        self.loadingLevelMapName = nil;

        didStartLoading_ = NO;
    }
    return self;
}

- (void) step:(ccTime)dt {
    static int screenWidth = [[CCDirector sharedDirector] winSize].width;
    assert( backgroundWidth_ > screenWidth );
    
    // Before scrolling, we sleep for beforeScrollSleepSec_ seconds
    if (beforeScrollSleepSec_ > 0 )
    {
        beforeScrollSleepSec_ -= dt;
    }
    else
    {
        int scrollPixcels = backgroundWidth_ - screenWidth;
        if (loopParallax_)
        {
            if (parallexPosition_.x < -scrollPixcels*SCROLL_FACTOR ) // Reached half of the image?
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
            if (parallexPosition_.x >= -scrollPixcels*SCROLL_FACTOR )
            {
                parallexPosition_.x -= dt*16*SCROLL_FACTOR; // 16 pixcels per second
            }
        }
    }
    
    [parallaxNode_ setPosition: parallexPosition_];
}

- (void) onEnterTransitionDidFinish {
    if ( backgroundMusic_ ) {
        [Util playBGM:backgroundMusic_];
    }

    if ( self.loadingLevelMapName ) {
        assert( self.loadingLevel > 0 );
        // Should wait a frame to get the loading scene displayed on the screen.
        [self scheduleUpdate];
    }

    // If we have any background, start scheduling for scrolling it.
    if ( backgroundWidth_ > 0 ) {
        [self schedule:@selector(step:)];
    }

    if ( tryToRefreshAD_ ) {

        // In case refreshing the AD is enabled.
        if ([[AdManager sharedAdManager] isRefreshEnabled]) {
            // Try to show next AD when the screen changes.
            [[AdManager sharedAdManager] refresh];
        }
    }
    
    if (showDemoStage_) {
        if ( ! [[DemoManager sharedDemoManager] isRunningDemo] ) {
            [[DemoManager sharedDemoManager] runNextDemo];
        }
    }

    [super onEnterTransitionDidFinish];
}

/** Run end action for each InteractiveSprite in this layer. Called before this layer is removed */
-(void) runEndAction {
    for(id child in self.children)
    {
        if([child isKindOfClass:[InteractiveSprite class]])
        {
            InteractiveSprite * intrSprite = child;
            [intrSprite runEndAction];
        }
    }
}

- (void) onExit {
    
	// in case you have something to dealloc, do it in this method
    [self unscheduleAllSelectors];
    
    [super onExit];
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
    
    self.loadingLevelMapName = nil;
    [sceneName_ release];

    delete widgetContainer_;
    widgetContainer_ = NULL;

	// don't forget to call "super dealloc"
	[super dealloc];
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
	[scene addChild:layer z:0 tag:GeneralSceneLayerTagMenu];
	
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

	// add layer as a child to scene
	[scene addChild:layer z:0 tag:GeneralSceneLayerTagMenu];

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
    // Do nothing.
}

// Called by TxWidget when the value of the widget changes. 
// Ex> If the scene definition SVG contains TxToggleButton, this is called whenever the button is toggled. 
// Ex> If the scene definition SVG contains TxSlideBar, this is called whenever the sliding button is dragged. 
-(void)onWidgetAction:(TxWidget*)sender
{
    // By default, do nothing.
}

//SYNTESIZE_TRACE(GeneralScene)

@end
