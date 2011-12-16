//
//  EatenItem.cpp
//  rocknroll
//
//  Created by 김 강모 on 11. 10. 1..
//  Copyright 2011년 강모소프트. All rights reserved.
//
#include "EatenItem.h"
#include "Util.h"

CDSoundSource * EatenItem::_collideSound = NULL;


void EatenItem::onCollideWithHero(Hero * pHero) 
{
    // For the collided objects, remove them
    CCSprite * sprite = this->getSprite();

    [_scoreBoard increaseScore:_score];

    assert(_collideSound);
    [_collideSound play];

    if (_removeWhenEaten)
    {
        [sprite removeFromParentAndCleanup:YES];
        
        GameObject::removeSelf();
    }
}
