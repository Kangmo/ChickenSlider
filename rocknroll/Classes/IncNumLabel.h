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
    int _updateCount;
public:    
    IncNumLabel(CCLabelBMFont * label)
    {
        _targetCount = 0;
        _currentCount = 0;
        _updateCount = 0;
        
        _label = label;
        [label setString:@"0"];
        
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
        // Update the label once per 4 times.
        _updateCount ++;
        if ( (_updateCount & 0x04) != 0 )
            return;
        
        if ( _currentCount != _targetCount ) {
            // The amount of value to increase. (can have a negative value.)
            // Increase 1/2 of the gap at once.
            int stepCount = (_targetCount - _currentCount) >> 1;
            if (stepCount==0)
                stepCount = _currentCount < _targetCount ? 1 : -1;
             
            _currentCount += stepCount;
            
            if(_currentCount < 0 )
                _currentCount = 0;
            
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
