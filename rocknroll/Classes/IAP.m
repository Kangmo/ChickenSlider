//
//  IAP.m
//  rocknroll
//
//  Created by 김 강모 on 11. 10. 11..
//  Copyright 2011년 강모소프트. All rights reserved.
//

#import "IAP.h"
#import "MKStoreManager.h"

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
        // BUGBUG : leak
        theIAP = [[IAP alloc] init];
    }
    return theIAP;
}

-(void) tryPurchase:(NSString*)featureName
{
    assert(featureName);
    
    // See if it can be unlocked
    [[MKStoreManager sharedManager] buyFeature:featureName 
                                    onComplete:^(NSString* purchasedFeature)
     {
         NSLog(@"Purchased: %@", purchasedFeature);
         [self.delegate onIAPFinish:IAPR_PURCHASED product:featureName];
         /*
         // use this method to restore a purchase
         [[MKStoreManager sharedManager] restorePreviousTransactionsOnComplete:^
          {
              NSLog(@"Done restoring IAP");
          }
          onError:^(NSError* error)
          {
              NSLog(@"Error while restoring IAP : %@", error);
          }];
          */
     }
         onCancelled:^
     {
         NSLog(@"Canceled purchasing the product: %@", featureName);
         [self.delegate onIAPFinish:IAPR_CANCELED product:featureName];
         // User cancels the transaction, you can log this using any analytics software like Flurry.
     }];

}

+(BOOL) isFeaturePurchased:(NSString*)featureName
{
    BOOL purchased = [MKStoreManager isFeaturePurchased:featureName];
    return purchased;
}
@end
