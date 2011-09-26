#import <Foundation/Foundation.h>
#import "AbstractCamera.h"

@interface FollowCamera : AbstractCamera 
{
	b2Body * objectToFollow;
	b2Body * storedObjectToFollow;
	
	BOOL isReturningToObject;
}

@property(readonly) b2Body * objectToFollow;

-(void) follow:(b2Body*) body;


@end
