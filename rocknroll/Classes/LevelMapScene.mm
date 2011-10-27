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
-(void) setLevelFailed:(int)level;
@end

@implementation LevelMapScene

// initialize your instance here
-(id) initWithSceneName:(NSString*)sceneName
{
    self = [super initWithSceneName:sceneName];
    if (self) {
        // Initialization code here.
        isTryingToPlayLevel = NO;
        
        // For reserving hero movement by the time scene is shown on the screen.
        moveHeroReserved = NO;
        reservedCurrentLevel = -1;
        reservedTargetLevel = -1;

        levelCount = 0;
        highestUnlockedLevel = 1;
        currentHeroLevel = 1;
        
        _heroSprite = [[CCSprite spriteWithSpriteFrameName:HERO_SPRITE_NAME] retain]; 
        assert(_heroSprite);
        [self addChild:_heroSprite];
        
        _heroWaitingClip = [[[ClipFactory sharedFactory] clipByFile:HERO_WAITING_CLIP] retain];
        assert(_heroWaitingClip);
        
        [self loadLevelSprites];
        [self loadMapState];
        [self lockLevels];
        
    }
    
    return self;
}

-(void)startHeroClip:(NSDictionary*)clip {
    Helper::runClip(_heroSprite, clip);
}

-(void)stopHeroClip {
    [_heroSprite stopAllActions];
}

-(void) dealloc {
    [_heroSprite release];
    _heroSprite = nil;
    
    [_heroWaitingClip release];
    _heroWaitingClip = nil;
    
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
	
	// 'layer' is an autorelease object.
	LevelMapScene *layer = [LevelMapScene nodeWithSceneName:sceneName];
    if (cleared)
    {
        [layer setLevelCleared:level];
    }
    else
    {
        [layer setLevelFailed:level];
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

-(int)readIntAttr:(NSString*)attrName
{
    PersistentGameState * gs = [PersistentGameState sharedPersistentGameState];
    NSString * sceneAttrName = [sceneName_ stringByAppendingString:attrName];
    int attrValue =  [ gs readIntAttr:sceneAttrName];
    if (attrValue == 0) // It it not written yet.
    {
        attrValue = 1;
    }
    return attrValue;
}

-(void) writeIntAttr:(NSString*)attrName value:(int)attrValue
{
    PersistentGameState * gs = [PersistentGameState sharedPersistentGameState];
    NSString * sceneAttrName = [sceneName_ stringByAppendingString:attrName];
    [gs writeIntAttr:sceneAttrName value:attrValue];
}

- (int) readHighestUnlockedLevel
{
    return [self readIntAttr:HIGHEST_UNLOCKED_LEVEL_ATTR];
}

- (int) readCurrentHeroLevel
{
    return [self readIntAttr:CURRENT_HERO_LEVEL_ATTR];
}

- (void) writeHighestUnlockedLevel:(int)level
{
    [self writeIntAttr:HIGHEST_UNLOCKED_LEVEL_ATTR value:level];
}

- (void) writeCurrentHeroLevel:(int)level
{
    [self writeIntAttr:CURRENT_HERO_LEVEL_ATTR value:level];
}

- (void) loadLevelSprites {
    
    // No levels should have been loaded.
    assert(levelCount == 0);
    
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
                assert(levelNum<MAX_LEVELS_PER_MAP);
                
                intrSprites[levelNum-1] = intrSprite;
                if ( levelCount < levelNum )
                    levelCount = levelNum;
            }
        }
    }
    
    // Make sure there is no hole in the intrSprites array.
    for (int l=1; l<levelCount; l++ )
    {
        assert(intrSprites[l-1]);
    }
}

-(CGPoint) heroLevelPosition:(int)level
{
    assert( level >= 1);
    assert( level <= levelCount );
    return intrSprites[level-1].position;
}

-(void) setHeroPosition:(int)level
{
    _heroSprite.position = [self heroLevelPosition:level];
    
    // Show that the hero is waiting
    [self startHeroClip:_heroWaitingClip];
}

-(void)setHeroPositionCallback:(id)sender data:(void*)callbackData 
{
    int level = (int)callbackData;
    [self setHeroPosition:level];

    currentHeroLevel = level;
    [self writeCurrentHeroLevel:currentHeroLevel];
}

/** @brief Reserve the movement of Hero so that the hero moves forward or backward from a level based on whether the level was cleard or not. 
 */
- (void) reserveHeroMovementFrom:(int)fromLevel to:(int)toLevel
{
    reservedCurrentLevel = fromLevel;
    reservedTargetLevel = toLevel;
    
    moveHeroReserved = YES;
}

- (void) moveHeroPositionTo:(int)toLevel
{
    assert(toLevel>=1);
    assert(toLevel<=highestUnlockedLevel);
    assert(toLevel<=levelCount);
    
    // Stop all actions first.
    [_heroSprite stopAllActions];

    CGPoint newPosition = [self heroLevelPosition:toLevel];
    
    [_heroSprite runAction:[CCSequence actions:
                           [CCMoveTo actionWithDuration:1.0f position:newPosition],
                           [CCCallFuncND actionWithTarget:self selector:@selector(setHeroPositionCallback:data:) data:(void*)toLevel],
                       nil]];
}

