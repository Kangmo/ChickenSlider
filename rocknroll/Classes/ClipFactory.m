//
//  ClipFactory.m
//  rocknroll
//
//  Created by 김 강모 on 11. 9. 28..
//  Copyright 2011년 강모소프트. All rights reserved.
//

#import "ClipFactory.h"
#import "AKHelpers.h"

@implementation ClipFactory

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        clipDict = [[NSMutableDictionary dictionary] retain];
    }
    
    return self;
}

+ (ClipFactory*) sharedFactory 
{
    static ClipFactory * theFactory = nil;
    if ( theFactory == nil )
    {
        // BUGBUG : memory leak? The clip factory is not deallocated at all.
        theFactory = [[ClipFactory alloc] init];
        assert( theFactory );
    }
    
    return theFactory;
}

- (NSDictionary*) clipByFile:(NSString*) clipFileName
{
    NSDictionary * clip = [clipDict valueForKey:clipFileName];
    if ( ! clip )
    {
        clip = [AKHelpers animationClipFromPlist:clipFileName];
        assert( clip );
        
        [clipDict setValue:clip forKey:clipFileName];
    }

    return clip;
}

- (void) dealloc {
    [clipDict release];
    [super dealloc];
}
@end
