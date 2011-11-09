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
    int levelCount;
    InteractiveSprite * intrSprites[MAX_LEVELS_PER_MAP];
    // The highest unlocked level.
    int highestUnlockedLevel;
    // The level that the Hero is shown on the level map
    int currentHeroLevel;
    
    // The hero sprite to show on the map.
    CCSprite * _heroSprite;
    
    // Animation Clips
    CCAction * _heroWaitingAction;
    
    // For reserving hero movement by the time scene is shown on the screen.
    BOOL moveHeroReserved;
    int reservedCurrentLevel;
    int reservedTargetLevel;
    
    BOOL isTryingToPlayLevel;
}

+(CCScene*)sceneWithName:(NSString*)sceneName;
+(CCScene*)sceneWithName:(NSString*)sceneName level:(int)level cleared:(BOOL)cleared;
-(void) playLevel:(int)levelNum ofMap:(NSString*)mapNameAttr;

@end
