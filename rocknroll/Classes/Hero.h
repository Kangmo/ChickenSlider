/*
 *  Tiny Wings Remake
 *  http://github.com/haqu/tiny-wings
 *
 *  Created by Sergey Tikhonov http://haqu.net
 *  Released under the MIT License
 *
 */

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Box2D.h"

#define kPerfectTakeOffVelocityY 2.0f

@class AbstractCamera;
class HeroContactListener;

@interface Hero : CCNode {
	b2World *_world;
	b2Body *_body;
    AbstractCamera * _camera;
	//CCSprite *_sprite;
	float _radius;
	BOOL _awake;
	BOOL _flying;
	BOOL _diving;
	HeroContactListener *_contactListener;
	int _nPerfectSlides;
}
@property (nonatomic, assign) b2World *world;
@property (nonatomic, retain) CCSprite *sprite;
@property (readonly) BOOL awake;
@property (nonatomic) BOOL diving;

+ (id) heroWithWorld:(b2World*)world heroBody:(b2Body*)body camera:(AbstractCamera*)camera ;
- (id) initWithWorld:(b2World*)world heroBody:(b2Body*)body camera:(AbstractCamera*)camera ;

- (void) reset;
- (void) sleep;
- (void) wake;
- (void) updatePhysics;
- (void) updateNode;

- (void) landed;
- (void) tookOff;
- (void) hit;

@end
