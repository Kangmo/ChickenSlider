#import "Hero.h"
#import "HeroContactListener.h"
#import "Box2D.h"
#import "AbstractCamera.h"
#import "Util.h"
#import "AKHelpers.h"
#import "ClipFactory.h"
#import "BodyInfo.h"
#import "TouchXML.h"
#include "ParticleManager.h"

@interface Hero()
-(void)addDustParticle;
-(void)addMaxSpeedParticle;
@end

@implementation Hero
@synthesize world = _world;
@synthesize body = _body;
@synthesize awake = _awake;
@synthesize diving = _diving;
@synthesize hasWings = _hasWings;
@synthesize flying = _flying;
@synthesize isDead;

+ (id) heroWithWorld:(b2World*)world heroBody:(b2Body*)body camera:(AbstractCamera*)camera scoreBoard:(id<ScoreBoardProtocol>)sb{
	return [[[self alloc] initWithWorld:world heroBody:body camera:camera scoreBoard:sb] autorelease];
}

/** @brief Load all animation clips. 
 */
-(void) loadAnimationClips
{
    _droppingAction = [[[ClipFactory sharedFactory] clipActionByFile:@"clip_icarus_dropping.plist"] retain];
    assert(_droppingAction);
    _flyingAction = [[[ClipFactory sharedFactory] clipActionByFile:@"clip_icarus_flying.plist"] retain];
    assert(_flyingAction);
    _walkingAction = [[[ClipFactory sharedFactory] clipActionByFile:@"clip_icarus_walking.plist"] retain];
    assert(_walkingAction);
}

