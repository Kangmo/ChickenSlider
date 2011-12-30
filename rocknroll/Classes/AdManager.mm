//
//  AdLayer.m
//  rocknroll
//
//  Created by 김 강모 on 11. 10. 9..
//  Copyright 2011년 강모소프트. All rights reserved.
//
#import "cocos2d.h"
#import "AdManager.h"

#import "AdWhirlView.h"
#import "AppDelegate.h"

#import "StageScene.h"

@implementation AdManager

@synthesize adView;
@synthesize screenSize;
@synthesize hasAD;

static AdManager * theAdManager = nil;

+ (AdManager*) sharedAdManager {
    return theAdManager;
}

- (id)init
{
    self = [super init];
    if (self) {
        // ask director the the window size
        screenSize = [[CCDirector sharedDirector] winSize];
//        adView = nil;
        theAdManager = self;
        self.hasAD = NO;
    }
    
    return self;
}

-(void)dealloc {
    //Remove the adView controller
    self.adView.delegate = nil;
    self.adView = nil;
    [offlineAdView release];
    offlineAdView = nil;
    
    [super dealloc];
}

-(void)refresh {
    [self.adView rollOver];
}
-(void)setVisible:(BOOL)bVisible {
    self.adView.hidden = bVisible? NO:YES;
}
-(void)enableRefresh {
    [self.adView doNotIgnoreAutoRefreshTimer];
}

-(void)disableRefresh {
    [self.adView ignoreAutoRefreshTimer];   
}

-(BOOL)isRefreshEnabled {
    return ([self.adView isIgnoringAutoRefreshTimer])? NO:YES;
}

// Need this function. Otherwise device orientation is used by AdWhirl making iAD size changed based on the device orientation.
- (UIDeviceOrientation)adWhirlCurrentOrientation {
    return UIDeviceOrientationLandscapeLeft;
}

//These are the methods for the AdWhirl Delegate, you have to implement them
#pragma mark AdWhirlDelegate methods
-(void) pauseGame {
    [[SimpleAudioEngine sharedEngine] pauseBackgroundMusic];
    
    [[CCDirector sharedDirector] pause];
}

-(void) resumeGame {
    [[SimpleAudioEngine sharedEngine] resumeBackgroundMusic];
    
	[[CCDirector sharedDirector] resume];
}

- (void)adWhirlWillPresentFullScreenModal {
    //It's recommended to invoke whatever you're using as a "Pause Menu" so your
    //game won't keep running while the user is "playing" with the Ad (for example, iAds)
    [(AppDelegate*)[[UIApplication sharedApplication] delegate] pauseApp];
}

- (void)adWhirlDidDismissFullScreenModal {
    //Once the user closes the Ad he'll want to return to the game and continue where
    //he left it
    [(AppDelegate*)[[UIApplication sharedApplication] delegate] resumeApp];
}

- (NSString *)adWhirlApplicationKey {
    //Here you have to enter your AdWhirl SDK key
    return @"b8a0afb37cf349bebc8484186e94205c";
}

- (UIViewController *)viewControllerForPresentingModalView {
    //Remember that UIViewController we created in the Game.h file? AdMob will use it.
    //If you want to use "return self;" instead, AdMob will cancel the Ad requests.
    return viewController;
}

// Resize the Ad. UIView.frame is in the absolute coordinate in portrait mode.
-(void)adjustAdSize {
    assert ( self.hasAD );

//    [UIView beginAnimations:@"AdResize" context:nil];
//    [UIView setAnimationDuration:0.7];
    // Get the actual Ad size
    CGSize adSize = [adView actualAdSize];
    // Create a new frame so we can assign the actual size
    CGRect newFrame = adView.frame;
    // Set the height
    newFrame.size.height = adSize.width;
    newFrame.size.width = adSize.height;

    newFrame.origin.x = (screenSize.height - adSize.height);
    newFrame.origin.y = 0;
//    newFrame.origin.y = (screenSize.width - adSize.width)/2;
    
    if ( adView.frame.origin.x != newFrame.origin.x ||
        adView.frame.origin.y != newFrame.origin.y ||  
        adView.frame.size.width != newFrame.size.width || 
        adView.frame.size.height != newFrame.size.height )
    {
        // Assign the new frame to the current one
        adView.frame = newFrame;
    }
    
    // Apply animations
//    [UIView commitAnimations];
}

-(void)adWhirlDidReceiveAd:(AdWhirlView *)adWhirlView {

    assert(self.adView);
    
    //This is a little trick I'm using... on my game I created a CCMenu with an image to promote
    //my own paid game so this way I can guarantee that there will always be an Ad on-screen
    //even if there's no internet connection... it's up to you if you want to implement this or not.
    [offlineAdView removeFromSuperview];
    [offlineAdView release];
    offlineAdView = nil;

    //In case your game is in Landscape mode, set the interface orientation to that
    //of your game (actually, UIInterfaceOrientationLandscapeLeft and UIInterfaceOrientationLandscapeRight
    //will have the same effect on the ad... i.e. iAd). If your game is in Portrait mode, comment
    //the following line
    [self.adView rotateToOrientation:UIInterfaceOrientationLandscapeLeft];

    //Different networks have different Ad sizes, we want our Ad to display in it's right size so
    //we're invoking the method to resize the Ad
    [self adjustAdSize];
    
}

