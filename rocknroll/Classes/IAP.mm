//
//  IAP.m
//  rocknroll
//
//  Created by 김 강모 on 11. 10. 11..
//  Copyright 2011년 강모소프트. All rights reserved.
//

#import "IAP.h"
#import "MKStoreManager.h"
#import "AppAnalytics.h"
#import "GameConfig.h"

@implementation IAP
@synthesize delegate;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

-(void)dealloc
{
    self.delegate = nil;
    [super dealloc];
}

+(IAP*) sharedIAP {
    static IAP * theIAP = nil;
    
    if (! theIAP)
    {
        [MKStoreManager sharedManager];
// We should never run this in release mode
#if defined(DEBUG)
#  if defined(RESET_IAP_DATA)
        [[MKStoreManager sharedManager] removeAllKeychainData];
#  endif
#endif
        // BUGBUG : leak
        theIAP = [[IAP alloc] init];
    }
    return theIAP;
}

-(void)restoreIAP {
     // use this method to restore a purchase
     [[MKStoreManager sharedManager] restorePreviousTransactionsOnComplete:^
     {
         AppAnalytics::sharedAnalytics().logEvent( "IAP:RECEIVED_RESTORED_TX:" );

         NSLog(@"Done restoring IAP");
     }
     onError:^(NSError* error)
     {
         NSString * errorInfo = [NSString stringWithFormat:@"%@", error];
         std::string errorInfoStdStr = [Util toStdString:errorInfo];
         AppAnalytics::sharedAnalytics().logEvent( "IAP:RECEIVED_ERROR_RESTORING_TX:"+errorInfoStdStr);
         
         NSLog(@"Error while restoring IAP : %@", error);
     }];
}

-(void) tryPurchase:(NSString*)featureName
{
    assert(featureName);
    std::string featureNameStdStr = [Util toStdString:featureName];

    AppAnalytics::sharedAnalytics().logEvent( "IAP:TRY_PURCHASE:"+featureNameStdStr );

    // See if it can be unlocked
    [[MKStoreManager sharedManager] buyFeature:featureName 
                                    onComplete:^(NSString* purchasedFeature)
     {
         NSLog(@"Purchased: %@", purchasedFeature);
         [self.delegate onFinishIAP:featureName];
         
         AppAnalytics::sharedAnalytics().logEvent( "IAP:RECEIVED_PURCHASED:"+featureNameStdStr );
     }
         onCanceled:^
     {
         NSLog(@"Canceled purchasing the product: %@", featureName);
         [self.delegate onCancelIAP:featureName];
         
         [Util showAlertWithTitle:@"Purchase Canceled" message:@"Thank you! We will continue to make this game better for your next purchase!"];
         // User cancels the transaction, you can log this using any analytics software like Flurry.
         
         AppAnalytics::sharedAnalytics().logEvent( "IAP:RECEIVED_CANCELED:"+featureNameStdStr );
     }];

}

-(BOOL) isFeaturePurchased:(NSString*)featureName
{
    BOOL purchased = [MKStoreManager isFeaturePurchased:featureName];
    return purchased;
}
@end
