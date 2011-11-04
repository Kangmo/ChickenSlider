//
//  Hen.cpp
//  rocknroll
//
//  Created by 김 강모 on 11. 10. 1..
//  Copyright 2011년 강모소프트. All rights reserved.
//
#include "Hen.h"
#include "Util.h"
#import "GameObjectCleaner.h"

CDSoundSource * Hen::_collideSound = NULL;

void Hen::onCollideWithHero(Hero * pHero) 
{
    if ( _released )
    {
        return;
    }
    
    // For the collided objects, remove them
    CCSprite * sprite = this->getSprite();

    assert(_collideSound);
    [_collideSound play];

    Helper::runClip(sprite, _releasingClip);
    
    // BUGBUG : Set the game cleared or not cleared based on the number of keys collected.
    // Decrease life by 10 ( total 100)
    //[_scoreBoard decreaseLife:10];
    
    _released = true;
}
