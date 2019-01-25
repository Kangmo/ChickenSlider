//
//  DemoManager.h
//  rocknroll
//
//  Created by 김 강모 on 12. 1. 23..
//  Copyright (c) 2012년 강모소프트. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TSStack.h"
@class GeneralScene;

@interface DemoManager : NSObject
{
    TSStack * layerNameStack_;
}

+(DemoManager*) sharedDemoManager;

-(void) runNextDemo ;

-(BOOL) isRunningDemo ;

-(void) replaceMenuLayer:(CCLayer*)newLayer;
-(void) reserveReplacingMenuLayer:(GeneralScene*)newLayer;
-(void) pushLayerName:(NSString*)layerName;
-(NSString*) popLayerName;
@end

