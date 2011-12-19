//
//  AdLayer.h
//  rocknroll
//
//  Created by 김 강모 on 11. 10. 9..
//  Copyright 2011년 강모소프트. All rights reserved.
//

// Followed tutorial from http://emeene.com/2010/10/adwhirl-cocos2d-iphone/

#import "AdWhirlDelegateProtocol.h"
#import "RootViewController.h"

@interface AdManager : NSObject<AdWhirlDelegate>
{
    //Here is the important code we'll use
    AdWhirlView *adView;
    //This is a trick, AdMob uses a viewController to display its Ads, trust me, you'll need this
    RootViewController *viewController;

    CGSize screenSize;

}

// return the AdManager singleton.
+(AdManager*) sharedAdManager;

@property(assign, nonatomic) CGSize screenSize;

@property(nonatomic,retain) AdWhirlView *adView;

@property(assign, nonatomic) BOOL hasAD;
-(void)createAD;
-(void)removeAD;

-(void)refresh;
-(void)enableRefresh;
-(void)disableRefresh;
-(BOOL)isRefreshEnabled;

@end
