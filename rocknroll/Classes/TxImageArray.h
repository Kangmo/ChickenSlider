//
//  TxImageArray.h
//  rocknroll
//
//  Created by 김 강모 on 11. 11. 13..
//  Copyright (c) 2011년 강모소프트. All rights reserved.
//

#ifndef rocknroll_TxImageArray_h
#define rocknroll_TxImageArray_h

#include "TxToggleButton.h"
/*
 stageclear:
 WidgetType=ImageArray,WidgetName=StarPoints,Images=B_Star_0.png|B_Star_1.png|B_Star_2.png|B_Star_3.png
 // DefaultIndex=-1 means show nothing.
 WidgetType=ImageArray,WidgetName=ClearMessage,Images=new_high_score.png,DefaultIndex=-1

 play :
 WidgetType=ImageArray,WidgetName=KeysAndChicks,Images=amount.png,DefaultIndex=0
 */

class TxImageArray : public TxToggleButton
{
    public :
    TxImageArray(TxWidgetOwner * parentNode, const TxRect & rect, REF(TxPropSet) propSetRef) : TxToggleButton(parentNode, rect, propSetRef)    
    {
        menu_.isTouchEnabled= NO;
    }
    
    virtual ~TxImageArray()
    {
    }
};

#endif
