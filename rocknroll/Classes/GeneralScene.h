//
//  GeneralScene.h
//  rocknroll
//
//  Created by 강모 김 on 11. 7. 22..
//  Copyright 2011 강모소프트. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
class b2WorldEx;
@interface GeneralScene : CCLayer {
    b2WorldEx * world_;
}

+(CCScene*)sceneWithName:sceneName;

@end
