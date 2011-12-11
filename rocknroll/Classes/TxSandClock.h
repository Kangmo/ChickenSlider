//
//  TxSandClock.h
//  rocknroll
//
//  Created by 김 강모 on 11. 11. 13..
//  Copyright (c) 2011년 강모소프트. All rights reserved.
//

#ifndef rocknroll_TxSandClock_h
#define rocknroll_TxSandClock_h

#include "TxWidget.h"
/*
 play :
 WidgetType=SandClock,WidgetName=SandClock
 */
class TxSandClock : public TxWidget
{
    public :
    TxSandClock(TxWidgetOwner * parentNode, const TxRect & rect, REF(TxPropSet) propSetRef) : TxWidget(rect, propSetRef)
    {
    }
    virtual ~TxSandClock()
    {
    }
};

#endif
