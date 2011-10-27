//
//  Remedy.cpp
//  rocknroll
//
//  Created by 김 강모 on 11. 10. 1..
//  Copyright 2011년 강모소프트. All rights reserved.
//
#include "Remedy.h"
#include "Util.h"

CDSoundSource * Remedy::_collideSound = NULL;


void Remedy::onCollideWithHero(Hero * pHero) 
{
    // For the collided objects, remove them
    CCSprite * sprite = this->getSprite();

    assert(_collideSound);
    [_collideSound play];

    // Decrease life by 10 ( total 100)
    [_scoreBoard increaseLife:10];
    
    [sprite removeFromParentAndCleanup:YES];
    
    GameObject::removeSelf();
}
