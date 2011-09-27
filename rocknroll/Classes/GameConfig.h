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

//#define GAME_AUTOROTATION kGameAutorotationCCDirector
#define GAME_AUTOROTATION kGameAutorotationNone

/** @brief The maximum position for X or Y axis for a valid point.
 */
#define kMAX_POSITION (9999999.0f)

#define INIT_PTM_RATIO (32)
#define INIT_ZOOM_RATIO (1)

#define MIN_ZOOM_RATIO (0.15)
#define MAX_ZOOM_RATIO (10)

// The maximum wave height in meters. Used for adjusting ground level.
#define MAX_WAVE_HEIGHT (0.0f) 
// Zoom gradually to the target zoom value when Zooming ratio suddenly changes.
// This is necessary because the hero hits on the ground suddenly making a sudden change of zoom.
// At most, change Zoom by 10%
#define ZOOM_DELTA_RATIO (0.02f)

// The X position of hero on the screen. It is positioned on the ride side of the screen with the offset of 1/8 of screen width.
#define HERO_XPOS_RATIO (1.0f/8.0f)

#define HERO_MAX_YPOS_RATIO (0.7)
#define HERO_MIN_YPOS_RATIO (0.7)

// BUGBUG : Adjust the position for iPad, retina...
const float TARGET_OBJ_POS_X = 480.0f * HERO_XPOS_RATIO;
//const float TARGET_OBJ_POS_Y = 160.0f;
const float MIN_TARGET_OBJ_POS_Y = 320.0 * HERO_MAX_YPOS_RATIO;
const float MAX_TARGET_OBJ_POS_Y = 320.0 * HERO_MIN_YPOS_RATIO;

// Need to draw debug information of Box2D?
//#define BOX2D_DEBUG_DRAW (1)

//#define LOAD_RESOURCE_FROM_TEST_WEB (1)
#define TEST_WEB_URL_PREFIX @"http://192.168.123.147/~kmkim/rocknroll_Resources/"


#endif // __GAME_CONFIG_H

