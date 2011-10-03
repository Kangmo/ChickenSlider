//
//  LevelMapScene.h
//  rocknroll
//
//  Created by 김 강모 on 11. 10. 3..
//  Copyright 2011년 강모소프트. All rights reserved.
//

#import "GeneralScene.h"
#import "InteractiveBodyNode.h"
#import "GameObject.h"

@interface LevelMapScene : GeneralScene
    InteractiveBodyNode * levels[MAX_LEVELS_PER_MAP];
// Have level map rocks here. 
@end
