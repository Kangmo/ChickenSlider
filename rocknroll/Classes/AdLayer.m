//
//  AdLayer.m
//  rocknroll
//
//  Created by 김 강모 on 11. 10. 9..
//  Copyright 2011년 강모소프트. All rights reserved.
//

#import "AdLayer.h"

@interface AdLayer()
- (void)fixBannerToDeviceOrientation:(UIDeviceOrientation)orientation;   
@end

@implementation AdLayer
@synthesize enableAD;
- (id)init
{
    self = [super init];
    if (self) {
        // By default, the AD is disabled.
        self.enableAD = NO;
        adView = nil;
    }
    
    return self;
}

-(void) dealloc {
    [adView release];
    adView = nil;
    
    [super dealloc];
}

#pragma mark ADBannerView

- (void)fixBannerToDeviceOrientation:(UIDeviceOrientation)orientation
{
    //Don't rotate ad if it doesn't exist
    if (adView != nil)
    {
        // ask director the the window size
        CGSize size = [[CCDirector sharedDirector] winSize];
        
        CGFloat portraitScreenHeight = (size.width>size.height)?size.width:size.height;
        CGFloat portraitScreenWidth = (size.width<size.height)?size.width:size.height;
        
        //Set the transformation for each orientation
        switch (orientation)
        {
            case UIDeviceOrientationPortrait:
            {
                NSLog(@"fixBannerToDeviceOrientation UIDeviceOrientationPortrait");
                [adView setTransform:CGAffineTransformIdentity];
                [adView setCurrentContentSizeIdentifier:ADBannerContentSizeIdentifierPortrait];
                adView.center = CGPointMake(portraitScreenWidth/2, adView.frame.size.height/2);
                //                [adView setCenter:CGPointMake(160, 455)];
            }
                break;
            case UIDeviceOrientationPortraitUpsideDown:
            {
                NSLog(@"fixBannerToDeviceOrientation UIDeviceOrientationPortraitUpsideDown");
                [adView setTransform:CGAffineTransformIdentity];
                [adView setCurrentContentSizeIdentifier:ADBannerContentSizeIdentifierPortrait];
                [adView setTransform:CGAffineTransformMakeRotation(CC_DEGREES_TO_RADIANS(180))];
                adView.center = CGPointMake(portraitScreenWidth/2, portraitScreenHeight - adView.frame.size.height/2);
                //                [adView setCenter:CGPointMake(160, 25)];
            }
                break;
            case UIDeviceOrientationLandscapeLeft:
            {
                NSLog(@"fixBannerToDeviceOrientation UIDeviceOrientationLandscapeLeft");
                [adView setTransform:CGAffineTransformIdentity];
                [adView setCurrentContentSizeIdentifier:ADBannerContentSizeIdentifierLandscape];
                [adView setTransform:CGAffineTransformMakeRotation(CC_DEGREES_TO_RADIANS(90))];
                adView.center = CGPointMake(portraitScreenWidth-adView.frame.size.width/2,  portraitScreenHeight / 2 );
                //                [adView setCenter:CGPointMake(16, 240)];
            }
                break;
            case UIDeviceOrientationLandscapeRight:
            {
                NSLog(@"fixBannerToDeviceOrientation UIDeviceOrientationLandscapeRight");
                [adView setTransform:CGAffineTransformIdentity];
                [adView setCurrentContentSizeIdentifier:ADBannerContentSizeIdentifierLandscape];
                [adView setTransform:CGAffineTransformMakeRotation(CC_DEGREES_TO_RADIANS(-90))];
                adView.center = CGPointMake(adView.frame.size.width/2,  portraitScreenHeight / 2 );
                //                [adView setCenter:CGPointMake(304, 240)];
            }
                break;
            default:
                break;
        }
        //        adView.center = CGPointMake(adView.frame.size.width/2, adView.frame.size.height/2);
    }
}

-(void) orientationChanged:(NSNotification *)notification
{
    if ( self.enableAD )
    {
        NSLog(@"orientationChanged");
        UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
        
        //Transform Ad to adjust it to the current orientation
        [self fixBannerToDeviceOrientation:orientation];
    }
}

-(void)onEnter
{
    [super onEnter];
    
    if ( self.enableAD )
    {
        NSLog(@"onEnter called");
     
        if (adView == nil )
        {
            // initialize iAd object, but don't add it as a subview yet.
            adView = [[ADBannerView alloc]initWithFrame:CGRectZero];
            
            adView.requiredContentSizeIdentifiers = 
            [NSSet setWithObjects: 
             ADBannerContentSizeIdentifierPortrait, 
             // Only if we support rotation
             //#if GAME_AUTOROTATION!=kGameAutorotationNone
             ADBannerContentSizeIdentifierLandscape,
             //#endif
             nil];
            //            adView.currentContentSizeIdentifier = ADBannerContentSizeIdentifierPortrait;
            adView.currentContentSizeIdentifier = ADBannerContentSizeIdentifierLandscape;
        }
        
        assert(adView);
        
        adView.delegate = self;
        
        [[[CCDirector sharedDirector] openGLView] addSubview:adView];
        
        //Transform bannerView
        [self fixBannerToDeviceOrientation:(UIDeviceOrientation)[[CCDirector sharedDirector] deviceOrientation]];
        
        adView.hidden = YES;
    }
}

-(void)onExit
{
    if ( self.enableAD )
    {
        adView.delegate = nil;
        [adView removeFromSuperview];
    }    
    
    [super onExit];
}

#pragma mark -
#pragma mark ADBannerViewDelegate

- (BOOL)allowActionToRun
{
    NSLog(@"allowActionToRun called");
    return TRUE;
}

- (void) stopActionsForAd
{
    /* remember to pause music too! */
    NSLog(@"stopActionsForAd called");
    [[CCDirector sharedDirector] stopAnimation];
    [[CCDirector sharedDirector] pause];
}

- (void) startActionsForAd
{
    /* resume music, if paused */
    NSLog(@"startActionsForAd called");
    [[CCDirector sharedDirector] stopAnimation];
    [[CCDirector sharedDirector] resume];
    [[CCDirector sharedDirector] startAnimation];
}

-(void)bannerViewDidLoadAd:(ADBannerView *)banner
{
    NSLog(@"bannerViewDidLoadAd called");
    adView.hidden = NO;
    //[self moveBannerOnScreen];
}

-(void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
    NSLog(@"bannerView called - potentially with error %@",error);
    adView.hidden = YES;
    
}

-(void)bannerViewActionDidFinish:(ADBannerView *)banner
{
    NSLog(@"bannerViewActionDidFinish called");
    //	[[UIApplication sharedApplication] setStatusBarOrientation:(UIInterfaceOrientation)[[CCDirector sharedDirector]deviceOrientation]];
    UIDeviceOrientation orientation = (UIDeviceOrientation)[[CCDirector sharedDirector] deviceOrientation];
    [[UIApplication sharedApplication] setStatusBarOrientation:(UIInterfaceOrientation)orientation];
    [self fixBannerToDeviceOrientation:orientation];
    
    [self startActionsForAd];
}

-(BOOL)bannerViewActionShouldbegin:(ADBannerView *)banner willLeaveApplication:(BOOL)willLeave
{
    NSLog(@"bannerViewActionShould Begin called");
    
    BOOL shouldExecuteAction = [self allowActionToRun];
    if (!willLeave && shouldExecuteAction)
    {
        // insert code here to suspend any services that might conflict with the advertisement
        [self stopActionsForAd];
    }
    return shouldExecuteAction;
    //return YES;
}

@end
