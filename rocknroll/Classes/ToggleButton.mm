//
//  ToggleButton.m
//  rocknroll
//
//  Created by 김 강모 on 11. 12. 4..
//  Copyright (c) 2011년 강모소프트. All rights reserved.
//

#import "ToggleButton.h"
#import "ActionRelayer.h"
#import "Util.h"

@implementation ToggleButton
@synthesize touchEnabled;

-(id) initWithImages:(REF(StringVector)) imageStringVector actionRelayer:(ActionRelayer*)relayer
{
    relayer_ = nil;
    
    int imageCount=0;
    
    BOOST_FOREACH(std::string & imageString, *imageStringVector)
    {
        NSString * imageNSString = [Util toNSString:imageString];
        CCMenuItem * toggleItem = [CCMenuItemImage itemFromNormalImage:imageNSString
                                                        selectedImage:imageNSString
                                                               target:nil
                                                             selector:nil];
        if (imageCount==0)
        {
            self = [CCMenuItemToggle itemWithTarget:relayer
                                                    selector:@selector(relayAction:)
                                                    items:toggleItem, nil];        
            relayer_ = [relayer retain];
        }
        else
        {
            assert(self);
            [self.subItems addObject:toggleItem];
        }
        imageCount++;
    }
    
    return self;
}

-(void)dealloc {
    assert(relayer_);
    [relayer_ release];
    relayer_ = nil;
    
    [super dealloc];
}

@end
