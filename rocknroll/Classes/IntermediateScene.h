//
//  IntermediateScene.h
//  rocknroll
//
//  Created by 김 강모 on 11. 12. 14..
//  Copyright (c) 2011년 강모소프트. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "GeneralScene.h"

@interface IntermediateScene : GeneralScene
{
    CCScene * nextScene_;
}

+(CCScene*)sceneWithName:(NSString*)sceneName nextScene:(CCScene*)nextScene;

@end
