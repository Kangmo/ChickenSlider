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


-(int) readIntAttr:(NSString*)attrName default:(int)defaultValue;
-(void) writeIntAttr:(NSString*)attrName value:(int)attrValue;

-(float) readFloatAttr:(NSString*)attrName default:(float)defaultValue;
-(void) writeFloatAttr:(NSString*)attrName value:(float)attrValue;

-(NSString*) readStringAttr:(NSString*)attrName;
-(void) writeStringAttr:(NSString*)attrName value:(NSString*)attrValue;

@end
