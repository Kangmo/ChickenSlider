/*
 *  Tiny Wings Remake
 *  http://github.com/haqu/tiny-wings
 *
 *  Created by Sergey Tikhonov http://haqu.net
 *  Released under the MIT License
 *
 */

#import "Hero.h"
#import "HeroContactListener.h"
#import "Box2D.h"
#import "AbstractCamera.h"

@implementation Hero
@synthesize world = _world;
@synthesize sprite = _sprite;
@synthesize awake = _awake;
@synthesize diving = _diving;

+ (id) heroWithWorld:(b2World*)world heroBody:(b2Body*)body camera:(AbstractCamera*)camera {
	return [[[self alloc] initWithWorld:world heroBody:body camera:camera] autorelease];
}

- (id) initWithWorld:(b2World*)world heroBody:(b2Body*)body camera:(AbstractCamera*)camera {
	
	if ((self = [super init])) {
        
		_world = world;
        _body = body;
        _camera = camera;
        /*        
         #ifndef DRAW_BOX2D_WORLD
         self.sprite = [CCSprite spriteWithFile:@"hero.png"];
         [self addChild:_sprite];
         #endif
         */ 
		_radius = 14.0f;
        
		_contactListener = new HeroContactListener(self);
		_world->SetContactListener(_contactListener);
        
		[self reset];
	}
	return self;
}

- (void) dealloc {
    
	self.world = nil;
    /*	
     #ifndef DRAW_BOX2D_WORLD
     self.sprite = nil;
     #endif
     */
	delete _contactListener;
	[super dealloc];
}


- (void) reset {
    _flying = NO;
    _diving = NO;
    _nPerfectSlides = 0;
 
    // BUGBUG : Reset body position.
 
    //if (_body) {
    //	_world->DestroyBody(_body);
    //}
 
    // [self createBox2DBody];
    [self updateNode];
    [self sleep];
}
 

- (void) sleep {
	_awake = NO;
	_body->SetActive(false);
}

- (void) wake {
	_awake = YES;
	_body->SetActive(true);
	_body->ApplyLinearImpulse(b2Vec2(1,2), _body->GetPosition());
}

- (void) updatePhysics {
    
	// apply force if diving
	if (_diving) {
		if (!_awake) {
			[self wake];
			_diving = NO;
		} else {
			_body->ApplyForce(b2Vec2(0,-40),_body->GetPosition());
		}
	}
	
	// limit velocity
	const float minVelocityX = 3;
	const float minVelocityY = -40;
	b2Vec2 vel = _body->GetLinearVelocity();
	if (vel.x < minVelocityX) {
		vel.x = minVelocityX;
	}
	if (vel.y < minVelocityY) {
		vel.y = minVelocityY;
	}
	_body->SetLinearVelocity(vel);
}

- (void) updateNode {
	float x = _body->GetPosition().x * _camera.ptmRatio;
	float y = _body->GetPosition().y * _camera.ptmRatio;
    
	// CCNode position and rotation
	self.position = ccp(x, y);
	b2Vec2 vel = _body->GetLinearVelocity();
	float angle = atan2f(vel.y, vel.x);
    
#ifdef DRAW_BOX2D_WORLD
	body->SetTransform(body->GetPosition(), angle);
#else
	self.rotation = -1 * CC_RADIANS_TO_DEGREES(angle);
#endif
	
	// collision detection
	b2Contact *c = _world->GetContactList();
	if (c) {
		if (_flying) {
			[self landed];
		}
	} else {
		if (!_flying) {
			[self tookOff];
		}
	}
	
	// TEMP: sleep if below the screen
	if (y < -_radius && _awake) {
		[self sleep];
	}
}

- (void) landed {
    //	NSLog(@"landed");
	_flying = NO;
}

- (void) tookOff {
    //	NSLog(@"tookOff");
	_flying = YES;
	b2Vec2 vel = _body->GetLinearVelocity();
    //	NSLog(@"vel.y = %f",vel.y);
	if (vel.y > kPerfectTakeOffVelocityY) {
        //		NSLog(@"perfect slide");
		_nPerfectSlides++;
		if (_nPerfectSlides > 1) {
			if (_nPerfectSlides == 4) {
                // BUGBUG : show something
                //				[_game showFrenzy];
			} else {
                // BUGBUG : show something
                //				[_game showPerfectSlide];
			}
		}
	}
}

- (void) hit {
    //	NSLog(@"hit");
	_nPerfectSlides = 0;
    // BUGBUG : show something
    //	[_game showHit];
}

- (void) setDiving:(BOOL)diving {
	if (_diving != diving) {
		_diving = diving;
		// TODO: change sprite image here
	}
}

@end
