#import <Foundation/Foundation.h>
#import "cocos2d.h"

// SneakyInput headers
#import "ColoredCircleSprite.h"
#import "SneakyButton.h"
#import "SneakyButtonSkinnedBase.h"
#import "SneakyJoystick.h"
#import "SneakyJoystickSkinnedBase.h"

#import "SneakyExtensions.h"

@interface InputLayer : CCLayer 
{
	SneakyButton* fireButton;
	SneakyJoystick* joystick;
	
	ccTime totalTime;
	ccTime nextShotTime;
}

@end
