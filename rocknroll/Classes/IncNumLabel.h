//
//  IncNumLabel.h
//  rocknroll
//
//  Created by 김 강모 on 11. 10. 3..
//  Copyright 2011년 강모소프트. All rights reserved.
//

#ifndef rocknroll_IncNumLabel_h
#define rocknroll_IncNumLabel_h

#import "cocos2d.h"

class IncNumLabel {
private :
    CCLabelBMFont *_label;
    int _targetCount;
    int _currentCount;
public:    
    IncNumLabel()
    {
        _targetCount = 0;
        _currentCount = 0;

        _label = [CCLabelBMFont labelWithString:@"0" fntFile:@"punkboy.fnt"];
        
        [_label retain];
    }

    ~IncNumLabel()
    {
        assert(_label);
        [_label release];
        _label = NULL;
    }
    
    inline CCLabelBMFont * getLabel() {
        return _label;
    }
    
    inline void update()
    {
        if ( _currentCount < _targetCount ) {
            
            // Increase half of the diff to the target count at most.
            int incCount = (_targetCount - _currentCount) >> 1;
            if (incCount == 0)
                incCount = 1;
            
            _currentCount +=incCount ;
            
            [_label setString:[NSString stringWithFormat:@"%d", _currentCount]];
        }
    }
    
    inline void setTargetCount(int targetCount)
    {
        _targetCount = targetCount;
    }
    
    inline int getTargetCount()
    {
        return _targetCount; 
    }
    
    inline void setCount(int count)
    {
        _targetCount = _currentCount = count;
        [_label setString:[NSString stringWithFormat:@"%d", count]];
    }
    
    inline int getCount()
    {
        return _currentCount; 
    }

};

#endif
