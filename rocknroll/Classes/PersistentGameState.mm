//
//  PersistentGameState.m
//  rocknroll
//
//  Created by 김 강모 on 11. 10. 4..
//  Copyright 2011년 강모소프트. All rights reserved.
//

#import "PersistentGameState.h"

@implementation PersistentGameState

- (id)initWithFile:(NSString*)fileName
{
    self = [super init];
    if (self) {
        // Initialization code here.
        NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString * docDir = [paths objectAtIndex:0];
        _gameStatePath = [[docDir stringByAppendingPathComponent:fileName] retain];
        assert(_gameStatePath);
    }
    
    return self;
}
/*
-(NSMutableData *) getGameState 
{
    NSMutableData * gameState = [NSMutableData dataWithContentsOfFile:_gameStatePath];
    if (!gameState) { // The file is not written yet.
        gameState = [NSMutableData data]; 
    }
    assert(gameState);
    return gameState;
}
*/

-(NSMutableDictionary *) getGameState 
{
    NSDictionary * gameState = [NSKeyedUnarchiver unarchiveObjectWithFile:_gameStatePath];  
    
    NSMutableDictionary * mutableDictionary = nil;
    
    if (gameState) { 
        mutableDictionary = [NSMutableDictionary dictionaryWithDictionary:gameState];
        
    }
    else // The file is not written yet. Return an empty mutable dictionary
    {
        mutableDictionary = [NSMutableDictionary dictionary];
    }
    
    return mutableDictionary;
}

-(void) dealloc {
    [_gameStatePath release];
    _gameStatePath = nil;
    
    [super dealloc];
}

/** @brief Read an integer attribute value. Return 0 if it does not exist. 
 */
-(int) readIntAttr:(NSString*)attrName default:(int)defaultValue
{
    NSMutableDictionary * gameState = [self getGameState];
    NSNumber * number = [gameState valueForKey:attrName];
    int intValue = defaultValue;
    if (number)
    {
        intValue = [number intValue];
    }
    return intValue;
}

/** @brief Write an integer attribute value. 
 */
-(void) writeIntAttr:(NSString*)attrName value:(int)attrValue
{
    NSMutableDictionary * gameState = [self getGameState];
    NSNumber * number = [NSNumber numberWithInt:attrValue];
    
    [gameState setValue:number forKey:attrName];
    
    [NSKeyedArchiver archiveRootObject:gameState toFile:_gameStatePath];
}

/** @brief Read a float attribute value. Return 0 if it does not exist. 
 */
-(float) readFloatAttr:(NSString*)attrName default:(float)defaultValue
{
    NSMutableDictionary * gameState = [self getGameState];
    NSNumber * number = [gameState valueForKey:attrName];
    float floatValue = defaultValue;
    if ( number )
    {
        floatValue = [number floatValue];
    }
    return floatValue;
}

/** @brief Write a float attribute value. 
 */
-(void) writeFloatAttr:(NSString*)attrName value:(float)attrValue
{
    NSMutableDictionary * gameState = [self getGameState];
    NSNumber * number = [NSNumber numberWithFloat:attrValue];
    [gameState setValue:number forKey:attrName];
    
    [NSKeyedArchiver archiveRootObject:gameState toFile:_gameStatePath];
}


/** @brief Read a string attribute value. Return nil if it does not exist. 
 */
-(NSString*) readStringAttr:(NSString*)attrName 
{
    NSMutableDictionary * gameState = [self getGameState];
    NSString * string = [gameState valueForKey:attrName];
    return string;
}

/** @brief Write a string attribute value. 
 */
-(void) writeStringAttr:(NSString*)attrName value:(NSString*)attrValue
{
    NSMutableDictionary * gameState = [self getGameState];

    [gameState setValue:attrValue forKey:attrName];
    
    [NSKeyedArchiver archiveRootObject:gameState toFile:_gameStatePath];
}

+(PersistentGameState*) sharedPersistentGameState {
    // BUGBUG : Memory Leak : Need to destroy the singleton
    static PersistentGameState * thePersistentGameState = nil;
    if ( ! thePersistentGameState ) {
        thePersistentGameState = [[PersistentGameState alloc] initWithFile:@"game_state.dat"];
    }
    
    assert( [thePersistentGameState isKindOfClass:[PersistentGameState class]] );
    
    return thePersistentGameState;
}
@end
