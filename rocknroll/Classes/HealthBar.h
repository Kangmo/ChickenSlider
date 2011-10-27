//
//  HealthBar.h
//  rocknroll
//
//  Created by 김 강모 on 11. 10. 3..
//  Copyright 2011년 강모소프트. All rights reserved.
//

#ifndef rocknroll_HealthBar_h
#define rocknroll_HealthBar_h

#import "cocos2d.h"

class HealthBar {
private :
    CCProgressTimer *_progressTimer;
    float _targetPercent;
    float _currentPercent;
public:    
    HealthBar()
    {
        const float initialPercent = 100;
        _targetPercent = initialPercent;
        _currentPercent = initialPercent;

        _progressTimer = [[CCProgressTimer progressWithFile:@"health_bar.png"] retain];
        assert(_progressTimer);
        _progressTimer.type = kCCProgressTimerTypeHorizontalBarLR;
        _progressTimer.percentage = initialPercent;
        
        [_progressTimer retain];
    }

    ~HealthBar()
    {
        assert(_progressTimer);
        [_progressTimer release];
        _progressTimer = NULL;
    }
    
    inline CCProgressTimer * getProgressTimer() {
        return _progressTimer;
    }
    
    inline void update()
    {
        if ( _currentPercent != _targetPercent ) {
            
            // Increase half of the diff to the target count at most.
            float incPercent = _currentPercent<_targetPercent?1:-1;
            
            _currentPercent +=incPercent ;
            assert(_currentPercent >= 0 );
            assert(_currentPercent <= 100 );
            
            _progressTimer.percentage = _currentPercent; 
        }
    }
    
    inline void setTargetPercent(float targetPercent)
    {
        assert(targetPercent >= 0 );
        assert(targetPercent <= 100 );
        
        _targetPercent = targetPercent;
    }
    
    inline int getTargetPercent()
    {
        return _targetPercent; 
    }
    
    inline void setPercent(float percent)
    {
        assert(percent >= 0 );
        assert(percent <= 100 );
        
        _targetPercent = _currentPercent = percent;
        _progressTimer.percentage = percent;
    }
    
    inline int getPercent()
    {
        return _currentPercent; 
    }
};

#endif
