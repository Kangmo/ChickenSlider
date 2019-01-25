
#import <Foundation/Foundation.h>
#import "Util.h"
#import "AKHelpers.h"
#include "Box2D.h"
#include "GameConfig.h"
#import "ClipFactory.h"
#include "GameObject.h"
#import "BodyInfo.h"
#import "PersistentGameState.h"
#import "TouchXML.h"
#import "AppAnalytics.h"
#import "IAP.h"
#import "AppDelegate.h"

@implementation Util

/** @brief Retrieve a file from a URL, save it in document file 
 */
+(NSString*) retrieveResourceFile:(NSString*)fileName fromWeb:(NSString*)urlPrefix
{
    // Determile cache file path
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *filePath = [NSString stringWithFormat:@"%@/%@", [paths objectAtIndex:0],fileName];   
    
    // Construct the URL
    NSAssert1([urlPrefix characterAtIndex:[urlPrefix length]-1] == '/', @"The URL prefix(%@) does not ends with the char '/'", urlPrefix);
    NSString * urlString = [urlPrefix stringByAppendingString:fileName];

    // BUGBUG : Exception if network connectivity is not available.
    // Download and write to file
    NSURL *url = [NSURL URLWithString:urlString];
    NSData *urlData = [NSData dataWithContentsOfURL:url];
    NSAssert1(urlData, @"The URL(%@) is invalid.", url);
    [urlData writeToFile:filePath atomically:YES];
    return filePath;
}

/** @brief Load the resource from bundle or Web.
 * Loading resources from Web is used by desiners for testing purpose, as building Xcode project takes long time.
 */
+(NSString*) getResourcePath:(NSString*)fileName
{
#if defined(LOAD_RESOURCE_FROM_TEST_WEB)
    NSString *filePath = [Util retrieveResourceFile:fileName fromWeb:TEST_WEB_URL_PREFIX];
#else
    NSString *filePath = [[NSBundle mainBundle] pathForResource:fileName ofType:nil];  
#endif /*LOAD_RESOURCE_FROM_TEST_WEB*/
    return filePath;
}




/** @brief Did the user purchased any product? 
 */
+(BOOL) didPurchaseAny {
#if defined(DISABLE_ADS)    
    return YES; // BUGBUG : Optimization1 : Don't show AD.
#else
    return [[IAP sharedIAP] isFeaturePurchased:@"com.thankyousoft.chickenslidermulti.maps.map02"];
#endif
}

/** @brief Get the height of AD. Return 0 if we don't show any AD because the user purchased any feature.
 */
+(int) getAdHeight {
    if ( [self didPurchaseAny] ) {
        return 0;
    }
    return LANDSCAPE_AD_HEIGHT;
}


/** @brief Testing purpose only. Remove the key chain data about the purchase history. 
 */
/*
+(void) removeIapData
{
#if defined(NDEBUG)
    // In the release mode, we should not run this method. (This method is only for testing purpose.)
    assert(0);
#endif
#if defined(DEBUG)
    [[MKStoreManager sharedManager] removeAllKeychainData];
#endif
}
*/
/** @brief Return the center of the node
 */
+(CGPoint) getCenter:(CCNode*)node {
    return CGPointMake([node contentSize].width * 0.5, [node contentSize].height * 0.5);
}


+(int)loadIntAttr:(NSString*)attrName default:(int)defaultValue
{
    PersistentGameState * gs = [PersistentGameState sharedPersistentGameState];
    
    int attrValue =  [ gs readIntAttr:attrName default:defaultValue];
    
    return attrValue;
}

+(void) saveIntAttr:(NSString*)attrName value:(int)attrValue
{
    PersistentGameState * gs = [PersistentGameState sharedPersistentGameState];
    [gs writeIntAttr:attrName value:attrValue];
}


+(int) loadTotalChickCount {
    int count;
    count = [[PersistentGameState sharedPersistentGameState] readIntAttr:@"TotalChickCount" default:0];
    return count;
}

+(void) saveTotalChickCount:(int)count {
    [[PersistentGameState sharedPersistentGameState] writeIntAttr:@"TotalChickCount" value:count];
}

+(int) loadMusicVolume {
    int volume;
    volume = [[PersistentGameState sharedPersistentGameState] readIntAttr:@"MusicVolume" default:MAX_MUSIC_VOLUME];
    return volume;
}

+(void) saveMusicVolume:(int)volume {
    [[PersistentGameState sharedPersistentGameState] writeIntAttr:@"MusicVolume" value:volume];
}

+(int) loadEffectVolume {
    int volume;
    volume = [[PersistentGameState sharedPersistentGameState] readIntAttr:@"EffectVolume" default:MAX_EFFECT_VOLUME];
    return volume;
}

+(void) saveEffectVolume:(int)volume {
    [[PersistentGameState sharedPersistentGameState] writeIntAttr:@"EffectVolume" value:volume];
}

+(int) loadDifficulty {
    int difficulty;
    difficulty = [[PersistentGameState sharedPersistentGameState] readIntAttr:@"Difficulty" default:0];
    return difficulty;
}

