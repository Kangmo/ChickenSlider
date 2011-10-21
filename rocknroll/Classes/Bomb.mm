//
//  Bomb.cpp
//  rocknroll
//
//  Created by 김 강모 on 11. 10. 1..
//  Copyright 2011년 강모소프트. All rights reserved.
//
#include "Bomb.h"
#include "Util.h"

CDSoundSource * Bomb::_collideSound = NULL;

@interface GameObjectCleaner : NSObject
-(void)destroyObject:(id)sender data:(void*)unused;
@end

@implementation GameObjectCleaner
/** @brief destroy the object 
 */
-(void)destroyObject:(id)sender data:(void*)gameObjectPointer 
{
    CCLOG(@"destroyObject:%p", gameObjectPointer);
    
    GameObject * gameObject = (GameObject*)gameObjectPointer;

    // For the collided objects, remove them
    CCSprite * sprite = gameObject->getSprite();
    assert(sprite);

    [sprite removeFromParentAndCleanup:YES];
    
    gameObject->removeSelf();
    
    CCLOG(@"destroyObject:end");
    
    [self release];
}
@end

void Bomb::onCollideWithHero(Hero * pHero) 
{
    if ( _exploded )
    {
        return;
    }
    
    // For the collided objects, remove them
    CCSprite * sprite = this->getSprite();

    assert(_collideSound);
    [_collideSound play];

    Helper::runClip(sprite, _explosionClip);
    
    assert(_collideSound);
    [_collideSound play];

    GameObjectCleaner * cleaner = [[GameObjectCleaner alloc] init];
    [sprite runAction:[CCSequence actions:
                      [CCScaleTo actionWithDuration:0.3f scale:1.0f],
                      [CCCallFuncND actionWithTarget:cleaner selector:@selector(destroyObject:data:) data:(void*)this],
					  nil]];

    // Decrease life by 10 ( total 100)
    [_scoreBoard decreaseLife:10];
    
    _exploded = true;
}
