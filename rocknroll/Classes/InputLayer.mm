#import "InputLayer.h"
#import "StageScene.h"

@interface InputLayer (PrivateMethods)
-(void) addFireButton;
-(void) addJoystick;
@end


@implementation InputLayer

-(id) init
{
	if ((self = [super init]))
	{
		[self addFireButton];
		[self addJoystick];
		
		[self scheduleUpdate];
	}
	
	return self;
}

-(void) dealloc
{
    [self unscheduleUpdate];

	[super dealloc];
}

-(void) addFireButton
{
	float buttonRadius = 50;
	CGSize screenSize = [[CCDirector sharedDirector] winSize];

	fireButton = [SneakyButton button];
	fireButton.isHoldable = YES;
	
	SneakyButtonSkinnedBase* skinFireButton = [SneakyButtonSkinnedBase skinnedButton];
	skinFireButton.position = CGPointMake(screenSize.width - buttonRadius * 1.5f, buttonRadius * 1.5f);
	skinFireButton.defaultSprite = [CCSprite spriteWithFile:@"button-default.png"];
	skinFireButton.pressSprite = [CCSprite spriteWithFile:@"button-pressed.png"];
	skinFireButton.button = fireButton;
	[self addChild:skinFireButton];
}

-(void) addJoystick
{
	float stickRadius = 50;

	joystick = [SneakyJoystick joystickWithRect:CGRectMake(0, 0, stickRadius, stickRadius)];
	joystick.autoCenter = YES;
	
	// Now with fewer directions
	//joystick.isDPad = YES;
	//joystick.numberOfDirections = 8;
	
	SneakyJoystickSkinnedBase* skinStick = [SneakyJoystickSkinnedBase skinnedJoystick];
	skinStick.position = CGPointMake(stickRadius * 1.5f, stickRadius * 1.5f);
	skinStick.backgroundSprite = [CCSprite spriteWithFile:@"button-disabled.png"];
	skinStick.backgroundSprite.color = ccMAGENTA;
	skinStick.thumbSprite = [CCSprite spriteWithFile:@"button-disabled.png"];
	skinStick.thumbSprite.scale = 0.5f;
	skinStick.joystick = joystick;
	[self addChild:skinStick];
}

-(void) update:(ccTime)delta
{
	totalTime += delta;

    StageScene* stage = [StageScene sharedStageScene];
	Car* car = stage.car;
    
    assert(car);
    // Continuous fire
    if (fireButton.active && totalTime > nextShotTime)
    {
        nextShotTime = totalTime + 0.5f;
        
        b2Body * body = car->getBody();
        body->ApplyLinearImpulse(b2Vec2(100,200), body->GetPosition());
        //		[game shootBulletFromShip:[game defaultShip]];
    }
    
    // Allow faster shooting by quickly tapping the fire button.
    if (fireButton.active == NO)
    {
        nextShotTime = 0;
    }
    
    // Set the speed of the wheel.
    static float32 previousRadiansPerSec = 0;
    CGPoint velocity = ccpMult(joystick.velocity, -150);
    
    float32 radiansPerSec = velocity.x;
    float32 speedDiff = previousRadiansPerSec - radiansPerSec;
    if (speedDiff <0) 
        speedDiff = -speedDiff;
    
    if ( speedDiff >= 5 )
    {
        CCLOG(@"stick:(%f,%f)", joystick.velocity.x, joystick.velocity.y );
        CCLOG(@"radiansPerSec:%f", radiansPerSec );
        car->setWheelSpeed(radiansPerSec);
        previousRadiansPerSec = radiansPerSec;
    }
}

@end
