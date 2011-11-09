//
//  Chick.cpp
//  rocknroll
//
//  Created by 김 강모 on 11. 10. 1..
//  Copyright 2011년 강모소프트. All rights reserved.
//
#include "Chick.h"
#include "Util.h"
#import "GameObjectCleaner.h"

CDSoundSource * Chick::_collideSound = NULL;

void Chick::onCollideWithHero(Hero * pHero) 
{
    if ( _released )
    {
        return;
    }
    
    // For the collided objects, remove them
    CCSprite * sprite = this->getSprite();

    assert(_collideSound);
    [_collideSound play];

    Helper::runAction(sprite, _releasingAction);
    
    GameObjectCleaner * cleaner = [[GameObjectCleaner alloc] init];
    [sprite runAction:[CCSequence actions:
                      [CCScaleTo actionWithDuration:3.0f scale:1.0f],
                      [CCCallFuncND actionWithTarget:cleaner selector:@selector(destroyObject:data:) data:(void*)this],
					  nil]];

    // BUGBUG : Increase saved chickens count.
    
    // Decrease life by 10 ( total 100)
    //[_scoreBoard decreaseLife:10];
    
    _released = true;
}
