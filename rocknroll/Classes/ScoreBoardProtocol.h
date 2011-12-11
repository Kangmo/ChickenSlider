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
-(void) increaseKeys:(int) keysDiff;
-(int) getKeys;
-(void) setKeys:(int)keys;
-(void) increaseChicks:(int) chicksDiff;
-(int) getChicks;
-(void) setChicks:(int)chicks;
-(void) setSecondsLeft:(float)secondsLeft;
-(void) showMessage:(NSString*) message;
-(void) showCombo:(int)combo;
@end
