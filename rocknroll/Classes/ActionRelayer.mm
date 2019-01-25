//
//  ActionRelayer.m
//  rocknroll
//
//  Created by 김 강모 on 11. 12. 4..
//  Copyright (c) 2011년 강모소프트. All rights reserved.
//

#import "ActionRelayer.h"
#import "TxWidget.h"

@implementation ActionRelayer
@synthesize actionRelayListener;

-(id)initRelayerWithTarget:(id)target source:(TxWidget*)source
{
    if ( self = [super init] ) 
    {
        actionTarget_ = target;
        actionSource_ = source;
    }
    return self;
}

+(id)actionRelayerWithTarget:(id)target source:(TxWidget*)source 
{
    return [[[ActionRelayer alloc] initRelayerWithTarget:target source:source] autorelease];
}

-(void) relayAction: (id) sender
{
    // BUGBUG : Relay to actionListener
    [actionTarget_ onWidgetAction:actionSource_];
    if (self.actionRelayListener) {
        self.actionRelayListener->onActionRelay();
    }
}
@end
