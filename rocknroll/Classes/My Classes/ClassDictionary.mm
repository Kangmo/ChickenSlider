#import "ClassDictionary.h"
#import "cocos2d.h"

@implementation ClassInfo
@synthesize svgLayer;
-(id) initWithLayer:(CXMLElement*)l;
{
	if ( (self = [super init]) != nil) 
	{
        svgLayer = [l retain];
	}
	return self;
}

- (void) dealloc
{
	[svgLayer release];
	[super dealloc];
}

@end

@implementation ClassDictionary

-(id) init
{
	self = [super init];
	if (self != nil) 
	{
		classLayers = [[NSMutableDictionary alloc] initWithCapacity:10];
	}
	return self;
}

- (void) dealloc
{
	[classLayers release];
	[super dealloc];
}


- (void) loadClassesFrom:(NSString *)svgFileName
{
    CCLOG(@"Loading classes from the file :%@", svgFileName);
	NSData *data = [NSData dataWithContentsOfFile:svgFileName]; 
	CXMLDocument *svgDocument  = [[[CXMLDocument alloc] initWithData:data options:0 error:nil] autorelease];
	
    NSArray *layers = NULL;
	
    // root groups are layers for geometry
    layers = [[svgDocument rootElement] elementsForName:@"g"];
	for (CXMLElement * curLayer in layers) 
	{
		//layers with "ignore" attribute not loading
		if([curLayer attributeForName:@"ignore"])
		{
			CCLOG(@"ClassDictionary: layer ignored: %@",[[curLayer attributeForName:@"id"] stringValue]);
			continue;
		}
        
        NSString * className = [[curLayer attributeForName:@"id"] stringValue];
        ClassInfo * classInfo = [[ClassInfo alloc] initWithLayer:curLayer];
		CCLOG(@"ClassDictionary: loading class: %@", className);

        [classLayers setValue:classInfo forKey:className];
        [classInfo release];
	}
}

- (ClassInfo*) getClassByName:(NSString *)className
{
    ClassInfo * classInfo = (ClassInfo*) [classLayers valueForKey:className];
    assert(classInfo);
    return classInfo;
}
@end
