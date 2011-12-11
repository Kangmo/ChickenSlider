//
//  ToggleButton.h
//  rocknroll
//
//  Created by 김 강모 on 11. 12. 4..
//  Copyright (c) 2011년 강모소프트. All rights reserved.
//

#import "CCMenu.h"

#include "CppInfra.h"

/** A toggle button that implements TxToggleButton and TxImageArray.
    The implementation copied some source codes from the following website.
    http://www.reigndesign.com/blog/creating-a-button-using-ccmenuitemtoggle-in-cocos2d/
 */

@class ActionRelayer;

@interface ToggleButton : CCMenuItemToggle
{
    ActionRelayer * relayer_;
}

@property (readwrite, assign) BOOL touchEnabled;

-(id) initWithImages:(REF(StringVector)) imageStringVector actionRelayer:(ActionRelayer*)relayer;

@end
