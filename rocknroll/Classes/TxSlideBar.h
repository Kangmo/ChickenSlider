//
//  TxSlideBar.h
//  rocknroll
//
//  Created by 김 강모 on 11. 11. 13..
//  Copyright (c) 2011년 강모소프트. All rights reserved.
//

#ifndef rocknroll_TxSlideBar_h
#define rocknroll_TxSlideBar_h

#include "TxWidget.h"
#import "Slider.h"
#import "ActionRelayer.h"

/*
 options :
 WidgetType=SlideBar,WidgetName=MusicVolumeSlide,SlideImage=gage.png,SlideMin=0,SlideMax=10,SlideDefault=10,Align=Left
 */
class TxSlideBar : public TxWidget
{
protected:
    Slider *slider_;
public :
    TxSlideBar(TxWidgetOwner * parentNode, const TxRect & rect, REF(TxPropSet) propSetRef) : TxWidget(rect, propSetRef)
    {
        ActionRelayer * relayer = [ActionRelayer actionRelayerWithTarget:parentNode source:this];

        slider_ = [[Slider alloc] initWithActionRelayer:relayer];
        //slider_.liveDragging = YES;
        [parentNode addChild:slider_];
        
        TxWidget::align(slider_);
    }
    
    virtual ~TxSlideBar()
    {
        assert(slider_);
        [slider_ release];
        slider_ = nil;
    }
    
    float getValue()
    {
        return [slider_ value];
    }
    
    void setValue(float value)
    {
        [slider_ setValue:value];
    }
};

#endif
