//
//  IAP.h
//  rocknroll
//
//  Created by 김 강모 on 11. 10. 11..
//  Copyright 2011년 강모소프트. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol IAPDelegate <NSObject>

-(void)onFinishIAP:(NSString *)product;
-(void)onCancelIAP:(NSString *)product;

@end

@interface IAP : NSObject

@property (retain,nonatomic) id<IAPDelegate> delegate;

+(IAP*) sharedIAP;

-(void)restoreIAP;

-(void) tryPurchase:(NSString*)featureName;

-(BOOL) isFeaturePurchased:(NSString*)featureName;


@end
