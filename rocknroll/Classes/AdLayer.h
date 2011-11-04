//
//  AdLayer.h
//  rocknroll
//
//  Created by 김 강모 on 11. 10. 9..
//  Copyright 2011년 강모소프트. All rights reserved.
//

#import "CCLayer.h"

// Followed tutorial from http://emeene.com/2010/10/adwhirl-cocos2d-iphone/

#import "AdWhirlDelegateProtocol.h"
#import "RootViewController.h"

@interface AdLayer : CCLayer<AdWhirlDelegate>
{
    //Here is the important code we'll use
    AdWhirlView *adView;
    //This is a trick, AdMob uses a viewController to display its Ads, trust me, you'll need this
    RootViewController *viewController;

    CGSize screenSize;
}

@property(assign, nonatomic) CGSize screenSize;
@property(assign, nonatomic) BOOL enableAD;
@property(nonatomic,retain) AdWhirlView *adView;

@end
