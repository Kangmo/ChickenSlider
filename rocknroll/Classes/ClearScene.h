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
    
    REF(TxImageArray) starPoints_;
    REF(TxImageArray) clearMessage_;
    REF(TxLabel) keys_;
    REF(TxLabel) chicks_;
    REF(TxLabel) totalChicks_;
    REF(TxLabel) time_;
    REF(TxLabel) maxCombo_;
    REF(TxIntegerLabel) score_;

//    int maxLevel_;
}

+(CCScene*) sceneWithMap:(NSString*)mapName 
                   level:(int)level
                   score:(int)score 
                    keys:(int)keys 
                  chicks:(int)chicks 
                   stars:(int)stars 
                maxCombo:(int)maxComboCount
               timeSpent:(float)timeSpent;

@end
