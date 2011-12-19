//
//  ClearScene.h
//  rocknroll
//
//  Created by 김 강모 on 11. 11. 21..
//  Copyright (c) 2011년 강모소프트. All rights reserved.
//

#import "GeneralScene.h"

#include "TxWidgetFactory.h"

@interface ClearScene : GeneralScene
{
    // Information on the cleared stage.
    NSString * mapName_;
    int level_;
    
    // Indicates if the cleared stage was the last stage
    BOOL lastStage_;
    
    // These pointers are all weak references. 
    // It is fine to use weak references here, because widgetContainer_ in GeneralScene has strong reference to these objects.
    // We should not use boost::shared_ptr, because Objective-C++ class does not call destructors on member variables whose types are C++ classes 
    TxImageArray * starPoints_;
    TxImageArray * clearMessage_;
    TxLabel * keys_;
    TxLabel * chicks_;
    TxLabel * totalChicks_;
    TxLabel * time_;
    TxLabel * maxCombo_;
    TxIntegerLabel * score_;
    TxImageArray * nextStageButton_;

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
