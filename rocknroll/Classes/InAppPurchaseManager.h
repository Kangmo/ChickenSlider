//
//  InAppPurchaseManager.h
//  rocknroll
//
//  Created by 김 강모 on 11. 12. 23..
//  Copyright (c) 2011년 강모소프트. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <StoreKit/StoreKit.h>

#define kPRODUCT_ID @"com.thankyousoft.chickenslider.maps.map02"
//#define kPRODUCT_ID @"com.thankyousoft.rocknroll.map02"

#define kInAppPurchaseManagerProductsFetchedNotification @"kInAppPurchaseManagerProductsFetchedNotification"

// add a couple notifications sent out when the transaction completes
#define kInAppPurchaseManagerTransactionFailedNotification @"kInAppPurchaseManagerTransactionFailedNotification"
#define kInAppPurchaseManagerTransactionSucceededNotification @"kInAppPurchaseManagerTransactionSucceededNotification"

@protocol IAPDelegate <NSObject>

-(void)onFinishIAP:(NSString *)product;

@end

@interface InAppPurchaseManager : NSObject <SKProductsRequestDelegate, SKPaymentTransactionObserver>
{
    SKProduct *proUpgradeProduct;
    SKProductsRequest *productsRequest;
}

@property (retain,nonatomic) id<IAPDelegate> delegate;

// public methods
- (void)loadStore;
- (BOOL)canMakePurchases;
- (void)purchaseProUpgrade;
- (BOOL)didPurchase;

@end