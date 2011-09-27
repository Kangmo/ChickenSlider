#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface AKCCRandomDelayTime : CCDelayTime {
    ccTime minDuration;
    ccTime maxDuration;
}

+ (id)actionWithMinDuration:(ccTime)minDur maxDuration:(ccTime)maxDur;
- (id)initWithMinDuration:(ccTime)minDur maxDuration:(ccTime)maxDur;

@end
