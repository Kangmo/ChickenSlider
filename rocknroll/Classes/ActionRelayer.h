//
//  ActionRelayer.h
//  rocknroll
//
//  Created by 김 강모 on 11. 12. 4..
//  Copyright (c) 2011년 강모소프트. All rights reserved.
//

#import <Foundation/Foundation.h>

class TxWidget;

class ActionRelayListener {
public :
    virtual void onActionRelay() = 0;
};

@interface ActionRelayer : NSObject
{
    id actionTarget_;
    TxWidget* actionSource_;
}

@property (assign) ActionRelayListener * actionRelayListener;
+(id)actionRelayerWithTarget:(id)target source:(TxWidget*)source;

@end
