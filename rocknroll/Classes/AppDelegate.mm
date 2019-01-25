#import "cocos2d.h"
#import "AppDelegate.h"
#import "GameConfig.h"
#import "GeneralScene.h"
#import "StageScene.h"
#import "RootViewController.h"
#import "PersistentGameState.h"

#import "AdWhirlView.h"
#import "ClipFactory.h"
#import "Util.h"
#include "GameConfig.h"
#import "AdManager.h"
#import "FlurryAnalytics.h"
#include "AppAnalytics.h"
#import "IAP.h"
#import "GameState.h"

@implementation AppDelegate

@synthesize window;
@synthesize viewController;
@synthesize webBrowserController;

- (void) removeStartupFlicker
{
	//
	// THIS CODE REMOVES THE STARTUP FLICKER
	//
	// Uncomment the following code if you Application only supports landscape mode
	//
#if GAME_AUTOROTATION == kGameAutorotationUIViewController
	
	//	CC_ENABLE_DEFAULT_GL_STATES();
	//	CCDirector *director = [CCDirector sharedDirector];
	//	CGSize size = [director winSize];
	//	CCSprite *sprite = [CCSprite spriteWithFile:@"Default.png"];
	//	sprite.position = ccp(size.width/2, size.height/2);
	//	sprite.rotation = -90;
	//	[sprite visit];
	//	[[director openGLView] swapBuffers];
	//	CC_ENABLE_DEFAULT_GL_STATES();
	
#endif // GAME_AUTOROTATION == kGameAutorotationUIViewController	
}

static NSUncaughtExceptionHandler * defaultExceptionHandler = nil;

void uncaughtExceptionHandler(NSException *exception) {
    NSString * callStack = [NSString stringWithFormat:@"%@", [NSThread callStackSymbols]];
    
    [FlurryAnalytics logError:@"Uncaught Exception" message:callStack exception:exception];
    
    if(defaultExceptionHandler) {
        defaultExceptionHandler(exception);
    }
}

-(void) installExceptionHandler {
    defaultExceptionHandler = NSGetUncaughtExceptionHandler();
    
    NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
}

- (void) applicationDidFinishLaunching:(UIApplication*)application
{
	// Init the window
	window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	
	// Try to use CADisplayLink director
	// if it fails (SDK < 3.1) use the default director
	if( ! [CCDirector setDirectorType:kCCDirectorTypeDisplayLink] )
		[CCDirector setDirectorType:kCCDirectorTypeDefault];
	
	
	CCDirector *director = [CCDirector sharedDirector];
	
	// Init the View Controller
	viewController = [[RootViewController alloc] initWithNibName:nil bundle:nil];
	viewController.wantsFullScreenLayout = YES;
	
	//
	// Create the EAGLView manually
	//  1. Create a RGB565 format. Alternative: RGBA8
	//	2. depth format of 0 bit. Use 16 or 24 bit for 3d effects, like CCPageTurnTransition
	//
	//
	EAGLView *glView = [EAGLView viewWithFrame:[window bounds]
								   pixelFormat:kEAGLColorFormatRGB565	// kEAGLColorFormatRGBA8
								   depthFormat:0						// GL_DEPTH_COMPONENT16_OES
						];
	
	// attach the openglView to the director
	[director setOpenGLView:glView];
	
    //	// Enables High Res mode (Retina Display) on iPhone 4 and maintains low res on all other devices
    //	if( ! [director enableRetinaDisplay:YES] )
    //		CCLOG(@"Retina Display Not supported");
	
	//
	// VERY IMPORTANT:
	// If the rotation is going to be controlled by a UIViewController
	// then the device orientation should be "Portrait".
	//
	// IMPORTANT:
	// By default, this template only supports Landscape orientations.
	// Edit the RootViewController.m file to edit the supported orientations.
	//
#if GAME_AUTOROTATION == kGameAutorotationUIViewController
	[director setDeviceOrientation:kCCDeviceOrientationPortrait];
#else
	[director setDeviceOrientation:kCCDeviceOrientationLandscapeLeft];
#endif
	
	[director setAnimationInterval:1.0/60];
	[director setDisplayFPS:YES];
	
	
	// make the OpenGLView a child of the view controller
	[viewController setView:glView];
	
	// make the View Controller a child of the main window
	[window addSubview: viewController.view];
	
	[window makeKeyAndVisible];

    // Initialize GameKit
    GameKitHelper* gkHelper = [GameKitHelper sharedGameKitHelper];
    gkHelper.commDelegate = [GameState sharedGameState];

    [gkHelper authenticateLocalPlayer];

	// Default texture format for PNG/BMP/TIFF/JPEG/GIF images
	// It can be RGBA8888, RGBA4444, RGB5_A1, RGB565
	// You can change anytime.
	[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA8888];
    
	// Removes the startup flicker
	[self removeStartupFlicker];
    
#if ! defined(DISABLE_IAP)
    // Initialize IAP.
    [IAP sharedIAP];
#endif
    
    // Set volumes
    int musicVolume = [Util loadMusicVolume];
    int effectVolume = [Util loadEffectVolume];

    [[SimpleAudioEngine sharedEngine] setBackgroundMusicVolume:(float)musicVolume/MAX_MUSIC_VOLUME];
    [[SimpleAudioEngine sharedEngine] setEffectsVolume:(float)effectVolume/MAX_EFFECT_VOLUME];
    
    // Load the sprite frames.
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"sprites.plist" textureFile:@"sprites.pvr"];

    // Load the sprite frames.
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"menu_sprites.plist" textureFile:@"menu_sprites.pvr"];

    // Enable AD only if no feature is not purchased
    if ( ! [Util didPurchaseAny ] )
    {
        adManager = [[AdManager alloc] init];
        [adManager createAD];
        // Enable refreshing ADs for the best performance.
        [[AdManager sharedAdManager] enableRefresh];
        [[AdManager sharedAdManager] refresh];
    }
    
