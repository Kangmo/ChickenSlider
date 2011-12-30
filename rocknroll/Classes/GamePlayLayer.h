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
    // These pointers are all weak references. 
    // It is fine to use weak references here, because widgetContainer_ in GeneralScene has strong reference to these objects.
    // We should not use boost::shared_ptr, because Objective-C++ class does not call destructors on member variables whose types are C++ classes 

    
    TxLabel * stageName_ ;
    TxIntegerLabel * keyCount_ ;
    TxIntegerLabel * chickCount_ ;
    TxLabel * sandClockSeconds_ ;
    TxLabel * count_ ;
    TxLabel * unit_ ;
    TxLabel * message_ ;
    TxSandClock * sandClock_ ;
    TxFloatLabel * speed_ ;
    TxIntegerLabel * score_ ;
    TxLabel * highScore_ ;
    TxLabel * mapPosition_ ;
    
    
    TxAnimationClip * touchTutorClip_ ;
    TxAnimationClip * stageClearClip_ ;
    TxAnimationClip * stageTimeoutClip_ ;

    int totalSeconds_;
    int nHighScore_;
    int nScore_;
    
    int prevMapProgress;
}

+(id)layerWithSceneName:(NSString*)sceneName;
-(void) update: (ccTime) dt;
-(void) setStageName:(NSString*)stageName;
-(void) setSpeedRatio:(float) speedRatio;
-(BOOL) isNewHighScore;
-(void) setHighScore:(int)highScore;
-(void) setScore:(int) score;
-(void) setKeys:(int)keys;
-(void) setChicks:(int)chicks;
-(void) setSecondsLeft:(float)secondsLeft;
-(void) showMessage:(NSString*) message ;
-(void) setMapProgress:(int)mapProgress;
-(void) showCombo:(int)combo;
-(void) startStageClearAnim ;
-(void) startStageTimeoutAnim;
-(void) showTouchTutor:(BOOL)bShow;

@end
