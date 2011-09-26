#import "BodyInfo.h"


@implementation BodyInfo

@synthesize data, name, rect;
@synthesize spriteName, textureName, spriteOffset;

-(void)dealloc
{
    [data release];
    [name release];
    [spriteName release];
    [textureName release];
    
    [super dealloc];
}

@end