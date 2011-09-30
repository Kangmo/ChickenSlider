#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Box2D.h"
#import "BodyInfo.h"
#import "Util.h"

#include "GameObjectContainer.h"

@interface AbstractCamera : NSObject 
{
	CGPoint cameraPosition;
	float zoom;
	float ptmRatio;
	float originalPtmRatio;
	
	float maxZoom;
	float minZoom;
	
	NSMutableArray *storedTouches;
	float oldTouchZoomDistance;
}

@property(readonly) CGPoint cameraPosition;
@property(readonly) float zoom;
@property(readonly) float maxZoom;
@property(readonly) float minZoom;
@property(readonly) float ptmRatio;

-(void) eventBegan:(NSSet *) touches;
-(void) eventMoved:(NSSet *) touches;
-(void) eventEnded:(NSSet *) touches;
-(void) updateFollowPosition;

-(void) updateSpriteFromBody:(b2Body*) body;
-(void) updateSpriteFromGameObject:(REF(GameObject)) gameObject;

-(void) ZoomTo:(float)newZoom;

-(void) ZoomToObject:(b2Body*) body screenPart:(float) part;

-(b2Vec2) b2vPosition;

@end
