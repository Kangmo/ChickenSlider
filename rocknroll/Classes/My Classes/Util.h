#ifndef __THX_UTIL_H_ 
#define __THX_UTIL_H_ (1)

#import <Foundation/Foundation.h>
#include "Box2D.h"
#import "Cocos2d.h"
#include "GameConfig.h"
#include "CppInfra.h"

@class CXMLElement;

@interface Util : NSObject 

+(NSString*) getResourcePath:(NSString*)fileName;

+(NSString*) retrieveResourceFile:(NSString*)fileName fromWeb:(NSString*)urlPrefix;

+(CCParticleSystemQuad*)createParticleEmitter:(NSString*)particleImage count:(int)particleCount duration:(float)duration;

+(BOOL) didPurchaseAny;

+(void) removeIapData;

+(CGPoint) getCenter:(CCNode*)node;

+(int) loadTotalChickCount;

+(void) saveTotalChickCount:(int)count;
    
+(CCScene*) defaultSceneTransition:(CCScene*)newScene;

+(NSString*) toNSString:(const std::string &) stdString;

+(float) getFloatValue:(CXMLElement*)xmlElement name:(NSString*)attrName defaultValue:(float)defaultValue;

+(int) getIntValue:(CXMLElement*)xmlElement name:(NSString*)attrName defaultValue:(int)defaultValue;

+(NSString*) getStringValue:(CXMLElement*)xmlElement name:(NSString*)attrName defaultValue:(NSString*)defaultValue;

+(void) playBGM:(NSString*) musicFileName;

@end

class GameObject;
class b2World;

namespace Helper
{
    void removeAttachedBodyNodes(b2World * world );
    
    void getSpriteAndAction(NSString* initClipFile, NSString* initFrameAnim, CCSprite ** oSprite, CCAction ** oAction);
    
    void runAction(b2Body *body, CCAction* action);
    void runAction(REF(GameObject) refGameObject, CCAction* action); 
    void runAction(CCSprite * sprite, CCAction* action);
    
    inline box_t getBox(CGPoint minPoint, CGPoint maxPoint) 
    {
        return box_t( point_t( minPoint.x, minPoint.y ), point_t( maxPoint.x, maxPoint.y ) );
    }
}

#endif /* __THX_UTIL_H_ */