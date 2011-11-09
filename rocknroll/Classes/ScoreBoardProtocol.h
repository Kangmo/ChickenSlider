//
//  ScoreBoardProtocol.h
//  rocknroll
//
//  Created by 김 강모 on 11. 10. 3..
//  Copyright 2011년 강모소프트. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ScoreBoardProtocol <NSObject>
-(void) increaseSpeedRatio:(float) speedRatioDiff;
-(void) setSpeedRatio:(float) speedRatio;
-(void) increaseScore:(int) scoreDiff;
-(void) increaseFeathers:(int) featherDiff;
-(void) increaseLife:(float)lifePercentDiff;
-(void) decreaseLife:(float)lifePercentDiff;
-(void) showMessage:(NSString*) message;
@end
