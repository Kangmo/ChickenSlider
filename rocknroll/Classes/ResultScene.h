//
//  ResultScene.h
//  rocknroll
//
//  Created by 김 강모 on 11. 11. 21..
//  Copyright (c) 2011년 강모소프트. All rights reserved.
//

#import "GeneralScene.h"

#include "TxWidgetFactory.h"

@interface ResultScene : GeneralScene
{
    // Information on the cleared stage.
    NSString * mapName_;
    int level_;
    
    // Indicates if the cleared stage was the last stage
    BOOL lastStage_;
    
    // These pointers are all weak references. 
    // It is fine to use weak references here, because widgetContainer_ in GeneralScene has strong reference to these objects.
    // We should not use boost::shared_ptr, because Objective-C++ class does not call destructors on member variables whose types are C++ classes 
    TxImageArray * clearMessage_;
    TxLabel * player1Name_;
    TxLabel * player1Time_;
    TxLabel * player2Name_;
    TxLabel * player2Time_;
    TxLabel * player3Name_;
    TxLabel * player3Time_;
    TxLabel * player4Name_;
    TxLabel * player4Time_;
    TxIntegerLabel * score_;

//    int maxLevel_;
}

+(CCScene*) sceneWithMap:(NSString*)mapName 
                   level:(int)level
               lastStage:(BOOL)lastStage
                   score:(int)score 
                    keys:(int)keys 
                  chicks:(int)chicks 
                   stars:(int)stars 
                maxCombo:(int)maxComboCount
               timeSpent:(float)timeSpent
                timeLeft:(float)timeLeft;

@end