-(void)adWhirlDidFailToReceiveAd:(AdWhirlView *)adWhirlView usingBackup:(BOOL)yesOrNo {
    //The code to show my own Ad banner again
}

-(void)createAD {
    assert( ! self.hasAD );
    self.hasAD = YES;
    
    //Let's allocate the viewController (it's the same RootViewController as declared
    //in our AppDelegate; will be used for the Ads)
    viewController = [(AppDelegate*)[[UIApplication sharedApplication] delegate] viewController];
    
    // Create the offline Ad view
    {
        /*
        offlineAdView = [[OfflineAdView alloc] init];
        
        offlineAdView.autoresizingMask = UIViewAutoresizingNone; 
        offlineAdView.frame = CGRectMake((screenSize.width/2)-(OFFLINE_AD_WIDTH/2),screenSize.height-OFFLINE_AD_HEIGHT,screenSize.width,OFFLINE_AD_HEIGHT);
      
        [viewController.view addSubview:offlineAdView];
        [viewController.view bringSubviewToFront:offlineAdView];

        [offlineAdView setTransform:CGAffineTransformMakeRotation(CC_DEGREES_TO_RADIANS(90))];
        offlineAdView.frame = CGRectMake(screenSize.width - OFFLINE_AD_WIDTH, 0, OFFLINE_AD_HEIGHT, OFFLINE_AD_WIDTH);
         */
    }
    
    //Assign the AdWhirl Delegate to our adView
    self.adView = [AdWhirlView requestAdWhirlViewWithDelegate:self];
    assert(self.adView);
    
    //Set auto-resizing mask
    self.adView.autoresizingMask = UIViewAutoresizingNone; 
    //self.adView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
    //This isn't really needed but also it makes no harm. It just retrieves the configuration
    //from adwhirl.com so it knows what Ad networks to use
    [adView updateAdWhirlConfig];
    //Get the actual size for the requested Ad
    CGSize adSize = [adView actualAdSize];
    
    //
    //Set the position; remember that we are using 4 values (in this order): X, Y, Width, Height
    //You can comment this line if your game is in portrait mode and you want your Ad on the top
    //if you want the Ad in other position (portrait or landscape), use the following code,
    //for this example, the Ad will be positioned in the bottom+center of the screen
    //(in landscape mode):
    //Same explanation as the one in the method "adjustAdSize" for the Ad's width
    /*
    self.adView.frame = CGRectMake((screenSize.width/2)-(adSize.width/2),screenSize.height-adSize.height,screenSize.width,adSize.height);
     */
    self.adView.frame = CGRectMake(0,screenSize.height-adSize.height,screenSize.width,adSize.height);
    //
    //NOTE:
    //adSize.height = the height of the requested Ad
    //
    //Trying to keep everything inside the Ad bounds
    self.adView.clipsToBounds = YES;
    //Adding the adView (used for our Ads) to our viewController
    [viewController.view addSubview:adView];
    //Bring our view to front
    [viewController.view bringSubviewToFront:adView];
    /*
     CGAffineTransform transform = CGAffineTransformMakeTranslation(50, 150);
     transform = CGAffineTransformTranslate(transform, 0, 0);
     transform = CGAffineTransformRotate(transform, CC_DEGREES_TO_RADIANS(90));
     [adView setTransform:transform];
     */
    
    [adView setTransform:CGAffineTransformMakeRotation(CC_DEGREES_TO_RADIANS(90))];
    
    
    //adView.center = CGPointMake(portraitScreenWidth-adView.frame.size.width/2,  portraitScreenHeight / 2 );
    //                [adView setCenter:CGPointMake(16, 240)];
    
    // Make sure that we show AD at first.
    [self refresh];
}

-(void)removeAD {
    assert(self.hasAD);
    //There's something weird about AdWhirl because setting the adView delegate
    //to "nil" doesn't stops the Ad requests and also it doesn't remove the adView
    //from superView; do the following to remove AdWhirl from your scene.
    //
    //If adView exists, remove everything
    if (adView) {
        //Remove adView from superView
        [adView removeFromSuperview];
        //Replace adView's view with "nil"
        [adView replaceBannerViewWith:nil];
        //Tell AdWhirl to stop requesting Ads
        [adView ignoreNewAdRequests];
        //Set adView delegate to "nil"
        [adView setDelegate:nil];
        //Release adView
        [adView release];
        //set adView to "nil"
        adView = nil;
        
        [offlineAdView release];
        offlineAdView = nil;
    }
}

@end
