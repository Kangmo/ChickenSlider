//
//  Profiler.cpp
//  rocknroll
//
//  Created by 김 강모 on 11. 11. 5..
//  Copyright 2011년 강모소프트. All rights reserved.
//

#include <iostream>

#include "Profiler.h"

BOOL TimeProfiler::IsEnabled = TRUE;

#if defined(DO_PROFILE)

PROF_DEFINE(stage_tick_adjustZoomWithGroundY);
PROF_DEFINE(stage_tick_updateFollowPosition);
PROF_DEFINE(stage_tick_adjustTerrains);
PROF_DEFINE(stage_tick_adjustSky);
PROF_DEFINE(stage_tick_hero_updatePhysics);
PROF_DEFINE(stage_tick_world_step);
PROF_DEFINE(stage_tick_hero_updateNode);
PROF_DEFINE(stage_tick_cam_updateSpriteFromBody);
PROF_DEFINE(stage_tick_checkCollisions4GameObjects);
PROF_DEFINE(stage_tick_checkStageClear);
PROF_DEFINE(stage_tick_checkHeroDead);
PROF_DEFINE(stage_tick_updateGameObjects);
PROF_DEFINE(stage_tick_update_labels);

PROF_DEFINE(terrain_draw);
PROF_DEFINE(cocos2d_layer_visit);
/*
PROF_DEFINE(temp0);
PROF_DEFINE(temp1);
PROF_DEFINE(temp2);
PROF_DEFINE(temp3);
PROF_DEFINE(temp4);
PROF_DEFINE(temp5);
PROF_DEFINE(temp6);
PROF_DEFINE(temp7);
PROF_DEFINE(temp8);
PROF_DEFINE(temp9);
*/
void printProfResult()
{// CCDirectorIOS.drawScene
 //   (1) scheduler schedule=>tick=>StageScene.tick
 //   (2)runningScene visit
 //   (3)           terrain draw 
    //PROF_PRINT(stage_tick); // (1)
    
    PROF_PRINT(stage_tick_adjustZoomWithGroundY);
    PROF_PRINT(stage_tick_updateFollowPosition);
    PROF_PRINT(stage_tick_adjustTerrains);
    PROF_PRINT(stage_tick_adjustSky);
    PROF_PRINT(stage_tick_hero_updatePhysics);
    PROF_PRINT(stage_tick_world_step);
    PROF_PRINT(stage_tick_hero_updateNode);
    PROF_PRINT(stage_tick_cam_updateSpriteFromBody);
    PROF_PRINT(stage_tick_checkCollisions4GameObjects);
    PROF_PRINT(stage_tick_checkStageClear);
    PROF_PRINT(stage_tick_checkHeroDead);
    PROF_PRINT(stage_tick_updateGameObjects);
    PROF_PRINT(stage_tick_update_labels);
    
    PROF_PRINT(cocos2d_layer_visit); //(2)
    PROF_PRINT(terrain_draw); //(3)
/*    
    PROF_PRINT(temp0); //(3)
    PROF_PRINT(temp1); //(3)
    PROF_PRINT(temp2); //(3)
    PROF_PRINT(temp3); //(3)
    PROF_PRINT(temp4); //(3)
    PROF_PRINT(temp5); //(3)
    PROF_PRINT(temp6); //(3)
    PROF_PRINT(temp7); //(3)
    PROF_PRINT(temp8); //(3)
    PROF_PRINT(temp9); //(3)
 */   
    double totalTickTime = 0;
    totalTickTime += PROF_TOTAL_TIME(stage_tick_adjustZoomWithGroundY);
    totalTickTime += PROF_TOTAL_TIME(stage_tick_updateFollowPosition);
    totalTickTime += PROF_TOTAL_TIME(stage_tick_adjustTerrains);
    totalTickTime += PROF_TOTAL_TIME(stage_tick_adjustSky);
    totalTickTime += PROF_TOTAL_TIME(stage_tick_hero_updatePhysics);
    totalTickTime += PROF_TOTAL_TIME(stage_tick_world_step);
    totalTickTime += PROF_TOTAL_TIME(stage_tick_hero_updateNode);
    totalTickTime += PROF_TOTAL_TIME(stage_tick_cam_updateSpriteFromBody);
    totalTickTime += PROF_TOTAL_TIME(stage_tick_checkCollisions4GameObjects);
    totalTickTime += PROF_TOTAL_TIME(stage_tick_checkStageClear);
    totalTickTime += PROF_TOTAL_TIME(stage_tick_checkHeroDead);
    totalTickTime += PROF_TOTAL_TIME(stage_tick_updateGameObjects);
    totalTickTime += PROF_TOTAL_TIME(stage_tick_update_labels);
    
    double totalTime = 0;
    totalTime+= totalTickTime;
    totalTime+= PROF_TOTAL_TIME(cocos2d_layer_visit);
    //totalTime+= PROF_TOTAL_TIME(terrain_draw);
    
    printf("profile results:\n");
    printf("stage_tick=%lf sec,%lf%%\n", totalTickTime, totalTickTime * 100.0f / totalTime);
    double pure_cocos2d_visit_time = (PROF_TOTAL_TIME(cocos2d_layer_visit) - PROF_TOTAL_TIME(terrain_draw));
    printf("pure cocos2d_layer_visit=%lf sec,%lf%%\n", pure_cocos2d_visit_time, pure_cocos2d_visit_time * 100.0f / totalTime);
    printf("terrain_draw=%lf sec,%lf%%\n", PROF_TOTAL_TIME(terrain_draw), PROF_TOTAL_TIME(terrain_draw) * 100.0f / totalTime);
    
    
    printf("profile results(stage tick only):\n");
    printf("adjustZoomWithGroundY=%lf%%\n", PROF_TOTAL_TIME(stage_tick_adjustZoomWithGroundY) * 100.0f / totalTickTime);
    printf("updateFollowPosition=%lf%%\n", PROF_TOTAL_TIME(stage_tick_updateFollowPosition) * 100.0f / totalTickTime);
    printf("adjustTerrains=%lf%%\n", PROF_TOTAL_TIME(stage_tick_adjustTerrains) * 100.0f / totalTickTime);
    printf("adjustSky=%lf%%\n", PROF_TOTAL_TIME(stage_tick_adjustSky) * 100.0f / totalTickTime);
    printf("hero_updatePhysics=%lf%%\n", PROF_TOTAL_TIME(stage_tick_hero_updatePhysics) * 100.0f / totalTickTime);
    printf("world_step=%lf%%\n", PROF_TOTAL_TIME(stage_tick_world_step) * 100.0f / totalTickTime);
    printf("hero_updateNode=%lf%%\n", PROF_TOTAL_TIME(stage_tick_hero_updateNode) * 100.0f / totalTickTime);
    printf("cam_updateSpriteFromBody=%lf%%\n", PROF_TOTAL_TIME(stage_tick_cam_updateSpriteFromBody) * 100.0f / totalTickTime);
    printf("checkCollisions4GameObjects=%lf%%\n", PROF_TOTAL_TIME(stage_tick_checkCollisions4GameObjects) * 100.0f / totalTickTime);
    printf("checkStageClear=%lf%%\n", PROF_TOTAL_TIME(stage_tick_checkStageClear) * 100.0f / totalTickTime);
    printf("checkHeroDead=%lf%%\n", PROF_TOTAL_TIME(stage_tick_checkHeroDead) * 100.0f / totalTickTime);
    printf("updateGameObjects=%lf%%\n", PROF_TOTAL_TIME(stage_tick_updateGameObjects) * 100.0f / totalTickTime);
    printf("update_labels=%lf%%\n", PROF_TOTAL_TIME(stage_tick_update_labels) * 100.0f / totalTickTime);
}

void resetAllProfilers() {
    PROF_RESET(stage_tick_adjustZoomWithGroundY);
    PROF_RESET(stage_tick_updateFollowPosition);
    PROF_RESET(stage_tick_adjustTerrains);
    PROF_RESET(stage_tick_adjustSky);
    PROF_RESET(stage_tick_hero_updatePhysics);
    PROF_RESET(stage_tick_world_step);
    PROF_RESET(stage_tick_hero_updateNode);
    PROF_RESET(stage_tick_cam_updateSpriteFromBody);
    PROF_RESET(stage_tick_checkCollisions4GameObjects);
    PROF_RESET(stage_tick_checkStageClear);
    PROF_RESET(stage_tick_checkHeroDead);
    PROF_RESET(stage_tick_updateGameObjects);
    PROF_RESET(stage_tick_update_labels);
    
    PROF_RESET(terrain_draw);
    PROF_RESET(cocos2d_layer_visit);
}

#endif /*DO_PROFILE*/