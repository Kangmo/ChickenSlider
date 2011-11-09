#import "BodyInfo.h"


@implementation BodyInfo

@synthesize data, name, rect;
@synthesize spriteName, textureName, spriteOffset;
@synthesize initClipFile, initFrameAnim, defaultAction;

-(void)dealloc
{
    [data release];
    [name release];
    [spriteName release];
    [textureName release];
    [initClipFile release];
    [initFrameAnim release];
    [defaultAction release]; 
    
    [super dealloc];
}

@end