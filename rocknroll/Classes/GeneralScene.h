#import <Foundation/Foundation.h>
#import "cocos2d.h"
class b2WorldEx;
@interface GeneralScene : CCLayer {
    b2WorldEx * world_;
}

+(CCScene*)sceneWithName:sceneName;

@end
