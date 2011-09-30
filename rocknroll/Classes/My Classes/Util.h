#ifndef __THX_UTIL_H_ 
#define __THX_UTIL_H_ (1)

#import <Foundation/Foundation.h>
#include "Box2D.h"
#import "Cocos2d.h"
#include "GameConfig.h"
#include "CppInfra.h"

@interface Util : NSObject {
}

+(NSString*) getResourcePath:(NSString*)fileName;

+(NSString*) retrieveResourceFile:(NSString*)fileName fromWeb:(NSString*)urlPrefix;

@end

class GameObject;
class b2World;

namespace Helper
{
    void removeAttachedBodyNodes(b2World * world );
    
    void getSpriteAndClip(NSString* initClipFile, NSString* initFrameAnim, CCSprite ** oSprite, NSDictionary ** oClip);
    
    void runClip(b2Body *body, NSDictionary* clip) ;

    void runClip(REF(GameObject) refGameObject, NSDictionary* clip) ;
}

#endif /* __THX_UTIL_H_ */