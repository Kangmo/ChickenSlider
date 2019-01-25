//
//  IAP.m
//  rocknroll
//
//  Created by 김 강모 on 11. 10. 11..
//  Copyright 2011년 강모소프트. All rights reserved.
//

#import "IAP.h"
#import "InAppPurchaseManager.h"
#import "AppAnalytics.h"

@implementation IAP

- (id)init
{
    self = [super init];
    if (self) {
        [self loadStore];
    }
    
    return self;
}

-(void)dealloc
{
    
//    self.delegate = nil;
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
    std::string featureNameStdStr = [Util toStdString:featureName];
    
    AppAnalytics::sharedAnalytics().logEvent( "IAP:TRY_PURCHASE:"+featureNameStdStr );
    if ([self canMakePurchases]) {
        [self purchaseProUpgrade];
    }
    else {
        [Util showAlertWithTitle:@"Unable to Purchase" message:@"Check your wireless connection."];
        
        AppAnalytics::sharedAnalytics().logEvent( "IAP:CANT_PURCHASE:"+featureNameStdStr );
    }
}

-(BOOL) isFeaturePurchased:(NSString*)featureName
{
    BOOL purchased = [self didPurchase];
    return purchased;
}
@end
