//
//  PersistentGameState.h
//  rocknroll
//
//  Created by 김 강모 on 11. 10. 4..
//  Copyright 2011년 강모소프트. All rights reserved.
//
@interface PersistentGameState : NSObject
{
    NSString * _gameStatePath;
}

+(PersistentGameState*) sharedPersistentGameState;
-(int) readIntAttr:(NSString*)attrName;
-(void) writeIntAttr:(NSString*)attrName value:(int)attrValue;

@end
