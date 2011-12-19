#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "CCLayer.h"
#import "ProgressCircle.h"
#import "GeneralMessageProtocol.h"
#import "TxWidgetContainer.h"
#import "TxWidget.h"
typedef enum {
    GeneralSceneLayerTagMain=100,
    GeneralSceneLayerTagRealQuit=101 // The layer for asking if the user really wants to quit the stage.
} GeneralSceneLayerTags;

class b2WorldEx;
@interface GeneralScene : CCLayer<GeneralMessageProtocol, TxWidgetListener> {  
    b2WorldEx * world_;
    NSString * sceneName_;

    BOOL didStartLoading_;
    TxWidgetContainer * widgetContainer_;
    
    // The background music
    NSString * backgroundMusic_;
    
    // For scrolling background
    float beforeScrollSleepSec_; // Before scrolling, sleep beforeScrollSleepSec_ seconds.
    int backgroundWidth_; 
    CCParallaxNode *parallaxNode_;
    CGPoint parallexPosition_;
    BOOL loopParallax_; // Scroll over and over?
    
    BOOL tryToRefreshAD_; // Need to try to refresh ADs whenever this scene is shown?
}

// The listener that listens to action messages from this dialog layer.
// Ex1> GeneralScene(PauseLayer.svg) sends "Resume" or "Quit" message to StageScene. 
// Ex2> GeneralScene(ConfirmQuitLayer.svg) sends "Quit" or "Cancel" to GeneralScene(PauseLayer.svg)
@property(nonatomic,assign) id<GeneralMessageProtocol> actionListener;
@property(nonatomic,assign) int loadingLevel;
@property(nonatomic,retain) NSString * loadingLevelMapName;


+(id)nodeWithSceneName:(NSString*)sceneName;
+(CCScene*)sceneWithName:(NSString*)sceneName;
+(CCScene*)loadingSceneOfMap:(NSString*)mapName levelNum:(int)level;

// initialize your instance here
-(id) initWithSceneName:(NSString*)sceneName;

@end
