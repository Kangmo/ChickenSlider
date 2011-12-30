//
//  OfflineAdView.h
//  rocknroll
//
//  Created by 김 강모 on 11. 12. 21..
//  Copyright (c) 2011년 강모소프트. All rights reserved.
//

#import <UIKit/UIKit.h>

#define OFFLINE_AD_WIDTH (480)
#define OFFLINE_AD_HEIGHT (32)

@interface OfflineAdView : UIView
{
    NSTimer * rolloverTimer;
    UIButton * adButton;
    // The AD we are showing. starts from 0.
    int adNum;
}

@end