+(void) saveDifficulty:(int)difficulty {
    [[PersistentGameState sharedPersistentGameState] writeIntAttr:@"Difficulty" value:difficulty];
}

+(int) loadTouchTutor {
    int touchTutor;
    // By default, the touch tutor is turned on(=1).
    touchTutor = [[PersistentGameState sharedPersistentGameState] readIntAttr:@"TouchTutor" default:1];
    return touchTutor;
}

+(void) saveTouchTutor:(int)touchTutor {
    [[PersistentGameState sharedPersistentGameState] writeIntAttr:@"TouchTutor" value:touchTutor];
}

/** @brief return the play mode. 0 : Single Play, 1: MultiPlay
 */
+(int) loadPlayMode{
    int playMode;
    playMode = [[PersistentGameState sharedPersistentGameState] readIntAttr:@"PlayMode" default:0];
    return playMode;
}

/** @brief save play mode. 0 : Single Play, 1: MultiPlay 
 */
+(void) savePlayMode:(int)playMode {
    [[PersistentGameState sharedPersistentGameState] writeIntAttr:@"PlayMode" value:playMode];
}

+(NSString*) levelStateName:(NSString*)stateName mapName:(NSString*)mapName level:(int)level {
    return [NSString stringWithFormat:@"%@_%@_%02d",stateName,mapName,level];
}

+(NSString*) mapStateName:(NSString*)stateName mapName:(NSString*)mapName {
    return [NSString stringWithFormat:@"%@_%@",stateName,mapName];
}

+(int) loadHighScore:(NSString*)mapName level:(int)level {
    NSString * stateName = [Util levelStateName:@"HighScore" mapName:mapName level:level];
    
    int highScore;
    highScore = [[PersistentGameState sharedPersistentGameState] readIntAttr:stateName default:0];
    return highScore;
}

+(void) saveHighScore:(NSString*)mapName level:(int)level highScore:(int)highScore {
    NSString * stateName = [Util levelStateName:@"HighScore" mapName:mapName level:level];
    
    [[PersistentGameState sharedPersistentGameState] writeIntAttr:stateName value:highScore];
}

/** @brief load the star count for the specific map and level.
    The default star count is -1, not to show anything at all.
 */
+(int) loadStarCount:(NSString*)mapName level:(int)level {
    NSString * stateName = [Util levelStateName:@"StarCount" mapName:mapName level:level];
    
    int highScore;
    highScore = [[PersistentGameState sharedPersistentGameState] readIntAttr:stateName default:-1];
    return highScore;
}

+(void) saveStarCount:(NSString*)mapName level:(int)level starCount:(int)starCount {
    NSString * stateName = [Util levelStateName:@"StarCount" mapName:mapName level:level];
    
    [[PersistentGameState sharedPersistentGameState] writeIntAttr:stateName value:starCount];
}

+ (int) loadHighestUnlockedLevel:(NSString*)mapName
{
#if defined(UNLOCK_LEVELS_FOR_TEST)
    return 999;
#else
    NSString * stateName = [Util mapStateName:@"HighestUnlockedLevel" mapName:mapName];
    return [Util loadIntAttr:stateName default:1];
#endif
}

+ (void) saveHighestUnlockedLevel:(NSString*)mapName level:(int)level
{
    NSString * stateName = [Util mapStateName:@"HighestUnlockedLevel" mapName:mapName];
    [Util saveIntAttr:stateName value:level];
}


+(CCScene*) defaultSceneTransition:(CCScene*)newScene {
    return newScene;
//    return newScene;
//    return [CCTransitionSlideInR transitionWithDuration:1.0 scene:newScene];
//    return [CCTransitionSlideInB transitionWithDuration:1.0 scene:newScene];
//    return  [CCTransitionTurnOffTiles transitionWithDuration:0.3 scene:newScene];
}

+(std::string)toStdString:(NSString*)nsString {
    std::string str = [nsString cStringUsingEncoding: NSASCIIStringEncoding];
    return str;
}
+(NSString*) toNSString:(const std::string &) stdString
{
    NSString * string = [NSString stringWithCString:stdString.c_str() 
                         encoding:[NSString defaultCStringEncoding]];
    return string;
}

/** @brief Get a float value from XML element with the give attribute name. Return the defaultValue if the value does not exist*/
+(float) getFloatValue:(CXMLElement*)xmlElement name:(NSString*)attrName defaultValue:(float)defaultValue
{
    NSString * attrValueString = [[xmlElement attributeForName:attrName] stringValue];
    if ( attrValueString )
    {
        return [attrValueString floatValue];
    }
    return defaultValue;
}

/** @brief Get an integer value from XML element with the give attribute name. Return the defaultValue if the value does not exist*/
+(int) getIntValue:(CXMLElement*)xmlElement name:(NSString*)attrName defaultValue:(int)defaultValue
{
    NSString * attrValueString = [[xmlElement attributeForName:attrName] stringValue];
    if ( attrValueString )
    {
        return [attrValueString intValue];
    }
    return defaultValue;
}

