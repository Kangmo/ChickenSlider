/*

 AdWhirlAdapterIAd.m

 Copyright 2010 AdMob, Inc.

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.

 */

#import "AdWhirlAdapterIAd.h"
#import "AdWhirlAdNetworkConfig.h"
#import "AdWhirlView.h"
#import "AdWhirlLog.h"
#import "AdWhirlAdNetworkAdapter+Helpers.h"
#import "AdWhirlAdNetworkRegistry.h"

@implementation AdWhirlAdapterIAd

+ (AdWhirlAdNetworkType)networkType {
  return AdWhirlAdNetworkTypeIAd;
}
- (void)fixBannerToDeviceOrientation:(UIInterfaceOrientation)orientation
{
    ADBannerView *adView = (ADBannerView *)self.adNetworkView;
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
            case UIInterfaceOrientationPortrait:
            {
                NSLog(@"fixBannerToDeviceOrientation UIDeviceOrientationPortrait");
                [adView setTransform:CGAffineTransformIdentity];
                [adView setCurrentContentSizeIdentifier:ADBannerContentSizeIdentifierPortrait];
                adView.center = CGPointMake(portraitScreenWidth/2, adView.frame.size.height/2);
                //                [adView setCenter:CGPointMake(160, 455)];
            }
                break;
            case UIInterfaceOrientationPortraitUpsideDown:
            {
                NSLog(@"fixBannerToDeviceOrientation UIDeviceOrientationPortraitUpsideDown");
                [adView setTransform:CGAffineTransformIdentity];
                [adView setCurrentContentSizeIdentifier:ADBannerContentSizeIdentifierPortrait];
                [adView setTransform:CGAffineTransformMakeRotation(CC_DEGREES_TO_RADIANS(180))];
                adView.center = CGPointMake(portraitScreenWidth/2, portraitScreenHeight - adView.frame.size.height/2);
                //                [adView setCenter:CGPointMake(160, 25)];
            }
                break;
            case UIInterfaceOrientationLandscapeLeft:
            {
                NSLog(@"fixBannerToDeviceOrientation UIDeviceOrientationLandscapeLeft");
                [adView setTransform:CGAffineTransformIdentity];
                [adView setCurrentContentSizeIdentifier:ADBannerContentSizeIdentifierLandscape];
                [adView setTransform:CGAffineTransformMakeRotation(CC_DEGREES_TO_RADIANS(90))];
                adView.center = CGPointMake(portraitScreenWidth-adView.frame.size.width/2,  portraitScreenHeight / 2 );
                //                [adView setCenter:CGPointMake(16, 240)];
            }
                break;
            case UIInterfaceOrientationLandscapeRight:
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

+ (void)load {
  if(NSClassFromString(@"ADBannerView") != nil) {
    [[AdWhirlAdNetworkRegistry sharedRegistry] registerClass:self];
  }
}

- (void)getAd {
  ADBannerView *iAdView = [[ADBannerView alloc] initWithFrame:CGRectZero];
  kADBannerContentSizeIdentifierPortrait =
    &ADBannerContentSizeIdentifierPortrait != nil ?
      ADBannerContentSizeIdentifierPortrait :
      ADBannerContentSizeIdentifier320x50;
  kADBannerContentSizeIdentifierLandscape =
    &ADBannerContentSizeIdentifierLandscape != nil ?
      ADBannerContentSizeIdentifierLandscape :
      ADBannerContentSizeIdentifier480x32;
  iAdView.requiredContentSizeIdentifiers = [NSSet setWithObjects:
                                            kADBannerContentSizeIdentifierPortrait,
                                            kADBannerContentSizeIdentifierLandscape,
                                            nil];
  UIDeviceOrientation orientation;
  if ([self.adWhirlDelegate respondsToSelector:@selector(adWhirlCurrentOrientation)]) {
    orientation = [self.adWhirlDelegate adWhirlCurrentOrientation];
  }
  else {
    orientation = [UIDevice currentDevice].orientation;
  }

  if (UIDeviceOrientationIsLandscape(orientation)) {
    iAdView.currentContentSizeIdentifier = kADBannerContentSizeIdentifierLandscape;
  }
  else {
    iAdView.currentContentSizeIdentifier = kADBannerContentSizeIdentifierPortrait;
  }
  [iAdView setDelegate:self];

  self.adNetworkView = iAdView;
  [iAdView release];
}

- (void)stopBeingDelegate {
  ADBannerView *iAdView = (ADBannerView *)self.adNetworkView;
  if (iAdView != nil) {
    iAdView.delegate = nil;
  }
}

- (void)rotateToOrientation:(UIInterfaceOrientation)orientation {
    
  ADBannerView *iAdView = (ADBannerView *)self.adNetworkView;
  if (iAdView == nil) return;
  if (UIInterfaceOrientationIsLandscape(orientation)) {
    iAdView.currentContentSizeIdentifier = kADBannerContentSizeIdentifierLandscape;
  }
  else {
    iAdView.currentContentSizeIdentifier = kADBannerContentSizeIdentifierPortrait;
  }
 
  // [self fixBannerToDeviceOrientation:orientation];
  // ADBanner positions itself in the center of the super view, which we do not
  // want, since we rely on publishers to resize the container view.
  // position back to 0,0
  CGRect newFrame = iAdView.frame;
  newFrame.origin.x = newFrame.origin.y = 0;
  iAdView.frame = newFrame;
}

- (BOOL)isBannerAnimationOK:(AWBannerAnimationType)animType {
  if (animType == AWBannerAnimationTypeFadeIn) {
    return NO;
  }
  return YES;
}

- (void)dealloc {
  [super dealloc];
}

#pragma mark IAdDelegate methods

- (void)bannerViewDidLoadAd:(ADBannerView *)banner {
  // ADBanner positions itself in the center of the super view, which we do not
  // want, since we rely on publishers to resize the container view.
  // position back to 0,0
  CGRect newFrame = banner.frame;
  newFrame.origin.x = newFrame.origin.y = 0;
  banner.frame = newFrame;

  [adWhirlView adapter:self didReceiveAdView:banner];
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error {
  [adWhirlView adapter:self didFailAd:error];
}

- (BOOL)bannerViewActionShouldBegin:(ADBannerView *)banner willLeaveApplication:(BOOL)willLeave {
  [self helperNotifyDelegateOfFullScreenModal];
  return YES;
}

- (void)bannerViewActionDidFinish:(ADBannerView *)banner {
  [self helperNotifyDelegateOfFullScreenModalDismissal];
}

@end
