//
//  DemoManager.m
//  rocknroll
//
//  Created by 김 강모 on 12. 1. 23..
//  Copyright (c) 2012년 강모소프트. All rights reserved.
//

#import "DemoManager.h"
#import "StageScene.h"
#import "GeneralScene.h"
@implementation DemoManager

static DemoManager *instanceOfDemoManager;

#pragma mark Singleton stuff
+(id) alloc
{
	@synchronized(self)	
	{
		NSAssert(instanceOfDemoManager == nil, @"Attempted to allocate a second instance of the singleton: DemoManager");
		instanceOfDemoManager = [[super alloc] retain];
		return instanceOfDemoManager;
	}
	
	// to avoid compiler warning
	return nil;
}

-(id) init {
    if ( self = [super init] ) {
        layerNameStack_ = [[TSStack alloc] init];
    }
    return self;
}

-(void) dealloc
{
	CCLOG(@"dealloc %@", self);
	[layerNameStack_ release];
    
	[super dealloc];
}

-(void) pushLayerName:(NSString*)layerName {
    assert(layerName);
    [layerNameStack_ push:layerName]; 
}

-(NSString*) popLayerName {
    id item = [layerNameStack_ pop];
    if (item) {
        assert( [item isKindOfClass:[NSString class]] );
    }
    return item;
}

+(DemoManager*) sharedDemoManager
{
	@synchronized(self)
	{
		if (instanceOfDemoManager == nil)
		{
			[[DemoManager alloc] init];
		}
		
		return instanceOfDemoManager;
	}
	
	// to avoid compiler warning
	return nil;
}

const int DEMO_STAGE_LAYER = 1004;

typedef struct demo_stage_desc_t {
    NSString * map;
    int level;
}demo_stage_desc_t;



-(StageScene*) nextDemoStage {
    static demo_stage_desc_t demoStages[] = {
        {@"MAP02", 12},
        {@"MAP01", 12},
        {@"MAP02", 22},
        {@"MAP02", 15},
        {@"MAP01", 8},
        {@"MAP01", 15},
        {@"MAP02", 3},
        {@"MAP02", 7},
        {@"MAP01", 4},
        {@"MAP02", 18},
        {nil,0},
    };
    static int nextDemoIndex = 0;
    
    /** BUGBUG : Think loading asynchronously */
    StageScene * nextStage = [[[StageScene alloc] initInMap:demoStages[nextDemoIndex].map 
                                                   levelNum:demoStages[nextDemoIndex].level
                                                     playUI:nil] autorelease];

    if (demoStages[ ++nextDemoIndex ].map == nil) {
        nextDemoIndex = 0;
    }
    
    return nextStage;
}

-(void) runNextDemo {
    CCScene * scene = [CCDirector sharedDirector].runningScene;
    [scene removeChildByTag:DEMO_STAGE_LAYER cleanup:YES];
    
    StageScene * nextStageLayer = [self nextDemoStage];
    [scene addChild:nextStageLayer z:-1 tag:DEMO_STAGE_LAYER];
}

-(BOOL) isRunningDemo {
    CCScene * scene = [CCDirector sharedDirector].runningScene;
    id demoStageLayer = [scene getChildByTag:DEMO_STAGE_LAYER];
    return demoStageLayer ? YES : NO;
}

-(void) replaceMenuLayer:(CCLayer*)newLayer {
    CCScene * scene = [CCDirector sharedDirector].runningScene;

    [scene removeChildByTag:GeneralSceneLayerTagMenu cleanup:YES];

    // -2 : Scrolling background, (Cloud with sky)
    // -1 : StageScene, (demo or play)
    // 0  : Static background
    // 1  : playUI, unused in menu scenes
    // 2  : PauseScene, menu layers in other menus scenes
    [scene addChild:newLayer z:2 tag:GeneralSceneLayerTagMenu];
}

-(void)onReplaceMenuLayer:(id)sender data:(void*)newLayer 
{
    NSAssert1( [(id)newLayer isKindOfClass:[CCLayer class]], @"newLayer passed to onReplaceMenuLayer is not a CCLayer:%@", (id)newLayer);
    
    [self replaceMenuLayer:(CCLayer*)newLayer];
    
    [(id)newLayer release]; // Release once because we retained once in reserveReplacingMenuLayer:.
}

-(void) reserveReplacingMenuLayer:(GeneralScene*)newLayer {
    CCScene * scene = [CCDirector sharedDirector].runningScene;
    id layer = [scene getChildByTag:GeneralSceneLayerTagMenu];
    NSAssert1( [layer isKindOfClass:[GeneralScene class]], @"getChildByTag(GeneralSceneLayerTagMenu) does not return a GeneralScene:%@", layer);
    GeneralScene * menuLayer = (GeneralScene*) layer;
    [menuLayer runEndAction];
    
    [newLayer retain]; // Retain not to deallocate the new layer
    
    id delayedAction = [CCCallFuncND actionWithTarget:self selector:@selector(onReplaceMenuLayer:data:) data:(void*)newLayer];
    [menuLayer runAction:[CCSequence actions: [CCDelayTime actionWithDuration:1.0f], delayedAction, nil]];
}

+(void) dealloc
{
	CCLOG(@"dealloc %@", self);
	
	[instanceOfDemoManager release];
	instanceOfDemoManager = nil;
    
	[super dealloc];
}

@end
