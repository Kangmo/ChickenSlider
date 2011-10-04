#import <Foundation/Foundation.h>
#import "cocos2d.h"
class b2WorldEx;
@interface GeneralScene : CCLayer {  
    b2WorldEx * world_;
}

+(CCScene*)sceneWithName:sceneName;

// initialize your instance here
-(id) initWithSceneName:(NSString*)sceneName;

@end
