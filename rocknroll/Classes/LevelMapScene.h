//
//  LevelMapScene.h
//  rocknroll
//
//  Created by 김 강모 on 11. 10. 3..
//  Copyright 2011년 강모소프트. All rights reserved.
//

#import "GeneralScene.h"
#import "InteractiveSprite.h"
#import "GameObject.h"

@interface LevelMapScene : GeneralScene
{
    int minLevel;
    int maxLevel;
    
    InteractiveSprite * intrSprites[MAX_LEVELS_PER_MAP];
    // The highest unlocked level.
    int highestUnlockedLevel;
    
    BOOL isTryingToPlayLevel;
    
    NSString * mapName_;
}


+(CCScene*)sceneWithName:(NSString*)sceneName;
+(CCScene*)sceneWithName:(NSString*)sceneName level:(int)level cleared:(BOOL)cleared;

@end
