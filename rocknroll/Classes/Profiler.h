//
//  Profiler.h
//  rocknroll
//
//  Created by 김 강모 on 11. 11. 3..
//  Copyright 2011년 강모소프트. All rights reserved.
//

#ifndef rocknroll_Profiler_h
#define rocknroll_Profiler_h

const int DIST_ARRAY_ITEM_COUNT = 29;

class TimeProfiler 
{
private :    
    // The accumlated time
    float accTime;
    float beginTime;
    int profileCount;
    const char * profilerName;
    // 10 items : 0~100,~200,~300,...,~1000ns(1ms)
    // 9 items : 1ms~2ms,~3ms,...,~10ms,
    // 9 item : 10ms~20ms,~30ms,...,~100ms,
    // 1 item : 100ms~,
    int distArray[DIST_ARRAY_ITEM_COUNT];
public :
    static BOOL IsEnabled;

    TimeProfiler(const char * name) {
        accTime = 0.0f;
        beginTime = 0.0f;
        profileCount = 0;
        profilerName = name;
        memset(distArray, 0, sizeof(distArray));
    }
    ~TimeProfiler() {
        
    }
    void begin()
    {
        if (IsEnabled)
        {
            assert(beginTime == 0.0f);
            beginTime = CACurrentMediaTime(); 
        }
    }
    void end()
    {
        if (IsEnabled)
        {
            assert(beginTime > 0.0f);
            
            float timeDiff = CACurrentMediaTime() - beginTime; 
            // BUGBUG : Sometimes timeDiff is less than 0.0f. Find out Why.
            updateDistArray( timeDiff );
            accTime += timeDiff;
            profileCount++;
            
            beginTime = 0.0f;
        }
    }
    
    float getTotalTime()
    {
        return accTime;
    }
    int getProfileCount()
    {
        return profileCount;
    }
    void updateDistArray(float timeDiff)
    {

        int distArrayIndex=DIST_ARRAY_ITEM_COUNT;
        
        // 10 items : 0~100,~200,~300,...,~1000ns(1ms)
        if ( timeDiff < 0.0001 ) {
            distArrayIndex = 0;
        }
        else if ( timeDiff < 0.0002 ) {
            distArrayIndex = 1;
        }
        else if ( timeDiff < 0.0003 ) {
            distArrayIndex = 2;
        }
        else if ( timeDiff < 0.0004 ) {
            distArrayIndex = 3;
        }
        else if ( timeDiff < 0.0005 ) {
            distArrayIndex = 4;
        }
        else if ( timeDiff < 0.0006 ) {
            distArrayIndex = 5;
        }
        else if ( timeDiff < 0.0007 ) {
            distArrayIndex = 6;
        }
        else if ( timeDiff < 0.0008 ) {
            distArrayIndex = 7;
        }
        else if ( timeDiff < 0.0009 ) {
            distArrayIndex = 8;
        }
        else if ( timeDiff < 0.001 ) {
            distArrayIndex = 9;
        }
        // 9 itesm : 1ms~2ms,~3ms,...,~10ms,
        else if ( timeDiff < 0.002 ) {
            distArrayIndex = 10;
        }
        else if ( timeDiff < 0.003 ) {
            distArrayIndex = 11;
        }
        else if ( timeDiff < 0.004 ) {
            distArrayIndex = 12;
        }
        else if ( timeDiff < 0.005 ) {
            distArrayIndex = 13;
        }
        else if ( timeDiff < 0.006 ) {
            distArrayIndex = 14;
        }
        else if ( timeDiff < 0.007 ) {
            distArrayIndex = 15;
        }
        else if ( timeDiff < 0.008 ) {
            distArrayIndex = 16;
        }
        else if ( timeDiff < 0.009 ) {
            distArrayIndex = 17;
        }
        else if ( timeDiff < 0.01 ) {
            distArrayIndex = 18;
        }
        else if ( timeDiff < 0.02 ) {
            distArrayIndex = 19;
        }
        else if ( timeDiff < 0.03 ) {
            distArrayIndex = 20;
        }
        else if ( timeDiff < 0.04 ) {
            distArrayIndex = 21;
        }
        else if ( timeDiff < 0.05 ) {
            distArrayIndex = 22;
        }
        else if ( timeDiff < 0.06 ) {
            distArrayIndex = 23;
        }
        else if ( timeDiff < 0.07 ) {
            distArrayIndex = 24;
        }
        else if ( timeDiff < 0.08 ) {
            distArrayIndex = 25;
        }
        else if ( timeDiff < 0.09 ) {
            distArrayIndex = 26;
        }
        else if ( timeDiff < 0.1 ) {
            distArrayIndex = 27;
        }
        // 1 item : >=100ms
        else {
            distArrayIndex = 28;
        }
        
        assert(distArrayIndex<DIST_ARRAY_ITEM_COUNT);
        distArray[distArrayIndex]++;
    }
    
