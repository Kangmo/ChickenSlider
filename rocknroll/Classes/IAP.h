//
//  IAP.h
//  rocknroll
//
//  Created by 김 강모 on 11. 10. 11..
//  Copyright 2011년 강모소프트. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum IAPResponse 
{
    IAPR_PURCHASED=1,
    IAPR_CANCELED
}IAPResponse;

@protocol IAPDelegate <NSObject>

-(void)onIAPFinish:(IAPResponse)response product: (NSString *)product;

@end

@interface IAP : NSObject

@property (retain,nonatomic) id<IAPDelegate> delegate;

+(IAP*) sharedIAP;

-(void)restoreIAP;

-(void) tryPurchase:(NSString*)featureName;

+(BOOL) isFeaturePurchased:(NSString*)featureName;


@end
