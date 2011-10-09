//
//  AdLayer.h
//  rocknroll
//
//  Created by 김 강모 on 11. 10. 9..
//  Copyright 2011년 강모소프트. All rights reserved.
//

#import "CCLayer.h"
#import <iAd/iAd.h>

@interface AdLayer : CCLayer<ADBannerViewDelegate>
{
    ADBannerView *adView;
}
@property(assign, nonatomic) BOOL enableAD;
@end
