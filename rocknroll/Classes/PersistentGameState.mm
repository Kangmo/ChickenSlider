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
-(int) readIntAttr:(NSString*)attrName 
{
    NSMutableDictionary * gameState = [self getGameState];
    NSNumber * number = [gameState valueForKey:attrName];
    int intValue = [number intValue];
    return intValue;
/*    
    NSMutableData * gameState = [self getGameState];

    NSKeyedUnarchiver * decoder = [[NSKeyedUnarchiver alloc] initForReadingWithData:gameState ];
    int attrValue = [decoder decodeIntForKey:attrName];
    
    [decoder finishDecoding];
    [decoder release];
    
    return attrValue;
*/
}

/** @brief Write an integer attribute value. 
 */
-(void) writeIntAttr:(NSString*)attrName value:(int)attrValue
{
    NSMutableDictionary * gameState = [self getGameState];
    NSNumber * number = [NSNumber numberWithInt:attrValue];
    [gameState setValue:number forKey:attrName];
    
    [NSKeyedArchiver archiveRootObject:gameState toFile:_gameStatePath];
/*    
    NSMutableData * gameState = [self getGameState];

    NSKeyedArchiver * encoder = [[NSKeyedArchiver alloc] initForWritingWithMutableData:gameState ];
    
    [encoder encodeInt:attrValue forKey:attrName];
    [encoder finishEncoding];
    
    [gameState writeToFile:_gameStatePath atomically:YES];
    [encoder release];
*/
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
