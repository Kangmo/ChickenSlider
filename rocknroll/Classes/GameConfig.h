//
//  GameConfig.h
//  thxengine
//
//  Created by 강모 김 on 11. 7. 19..
//  Copyright 강모소프트 2011. All rights reserved.
//

#ifndef __GAME_CONFIG_H
#define __GAME_CONFIG_H

//
// Supported Autorotations:
//		None,
//		UIViewController,
//		CCDirector
//
#define kGameAutorotationNone 0
#define kGameAutorotationCCDirector 1
#define kGameAutorotationUIViewController 2

#define GAME_AUTOROTATION kGameAutorotationNone

#define INIT_PTM_RATIO (32)
#define INIT_ZOOM_RATIO (1)
// The maximum wave height in meters. Used for adjusting ground level.
#define MAX_WAVE_HEIGHT (5) 
// Zoom gradually to the target zoom value when Zooming ratio suddenly changes.
// This is necessary because the hero hits on the ground suddenly making a sudden change of zoom.
// At most, change Zoom by 10%
#define ZOOM_DELTA_RATIO (0.1f)
//#define LOAD_RESOURCE_FROM_TEST_WEB (1)
#define TEST_WEB_URL_PREFIX @"http://192.168.123.147/~kmkim/rocknroll_Resources/"


#endif // __GAME_CONFIG_H

