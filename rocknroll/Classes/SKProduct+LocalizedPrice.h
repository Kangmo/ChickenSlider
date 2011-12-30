//
//  SKProduct+LocalizedPrice.h
//  rocknroll
//
//  Created by 김 강모 on 11. 12. 23..
//  Copyright (c) 2011년 강모소프트. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

@interface SKProduct (LocalizedPrice)

@property (nonatomic, readonly) NSString *localizedPrice;

@end