- (id) initWithWorld:(b2World*)world heroBody:(b2Body*)body camera:(AbstractCamera*)camera scoreBoard:(id<ScoreBoardProtocol>)sb{
	
	if ((self = [super init])) {
        
        _scorePerCombo = [Util loadDifficulty] ? SCORE_PER_COMBO_FOR_HARD_MODE : SCORE_PER_COMBO_FOR_EASY_MODE;
        
        self.isDead = NO;
        _hasWings = YES;
		_world = world;
        _body = body;
        _camera = camera;
        _scoreBoard = sb;
        _maxSpeedParticleEmitter = nil;
        _dustParticleEmitter = nil;

        // Init Sound Effects
        {
            _3comboSound = [[[ClipFactory sharedFactory] soundByFile:@"3combo"SND_EXT] retain];
            assert(_3comboSound);
            _5comboSound = [[[ClipFactory sharedFactory] soundByFile:@"5combo"SND_EXT] retain];
            assert( _5comboSound);
            _dropSound = [[[ClipFactory sharedFactory] soundByFile:@"drop"SND_EXT] retain];
            assert(_dropSound);
            _jumpSound = [[[ClipFactory sharedFactory] soundByFile:@"jump"SND_EXT] retain];
            assert(_jumpSound);
            _slideFailSound = [[[ClipFactory sharedFactory] soundByFile:@"slidefail"SND_EXT] retain];
            assert(_slideFailSound);
            _boostSound = [[[ClipFactory sharedFactory] soundByFile:@"boost"SND_EXT] retain];
            assert(_boostSound);
        }
        
        { // Get attribute values from XML.
            BodyInfo * bi = (BodyInfo*) body->GetUserData();
            
            _minSpeedX = [Util getFloatValue:bi.xmlElement name:@"minSpeedX" defaultValue:3];
            _minSpeedY = [Util getFloatValue:bi.xmlElement name:@"minSpeedY" defaultValue:-40];
            _maxSpeed = [Util getFloatValue:bi.xmlElement name:@"maxSpeed" defaultValue:60];
            
            // Not necessary anymore.
            bi.xmlElement = nil;
            
        }

        // Change the sprite z layer above other objects such as terrain
        CCSprite * heroSprite = [self getSprite];
        [[heroSprite parent] reorderChild:heroSprite z:100];

        // Add particle emitters.
        [self addDustParticle];        
        [self addMaxSpeedParticle];

        
		_contactListener = new HeroContactListener(self);
		_world->SetContactListener(_contactListener);

        if ([Util loadDifficulty])
            isHardMode = YES;
        else
            isHardMode = NO;
        
        [self loadAnimationClips];
		[self reset];
	}
	return self;
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

- (void) playClipAction:(CCAction *) action {
    _currentAction = action;
    Helper::runAction(_body, action);
}

-(void) addMaxSpeedParticle
{
    assert( ! _maxSpeedParticleEmitter);
    // Particle emitter.
//    _particleEmitter = ParticleManager::createParticleEmitter(@"stars.png", 30, duration);
    _maxSpeedParticleEmitter = ParticleManager::createMeteor();
    [_maxSpeedParticleEmitter retain];

    // by default, stop emission.
    _maxSpeedParticleEmitter.emissionRate = 0;   
    
    CCSprite * sprite = [self getSprite];
    assert(sprite);

    [sprite addChild:_maxSpeedParticleEmitter z:-10]; // adding the emitter
    
    // Add at the back of the Hero.
    _maxSpeedParticleEmitter.position = ccp( sprite.contentSize.width * 0.5, sprite.contentSize.height * 0.5);
}
-(void) pauseMaxSpeedParticle
{
    _maxSpeedParticleEmitter.emissionRate = 0;   
}

-(void) resumeMaxSpeedParticle
{
    _maxSpeedParticleEmitter.emissionRate = 20;   
}

-(void) addDustParticle
{
    if (!_dustParticleEmitter) { // Add dust particle only once even though the Hero hits on the ground multiple times.
        // Particle emitter.
        //    _particleEmitter = ParticleManager::createParticleEmitter(@"stars.png", 30, duration);
        _dustParticleEmitter = ParticleManager::createDust();
        [_dustParticleEmitter retain];
        
        // by default, stop emission.
        _dustParticleEmitter.emissionRate = 0;   

        CCSprite * sprite = [self getSprite];
        assert(sprite);
        
        [sprite addChild:_dustParticleEmitter z:10]; // adding the emitter
        
        // Add at the back of the Hero.
        _dustParticleEmitter.position = ccp( sprite.contentSize.height * 0.25, sprite.contentSize.height * 0.25);
        
    }
}
-(void) pauseDustParticle
{
    _dustParticleEmitter.emissionRate = 0;   
}

-(void) resumeDustParticle
{
    // BUGBUG : Optimize dust particles... If we emitt dust partcles, FPS drops from 60 to 50.
    _dustParticleEmitter.emissionRate = 0;   
//    _dustParticleEmitter.emissionRate = 5;   
}

-(void) addParticleAtHeroPosition:(ARCH_OPTIMAL_PARTICLE_SYSTEM*)emitter {
    CCSprite * sprite = [self getSprite];
    assert(sprite);
    
    // Don't add the particle as a child of the Hero sprite, because it will make the particles rotate as the Hero sprite rotates.
    [[sprite parent] addChild:emitter z:10]; 
    emitter.position = sprite.position;
}
-(void) addSaveChickParticle
{
    ARCH_OPTIMAL_PARTICLE_SYSTEM * emitter = ParticleManager::createChickSaveParticle();
    
    [self addParticleAtHeroPosition:emitter];
}

-(void) add5ComboParticle
{
    ARCH_OPTIMAL_PARTICLE_SYSTEM * emitter = ParticleManager::createExplosion();
    
    [self addParticleAtHeroPosition:emitter];
}

-(void) removemaxSpeedParticle
{
    if (_maxSpeedParticleEmitter)
    {
        [_maxSpeedParticleEmitter stopSystem];
        [_maxSpeedParticleEmitter removeFromParentAndCleanup:YES];
        [_maxSpeedParticleEmitter release];
        _maxSpeedParticleEmitter = nil;
    }
}

-(void) removeDustParticle
{
    if (_dustParticleEmitter)
    {
        [_dustParticleEmitter stopSystem];
        [_dustParticleEmitter removeFromParentAndCleanup:YES];
        [_dustParticleEmitter release];
        _dustParticleEmitter = nil;
    }
}

- (void) sleep {
	_awake = NO;
	_body->SetActive(false);
}

- (void) wake {
	_awake = YES;
	_body->SetActive(true);

    //Don't Jump
    //_body->ApplyLinearImpulse(b2Vec2(1,2), _body->GetPosition());
}

-(void) playDetachingWing:(NSString*)wingSpriteFrameName
{
    CCSprite * heroSprite = [self getSprite];
    
    CCSprite * wingSprite = [CCSprite spriteWithSpriteFrameName:wingSpriteFrameName];
    assert(wingSprite);
    [[heroSprite parent] addChild:wingSprite];
    wingSprite.position = heroSprite.position;

    [heroSprite addChild:wingSprite z:10];

    [wingSprite runAction:[CCSequence actions:
                      [CCFadeOut actionWithDuration:2.0f],
					  [CCCallFuncND actionWithTarget:wingSprite selector:@selector(removeFromParentAndCleanup:) data:(void*)YES],
					  nil]];

}

/** @brief Show the effect that the wings are detached from the body and disappeared
 */
-(void) playDetachingWings {
// BUGBUG : Detaching wings does not work well.
//    [self playDetachingWing:@"icarus_leftwing.png"];
//    [self playDetachingWing:@"icarus_rightwing.png"];
}

-(void) changeSpeed:(float)speedGain
{
	b2Vec2 vel = _body->GetLinearVelocity();
    
    if ( speedGain > 0.0f )
    {
        // The length of the vector is the speed
        float speed = sqrt(vel.x * vel.x + vel.y * vel.y); 
        float newSpeed = speed + speedGain;

        if (newSpeed > _maxSpeed )
            newSpeed = _maxSpeed;
        float factor = newSpeed / speed;
        
        vel.x *= factor;
        vel.y *= factor;
    }
    
	if (vel.x < _minSpeedX) {
		vel.x = _minSpeedX;
	}
	if (vel.y < _minSpeedY) {
		vel.y = _minSpeedY;
	}
	_body->SetLinearVelocity(vel);
}

/** @brief Called when the user shakes device!
 */
-(void) boostSpeed {
    [_boostSound play];
    // Boost the speed of Hero
    [self changeSpeed:SHAKE_DEVICE_HERO_SPEED_GAIN];

}

- (void) updatePhysics {
    if (_hasWings)
    {
        if (_flying) {
            if ( _currentAction != _flyingAction ) {
                [self playClipAction:_flyingAction];
            }
        }
        else
        {
            if ( _currentAction != _walkingAction ) {
                [self playClipAction: _walkingAction];
            }
        }
        
        // apply force if diving
        if (_diving) {
            if (!_awake) {
                [self wake];
                //_diving = YES;
                if ( _currentAction != _flyingAction )
                {
                    [self playClipAction:_flyingAction];
                }
            } else {
                if ( _currentAction != _droppingAction ) {
                    //The dropping sound is not really good. Don't play it.
                    //[_dropSound play];
                    [self playClipAction:_droppingAction];
                }
                
                _body->ApplyForce(b2Vec2(0,-40),_body->GetPosition());
            }
        }
    }
    
    // 0 means no change in speed.
    // Need to do this to check the minimum/maximum speed of the Hero.
    [self changeSpeed:0];
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
                [self resumeDustParticle];
                [self landed];
            }
        } else {
            if (!_flying) {
                [self pauseDustParticle];
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
        
        BOOL effectPlayed = NO;
        
		if (_nPerfectSlides == 1) {
            [_scoreBoard showMessage:@"Nice!"];
        } else if (_nPerfectSlides > 1) {
			if (_nPerfectSlides == 3) {
                [_3comboSound play];
                effectPlayed = YES;
			}
            else if (_nPerfectSlides == 5) {
                [self resumeMaxSpeedParticle];
                [self add5ComboParticle];
                [_5comboSound play];
                effectPlayed = YES;
            }

            [_scoreBoard showCombo:_nPerfectSlides];
		}
        
        if (!effectPlayed)
        {
            // Play jump sound if no effect is played.
            [_jumpSound play];
        }
        
        if (isHardMode) { // Increase speed ratio only in the hard mode.
            [_scoreBoard increaseSpeedRatio:FRAME_SPEED_RATIO_PER_COMBO];
        }
        
        [_scoreBoard increaseScore:_scorePerCombo * ((_nPerfectSlides<10)?_nPerfectSlides:10)];
	}
}

- (void) hit {
    //	NSLog(@"hit");
	_nPerfectSlides = 0;
    
    [self pauseMaxSpeedParticle];
    
    [_slideFailSound play];
    
//    [_scoreBoard showMessage:@"Oops~"];
    
    [_scoreBoard setSpeedRatio:MIN_FRAME_SPEED_RATIO];
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

- (void) dealloc {
    [self removemaxSpeedParticle];
    [self removeDustParticle];
    
    // Stop all actions
    Helper::runAction(_body, NULL);
    
	self.world = nil;
    self.body = nil;
    
    [_droppingAction release];
    [_flyingAction release];
    [_walkingAction release];
    
    [_3comboSound release];
    [_5comboSound release];
    [_dropSound release];
    [_jumpSound release];
    [_slideFailSound release]; 
    [_boostSound release];
    
	delete _contactListener;
	[super dealloc];
}



@end
