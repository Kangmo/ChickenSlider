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

+ (id) heroWithWorld:(b2World*)world heroBody:(b2Body*)body camera:(AbstractCamera*)camera scoreBoard:(id<ScoreBoardProtocol>)sb{
	return [[[self alloc] initWithWorld:world heroBody:body camera:camera scoreBoard:sb] autorelease];
}

/** @brief Load all animation clips. 
 */
-(void) loadAnimationClips
{
    flyingClip = [[[ClipFactory sharedFactory] clipByFile:@"clip_snail_flying.plist"] retain];
    assert(flyingClip);
    walkingClip = [[[ClipFactory sharedFactory] clipByFile:@"clip_snail_walking.plist"] retain];
    assert(walkingClip);
}


- (id) initWithWorld:(b2World*)world heroBody:(b2Body*)body camera:(AbstractCamera*)camera scoreBoard:(id<ScoreBoardProtocol>)sb{
	
	if ((self = [super init])) {
        
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
    [flyingClip release];
    [walkingClip release];

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
- (void) showMessage:(NSString*) message {
    CCSprite * sprite = [self getSprite];
    assert(sprite);
    
    CCNode * parent = sprite.parent;
    assert( [parent isKindOfClass:[CCLayer class]] );
    [Util showMessage:message inLayer:(CCLayer*)parent];
}

-(void) createParticle:(float)duration
{
    // Particle emitter.
    CCParticleSystemQuad * emitter;
//        [emitter resetSystem];
 
    //	ParticleSystem *emitter = [RockExplosion node];
    emitter = [[CCParticleSystemQuad alloc] initWithTotalParticles:30];
    emitter.texture = [[CCTextureCache sharedTextureCache] addImage: @"stars.png"];
    
    // duration
    //	emitter.duration = -1; //continuous effect
    emitter.duration = duration;
    
    // gravity
    emitter.gravity = CGPointZero;
    
    // angle
    emitter.angle = 90;
    emitter.angleVar = 360;
    
    // speed of particles
    emitter.speed = 160;
    emitter.speedVar = 20;
    
    // radial
    emitter.radialAccel = -120;
    emitter.radialAccelVar = 0;
    
    // tagential
    emitter.tangentialAccel = 30;
    emitter.tangentialAccelVar = 0;
    
    // life of particles
    emitter.life = 1;
    emitter.lifeVar = 1;
    
    // spin of particles
    emitter.startSpin = 0;
    emitter.startSpinVar = 0;
    emitter.endSpin = 0;
    emitter.endSpinVar = 0;
    
    // color of particles
    ccColor4F startColor = {0.5f, 0.5f, 0.5f, 1.0f};
    emitter.startColor = startColor;
    ccColor4F startColorVar = {0.5f, 0.5f, 0.5f, 1.0f};
    emitter.startColorVar = startColorVar;
    ccColor4F endColor = {0.1f, 0.1f, 0.1f, 0.2f};
    emitter.endColor = endColor;
    ccColor4F endColorVar = {0.1f, 0.1f, 0.1f, 0.2f};
    emitter.endColorVar = endColorVar;
    
    // size, in pixels
    emitter.startSize = 20.0f;
    emitter.startSizeVar = 10.0f;
    emitter.endSize = kParticleStartSizeEqualToEndSize;
    // emits per second
    emitter.emissionRate = emitter.totalParticles/emitter.life;
    // additive
    emitter.blendAdditive = YES;
    emitter.position = ccp(0,0); // setting emitter position
    
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
    
	// apply force if diving
	if (_diving) {
		if (!_awake) {
			[self wake];
			_diving = NO;
            Helper::runClip(_body, walkingClip);
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
    Helper::runClip(_body, walkingClip);
}

- (void) tookOff {
    //	NSLog(@"tookOff");
	_flying = YES;

    Helper::runClip(_body, flyingClip);
    
	b2Vec2 vel = _body->GetLinearVelocity();
    //	NSLog(@"vel.y = %f",vel.y);
	if (vel.y > kPerfectTakeOffVelocityY) {
        //		NSLog(@"perfect slide");
		_nPerfectSlides++;
		if (_nPerfectSlides == 1) {
            [self showMessage:@"Nice!"];
        } else if (_nPerfectSlides > 1) {
			if (_nPerfectSlides == 3) {
                [self showMessage:@"Crazy 3 Combo!"];
                [self createParticle:3];
			} else {
                [self showMessage:[NSString stringWithFormat:@"%d Combo!", _nPerfectSlides]];
			}
		}
        
        [_scoreBoard increaseScore:SCORE_PER_COMBO * _nPerfectSlides];
	}
}

- (void) hit {
    //	NSLog(@"hit");
	_nPerfectSlides = 0;
    
    [self showMessage:@"Oops~"];
}

- (void) setDiving:(BOOL)diving {
	if (_diving != diving) {
		_diving = diving;
		// TODO: change sprite image here
	}
}


@end
