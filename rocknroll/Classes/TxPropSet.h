//
//  TxPropSet.h
//  rocknroll
//
//  Created by 김 강모 on 11. 11. 13..
//  Copyright (c) 2011년 강모소프트. All rights reserved.
//

#ifndef rocknroll_TxPropSet_h
#define rocknroll_TxPropSet_h

#include "CppInfra.h"

class TxPropSet
{
//    const REF(StringVector) StringVectorRefNull = (REF(StringVector)(StringVector*)NULL);
    typedef std::map<std::string, REF(StringVector)> PropMap;
    PropMap propMap_;
public :
    TxPropSet()
    {
    }
    virtual ~TxPropSet()
    {
    }
    void addPropString(const std::string & propName, const std::string & propValue)
    {
        REF(StringVector) stringVectorRef((StringVector*)NULL);
        stringVectorRef = (REF(StringVector))new StringVector();
        stringVectorRef->at(0) = propValue;
        addPropArray(propName, stringVectorRef);
    }
    
    void addPropArray(const std::string & propName, REF(StringVector) stringVectorRef)
    {
        assert( ! propMap_[propName] );
        propMap_[propName] = stringVectorRef;
    }
    
    REF(StringVector) getPropArray(const std::string & propName)
    {
        REF(StringVector) stringVectorRef = propMap_[propName];
        return stringVectorRef;
    }
    
    const std::string & getPropString(const std::string & propName)
    {
        static std::string theEmptyStr = "";
        REF(StringVector) stringVectorRef = getPropArray(propName);
        if (!stringVectorRef)
        {
            return theEmptyStr;
        }
        assert( stringVectorRef->size() == 1 );
        return stringVectorRef->at(0);
    }
};

#endif
