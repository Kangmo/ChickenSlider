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

#import "AdLayer.h"
#import "GeneralMessageProtocol.h"

#import "TxWidget.h"
#import "GamePlayLayer.h"

class b2WorldEx;
@class Sky;

typedef enum {
    StageSceneLayerTagStage=1,
    StageSceneLayerTagGamePlayUI=2,
    StageSceneLayerTagInput=3
} StageSceneLayerTags;

@class GamePlayLayer;

// HelloWorld Layer
@interface StageScene : AdLayer<ScoreBoardProtocol, TutorialBoardProtocol, GeneralMessageProtocol, TxWidgetListener>
{
    // The layer containing game play UI such as scores, time left etc.
    GamePlayLayer * playUI;
    // The name of the map where the stage exists
    NSString * mapName;
    // The current number of level in the map
    int level;
    // The name of the ending scene. The scene will be shown using IntermediateScene class before showing the clear scene.
    NSString * closingScene;
    // +++++++++ Attributes read from the stage SVG file +++++++++++++
    // The background music file.
    NSString * musicFileName;
    // The background image file.
    NSString * backgroundImage;
    // The ground texture image
    NSString * groundTexture;
    // The play time(second) that the user should finish the game for the stage.
    int playTimeSec;
    // The number of chicks to save for one star.
    int oneStarCount;
    // The number of chicks to save for two stars.
    int twoStarCount;
    // The number of chicks to save for three stars.
    int threeStarCount;
    // -------- Attributes read from the stage SVG file ------------
    
    // Did we gave up stage?
    BOOL gaveUpStage;
    
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
    
    // sb means score board
    int sbChicks;
    int sbScore;
    int sbKeys;
    float sbSpeedRatio;
    float sbSecondsLeft;
    // The recent second that we printed on the scoreboard.
    int   sbRecentSecond;
    // The maximum combo count
    int   maxComboCount;
    
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
    
    BOOL isHardMode;
}

@property (nonatomic, assign) Car * car;
@property (nonatomic, retain) Hero * hero;

// returns a Scene that contains the HelloWorld as the only child
+(CCScene*) sceneInMap:(NSString*)mapName levelNum:(int)level;
+(StageScene*) sharedStageScene;
-(BOOL) needJoystick;

-(void) finishStageWithMessage:(NSString*)message stageCleared:(BOOL)clearedCurrentStage;

-(void) giveUpGame:(NSString*)message;
-(void) resumeGame;


@end
