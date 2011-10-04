#import "GeneralScene.h"
#import "svgLoader.h"
#import "Util.h"
#import "RetainCountTrace.h"
#import "b2WorldEx.h"
#import "InteractiveSprite.h"

@implementation GeneralScene

// initialize your instance here
-(id) initWithSceneName:(NSString*)sceneName
{
	if( (self=[super init])) 
	{
        NSString * svgFileName = [sceneName stringByAppendingString:@".svg"];
        NSString * backgroundFileName = [sceneName stringByAppendingString:@".png"];
    
        // ask director the the window size
        CGSize size = [[CCDirector sharedDirector] winSize];
        
        // Set background
        {
            
            CCSprite * bg = [CCSprite spriteWithFile:backgroundFileName];
            
            // position the label on the center of the screen
            bg.position =  ccp( size.width /2 , size.height/2 );
            
            [self addChild:bg z:0];
 
        }
        
        // Parse svg file
        {
            NSString *filePath = [Util getResourcePath:svgFileName];

            svgLoader * loader = [[svgLoader alloc] initWithWorld:nil andStaticBody:nil andLayer:self terrains:nil gameObjects:NULL scoreBoard:nil];

            [loader instantiateObjectsIn:filePath];
            
            [loader release];
        }
    
    }
    
    return self;
}

+(id)nodeWithSceneName:(NSString*)sceneName
{
    return [[[GeneralScene alloc] initWithSceneName:sceneName] autorelease];
}

+(CCScene*)sceneWithName:(NSString*)sceneName
{
    // 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	GeneralScene *layer = [GeneralScene nodeWithSceneName:sceneName];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
    CCLOG(@"GeneralScene:dealloc");

    for (id child in self.children) {
        if ([child isKindOfClass:[InteractiveSprite class]])
        {
            InteractiveSprite * intrSprite = (InteractiveSprite*) child;
            [intrSprite removeFromTouchDispatcher];
        }
    }
    
	// don't forget to call "super dealloc"
	[super dealloc];
}

//SYNTESIZE_TRACE(GeneralScene)

@end
