//
//  TSStack.m
//  rocknroll
//
//  Created by 김 강모 on 12. 1. 24..
//  Copyright (c) 2012년 강모소프트. All rights reserved.
//

#import "TSStack.h"

@implementation TSStack
// superclass overrides

- (id)init {
    if (self = [super init]) {
        contents = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)dealloc {
    [contents release];
    [super dealloc];
}

// Stack methods

- (void)push:(id)object {
    [contents addObject:object];
}

- (id)pop {
    NSUInteger count = [contents count];
    if (count > 0) {
        id returnObject = [[contents objectAtIndex:count - 1] retain];
        [contents removeLastObject];
        return [returnObject autorelease];
    }
    else {
        return nil;
    }
}

@end
