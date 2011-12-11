//
//  TxSandClock.h
//  rocknroll
//
//  Created by 김 강모 on 11. 11. 13..
//  Copyright (c) 2011년 강모소프트. All rights reserved.
//

#ifndef rocknroll_TxSandClock_h
#define rocknroll_TxSandClock_h

#include "TxImageArray.h"
/*
 play :
WidgetType=SandClock,WidgetName=SandClock,Images=clock00.png|clock01.png|clock02.png|clock03.png|clock04.png|clock05.png|clock06.png|clock07.png|clock08.png|clock09.png|clock10.png|clock11.png,Align=Center
 */
class TxSandClock : public TxImageArray
{
    public :
    TxSandClock(TxWidgetOwner * parentNode, const TxRect & rect, REF(TxPropSet) propSetRef) : TxImageArray(parentNode,rect, propSetRef)
    {
    }
    virtual ~TxSandClock()
    {
    }
    
    void setProgress(int secondsLeft, int totalSeconds)
    {
        int imageCount = getImageCount();
        int secondsElapsed = totalSeconds - secondsLeft;
        int imageIndex = secondsElapsed * imageCount / totalSeconds;
        assert(imageIndex >=0 );
        if (imageIndex >= imageCount)
            imageIndex = imageCount - 1;
        setValue(imageIndex);
    }

};

#endif
