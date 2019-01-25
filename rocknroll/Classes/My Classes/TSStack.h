//
//  TSStack.h
//  rocknroll
//
//  Created by 김 강모 on 12. 1. 24..
//  Copyright (c) 2012년 강모소프트. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TSStack : NSObject
{
    NSMutableArray *contents;
}

- (void)push:(id)object;
- (id)pop;
@end
