//
//  TxWidgetFactory.h
//  rocknroll
//
//  Created by 김 강모 on 11. 11. 13..
//  Copyright (c) 2011년 강모소프트. All rights reserved.
//

#ifndef rocknroll_TxWidgetFactory_h
#define rocknroll_TxWidgetFactory_h

#import "cocos2d.h"
#include "StringParser.h"
#include "TxWidget.h"
#include "TxLabel.h"
#include "TxImageArray.h"
#include "TxSlideBar.h"
#include "TxSandClock.h"
#include "TxToggleButton.h"
#include "TxFloatLabel.h"
#include "TxIntegerLabel.h"
#include "TxAnimationClip.h"

namespace TxWidgetFactory
{
    /** @brief Create a new widget with the given rect and property list within the given CCNode */
    inline REF(TxWidget) newWidget(TxWidgetOwner * parentNode, const TxRect & rect, const std::string & propListString)
    {
        REF(TxWidget) widgetRef = REF(TxWidget)((TxWidget*)NULL);
        
        REF(TxPropSet) propSetRef = StringParser::getPropSet(propListString);
        
        const std::string & WIDGET_TYPE = "WidgetType";
        const std::string & widgetType = propSetRef->getPropString(WIDGET_TYPE);
        
        if (widgetType == "Label")
        {
            widgetRef = REF(TxWidget) (new TxLabel( parentNode, rect, propSetRef) );
        }
        else if (widgetType == "ImageArray")
        {
            widgetRef = REF(TxWidget) (new TxImageArray( parentNode, rect, propSetRef) );
        }
        else if (widgetType == "SlideBar")
        {
            widgetRef = REF(TxWidget) (new TxSlideBar( parentNode, rect, propSetRef) );
        }
        else if (widgetType == "SandClock")
        {
            widgetRef = REF(TxWidget) (new TxSandClock( parentNode, rect, propSetRef) );
        }
        else if (widgetType == "ToggleButton")
        {
            widgetRef = REF(TxWidget) (new TxToggleButton( parentNode, rect, propSetRef) );
        }
        else if (widgetType == "FloatLabel")
        {
            widgetRef = REF(TxWidget) (new TxFloatLabel( parentNode, rect, propSetRef) );
        }
        else if (widgetType == "IntegerLabel")
        {
            widgetRef = REF(TxWidget) (new TxIntegerLabel( parentNode, rect, propSetRef) );
        }
        else if (widgetType == "AnimationClip")
        {
            widgetRef = REF(TxWidget) (new TxAnimationClip( parentNode, rect, propSetRef) );
        }
        else
        {
            // Shouldn't come here.
            assert(0);
        }
                      
        assert(widgetRef);
        return widgetRef;
    }
};

#endif
