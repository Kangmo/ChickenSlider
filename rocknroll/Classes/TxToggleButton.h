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

/*
 options :
 WidgetType=ImageSwitch,WidgetName=Difficulty,Images=Sel_Easy.png|Sel_Hard.png
 */
class TxToggleButton : public TxWidget
{
protected:
    CCMenuItemToggle * toggleButton_;
    CCMenu * menu_;
public :
    TxToggleButton(TxWidgetOwner * parentNode, const TxRect & rect, REF(TxPropSet) propSetRef) : TxWidget(rect, propSetRef)    
    {
        ActionRelayer * relayer = [ActionRelayer actionRelayerWithTarget:parentNode source:this];
        
        REF(StringVector) imageStringVector = getPropArray("Images");

        // Create toggleButton_ from imageStringVector
        {
            int imageCount=0;
            
            BOOST_FOREACH(std::string & imageString, *imageStringVector)
            {
                NSString * imageNSString = [Util toNSString:imageString];
                CCSprite * normalSprite = [CCSprite spriteWithSpriteFrameName:imageNSString];
                CCSprite * selectedsprite = [CCSprite spriteWithSpriteFrameName:imageNSString];
                CCMenuItem * toggleItem = [[CCMenuItemSprite itemFromNormalSprite:normalSprite
                                                                   selectedSprite:selectedsprite
                                                                           target:nil
                                                                         selector:nil] retain];
                if (imageCount==0)
                {
                    toggleButton_ = [[CCMenuItemToggle itemWithTarget:relayer
                                                             selector:@selector(relayAction:)
                                                                items:toggleItem, nil] retain];        
                }
                else
                {
                    [toggleButton_.subItems addObject:toggleItem];
                }
                imageCount++;
            }
        }

        
        menu_ = [[CCMenu menuWithItems:toggleButton_, nil] retain];
        menu_.isTouchEnabled= YES;
        
        [parentNode addChild:menu_];
        
        TxWidget::align(menu_);
        
        int defaultIndex = -1;
        if (getIsPersistent()) {
            // The default value is -1 : Don't show any image if the persistent attribute does not exist.
            defaultIndex = [Util loadIntAttr:[Util toNSString:getName()] default:-1];
        }
        
        if (defaultIndex == -1)
        {
            NSString * defaultIndexString = getPropNSString("DefaultIndex");
            if (defaultIndexString)
                defaultIndex = [defaultIndexString intValue];
        }
        
        setValue(defaultIndex);
    }
    
    virtual ~TxToggleButton()
    {
        assert(toggleButton_);
        [toggleButton_ release];
        toggleButton_ = NULL;
        
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
    
    int getImageCount()
    {
        int count = [[toggleButton_ subItems] count];
        return count;
    }
    void disable() {
        menu_.isTouchEnabled= NO;
    }
    void setValue(int value)
    {
#if defined(DEBUG)
        int maxValue = getImageCount();
        assert( value < maxValue );
#endif
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
