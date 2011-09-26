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

// The X position of hero on the screen. It is positioned on the ride side of the screen with the offset of 1/8 of screen width.
#define HERO_XPOS_RATIO (1.0f/8.0f)

// Need to draw debug information of Box2D?
//#define BOX2D_DEBUG_DRAW (1)

//#define LOAD_RESOURCE_FROM_TEST_WEB (1)
#define TEST_WEB_URL_PREFIX @"http://192.168.123.147/~kmkim/rocknroll_Resources/"


#endif // __GAME_CONFIG_H

