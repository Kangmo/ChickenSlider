//
//  AdLayer.m
//  rocknroll
//
//  Created by 김 강모 on 11. 10. 9..
//  Copyright 2011년 강모소프트. All rights reserved.
//
#import "cocos2d.h"
#import "AdLayer.h"

#import "AdWhirlView.h"
#import "AppDelegate.h"

@implementation AdLayer

@synthesize adView;
@synthesize enableAD;
@synthesize screenSize;

- (id)init
{
    self = [super init];
    if (self) {
        // By default, the AD is disabled.
        self.enableAD = NO;
        // ask director the the window size
        screenSize = [[CCDirector sharedDirector] winSize];

//        adView = nil;
    }
    
    return self;
}

-(void)dealloc {
    //Remove the adView controller
    self.adView.delegate = nil;
    self.adView = nil;

    [super dealloc];
}


//These are the methods for the AdWhirl Delegate, you have to implement them
#pragma mark AdWhirlDelegate methods
-(void) pauseGame {
    // By default, do nothing.
}

-(void) resumeGame {
    // By default, do nothing.
}

- (void)adWhirlWillPresentFullScreenModal {
    //It's recommended to invoke whatever you're using as a "Pause Menu" so your
    //game won't keep running while the user is "playing" with the Ad (for example, iAds)
    [self pauseGame];
}

- (void)adWhirlDidDismissFullScreenModal {
    //Once the user closes the Ad he'll want to return to the game and continue where
    //he left it
    [self resumeGame];
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
    assert ( self.enableAD );

    [UIView beginAnimations:@"AdResize" context:nil];
    [UIView setAnimationDuration:0.7];
    // Get the actual Ad size
    CGSize adSize = [adView actualAdSize];
    // Create a new frame so we can assign the actual size
    CGRect newFrame = adView.frame;
    // Set the height
    newFrame.size.height = screenSize.width;
    newFrame.size.width = adSize.height;

    newFrame.origin.x = (screenSize.height - adSize.height);

    newFrame.origin.y = (screenSize.width - adSize.width)/2;

    // Assign the new frame to the current one
    adView.frame = newFrame;
    
    // Apply animations
    [UIView commitAnimations];
}

-(void)adWhirlDidReceiveAd:(AdWhirlView *)adWhirlView {
    if ( ! self.enableAD )
    {
        return;
    }
    assert(self.adView);
    
    //This is a little trick I'm using... on my game I created a CCMenu with an image to promote
    //my own paid game so this way I can guarantee that there will always be an Ad on-screen
    //even if there's no internet connection... it's up to you if you want to implement this or not.
    // BUGBUG : Need to understand if this is necessary.
    //[self removeChild:adBanner cleanup:YES];
    
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

-(void)onEnter {
    if ( self.enableAD )
    {
        //Let's allocate the viewController (it's the same RootViewController as declared
        //in our AppDelegate; will be used for the Ads)
        viewController = [(AppDelegate*)[[UIApplication sharedApplication] delegate] viewController];
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
        self.adView.frame = CGRectMake((screenSize.width/2)-(adSize.width/2),screenSize.height-adSize.height,screenSize.width,adSize.height);
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
    }
    
    [super onEnter];
}

-(void)onExit {
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
    }
    [super onExit];
}

@end
