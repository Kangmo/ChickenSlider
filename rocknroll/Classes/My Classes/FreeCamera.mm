#import "FreeCamera.h"


@implementation FreeCamera

-(void) eventBegan:(NSSet *) touches
{
	[super eventBegan:touches];
}

-(void) eventMoved:(NSSet *) touches
{
	[super eventMoved:touches];
}
-(void) eventEnded:(NSSet *) touches
{
	[super eventEnded:touches];
}
-(void) updateFollowPosition
{
	[super updateFollowPosition];
}

-(void) updateSpriteFromBody:(b2Body*) body
{
	[super updateSpriteFromBody:body];
}
@end
