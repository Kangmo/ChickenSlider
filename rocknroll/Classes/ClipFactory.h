//
//  ClipFactory.h
//  rocknroll
//
//  Created by 김 강모 on 11. 9. 28..
//  Copyright 2011년 강모소프트. All rights reserved.
//



@interface ClipFactory : NSObject
{
    NSMutableDictionary * clipDict;
}


+ (ClipFactory*) sharedFactory ;
- (NSDictionary*) clipByFile:(NSString*) clipFileName;

@end
