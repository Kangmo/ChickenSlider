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
        animDict = [[NSMutableDictionary dictionary] retain];
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

- (NSDictionary*) animByFile:(NSString*) animSetFileName
{
//    CCLOG(@"animByFile:%@", animSetFileName);
    {
        NSDictionary * animSet = [animDict valueForKey:animSetFileName];
        if ( ! animSet )
        {
//            CCLOG(@"Not found in cache :%@", animSetFileName);
            
            animSet = [AKHelpers animationSetFromPlist:animSetFileName];
            assert( animSet );
            
            [animDict setValue:animSet forKey:animSetFileName];
        }
        
        return animSet;
    }    
}

- (void) purgeCachedData
{
    [clipDict removeAllObjects];
    [animDict removeAllObjects];
}


- (void) dealloc {
    [clipDict release];
    [animDict release];
    [super dealloc];
}
@end
