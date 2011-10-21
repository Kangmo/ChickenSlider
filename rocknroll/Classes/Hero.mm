#import "Hero.h"
#import "HeroContactListener.h"
#import "Box2D.h"
#import "AbstractCamera.h"
#import "Util.h"
#import "AKHelpers.h"
#import "ClipFactory.h"

@implementation Hero
@synthesize world = _world;
@synthesize body = _body;
@synthesize awake = _awake;
@synthesize diving = _diving;
@synthesize isDead;

+ (id) heroWithWorld:(b2World*)world heroBody:(b2Body*)body camera:(AbstractCamera*)camera scoreBoard:(id<ScoreBoardProtocol>)sb{
	return [[[self alloc] initWithWorld:world heroBody:body camera:camera scoreBoard:sb] autorelease];
}

/** @brief Load all animation clips. 
 */
-(void) loadAnimationClips
{
    _nowingsClip = [[[ClipFactory sharedFactory] clipByFile:@"clip_icarus_nowings.plist"] retain];
    assert(_nowingsClip);
    _droppingClip = [[[ClipFactory sharedFactory] clipByFile:@"clip_icarus_dropping.plist"] retain];
    assert(_droppingClip);
    _flyingClip = [[[ClipFactory sharedFactory] clipByFile:@"clip_icarus_flying.plist"] retain];
    assert(_flyingClip);
    _walkingClip = [[[ClipFactory sharedFactory] clipByFile:@"clip_icarus_walking.plist"] retain];
    assert(_walkingClip);
}


- (id) initWithWorld:(b2World*)world heroBody:(b2Body*)body camera:(AbstractCamera*)camera scoreBoard:(id<ScoreBoardProtocol>)sb{
	
	if ((self = [super init])) {
        self.isDead = NO;
		_world = world;
        _body = body;
        _camera = camera;
        _scoreBoard = sb;
        
		_contactListener = new HeroContactListener(self);
		_world->SetContactListener(_contactListener);
        
        [self loadAnimationClips];
		[self reset];
	}
	return self;
}

- (void) dealloc {
    
	self.world = nil;
    self.body = nil;
    [_flyingClip release];
    [_walkingClip release];

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

- (CCSprite*) getSprite {
    BodyInfo *bi = (BodyInfo*)_body->GetUserData();
    assert(bi);
    id sprite = nil;
    if(bi.data)
    {
        sprite = (CCSprite*)bi.data;
        assert([sprite isKindOfClass:[CCSprite class]]);
    }
    return sprite;
    
}

- (NSDictionary *) currentClip {
    return _currentClip;
}

- (void) playClip:(NSDictionary *) clip {
    _currentClip = clip;
    Helper::runClip(_body, clip);
}

-(void) createParticle:(float)duration
{
    // Particle emitter.
    CCParticleSystemQuad * emitter = [Util createParticleEmitter:@"stars.png" count:30 duration:duration];

    CCSprite * sprite = [self getSprite];
    assert(sprite);

    [sprite addChild:emitter z:10]; // adding the emitter
    
    emitter.autoRemoveOnFinish = YES; // this removes/deallocs the emitter after its animation
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
    if (_flying) {
        if ( [self currentClip] != _flyingClip ) {
            [self playClip:_flyingClip];
        }
    }
    else
    {
        if ( [self currentClip] != _walkingClip ) {
            [self playClip: _walkingClip];
        }
    }
    
	// apply force if diving
	if (_diving) {
		if (!_awake) {
			[self wake];
			_diving = NO;
            [self playClip:_flyingClip];
		} else {
            if ( [self currentClip] != _droppingClip ) {
                [self playClip:_droppingClip];
            }
            
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
    
	// CCNode position and rotation
//	self.position = ccp(x, y);
	b2Vec2 vel = _body->GetLinearVelocity();
	float angle = atan2f(vel.y, vel.x);
/*    
#ifdef DRAW_BOX2D_WORLD
	body->SetTransform(body->GetPosition(), angle);
#else
*/
	_body->SetTransform(_body->GetPosition(), angle);
    
//	self.rotation = -1 * CC_RADIANS_TO_DEGREES(angle);
//#endif
	if (_awake) 
    {
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
		if (_nPerfectSlides == 1) {
            [_scoreBoard showMessage:@"Nice!"];
        } else if (_nPerfectSlides > 1) {
			if (_nPerfectSlides == 3) {
                [self createParticle:3];
			}
            
            [_scoreBoard showMessage:[NSString stringWithFormat:@"%d Combo!", _nPerfectSlides]];
		}
        
        [_scoreBoard increaseScore:SCORE_PER_COMBO * _nPerfectSlides];
	}
}

- (void) hit {
    //	NSLog(@"hit");
	_nPerfectSlides = 0;
    
    [_scoreBoard showMessage:@"Oops~"];
}

- (void) setDiving:(BOOL)diving {
	if (_diving != diving) {
		_diving = diving;
		// TODO: change sprite image here
	}
}

- (void) dropWings {
    _hasWings = NO;
}

-(void) dead {
/*    
    b2Vec2 vel;
    vel.x=0; vel.y=0;
    _body->SetLinearVelocity(vel);
    _body->ApplyLinearImpulse(b2Vec2(0,5), _body->GetPosition());
 */
    self.isDead = YES;
}




@end
