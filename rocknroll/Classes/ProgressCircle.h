//
//  ProgressCircle.h
//  rocknroll
//
//  Created by 김 강모 on 11. 10. 11..
//  Copyright 2011년 강모소프트. All rights reserved.
//

#import "cocos2d.h"

@interface ProgressCircle : CCNode
{
    CCProgressTimer * progressTimer_;
    ccTime acculuatedTime_;
    BOOL isStarted_;
}
-(void) start ;
-(void) stop ;

@end