    void printDist()
    {
        printf("DIST=[0~100ns=]");
        for (int i=0; i<DIST_ARRAY_ITEM_COUNT; i++)
        {
            if ( i==10 )
            {
                printf("1~2ms:");
            }
            if ( i==19 )
            {
                printf("10~20ms:");
            }
            if ( i==28 )
            {
                printf(">=100ms:");
            }
            printf("%d",distArray[i]);
            if ( i<28) 
                printf(",");
        }
        printf("]\n");
    }

    void print()
    {
        printf("[profiler name=%s, count=%d, total=%f, avg=%f\n", profilerName, profileCount, accTime, accTime/(float)profileCount );
        printDist();
    }
};

#define DO_PROFILE (1)

#if defined(DO_PROFILE)
#  define PROF_ENABLE() TimeProfiler::IsEnabled = TRUE
#  define PROF_DISABLE() TimeProfiler::IsEnabled = FALSE
#  define PROF_DEFINE(x) TimeProfiler prof##x(#x)
#  define PROF_DECLARE(x) extern TimeProfiler prof##x
#  define PROF_BEGIN(x) prof##x.begin()
#  define PROF_END(x) prof##x.end()
#  define PROF_PRINT(x) prof##x.print()
#  define PROF_TOTAL_TIME(x) (prof##x.getTotalTime())
#  define PROF_COUNT(x) (prof##x.getProfileCount())
#  define PROF_PRINT_RESULT() printProfResult()
extern void printProfResult();
#else
#  define PROF_ENABLE()
#  define PROF_DISABLE()
#  define PROF_DEFINE(x)
#  define PROF_DECLARE(x)
#  define PROF_BEGIN(x)
#  define PROF_END(x)
#  define PROF_PRINT(x)
#  define PROF_TOTAL_TIME(x)
#  define PROF_COUNT(x)
#  define PROF_PRINT_RESULT()
#endif


PROF_DECLARE(stage_tick_adjustZoomWithGroundY);
PROF_DECLARE(stage_tick_updateFollowPosition);
PROF_DECLARE(stage_tick_adjustTerrains);
PROF_DECLARE(stage_tick_adjustSky);
PROF_DECLARE(stage_tick_hero_updatePhysics);
PROF_DECLARE(stage_tick_world_step);
PROF_DECLARE(stage_tick_hero_updateNode);
PROF_DECLARE(stage_tick_cam_updateSpriteFromBody);
PROF_DECLARE(stage_tick_checkCollisions4GameObjects);
PROF_DECLARE(stage_tick_checkStageClear);
PROF_DECLARE(stage_tick_checkHeroDead);
PROF_DECLARE(stage_tick_updateGameObjects);
PROF_DECLARE(stage_tick_update_labels);
PROF_DECLARE(terrain_draw);
PROF_DECLARE(cocos2d_layer_visit);
PROF_DECLARE(temp1);
PROF_DECLARE(temp2);
PROF_DECLARE(temp3);


#endif
