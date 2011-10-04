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
}

+(CCScene*)sceneWithName:(NSString*)sceneName;

@end
