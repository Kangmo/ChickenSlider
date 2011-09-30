#import <Foundation/Foundation.h>
#import "Util.h"
#import "AKHelpers.h"
#include "Box2D.h"
#include "InteractiveBodyNode.h"
#include "GameConfig.h"
#import "ClipFactory.h"
#include "GameObjectContainer.h"

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

@end

namespace Helper 
{
    /** @brief Delete the body info attached to each b2Body in b2World.
     */
    void removeAttachedBodyNodes(b2World * world )
    {
        //Iterate over the bodies in the physics world
        for (b2Body* b = world->GetBodyList(); b; b = b->GetNext())
        {
            NSObject * object = (NSObject*) b->GetUserData();
            if ( object )
            {
                if ([object isKindOfClass:[InteractiveBodyNode class]])
                {
                    InteractiveBodyNode * bodyNode = (InteractiveBodyNode*) object;
                    [bodyNode removeFromTouchDispatcher];
                }
                
                [object release];
                b->SetUserData(NULL);
            }
        }
    }
    
    void getSpriteAndClip(NSString* initClipFile, NSString* initFrameAnim, CCSprite ** oSprite, NSDictionary ** oClip)
    {
        assert(initClipFile);
        assert(initFrameAnim);
        assert(oSprite);
        assert(oClip);
        
        //NSAssert(initFrameAnim, @"svg parsesr : You should specifiy initFrameAnim if you specified initClipName attribute for a body.");
        
        NSDictionary *clip = [[ClipFactory sharedFactory] clipByFile:initClipFile];
        assert(clip);
        
        NSDictionary *animSet = [AKHelpers animationSetOfClip:clip];
        
        CCSprite *sprite = [CCSprite spriteWithSpriteFrame:[AKHelpers initialFrameForAnimationWithName:initFrameAnim
                                                                                               fromSet:animSet]];
        assert(sprite);
        
        *oSprite = sprite;
        *oClip = clip;
    }

    /** @brief Apply animation clip to the sprite attached to the given Box2D body.
     */
    void runClip(b2Body *body, NSDictionary* clip) 
    {
        BodyInfo *bi = (BodyInfo*)body->GetUserData();
        if(bi.data)
        {
            
            CCSprite*bodySprite = (CCSprite*)bi.data;
            [bodySprite stopAllActions];
            [AKHelpers applyAnimationClip:clip toNode:bodySprite];
        }
    }

    /** @brief Apply animation clip to the sprite attached to the given GameObject.
     */
    void runClip(REF(GameObject) refGameObject, NSDictionary* clip) 
    {
        CCSprite * sprite = refGameObject->getSprite();
        
        [sprite stopAllActions];
        [AKHelpers applyAnimationClip:clip toNode:sprite];
    }

}