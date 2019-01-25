//
//  TxIntegerLabel.h
//  rocknroll
//
//  Created by 김 강모 on 11. 11. 13..
//  Copyright (c) 2011년 강모소프트. All rights reserved.
//

#ifndef rocknroll_TxIntegerLabel_h
#define rocknroll_TxIntegerLabel_h

#include "TxLabel.h"
#include "IncNumLabel.h"

/*
 play :
 WidgetType=IntegerLabel,WidgetName=Score,Font=yellow34.fnt,Align=Left
 */
class TxIntegerLabel : public TxLabel
{
protected:
    IncNumLabel * _incNumLabel;
public :

    TxIntegerLabel(TxWidgetOwner * parentNode, const TxRect & rect, REF(TxPropSet) propSetRef) : TxLabel(parentNode, rect, propSetRef)
    {
        _incNumLabel = new IncNumLabel(label_);
    }
    
    virtual ~TxIntegerLabel()
    {
        assert(_incNumLabel);
        delete _incNumLabel;
        _incNumLabel = NULL;
    }    

    virtual CCNode * getNode() {
        return _incNumLabel->getLabel();
    }
    
    IncNumLabel * getWidgetImpl()
    {
        return _incNumLabel;
    }
};

#endif
