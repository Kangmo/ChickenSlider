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
#import "Hero.h"

CDSoundSource * Chick::_collideSound = NULL;

void Chick::onCollideWithHero(Hero * pHero) 
{
    if ( _released )
    {
        return;
    }

    int keyCount = [_scoreBoard getKeys];
    if (keyCount < KEYS_PER_CHICK )
    {
        return;
    }
    
    // Decrease Keys by KEYS_PER_CHICK(5)
    [_scoreBoard setKeys:keyCount - KEYS_PER_CHICK];
    // Increase Chicks saved.
    [_scoreBoard increaseChicks:1];

    
    // Speed Up. _heroSpeedGain is from the heroSpeedGain attribute in the Bird class in game_classes.svg
    [pHero changeSpeed:_heroSpeedGain];
    
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
    
    // Decrease life by 10 ( total 100)
    //[_scoreBoard decreaseLife:10];
    
    _released = true;
}
