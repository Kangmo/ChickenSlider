#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Box2D.h"
#import "ScoreBoardProtocol.h"


#define kPerfectTakeOffVelocityY 2.0f

@class AbstractCamera;
class HeroContactListener;

@interface Hero :NSObject {
	b2World *_world;
	b2Body *_body;
    // Score Board
    id<ScoreBoardProtocol> _scoreBoard;
    
    AbstractCamera * _camera;

	float _radius;
	BOOL _awake;
	BOOL _flying;
	BOOL _diving;

    BOOL _hasWings;

	HeroContactListener *_contactListener;
	int _nPerfectSlides;
    
    // Currently running clip 
    CCAction * _currentAction;
    
    // Animation Clips
    CCAction * _nowingsAction;
    CCAction * _droppingAction;
    CCAction * _flyingAction;
    CCAction * _walkingAction;
}
@property (nonatomic, assign) b2World *world;
@property (nonatomic, assign) b2Body *body;
@property (readonly) BOOL awake;
@property (nonatomic) BOOL diving;
@property (readonly, nonatomic) BOOL flying;
@property (nonatomic) BOOL isDead;
@property (readonly) BOOL hasWings;

+ (id) heroWithWorld:(b2World*)world heroBody:(b2Body*)body camera:(AbstractCamera*)camera scoreBoard:(id<ScoreBoardProtocol>)sb;
- (id) initWithWorld:(b2World*)world heroBody:(b2Body*)body camera:(AbstractCamera*)camera scoreBoard:(id<ScoreBoardProtocol>)sb;

- (CCSprite*) getSprite;

- (void) reset;
- (void) sleep;
- (void) wake;
- (void) updatePhysics;
- (void) updateNode;

- (void) landed;
- (void) tookOff;
// Hit on the ground
- (void) hit;
// Health bar reached at 0%. Drop the wings.
- (void) dropWings;
- (void) dead;


@end
