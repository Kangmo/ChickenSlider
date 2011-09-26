#import "cocos2d.h"
#import "Box2D.h"
#import "GLES-Render.h"
#import "JointDeclaration.h"
#import "svgLoader.h"
#import "ClassDictionary.h"
#import "AbstractCamera.h"
#import "FreeCamera.h"
#import "FollowCamera.h"
#include "Car.h"
#include "Hero.h"
#include "GameConfig.h"

class b2WorldEx;

typedef enum {
    StageSceneLayerTagStage=1,
    StageSceneLayerTagInput
} StageSceneLayerTags;

// HelloWorld Layer
@interface StageScene : CCLayer
{
	b2WorldEx* world;
	GLESDebugDraw *m_debugDraw;
	
	CCSprite * arrow;
	
	AbstractCamera * cam;
	
	Car * car;
	Hero * hero;
    
    NSMutableArray * terrains;
    
	float st;
}

// returns a Scene that contains the HelloWorld as the only child
+(CCScene*) sceneWithLevel:(NSString*)levelStr;
+(StageScene*) sharedStageScene;
-(BOOL) needJoystick;

@property (nonatomic, assign) Car * car;
@property (nonatomic, retain) Hero * hero;

@end
