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
#include "HealthBar.h"
#include "FloatLabel.h"

#import"AdLayer.h"

class b2WorldEx;
@class Sky;

typedef enum {
    StageSceneLayerTagStage=1,
    StageSceneLayerTagInput
} StageSceneLayerTags;

// HelloWorld Layer
@interface StageScene : AdLayer<ScoreBoardProtocol, TutorialBoardProtocol>
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
    
    int curFeathers;
    int targetFeathers;
    IncNumLabel feathersLabel;
    IncNumLabel scoreLabel;
    HealthBar   healthBar;
    FloatLabel *speedRatioLabel;
    
    CCSpriteBatchNode * spriteSheet;

    // The tutorial label to show on screen. While this is shown, the game is paused. If the user touches, the game resumes.
    // TutorialBox game object sets this text via TutorialBoardProtocol. Touch handler sets this to null removing it from the screen.
    CCLabelBMFont * tutorialLabel;
    BOOL stageCleared;

    // Indicates that the game was paused to show the tutorial text.
    BOOL isGamePaused;
    
    float worldGroundY;
    // The X position of the hero by the time we removed the game objects that went behind the left side of the screen.
    float heroXatZ1_ofLastGameObjectRemoval;
}

@property (nonatomic, assign) Car * car;
@property (nonatomic, retain) Hero * hero;
@property (nonatomic, assign) BOOL giveUpStage;

// returns a Scene that contains the HelloWorld as the only child
+(CCScene*) sceneInMap:(NSString*)mapName levelNum:(int)level;
+(StageScene*) sharedStageScene;
-(BOOL) needJoystick;

-(void) increaseScore:(int) scoreDiff;
-(void) increaseFeathers:(int) feathersDiff;

- (void) finishStageWithMessage:(NSString*)message stageCleared:(BOOL)clearedCurrentStage;
@end
