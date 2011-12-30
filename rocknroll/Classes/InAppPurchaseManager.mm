//
//  InAppPurchaseManager.m
//  rocknroll
//
//  Created by 김 강모 on 11. 12. 23..
//  Copyright (c) 2011년 강모소프트. All rights reserved.
//

#import "InAppPurchaseManager.h"
#include "AppAnalytics.h"
#import "FlurryAnalytics.h"
#import "Util.h"

@implementation InAppPurchaseManager
@synthesize delegate;

// InAppPurchaseManager.m
- (void)requestProUpgradeProductData
{
    NSSet *productIdentifiers = [NSSet setWithObject:kPRODUCT_ID ];
    productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:productIdentifiers];
    productsRequest.delegate = self;
    [productsRequest start];
    
    // we will release the request object in the delegate callback
}

#pragma mark -
#pragma mark SKProductsRequestDelegate methods

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    NSArray *products = response.products;
    proUpgradeProduct = [products count] == 1 ? [[products objectAtIndex:0] retain] : nil;
    if (proUpgradeProduct)
    {
        NSLog(@"Product title: %@" , proUpgradeProduct.localizedTitle);
        NSLog(@"Product description: %@" , proUpgradeProduct.localizedDescription);
        NSLog(@"Product price: %@" , proUpgradeProduct.price);
        NSLog(@"Product id: %@" , proUpgradeProduct.productIdentifier);


        std::string prodId = [Util toStdString:proUpgradeProduct.productIdentifier];
        
        AppAnalytics::sharedAnalytics().logEvent( "IAP:RECEIVED_PROD_INFO:"+prodId );
    }
    
    for (NSString *invalidProductId in response.invalidProductIdentifiers)
    {
        NSLog(@"Invalid product id: %@" , invalidProductId);
        std::string invalidProductIdStr = [Util toStdString:invalidProductId];
        
        AppAnalytics::sharedAnalytics().logEvent( "IAP:INVALID_PROD_ID:"+invalidProductIdStr );
        
        [Util showAlertWithTitle:@"Invalid Product ID" message:invalidProductId];

    }
    
    // finally release the reqest we alloc/init’ed in requestProUpgradeProductData
    [productsRequest release];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kInAppPurchaseManagerProductsFetchedNotification object:self userInfo:nil];
}




#pragma -
#pragma Public methods

//
// call this method once on startup
//
- (void)loadStore
{
    // restarts any purchases if they were interrupted last time the app was open
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    
    // get the product description (defined in early sections)
    [self requestProUpgradeProductData];
}

//
// call this before making a purchase
//
- (BOOL)canMakePurchases
{
    return [SKPaymentQueue canMakePayments];
}

//
// kick off the upgrade transaction
//
- (void)purchaseProUpgrade
{
    SKPayment *payment = [SKPayment paymentWithProductIdentifier:kPRODUCT_ID];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

#pragma -
#pragma Purchase helpers

//
// saves a record of the transaction by storing the receipt to disk
//
- (void)recordTransaction:(SKPaymentTransaction *)transaction
{
    if ([transaction.payment.productIdentifier isEqualToString:kPRODUCT_ID])
    {
        // save the transaction receipt to disk
        [[NSUserDefaults standardUserDefaults] setValue:transaction.transactionReceipt forKey:@"proUpgradeTransactionReceipt" ];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

//
// enable pro features
//
- (void)provideContent:(NSString *)productId
{
    if ([productId isEqualToString:kPRODUCT_ID])
    {
        // enable the pro features
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isProUpgradePurchased" ];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [self.delegate onFinishIAP:productId];
    }
}

- (BOOL)didPurchase
{
    BOOL didPurchase = NO;
    
    // enable the pro features
    didPurchase = [[NSUserDefaults standardUserDefaults] boolForKey:@"isProUpgradePurchased" ];
    
    return didPurchase;
}

//
// removes the transaction from the queue and posts a notification with the transaction result
//
- (void)finishTransaction:(SKPaymentTransaction *)transaction wasSuccessful:(BOOL)wasSuccessful
{
    // remove the transaction from the payment queue.
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:transaction, @"transaction" , nil];
    if (wasSuccessful)
    {
        // send out a notification that we’ve finished the transaction
        [[NSNotificationCenter defaultCenter] postNotificationName:kInAppPurchaseManagerTransactionSucceededNotification object:self userInfo:userInfo];
    }
    else
    {
        // send out a notification for the failed transaction
        [[NSNotificationCenter defaultCenter] postNotificationName:kInAppPurchaseManagerTransactionFailedNotification object:self userInfo:userInfo];
    }
}

//
// called when the transaction was successful
//
- (void)completeTransaction:(SKPaymentTransaction *)transaction
{
    [self recordTransaction:transaction];
    [self provideContent:transaction.payment.productIdentifier];
    [self finishTransaction:transaction wasSuccessful:YES];

    AppAnalytics::sharedAnalytics().logEvent( "IAP:COMPLETE_TRANSACTION" );
}

//
// called when a transaction has been restored and and successfully completed
//
- (void)restoreTransaction:(SKPaymentTransaction *)transaction
{
    [self recordTransaction:transaction.originalTransaction];
    [self provideContent:transaction.originalTransaction.payment.productIdentifier];
    [self finishTransaction:transaction wasSuccessful:YES];
    
    AppAnalytics::sharedAnalytics().logEvent( "IAP:RESTORE_TRANSACTION" );
}

//
// called when a transaction has failed
//
- (void)failedTransaction:(SKPaymentTransaction *)transaction
{
    if (transaction.error.code != SKErrorPaymentCancelled)
    {
        // error!
        [self finishTransaction:transaction wasSuccessful:NO];
        
        [FlurryAnalytics logError:@"IAP:FAILED_TRANSACTION" message:@"IAP Failed" error:transaction.error];

        NSString * message = [NSString stringWithFormat:@"%@", transaction.error];
        [Util showAlertWithTitle:@"Payment Failed" message:message];
        
        CCLOG(@"IAP:FAILED_TRANSACTION:%@", message);
    }
    else
    {
        // this is fine, the user just cancelled, so don’t notify
        [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
        
        AppAnalytics::sharedAnalytics().logEvent( "IAP:USER_CANCELED" );
    }
}

#pragma mark -
#pragma mark SKPaymentTransactionObserver methods

//
// called when the transaction status is updated
//
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    for (SKPaymentTransaction *transaction in transactions)
    {
        switch (transaction.transactionState)
        {   // Transaction is being added to the server queue.

            case SKPaymentTransactionStatePurchased:
                [self completeTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                [self failedTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:
                [self restoreTransaction:transaction];
                break;
            case SKPaymentTransactionStatePurchasing:
                AppAnalytics::sharedAnalytics().logEvent( "IAP:PURCHASING" );
                break;
            default:
                NSString * message = [NSString stringWithFormat:@"Code: %d", (int)transaction.transactionState];
                AppAnalytics::sharedAnalytics().logEvent( "IAP:Unkown_Payment_Transaction" + [Util toStdString:message]);

                [Util showAlertWithTitle:@"Unkown Payment Transaction" message:message];

                break;
        }
    }
}
@end

