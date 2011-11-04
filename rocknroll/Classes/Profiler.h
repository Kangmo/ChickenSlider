//
//  Profiler.h
//  rocknroll
//
//  Created by 김 강모 on 11. 11. 3..
//  Copyright 2011년 강모소프트. All rights reserved.
//

#ifndef rocknroll_Profiler_h
#define rocknroll_Profiler_h

class TimeProfiler 
{
private :    
    // The accumlated time
    float accTime;
    float beginTime;
    const char * profilerName;
    
public :
    TimeProfiler(const char * profilerName) {
        accTime = 0.0f;
        beginTime = 0.0f;
    }
    ~TimeProfiler() {
        
    }
    void begin()
    {
        beginTime = CACurrentMediaTime(); 
    }
    void end()
    {
        float timeDiff = CACurrentMediaTime() - beginTime; 
        accTime += timeDiff;
    }
    void print()
    {
        
    }
};

#endif
