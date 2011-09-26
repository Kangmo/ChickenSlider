#import "FollowCamera.h"
#include "GameConfig.h"

#define RETURN_FRAMES 30

@implementation FollowCamera

@synthesize objectToFollow;


-(void) follow:(b2Body*) body
{
	storedObjectToFollow = NULL;
	objectToFollow = body;
	isReturningToObject = YES;

}
-(void) eventBegan:(NSSet *) touches
{
	[super eventBegan:touches];
	isReturningToObject = NO;
	
}
-(void) eventMoved:(NSSet *) touches
{	
	if([storedTouches count]==1)
	{
		UITouch * touch = [storedTouches objectAtIndex:0];
		CGPoint location = [touch locationInView: [touch view]];
		location = [[CCDirector sharedDirector] convertToGL: location];
		CGPoint oldlocation = [touch previousLocationInView: [touch view]];
		oldlocation = [[CCDirector sharedDirector] convertToGL: oldlocation];
		
		CGPoint curDelta = ccpSub(location, oldlocation);
		cameraPosition = ccpAdd(curDelta, cameraPosition);
	}
	
	if([storedTouches count]==2) // do zoom
	{
		UITouch * touch1 = [storedTouches objectAtIndex:0];
		CGPoint location1 = [touch1 locationInView: [touch1 view]];
		location1 = [[CCDirector sharedDirector] convertToGL: location1];
		
		UITouch * touch2 = [storedTouches objectAtIndex:1];
		CGPoint location2 = [touch2 locationInView: [touch2 view]];
		location2 = [[CCDirector sharedDirector] convertToGL: location2];
		
		float touchDistance = ccpDistance(location1, location2);
		
		if(touchDistance > oldTouchZoomDistance) // zoom +
		{
			[self ZoomTo:zoom + zoom/50];
		}
		else if(touchDistance < oldTouchZoomDistance) //zoom -
		{
			[self ZoomTo:zoom - zoom/50];
		}
		
		oldTouchZoomDistance = touchDistance;		
	}
	
	//[self updateFollowPosition];
	//CCLOG(@"Moved. Touch count: %d", [storedTouches count]);
}
-(void) eventEnded:(NSSet *) touches
{
	[super eventEnded:touches];
	
	if([storedTouches count]==0) 
	{
		isReturningToObject = YES;
	}
}

// BUGBUG : Adjust the position for iPad, retina...
const float TARGET_OBJ_POS_X = 480.0f * HERO_XPOS_RATIO;
//const float TARGET_OBJ_POS_Y = 160.0f;
const float MIN_TARGET_OBJ_POS_Y = 320.0 * 0.5;
const float MAX_TARGET_OBJ_POS_Y = 320.0 * 0.9;

-(void) updateFollowPosition
{
	if(objectToFollow)
	{
		//pos in phy coords
		CGPoint objPosition = CGPointMake(objectToFollow->GetPosition().x, objectToFollow->GetPosition().y);
        //CGPointMake(-objectToFollow->GetPosition().x, -objectToFollow->GetPosition().y);
		
		//convert to screen coords
		objPosition = ccpMult(objPosition, ptmRatio);
		
        // Follow in Y axis for the first time only.
        //objPosition = ccpAdd(objPosition, CGPointMake(TARGET_OBJ_POS_X, TARGET_OBJ_POS_Y));
        
        float targetObjPosY = objPosition.y;
        if ( targetObjPosY < MIN_TARGET_OBJ_POS_Y )
        {
            targetObjPosY = MIN_TARGET_OBJ_POS_Y;
        }
        if ( targetObjPosY > MAX_TARGET_OBJ_POS_Y )
        {
            targetObjPosY = MAX_TARGET_OBJ_POS_Y;
        }
        
        CGPoint objTargetDiff = ccpSub(CGPointMake(TARGET_OBJ_POS_X, targetObjPosY), objPosition);

		CGPoint returnDelta = ccpSub(objTargetDiff,cameraPosition);
		float deltaLength= ccpLength(returnDelta);
		if(deltaLength>0.5f)
		{
            // To make the camera follow the target object slowly, uncomment this block.
//			returnDelta = ccpNormalize(returnDelta);
//			returnDelta = ccpMult(returnDelta, deltaLength/2);
            
			cameraPosition = ccpAdd(cameraPosition, returnDelta);
		}
	}
}

-(void) dealloc
{
    [super dealloc];
}

@end