#if ! defined(DEBUG)    
    [self installExceptionHandler];
#endif
    
    // Start Flurry Analytics
    AppAnalytics::sharedAnalytics().startSession("YAP4LQ93A59M1MS6QB2Q");

    AppAnalytics::sharedAnalytics().beginEventProperty();
    AppAnalytics::sharedAnalytics().addDeviceProperties();
    AppAnalytics::sharedAnalytics().endEventProperty();
    AppAnalytics::sharedAnalytics().beginTimedEvent("AppPlayTime");
    
    CCScene * theFirstScene = [GeneralScene sceneWithName:@"MainMenuScene"];
    //CCScene * theFirstScene = [StageScene sceneInMap:@"MAP01" levelNum:1];
	
    // Run the main menu Scene
	[[CCDirector sharedDirector] runWithScene: theFirstScene];

    appDelegateCalledPause = NO;
    webBrowserController = nil;
}

-(void) pauseApp {
    [[SimpleAudioEngine sharedEngine] pauseBackgroundMusic];
    
    // If the director is already paused, stay paused.
    if (! [[CCDirector sharedDirector] isPaused] ) {
        [[CCDirector sharedDirector] pause];
        appDelegateCalledPause = YES;
    }
    else
    {
        appDelegateCalledPause = NO;
    }
}

-(void) resumeApp {
    [[SimpleAudioEngine sharedEngine] resumeBackgroundMusic];
    
    // resume the director only if the app delegate paused it.
    // Ex> The user pressed pause button in the game play screen. We should not resume the director in this case.
    if (appDelegateCalledPause) { 
        [[CCDirector sharedDirector] resume];
    }
}
- (void)applicationWillResignActive:(UIApplication *)application {
    [self pauseApp];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [self resumeApp];
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    NSLog(@"AppDelegate:applicationDidReceiveMemoryWarning");
    
	[[CCDirector sharedDirector] purgeCachedData];
    [[ClipFactory sharedFactory] purgeCachedData];
    [[CCTextureCache sharedTextureCache] removeAllTextures];
}

-(void) applicationDidEnterBackground:(UIApplication*)application {
	[[CCDirector sharedDirector] stopAnimation];
}

-(void) applicationWillEnterForeground:(UIApplication*)application {
	[[CCDirector sharedDirector] startAnimation];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    
    AppAnalytics::sharedAnalytics().endTimedEvent("AppPlayTime");

    if (adManager)
    {
        if (adManager.hasAD)
            [adManager removeAD];
    }
	CCDirector *director = [CCDirector sharedDirector];
	
	[[director openGLView] removeFromSuperview];
	
	[viewController release];
	
	[window release];
	
	[director end];	
}

- (void)applicationSignificantTimeChange:(UIApplication *)application {
	[[CCDirector sharedDirector] setNextDeltaTimeZero:YES];
}

-(void)openWebView:(NSString*)URLString {
    if (self.webBrowserController == nil) {
        AdWhirlWebBrowserController *ctrlr = [[AdWhirlWebBrowserController alloc] init];
        self.webBrowserController = ctrlr;
        [ctrlr release];
    }
    webBrowserController.delegate = self;
    [webBrowserController presentWithController:self.viewController
                                     transition:AWCustomAdWebViewAnimTypeFlipFromLeft];

    [self pauseApp];
    
    NSURL * url = [NSURL URLWithString: URLString];
    [webBrowserController loadURL:url];
}

/** @brief implements AdWhirlWebBrowserController. Called when the web browser view is closed.
 */
- (void)webBrowserClosed:(AdWhirlWebBrowserController *)controller {
    if (controller != webBrowserController) return;
    self.webBrowserController = nil; // don't keep around to save memory

    [self resumeApp];
}


- (void)dealloc {
    if (adManager)
    {
        [adManager release];
        adManager = nil;
    }
	[[CCDirector sharedDirector] end];
	[window release];
	[super dealloc];
}

@end