- (void) onEnterTransitionDidFinish {
    
    if (moveHeroReserved)
    {
        // Set the current position
        [self setHeroPosition:reservedCurrentLevel];
        
        assert (reservedCurrentLevel != reservedTargetLevel);

        [self moveHeroPositionTo:reservedTargetLevel];

        // BUGBUG:play some sound!
    }
    else
    {
        [self setHeroPosition:currentHeroLevel];
    }
}

- (void) loadMapState {
    highestUnlockedLevel = [self readHighestUnlockedLevel];
    currentHeroLevel = [self readCurrentHeroLevel];
    
    assert (currentHeroLevel <= highestUnlockedLevel );
}

-(void) unlockLevel:(int)level {
    assert(level>=1);
    assert(level<=levelCount);
    assert(level<=highestUnlockedLevel);
    
    InteractiveSprite * intrSprite = intrSprites[level-1];
    [intrSprite setLocked:NO];
}

-(void) lockLevels {
    for (int level = highestUnlockedLevel+1; level <=levelCount; level++ )
    {
        InteractiveSprite * intrSprite = intrSprites[level-1];
        [intrSprite setLocked:YES];
    }
    
    for (int level = 1; level <= highestUnlockedLevel; level ++ )
    {
        assert( ! [intrSprites[level-1] isLocked] ); // Shouldn't be locked by default.
    }

}

/** @brief Before the scene transition, the StageScene calls this function if the level is cleared. */
-(void) setLevelCleared:(int)level{
    assert( level <= levelCount );
    
    // Can we unlock the next level?
    if ( level == highestUnlockedLevel && (level+1) <= levelCount )
    {
        highestUnlockedLevel++;
        // Remove the lock sprite and make the level playable.
        [self unlockLevel:highestUnlockedLevel];
        // Write that the level was unlocked.
        [self writeHighestUnlockedLevel:highestUnlockedLevel];
    }
    
    currentHeroLevel = level;
    [self writeCurrentHeroLevel:currentHeroLevel];
}

/** @brief Before the scene transition, the StageScene calls this function if the level is failed.
 On the screen, the hero character moves one level backward.
 */
-(void) setLevelFailed:(int)level{
    assert( level <= levelCount );
    
    if ( level > 1 )
    {
        [self reserveHeroMovementFrom:level to:level-1];
    }
    
    currentHeroLevel = level;
    [self writeCurrentHeroLevel:currentHeroLevel];
}

typedef struct LevelInfo
{
    NSString * mapName;
    int newLevel;
} LevelInfo;

static LevelInfo gLevelInfo = {nil, 0};

-(void) replaceSceneCallback:(id)sender data:(void*)unusedData
{
    assert( gLevelInfo.mapName != nil);
    assert( gLevelInfo.newLevel >= 1 );
    assert( gLevelInfo.newLevel <= highestUnlockedLevel );    
    assert( gLevelInfo.newLevel <= levelCount );    
    
    // Replace the current scene to a loading scene that will again replace the scene to the new StageScene with the given map and level.
    CCScene * loadingScene = [GeneralScene loadingSceneOfMap:gLevelInfo.mapName levelNum:gLevelInfo.newLevel];
    [[CCDirector sharedDirector] replaceScene:loadingScene];
    
    //retained in playLevel:ofMap:
    [gLevelInfo.mapName release];
    
    gLevelInfo.mapName = nil;
    gLevelInfo.newLevel = 0;
}

/** @brief Move the character to the level, transition to the StageScene with the give level.
 */
-(void) playLevel:(int)newLevel ofMap:(NSString*)mapNameAttr {
    if (isTryingToPlayLevel)
        return;
    
    NSMutableArray * actions = [NSMutableArray array];
    
    // Make the Hero pass by each level between the last played level and the new level
    if (currentHeroLevel < newLevel) 
    {
        for (int level=currentHeroLevel; level <= newLevel; level++ )
        {
            CGPoint levelPosition = [self heroLevelPosition:level];
            CCMoveTo * moveToAction = [CCMoveTo actionWithDuration:0.2f position:levelPosition];
            [actions addObject:moveToAction];
        }
    }
    else if (currentHeroLevel > newLevel)
    {
        for (int level=currentHeroLevel; level >= newLevel; level-- )
        {
            CGPoint levelPosition = [self heroLevelPosition:level];
            CCMoveTo * moveToAction = [CCMoveTo actionWithDuration:0.2f position:levelPosition];
            [actions addObject:moveToAction];
        }
    }
    
    [actions addObject:[CCScaleTo actionWithDuration:0.2f scale:4.0f]];
    
    // released on replaceSceneCallback
    assert(gLevelInfo.mapName == nil);
    assert(gLevelInfo.newLevel == 0);
    
    gLevelInfo.mapName = [mapNameAttr retain];
    gLevelInfo.newLevel = newLevel;
    
    [actions addObject:[CCCallFuncND actionWithTarget:self selector:@selector(replaceSceneCallback:data:) data:(void*)nil]];
             
    [_heroSprite stopAllActions];
    [_heroSprite runAction:[CCSequence actionsWithArray:actions]];
     
     isTryingToPlayLevel = YES;
}

@end
