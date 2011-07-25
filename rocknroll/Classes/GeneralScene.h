//
//  GeneralScene.h
//  rocknroll
//
//  Created by 강모 김 on 11. 7. 22..
//  Copyright 2011 강모소프트. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
class b2World;
@interface GeneralScene : CCLayer {
    b2World * world_;
}

+(CCScene*)sceneWithName:sceneName;

@end
