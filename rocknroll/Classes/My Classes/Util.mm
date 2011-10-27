#import <Foundation/Foundation.h>
#import "Util.h"
#import "AKHelpers.h"
#include "Box2D.h"
#include "GameConfig.h"
#import "ClipFactory.h"
#include "GameObject.h"
#import "BodyInfo.h"
#import "MKStoreManager.h"
#import "PersistentGameState.h"

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

/** @brief Show message on top of the screen for 2 seconds.
 */
+ (void) showMessage:(NSString*)message inLayer:(CCLayer*)layer adHeight:(float)adHeight{
    static CGSize screenSize = [[CCDirector sharedDirector] winSize];

	CCLabelBMFont *label = [CCLabelBMFont labelWithString:message fntFile:@"punkboy.fnt"];
	label.position = ccp(screenSize.width/2, screenSize.height - screenSize.height/14 - adHeight);
	[label runAction:[CCScaleTo actionWithDuration:2.0f scale:1.4f]];
	[label runAction:[CCSequence actions:
					  [CCFadeOut actionWithDuration:2.0f],
					  [CCCallFuncND actionWithTarget:label selector:@selector(removeFromParentAndCleanup:) data:(void*)YES],
					  nil]];
	[layer addChild:label];
}

+(CCParticleSystemQuad*)createParticleEmitter:(NSString*)particleImage count:(int)particleCount duration:(float)duration{
    
    // Particle emitter.
    CCParticleSystemQuad * emitter;
    //        [emitter resetSystem];
    
    //	ParticleSystem *emitter = [RockExplosion node];
    emitter = [[CCParticleSystemQuad alloc] initWithTotalParticles:particleCount];
    emitter.texture = [[CCTextureCache sharedTextureCache] addImage: particleImage];
    
    // duration
    //	emitter.duration = -1; //continuous effect
    emitter.duration = duration;
    
    // gravity
    emitter.gravity = CGPointZero;
    
    // angle
    emitter.angle = 90;
    emitter.angleVar = 360;
    
    // speed of particles
    emitter.speed = 160;
    emitter.speedVar = 20;
    
    // radial
    emitter.radialAccel = -120;
    emitter.radialAccelVar = 0;
    
    // tagential
    emitter.tangentialAccel = 30;
    emitter.tangentialAccelVar = 0;
    
    // life of particles
    emitter.life = 1;
    emitter.lifeVar = 1;
    
    // spin of particles
    emitter.startSpin = 0;
    emitter.startSpinVar = 0;
    emitter.endSpin = 0;
    emitter.endSpinVar = 0;
    
    // color of particles
    ccColor4F startColor = {0.5f, 0.5f, 0.5f, 1.0f};
    emitter.startColor = startColor;
    ccColor4F startColorVar = {0.5f, 0.5f, 0.5f, 1.0f};
    emitter.startColorVar = startColorVar;
    ccColor4F endColor = {0.1f, 0.1f, 0.1f, 0.2f};
    emitter.endColor = endColor;
    ccColor4F endColorVar = {0.1f, 0.1f, 0.1f, 0.2f};
    emitter.endColorVar = endColorVar;
    
    // size, in pixels
    emitter.startSize = 20.0f;
    emitter.startSizeVar = 10.0f;
    emitter.endSize = kParticleStartSizeEqualToEndSize;
    // emits per second
    emitter.emissionRate = emitter.totalParticles/emitter.life;
    // additive
    emitter.blendAdditive = YES;
    emitter.position = ccp(0,0); // setting emitter position
    
    return emitter;
}

/** @brief Did the user purchased any product? 
 */
+(BOOL) didPurchaseAny {
    return [MKStoreManager isFeaturePurchased:@"com.thankyousoft.rocknroll.map02"];
}

/** @brief Testing purpose only. Remove the key chain data about the purchase history. 
 */
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

/** @brief Return the center of the node
 */
+(CGPoint) getCenter:(CCNode*)node {
    return CGPointMake([node contentSize].width * 0.5, [node contentSize].height * 0.5);
}


+(int) loadFeatherCount {
    int count;
    count = [[PersistentGameState sharedPersistentGameState] readIntAttr:@"FeatherCount"];
    return count;
}

+(void) saveFeatherCount:(int)count {
    [[PersistentGameState sharedPersistentGameState] writeIntAttr:@"FeatherCount" value:count];
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
        assert(body);
        assert(clip);
        
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
        assert(clip);
        
        CCSprite * sprite = refGameObject->getSprite();
        assert(sprite);
        
        [sprite stopAllActions];
        [AKHelpers applyAnimationClip:clip toNode:sprite];
    }

    /** @brief Apply animation clip to the given sprite.
     */
    void runClip(CCSprite * sprite, NSDictionary* clip)
    {
        assert(sprite);
        assert(clip);
        
        [sprite stopAllActions];
        [AKHelpers applyAnimationClip:clip toNode:sprite];
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