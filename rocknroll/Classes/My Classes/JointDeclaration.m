#import "JointDeclaration.h"


@implementation JointDeclaration

@synthesize body1, body2, point1, point2, jointType, maxTorque,motorSpeed,motorEnabled;;



- (NSString *)description
{
	return [NSString stringWithFormat:@"Joint: type: %@, b1=%@, b2=%@, p1=%fx%f, p2=%fx%f",jointType==1?@"kDistanceJoint":@"kRevoluteJoint",body1,body2,point1.x,point1.y,point2.x,point2.y];
}

-(void) dealloc
{
    [body1 release];
    [body2 release];
    [super dealloc];
}
@end
