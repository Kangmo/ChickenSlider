//
//  TxWidgetContainer.h
//  rocknroll
//
//  Created by 김 강모 on 11. 11. 13..
//  Copyright (c) 2011년 강모소프트. All rights reserved.
//

#ifndef rocknroll_TxWidgetContainer_h
#define rocknroll_TxWidgetContainer_h

#include "TxWidget.h"

const REF(TxWidget) widgetRefNull = REF(TxWidget)((TxWidget*)NULL);

/** @brief The container that provides interfaces to map REF(Widget)s to strings.
 */
class TxWidgetContainer
{
protected:
    typedef std::map<std::string, REF(TxWidget)> WidgetMap;
    WidgetMap widgetMap_;

    void addWidget(const std::string & widgetName, REF(TxWidget) widgetRef)
    {
        assert( widgetMap_[widgetName] == widgetRefNull );
        widgetMap_[widgetName] = widgetRef;
    }
public :
    TxWidgetContainer()
    {
    }
    virtual ~TxWidgetContainer()
    {
    }

    void addWidget(REF(TxWidget) widgetRef)
    {
        const std::string & widgetName = widgetRef->getName();
        addWidget( widgetName, widgetRef);
    }
 
    REF(TxWidget) getWidget(const std::string & widgetName )
    {
        REF(TxWidget) widgetRef = widgetMap_[widgetName];
        assert(widgetRef != widgetRefNull );
        return widgetRef;
    }
};

#endif
