#import "cocos2d.h"
#import "Box2D.h"
#import "GLES-Render.h"
#import "JointDeclaration.h"
#import "svgLoader.h"
#import "ClassDictionary.h"
#import "AbstractCamera.h"
#import "FreeCamera.h"
#import "FollowCamera.h"
#import "ScoreBoardProtocol.h"

#include "Car.h"
#include "Hero.h"
#include "GameConfig.h"
#include "GameObjectContainer.h"
#include "IncNumLabel.h"

#import"AdLayer.h"

class b2WorldEx;
@class Sky;

typedef enum {
    StageSceneLayerTagStage=1,
    StageSceneLayerTagInput
} StageSceneLayerTags;

// HelloWorld Layer
@interface StageScene : AdLayer<ScoreBoardProtocol>
{
    // The name of the map where the stage exists
    NSString * mapName;
    // The current number of level in the map
    int level;

    b2WorldEx* world;
	GLESDebugDraw *m_debugDraw;
	
	CCSprite * arrow;
	
	AbstractCamera * cam;
	
	Car * car;
	Hero * hero;
    
    NSMutableArray * terrains;
    // The maximum X of all terrains. If the hero goes beyond of it, the stage is cleared!
    float terrainMaxX;
    
	float st;
    
    Sky * sky;
    
    // The container that holds game objects. These are not defined as Box2D objects. 
    // Puting these objects (ex> 1000 Water Drops, not box2d objects, just stay at a static position) into Box2d make the game terribly slow.
    // We do collision detection on these objects with the Hero.
    GameObjectContainer gameObjectContainer;
    
    int curWaterDrops;
    int targetWaterDrops;
    IncNumLabel waterDropsLabel;
    IncNumLabel scoreLabel;
    
    CCSpriteBatchNode * spriteSheet;

    BOOL stageCleared;
}

@property (nonatomic, assign) Car * car;
@property (nonatomic, retain) Hero * hero;
@property (nonatomic, assign) BOOL giveUpStage;

// returns a Scene that contains the HelloWorld as the only child
+(CCScene*) sceneInMap:(NSString*)mapName levelNum:(int)level;
+(StageScene*) sharedStageScene;
-(BOOL) needJoystick;

-(void) increaseScore:(int) scoreDiff;
-(void) increaseWaterDrops:(int) waterDropsDiff;

- (void) finishStageWithMessage:(NSString*)message stageCleared:(BOOL)clearedCurrentStage;

@end
