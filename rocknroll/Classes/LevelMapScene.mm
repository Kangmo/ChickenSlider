//
//  LevelMapScene.m
//  rocknroll
//
//  Created by 김 강모 on 11. 10. 3..
//  Copyright 2011년 강모소프트. All rights reserved.
//

#import "LevelMapScene.h"
#import "PersistentGameState.h"
#import "Util.h"
#import "ClipFactory.h"
#import "StageScene.h"

#define HIGHEST_UNLOCKED_LEVEL_ATTR @"_highest_cleared_level"
#define CURRENT_HERO_LEVEL_ATTR @"_current_hero_level"
#define HERO_SPRITE_NAME @"feather00.png"
#define HERO_WAITING_CLIP @"clip_feather.plist"


@interface LevelMapScene()
-(void) loadLevelSprites;
-(void) loadMapState;
-(void) lockLevels;

-(void) setLevelCleared:(int)level;
@end

@implementation LevelMapScene

// initialize your instance here
-(id) initWithSceneName:(NSString*)sceneName
{
    NSString * mapName = sceneName;
    if ([sceneName isEqualToString:@"MAP02_02"])
        mapName = @"MAP02";
    
    self = [super initWithSceneName:sceneName];
    if (self) {
        mapName_ = [mapName retain];
        
        // Initialization code here.
        isTryingToPlayLevel = NO;
        
        minLevel = MAX_LEVELS_PER_MAP;
        maxLevel = 0;
        
        highestUnlockedLevel = 1;
        
        [self loadLevelSprites];
        [self loadMapState];
        [self lockLevels];
        
    }
    
    return self;
}


-(void) dealloc {
    [mapName_ release];
    mapName_ = nil;
    [super dealloc];
}

+(id)nodeWithSceneName:(NSString*)sceneName
{
    return [[[LevelMapScene alloc] initWithSceneName:sceneName] autorelease];
}

+(CCScene*)sceneWithName:(NSString*)sceneName level:(int)level cleared:(BOOL)cleared
{
    // 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
    // TODO : Think about not hardcoding the map select scene.
    if ([sceneName isEqualToString:@"MAP02"] && level >= 9 )
        sceneName = @"MAP02_02";

	// 'layer' is an autorelease object.
	LevelMapScene *layer = [LevelMapScene nodeWithSceneName:sceneName];
    if (cleared)
    {
        [layer setLevelCleared:level];
    }
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

+(CCScene*)sceneWithName:(NSString*)sceneName
{
    // 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	CCLayer *layer = [LevelMapScene nodeWithSceneName:sceneName];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}


- (void) loadLevelSprites {
    
    // No levels should have been loaded.
    assert(minLevel == MAX_LEVELS_PER_MAP);
    assert(maxLevel == 0);
    
    for(id child in self.children)
    {
        if([child isKindOfClass:[InteractiveSprite class]])
        {
            InteractiveSprite * intrSprite = (InteractiveSprite*) child;
            
            NSString * sceneName = [intrSprite.touchActionDescs valueForKey:@"SceneName"];
            assert(sceneName);
                
            if ( [sceneName isEqualToString:@"StageScene"] )
            {
                // The string uniquly identifying level of stage.  
                NSString * levelNumAttr = [intrSprite.touchActionDescs valueForKey:@"Arg2"];
                assert(levelNumAttr);
                
                int levelNum = [levelNumAttr intValue];
                assert(levelNum>0);
                assert(levelNum<=MAX_LEVELS_PER_MAP);
                
                intrSprites[levelNum-1] = intrSprite;
                if ( minLevel > levelNum )
                    minLevel = levelNum;
                if ( maxLevel < levelNum )
                    maxLevel = levelNum;
            }
        }
    }
    // Make sure there is no hole in the intrSprites array.
    for (int l=minLevel; l<maxLevel; l++ )
    {
        assert(intrSprites[l-1]);
    }
}

- (void) loadMapState {
    highestUnlockedLevel = [Util loadHighestUnlockedLevel:mapName_];
}

-(void) unlockLevel:(int)level {
    assert(level>=minLevel);

    // If the level we are going to unlock is within this MapSelectScene, unlock the level.
    if(level<=maxLevel)
    {
        InteractiveSprite * intrSprite = intrSprites[level-1];
        [intrSprite setLocked:NO];
    }
}

-(void) lockLevels {
    for (int level = highestUnlockedLevel+1; level <=maxLevel; level++ )
    {
        InteractiveSprite * intrSprite = intrSprites[level-1];
        [intrSprite setLocked:YES spriteFrameName:@"stagelocked.png"];
    }
}

/** @brief Before the scene transition, the StageScene calls this function if the level is cleared. */
-(void) setLevelCleared:(int)level{
    assert( level >= minLevel );
    assert( level <= maxLevel );

    // Can we unlock the next level?
    if ( level == highestUnlockedLevel )
    {
        highestUnlockedLevel++;
        
        // Write that the next level was unlocked.
        [Util saveHighestUnlockedLevel:mapName_ level:highestUnlockedLevel];
        
        if ((level+1) <= maxLevel)
        {
            // Remove the lock sprite and make the level playable.
            [self unlockLevel:highestUnlockedLevel];
        }
    }
}

@end
