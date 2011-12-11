//
//  GamePlayLayer.h
//  rocknroll
//
//  Created by 김 강모 on 11. 11. 21..
//  Copyright (c) 2011년 강모소프트. All rights reserved.
//

#import "GeneralScene.h"

// WidgetFactory has all widgets included.
#include "TxWidgetFactory.h"

@interface GamePlayLayer : GeneralScene
{
    REF(TxIntegerLabel) keyCount_ ;
    REF(TxIntegerLabel) chickCount_ ;
    REF(TxLabel) sandClockSeconds_ ;
    REF(TxLabel) count_ ;
    REF(TxLabel) unit_ ;
    REF(TxLabel) message_ ;
    REF(TxSandClock) sandClock_ ;
    REF(TxFloatLabel) speed_ ;
    REF(TxIntegerLabel) score_ ;
    REF(TxLabel) mapPosition_ ;
    
    int totalSeconds_;
}

+(id)layerWithSceneName:(NSString*)sceneName;
-(void) update: (ccTime) dt;
-(void) setSpeedRatio:(float) speedRatio;
-(void) setScore:(int) score;
-(void) setKeys:(int)keys;
-(void) setChicks:(int)chicks;
-(void) setSecondsLeft:(float)secondsLeft;
-(void) showMessage:(NSString*) message ;
-(void) setMapPosition:(float)mapPositionX;
-(void) showCombo:(int)combo;

@end
