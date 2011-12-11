//
//  FloatLabel.h
//  rocknroll
//
//  Created by 김 강모 on 11. 11. 6..
//  Copyright 2011년 강모소프트. All rights reserved.
//

#ifndef rocknroll_FloatLabel_h
#define rocknroll_FloatLabel_h

#import "cocos2d.h"

class FloatLabel {
private :
    
    CCLabelBMFont *_label;
    
    float _targetValue;
    float _currentValue;
    float _minValue;
    float _maxValue;
    float _stepValue; // For each update, how much should we change?

    inline void setLabelValue(float newValue)
    {
        [_label setString:[NSString stringWithFormat:@"X %1.2f", newValue]];
    }

public:    
    FloatLabel(CCLabelBMFont * label, float initialValue, float stepValue, float minValue, float maxValue)
    {
        _targetValue = initialValue;
        _currentValue = initialValue;
        _minValue = minValue;
        _maxValue = maxValue;
        _stepValue = stepValue;
        
        _label = label;
        [_label setString:@""];
        assert(_label);
        [_label retain];
        
        setLabelValue( _currentValue );
    }
    
    ~FloatLabel()
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
        if ( _currentValue != _targetValue ) {
            // The amount of value to increase. (can have a negative value.)
            float incValue = _targetValue - _currentValue;
            if ( incValue > _stepValue )
                incValue = _stepValue;
            if ( incValue < -_stepValue )
                incValue = -_stepValue;
            
            _currentValue += incValue;
            
            if(_currentValue < _minValue )
                _currentValue = _minValue;
            if(_currentValue > _maxValue )
                _currentValue = _maxValue;
            
            setLabelValue( _currentValue );
        }
    }
    
    inline void setTargetValue(float targetValue)
    {
        assert(targetValue >= _minValue );
        assert(targetValue <= _maxValue );
        
        _targetValue = targetValue;
    }
    
    inline float getTargetValue()
    {
        return _targetValue; 
    }
    
    inline void setValue(float value)
    {
        assert(value >= _minValue );
        assert(value <= _maxValue );
        
        _targetValue = _currentValue = value;
        
        setLabelValue( value );
    }
    
    inline float getValue()
    {
        return _currentValue; 
    }
};

#endif
