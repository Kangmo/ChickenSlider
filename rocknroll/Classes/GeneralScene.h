#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "AdLayer.h"

typedef enum {
    GeneralSceneLayerTagMain=1
} GeneralSceneLayerTags;

class b2WorldEx;
@interface GeneralScene : AdLayer {  
    b2WorldEx * world_;
    NSString * sceneName_;
}

// For the case this scene is "pushed", keep the previous layer that pushed this Scene.
@property(nonatomic,retain) CCLayer * previousLayer;
@property(nonatomic,assign) int loadingLevel;
@property(nonatomic,retain) NSString * loadingLevelMapName;

+(CCScene*)sceneWithName:(NSString*)sceneName;
+(CCScene*)sceneWithName:(NSString*)sceneName previousLayer:(CCLayer*)pl;
+(CCScene*)loadingSceneOfMap:(NSString*)mapName levelNum:(int)level;

// initialize your instance here
-(id) initWithSceneName:(NSString*)sceneName;

@end
