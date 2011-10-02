#import "BodyInfo.h"


@implementation BodyInfo

@synthesize data, name, rect;
@synthesize spriteName, textureName, spriteOffset;
@synthesize initClipFile, initFrameAnim, defaultClip;

-(void)dealloc
{
    [data release];
    [name release];
    [spriteName release];
    [textureName release];
    [initClipFile release];
    [initFrameAnim release];
    [defaultClip release]; 
    
    [super dealloc];
}

@end