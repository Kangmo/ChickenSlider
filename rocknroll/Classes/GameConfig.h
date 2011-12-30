#ifndef __GAME_CONFIG_H
#define __GAME_CONFIG_H

#define SND_EXT @".wav"

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


// The width and height of the terrain texture.
#define TERRAIN_TEXTURE_SIZE (512)

// The default terrain thickness for low-end devices such as iPhone 1G, 3G and iPod 1G.
#define TERRAIN_THICKNESS_LOWEND (128)

// How many keys do we need to save a chick?
#define KEYS_PER_CHICK (5)

/** @brief The maximum position for X or Y axis for a valid point.
 */
#define kMAX_POSITION (9999999.0f)

#define SCORE_PER_COMBO_FOR_HARD_MODE (100)
#define SCORE_PER_COMBO_FOR_EASY_MODE (80)
#define SCORE_PER_CHICK_FOR_HARD_MODE (1500)
#define SCORE_PER_CHICK_FOR_EASY_MODE (1000)
#define SCORE_PER_KEY (10)
#define SCORE_PER_SECOND_FOR_HARD_MODE (500)

#define INIT_PTM_RATIO (32)
#define INIT_ZOOM_RATIO (1)

#define MIN_ZOOM_RATIO (0.10)
#define MAX_ZOOM_RATIO (7)

// The maximum wave height in meters. Used for adjusting ground level.
#define MAX_WAVE_HEIGHT (3.0f) 
// Zoom gradually to the target zoom value when Zooming ratio suddenly changes.
// This is necessary because the hero hits on the ground suddenly making a sudden change of zoom.
// At most, change Zoom by 5%
//#define ZOOM_DELTA_RATIO (0.02f)
#define ZOOM_DELTA_RATIO (0.025f)

// The X position of hero on the screen. It is positioned on the ride side of the screen with the offset of 1/8 of screen width.
#define HERO_XPOS_RATIO (1.0f/4.0f)

#define HERO_MAX_YPOS_RATIO (0.65)
#define HERO_MIN_YPOS_RATIO (0.65)

// If the hero is below ground by 1 meter, he is dead.
#define HERO_DEAD_GAP_WORLD_Y (1)

// The maximum number of levels per map
#define MAX_LEVELS_PER_MAP (30)

#define INTERACTIVE_SPRITE_TOUCH_GAP (8)

// Start blinking the health bar if it reaches at 50% level.
#define HEALTH_BAR_BLINKING_THRESHOLD (50)

#define EASY_MODE_PLAY_TIME_FACTOR (1.35f)

// The default time duration to simulate in box2d for each frame.
#define EASY_MODE_FRAME_DURATION_SEC (1.0f/55.0f)
#define HARD_MODE_FRAME_DURATION_SEC (1.0f/45.0f)

// IncNumLabel.h

// The minimum frame speed ratio : 100%
#define MIN_FRAME_SPEED_RATIO (1.0f)

// The maximum frame speed ratio : 150%
#define MAX_FRAME_SPEED_RATIO (1.51f)

// Increase the frame duration by 10% for each combo. 
// This means the hero will fly faster, but not further.
#define FRAME_SPEED_RATIO_PER_COMBO (0.10f)

// When the frame duration changes, we change it gradually.
// FRAME_DURATION_CHANGE_STEP defines How much the frame duration can be changed per frame.
// 0.5% change per frame
#define STEP_FRAME_SPEED_RATIO (0.005f)

// BUGBUG : Adjust the position for iPad, retina...
const float TARGET_OBJ_POS_X = 480.0f * HERO_XPOS_RATIO;
//const float TARGET_OBJ_POS_Y = 160.0f;
const float MIN_TARGET_OBJ_POS_Y = 320.0 * HERO_MAX_YPOS_RATIO;
const float MAX_TARGET_OBJ_POS_Y = 320.0 * HERO_MIN_YPOS_RATIO;

const float GROUND_TO_NEWGROUND_GAP = 320.0;

// BUGBUG : iPad/iPhone 4 HD might have different height.
const float LANDSCAPE_AD_HEIGHT = 40;

#define MAX_MUSIC_VOLUME (10)
#define MAX_EFFECT_VOLUME (10)

// Need to draw debug information of Box2D?
//#define BOX2D_DEBUG_DRAW (1)

//#define LOAD_RESOURCE_FROM_TEST_WEB (1)
#define TEST_WEB_URL_PREFIX @"http://thankyousoft.com/game01/"

// For Terrains, how many points are we going to keep for an auto released pool?
// The higher, the better loading performance. The lower, the smaller memory foot print during loading.
#define SVG_LOADER_SHAPE_POINTS_PER_AUTOPOOL (32)

// Unlock all stage levels for testing
//#define UNLOCK_LEVELS_FOR_TEST (1)

//#define DISABLE_IAP (1)
#define RESET_IAP_DATA (1)

//#define DISABLE_ADS (1)

//#define DO_PROFILE (1)

#endif // __GAME_CONFIG_H

