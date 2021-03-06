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
    
    TxImageArray * playersGround_ ;
    TxAnimationClip * player1_ ; // The hero
    
    TxAnimationClip * player2_ ;
    TxAnimationClip * player3_ ;
    TxAnimationClip * player4_ ;
    
    TxLabel * player1Alias_ ;
    TxLabel * player2Alias_ ;
    TxLabel * player3Alias_ ;
    TxLabel * player4Alias_ ;

    TxAnimationClip * touchTutorClip_ ;
    TxAnimationClip * stageClearClip_ ;
    TxAnimationClip * stageTimeoutClip_ ;

    int totalSeconds_;
    int nHighScore_;
    int nScore_;
    
    int prevMapProgress;
    
    NSString * player2_id_;
    NSString * player3_id_;
    NSString * player4_id_;
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
-(void) showCombo:(int)combo;
-(void) startStageClearAnim ;
-(void) startStageTimeoutAnim;
-(void) showTouchTutor:(BOOL)bShow;

// Set map progress for other players
-(void) setProgress:(int)mapProgress position:(CGPoint)position player:(NSString*)playerID;

// Set map progress for the hero
-(void) setMapProgress:(int)mapProgress;
-(void) setHeroAlias:(NSString*)heroAlias;

@end
