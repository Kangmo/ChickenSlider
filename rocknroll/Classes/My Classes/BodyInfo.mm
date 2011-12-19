#import "BodyInfo.h"
#import "TouchXML.h"
//#include "RetainCountTrace.h"

@implementation BodyInfo

//SYNTESIZE_TRACE(BodyInfo);

@synthesize data, name, rect;
@synthesize spriteName, textureName, spriteOffset;
@synthesize initClipFile, initFrameAnim, defaultAction;
@synthesize xmlElement;

-(void)dealloc
{
    [data release];
    [name release];
    [spriteName release];
    [textureName release];
    [initClipFile release];
    [initFrameAnim release];
    [defaultAction release]; 
    [xmlElement release];
    
    [super dealloc];
}

@end