/** @brief Get a string value from XML element with the give attribute name. Return the defaultValue if the value does not exist*/
+(NSString*) getStringValue:(CXMLElement*)xmlElement name:(NSString*)attrName defaultValue:(NSString*)defaultValue
{
    NSString * attrValueString = [[xmlElement attributeForName:attrName] stringValue];
    if ( attrValueString )
    {
        return attrValueString;
    }
    return defaultValue;
}

/** @brief Play the background music. If the background music is already being played, do nothing. 
 */
+(void) playBGM:(NSString*) musicFileName
{
    static NSString * currentMusicFileName = nil;
    
    if ( [[CDAudioManager sharedManager] isBackgroundMusicPlaying] )
    {
        assert( currentMusicFileName );
        if ( [musicFileName isEqualToString:currentMusicFileName] )
        {
            // The same file is already being played. do nothing!
            return;
        }
        [currentMusicFileName release];
        currentMusicFileName = nil;

        [[CDAudioManager sharedManager] stopBackgroundMusic];
    }

    currentMusicFileName = [musicFileName retain];

    [[CDAudioManager sharedManager] playBackgroundMusic:musicFileName loop:YES];
    [CDAudioManager sharedManager].backgroundMusic.numberOfLoops = 1000;
}

+ (void) showAlertWithTitle:(NSString*)title message:(NSString*) message {
#if TARGET_OS_IPHONE
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:message
                                                   delegate:nil 
//                                          cancelButtonTitle:NSLocalizedString(@"Dismiss", @"")
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];             
#elif TARGET_OS_MAC
    NSAlert *alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle:NSLocalizedString(@"Dismiss", @"")];
    
    [alert setMessageText:title];
    [alert setInformativeText:message];             
    [alert setAlertStyle:NSInformationalAlertStyle];
    
    [alert runModal];
#endif    
}


+ (BOOL) doesString:(NSString*)testedString contain:(NSString *) containedstring
                options:(NSStringCompareOptions) options {
    NSRange rng = [testedString rangeOfString:containedstring options:options];
    return rng.location != NSNotFound;
}

+ (BOOL) doesString:(NSString*)testedString contain:(NSString *) containedstring {
    return [Util doesString:testedString contain:containedstring options:0];
}

@end

namespace Helper 
{
    /** @brief Delete the body info attached to each b2Body in b2World.
     */
    void removeAttachedBodyNodes(b2World * world )
    {
        assert(world);
        
        //Iterate over the bodies in the physics world
        for (b2Body* b = world->GetBodyList(); b; b = b->GetNext())
        {
            NSObject * object = (NSObject*) b->GetUserData();
            if ( object )
            {
                [object release];
                b->SetUserData(NULL);
            }
        }
    }
    
    void getSpriteAndAction(NSString* initClipFile, NSString* initFrameAnim, CCSprite ** oSprite, CCAction ** oAction)
    {
        assert(initClipFile);
        assert(initFrameAnim);
        assert(oSprite);
        assert(oAction);
        
        //NSAssert(initFrameAnim, @"svg parsesr : You should specifiy initFrameAnim if you specified initClipName attribute for a body.");
        
        CCAction *action = [[ClipFactory sharedFactory] clipActionByFile:initClipFile];
        assert(action);
        
        NSDictionary *animSet = [[ClipFactory sharedFactory] animationSetOfClipFile:initClipFile];
        
        CCSprite *sprite = [CCSprite spriteWithSpriteFrame:[AKHelpers initialFrameForAnimationWithName:initFrameAnim
                                                                                               fromSet:animSet]];
        assert(sprite);
        
        *oSprite = sprite;
        *oAction = action;
    }

    /** @brief Apply animation clip to the given sprite.
     */
    void runAction(CCSprite * sprite, CCAction* action)
    {
        assert(sprite);
        
        [sprite stopAllActions];
        if (action) {
            [sprite runAction:action];
        }
    }

    /** @brief Apply animation clip to the sprite attached to the given Box2D body.
     *         If action is NULL, stop the currently running action.
     */
    void runAction(b2Body *body, CCAction* action) 
    {
        assert(body);

        
        BodyInfo *bi = (BodyInfo*)body->GetUserData();
        if(bi.data)
        {
            
            CCSprite*bodySprite = (CCSprite*)bi.data;
            
            runAction(bodySprite, action);
        }
    }

    /** @brief Apply animation clip to the sprite attached to the given GameObject.
     */
    void runAction(REF(GameObject) refGameObject, CCAction* action) 
    {
        CCSprite * sprite = refGameObject->getSprite();
        
        runAction(sprite, action);
    }

    
    /** @brief Change the sprite frame with the one that has the given name.
     */
    void changeSpriteFrame(CCSprite *sprite, NSString * spriteFrameName)
    {
        assert(sprite);
        assert(spriteFrameName);
        
        CCSpriteFrame * spriteFrame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:spriteFrameName];
        assert(spriteFrame);
        [sprite setDisplayFrame:spriteFrame];
    }
}