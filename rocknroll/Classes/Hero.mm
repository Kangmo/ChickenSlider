#import "Hero.h"
#import "HeroContactListener.h"
#import "Box2D.h"
#import "AbstractCamera.h"
#import "Util.h"
#import "AKHelpers.h"
#import "ClipFactory.h"
#import "BodyInfo.h"
#import "TouchXML.h"

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
    _nowingsAction = [[[ClipFactory sharedFactory] clipActionByFile:@"clip_icarus_nowings.plist"] retain];
    assert(_nowingsAction);
    _droppingAction = [[[ClipFactory sharedFactory] clipActionByFile:@"clip_icarus_dropping.plist"] retain];
    assert(_droppingAction);
    _flyingAction = [[[ClipFactory sharedFactory] clipActionByFile:@"clip_icarus_flying.plist"] retain];
    assert(_flyingAction);
    _walkingAction = [[[ClipFactory sharedFactory] clipActionByFile:@"clip_icarus_walking.plist"] retain];
    assert(_walkingAction);
}

- (id) initWithWorld:(b2World*)world heroBody:(b2Body*)body camera:(AbstractCamera*)camera scoreBoard:(id<ScoreBoardProtocol>)sb{
	
	if ((self = [super init])) {
        self.isDead = NO;
        _hasWings = YES;
		_world = world;
        _body = body;
        _camera = camera;
        _scoreBoard = sb;
        _particleEmitter = nil;

        // Init Sound Effects
        {
            _3comboSound = [[[ClipFactory sharedFactory] soundByFile:@"3combo.wav"] retain];
            assert(_3comboSound);
            _7comboSound = [[[ClipFactory sharedFactory] soundByFile:@"7combo.wav"] retain];
            assert( _7comboSound);
            _dropSound = [[[ClipFactory sharedFactory] soundByFile:@"drop.wav"] retain];
            assert(_dropSound);
            _jumpSound = [[[ClipFactory sharedFactory] soundByFile:@"jump.wav"] retain];
            assert(_jumpSound);
            _slideFailSound = [[[ClipFactory sharedFactory] soundByFile:@"slidefail.wav"] retain];
            assert(_slideFailSound);
        }
        
        { // Get attribute values from XML.
            BodyInfo * bi = (BodyInfo*) body->GetUserData();
            
            _minSpeedX = [Util getFloatValue:bi.xmlElement name:@"minSpeedX" defaultValue:3];
            _minSpeedY = [Util getFloatValue:bi.xmlElement name:@"minSpeedY" defaultValue:-40];
            _maxSpeed = [Util getFloatValue:bi.xmlElement name:@"maxSpeed" defaultValue:60];
            
            // Not necessary anymore.
            bi.xmlElement = nil;
        }
        
		_contactListener = new HeroContactListener(self);
		_world->SetContactListener(_contactListener);

        
        [self loadAnimationClips];
		[self reset];
	}
	return self;
}

- (void) dealloc {
    // Stop all actions
    Helper::runAction(_body, NULL);
    
	self.world = nil;
    self.body = nil;
    
    [_nowingsAction release];
    [_droppingAction release];
    [_flyingAction release];
    [_walkingAction release];

    [_3comboSound release];
    [_7comboSound release];
    [_dropSound release];
    [_jumpSound release];
    [_slideFailSound release]; 
    
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

- (void) playClipAction:(CCAction *) action {
    _currentAction = action;
    Helper::runAction(_body, action);
}

-(void) createParticle:(float)duration
{
    // Particle emitter.
    _particleEmitter = [Util createParticleEmitter:@"stars.png" count:30 duration:duration];

    CCSprite * sprite = [self getSprite];
    assert(sprite);

    [sprite addChild:_particleEmitter z:10]; // adding the emitter
}

-(void) removeParticle
{
    if (_particleEmitter)
    {
        [_particleEmitter stopSystem];
        [_particleEmitter removeFromParentAndCleanup:YES];
        _particleEmitter = nil;
    }
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
                _diving = NO;
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
    else
    {
        // No wings anymore.
        // Is this the first time that the wings are detached?
        if ( _currentAction != _nowingsAction ) {
            [self playClipAction:_nowingsAction];
            [self playDetachingWings];
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
        
        BOOL effectPlayed = NO;
        
		if (_nPerfectSlides == 1) {
            [_scoreBoard showMessage:@"Nice!"];
        } else if (_nPerfectSlides > 1) {
			if (_nPerfectSlides == 3) {
                [self createParticle:1000];
                [_3comboSound play];
                effectPlayed = YES;
			}
            else if (_nPerfectSlides == 7) {
                [_7comboSound play];
                effectPlayed = YES;
            }

            [_scoreBoard showCombo:_nPerfectSlides];
		}
        
        if (!effectPlayed)
        {
            // Play jump sound if no effect is played.
            [_jumpSound play];
        }
        
        [_scoreBoard increaseSpeedRatio:FRAME_SPEED_RATIO_PER_COMBO];
        
        [_scoreBoard increaseScore:SCORE_PER_COMBO * _nPerfectSlides];
	}
}

- (void) hit {
    //	NSLog(@"hit");
	_nPerfectSlides = 0;
    
    [self removeParticle];
    [_slideFailSound play];
    
    [_scoreBoard showMessage:@"Oops~"];
    
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




@end
