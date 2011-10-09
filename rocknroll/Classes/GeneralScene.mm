#import "GeneralScene.h"
#import "svgLoader.h"
#import "Util.h"
#import "RetainCountTrace.h"
#import "b2WorldEx.h"
#import "InteractiveSprite.h"
#import "StageScene.h"

@implementation GeneralScene

@synthesize previousLayer;
@synthesize loadingLevel;
@synthesize loadingLevelMapName;

// initialize your instance here
-(id) initWithSceneName:(NSString*)sceneName
{
	if( (self=[super init])) 
	{
        sceneName_ = [sceneName retain];
        
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
        
        self.loadingLevel = 0;
        self.loadingLevelMapName = nil;
    }
    
    return self;
}

+(id)nodeWithSceneName:(NSString*)sceneName
{
    return [[[GeneralScene alloc] initWithSceneName:sceneName] autorelease];
}

+(CCScene*)sceneWithName:(NSString*)sceneName previousLayer:(CCLayer*)pl;
{
    // 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	GeneralScene *layer = [GeneralScene nodeWithSceneName:sceneName];
	layer.previousLayer = pl;
    
	// add layer as a child to scene
	[scene addChild:layer z:0 tag:GeneralSceneLayerTagMain];
	
	// return the scene
	return scene;
}

+(CCScene*)sceneWithName:(NSString*)sceneName
{
    return [self sceneWithName:sceneName previousLayer:nil];
}

// Create a loading scene that will again replace the scene to a new StageScene with the given map and level.
+(CCScene*)loadingSceneOfMap:(NSString*)mapName levelNum:(int)level
{
    // 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	GeneralScene *layer = [GeneralScene nodeWithSceneName:@"LoadingScene"];
	layer.loadingLevelMapName = mapName;
    layer.loadingLevel = level;
    // Should wait a frame to get the loading scene displayed on the screen.
    [layer scheduleUpdate];
    
	// add layer as a child to scene
	[scene addChild:layer z:0 tag:GeneralSceneLayerTagMain];
	
	// return the scene
	return scene;
}

-(void) update:(ccTime)delta
{
    [self unscheduleAllSelectors];
    
    // Arguments to the loading Scene should have been specified.
    assert ( self.loadingLevel > 0 );
    assert ( self.loadingLevelMapName );
    
    CCScene * newScene = [StageScene sceneInMap:self.loadingLevelMapName levelNum:self.loadingLevel];
    [[CCDirector sharedDirector] replaceScene:newScene];
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
    
    self.previousLayer = nil;
    self.loadingLevelMapName = nil;
    [sceneName_ release];
    
	// don't forget to call "super dealloc"
	[super dealloc];
}

//SYNTESIZE_TRACE(GeneralScene)

@end
