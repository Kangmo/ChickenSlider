//
//  TxImageSwitch.h
//  rocknroll
//
//  Created by 김 강모 on 11. 11. 13..
//  Copyright (c) 2011년 강모소프트. All rights reserved.
//

#ifndef rocknroll_TxImageSwitch_h
#define rocknroll_TxImageSwitch_h

#include "TxLabel.h"
#import "ActionRelayer.h"
#import "ToggleButton.h"
/*
 options :
 WidgetType=ImageSwitch,WidgetName=Difficulty,Images=Sel_Easy.png|Sel_Hard.png
 */
class TxToggleButton : public TxWidget
{
protected:
    ToggleButton * toggleButton_;
    CCMenu * menu_;
public :
    TxToggleButton(TxWidgetOwner * parentNode, const TxRect & rect, REF(TxPropSet) propSetRef) : TxWidget(rect, propSetRef)    
    {
        ActionRelayer * relayer = [ActionRelayer actionRelayerWithTarget:parentNode source:this];
        
        REF(StringVector) imageStringVector = getPropArray("Images");

        toggleButton_ = [[ToggleButton alloc] initWithImages:imageStringVector actionRelayer:relayer];

        menu_ = [[CCMenu menuWithItems:toggleButton_, nil] retain];
        menu_.isTouchEnabled= YES;
        
        [parentNode addChild:menu_];
        
        TxWidget::align(menu_);
        
        int defaultIndex = getIntPropValue("DefaultIndex");
        setValue(defaultIndex);
    }
    
    virtual ~TxToggleButton()
    {
        assert(menu_);
        [menu_ release];
        menu_ = NULL;
    }
    
    int getValue()
    {
        if ( toggleButton_.visible )
        {
            return toggleButton_.selectedIndex;
        }
        // If the toggle button is invisible, return false.
        return -1;
    }
    
    void setValue(int value)
    {
        int maxValue = [[toggleButton_ subItems] count];
        assert( value < maxValue );
        if ( value < 0 )
        {
            toggleButton_.visible = NO;
        }
        else
        {
            toggleButton_.visible = YES;
            toggleButton_.selectedIndex = value;
        }
    }
};

#endif
