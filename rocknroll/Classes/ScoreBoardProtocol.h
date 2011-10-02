//
//  ScoreBoardProtocol.h
//  rocknroll
//
//  Created by 김 강모 on 11. 10. 3..
//  Copyright 2011년 강모소프트. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ScoreBoardProtocol <NSObject>
-(void) increaseScore:(int) scoreDiff;
-(void) increaseWaterDrops:(int) waterDropsDiff;
@end
