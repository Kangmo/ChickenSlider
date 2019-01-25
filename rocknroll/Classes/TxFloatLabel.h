//
//  TxFloatLabel.h
//  rocknroll
//
//  Created by 김 강모 on 11. 11. 13..
//  Copyright (c) 2011년 강모소프트. All rights reserved.
//

#ifndef rocknroll_TxFloatLabel_h
#define rocknroll_TxFloatLabel_h

#include "TxLabel.h"
#include "FloatLabel.h"
/*
 play :
WidgetType=FloatLabel,WidgetName=Speed,InitValue=1.0,MinValue=1.0,MaxValue=1.5,StepValue=0.005,Font=yellow34.fnt,Align=Center,Prefix=x 
 */
class TxFloatLabel : public TxLabel
{
protected:
    FloatLabel * _floatLabel;

public :
    TxFloatLabel(TxWidgetOwner * parentNode, const TxRect & rect, REF(TxPropSet) propSetRef) : TxLabel(parentNode, rect, propSetRef)
    {
        float initValue = getFloatPropValue("InitValue", 0.0);
        float stepValue = getFloatPropValue("StepValue", 0.1);
        float minValue = getFloatPropValue("MinValue", 0.0);
        float maxValue = getFloatPropValue("MaxValue", 1.0);
        
        _floatLabel = new FloatLabel(label_, initValue, stepValue, minValue, maxValue);
    }
    
    FloatLabel * getWidgetImpl()
    {
        return _floatLabel;
    }
    
    virtual ~TxFloatLabel()
    {
        assert(_floatLabel);
        delete _floatLabel;
        _floatLabel = NULL;
    }
    
    virtual CCNode * getNode() {
        return _floatLabel->getLabel();
    }

};

#endif
