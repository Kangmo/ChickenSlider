//
//  IAP.h
//  rocknroll
//
//  Created by 김 강모 on 11. 10. 11..
//  Copyright 2011년 강모소프트. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "InAppPurchaseManager.h"
typedef enum IAPResponse 
{
    IAPR_PURCHASED=1,
    IAPR_CANCELED
}IAPResponse;


@interface IAP : InAppPurchaseManager {
}

+(IAP*) sharedIAP;

-(void) tryPurchase:(NSString*)featureName;

-(BOOL) isFeaturePurchased:(NSString*)featureName;

@end
