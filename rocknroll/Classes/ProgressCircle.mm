//
//  ProgressCircle.m
//  rocknroll
//
//  Created by 김 강모 on 11. 10. 11..
//  Copyright 2011년 강모소프트. All rights reserved.
//

#import "ProgressCircle.h"
#import "Util.h"

@implementation ProgressCircle

- (id)init
{
    self = [super init];
    if (self) {
        /*
        // DEBUG
        CCSprite * sprite = [[CCSprite spriteWithFile:@"Progress.png"] retain];
        [self addChild:sprite];
        sprite.position = CGPointMake(50,50);
        // DEBUG
        */
        
        // Initialization code here.
        acculuatedTime_ = 0;
        
        progressTimer_ = [[CCProgressTimer progressWithFile:@"Progress.png"] retain];
        assert(progressTimer_);
        progressTimer_.type = kCCProgressTimerTypeRadialCCW;
        progressTimer_.percentage = 0;
        
        isStarted_ = NO;
    }
    
    return self;
}

-(void)dealloc {
    [progressTimer_ release];
    progressTimer_ = nil;
    
    [super dealloc];
}

-(void) update:(ccTime)delta
{
    const float PROGRESS_DURATION_SECONDS = 3;
    
    acculuatedTime_ += delta;
    if ( acculuatedTime_ > PROGRESS_DURATION_SECONDS )
    {
        acculuatedTime_ = 0;
    }
    
    float percentage = acculuatedTime_/PROGRESS_DURATION_SECONDS * 100;
    progressTimer_.percentage = percentage;
    
    //CCLOG(@"Changed Circle Progress:%f%%",percentage);
}

-(void) start {
    if (! isStarted_)
    {
        [self addChild:progressTimer_];
        progressTimer_.position = [Util getCenter:self];
        
        [self scheduleUpdate];
        
        isStarted_ = YES;
    }
}

-(void) stop {
    if (isStarted_)
    {
        [self removeChild:progressTimer_ cleanup:NO];
        [self unscheduleAllSelectors];
    }
    
    isStarted_ = NO;
}

@end
