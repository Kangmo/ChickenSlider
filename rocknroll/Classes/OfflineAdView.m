//
//  OfflineAdView.m
//  rocknroll
//
//  Created by 김 강모 on 11. 12. 21..
//  Copyright (c) 2011년 강모소프트. All rights reserved.
//

#import "OfflineAdView.h"

@interface OfflineAdView()
-(void)onTouchAd:(id)obj;
-(void)setAd:(int)aAdNum;
-(void)rollover:(NSTimer *)timer;

@end
    
@implementation OfflineAdView

#define AD_ROLLOVER_INTERVAL (60.0)
#define MAX_AD_COUNT (3)
static NSString * AD_IMAGES[] = {
    @"ad_adver.png",
    @"ad_face.png",
    @"ad_twit.png",
};

static NSString * AD_URLS[] = {
    @"http://goo.gl/ldqtx",
    @"http://goo.gl/NmKLL",
    @"http://goo.gl/OhRe5",
};


-(id) init {
    if (self = [super init]) {
        adButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
        [self addSubview:adButton];
        /*
        UILabel * label = [[[UILabel alloc] init] autorelease];
        label.text=@"Kangmo@223339102409182409812049812094812094";
        [self addSubview:label];
        */
        [adButton addTarget:self 
                   action:@selector(onTouchAd:)
         forControlEvents:UIControlEventTouchDown];

        [self setAd:0];
        self.frame = adButton.frame;
        
        rolloverTimer = [NSTimer scheduledTimerWithTimeInterval:AD_ROLLOVER_INTERVAL
                                                         target:self
                                                       selector:@selector(rollover:)
                                                       userInfo:nil
                                                        repeats:YES];
        [rolloverTimer retain];
    }
    return self;
}

-(void)setAd:(int)aAdNum {
    assert(aAdNum >= 0 && aAdNum < MAX_AD_COUNT);
    adNum = aAdNum;
    
    NSString * adImage = AD_IMAGES[adNum];
    UIImage *buttonImage = [UIImage imageNamed:adImage];
    [adButton setBackgroundImage:buttonImage forState:UIControlStateNormal];
}

-(void)rollover:(NSTimer *)timer {
    int nextAdNum = (adNum + 1) % MAX_AD_COUNT;
    [self setAd:nextAdNum];
}

-(void)onTouchAd:(id)obj {
    NSString * adURL = AD_URLS[adNum];
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString: adURL]];
}

-(void)dealloc {
    [adButton release];
    adButton = nil;
    
    [rolloverTimer invalidate];
    [rolloverTimer release];
    rolloverTimer = nil;
}
@end
