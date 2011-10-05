//
//  WaterDrop.cpp
//  rocknroll
//
//  Created by 김 강모 on 11. 10. 1..
//  Copyright 2011년 강모소프트. All rights reserved.
//
#include "WaterDrop.h"

CDSoundSource * WaterDrop::_collideSound = NULL;

void WaterDrop::onCollideWithHero() 
{
    // Increase the water drops to show on the screen
    [_scoreBoard increaseWaterDrops:1];
    
    // For the collided objects, remove them
    CCSprite * sprite = this->getSprite();
    
    [sprite removeFromParentAndCleanup:YES];
    
    assert(_collideSound);
    [_collideSound play];
    
    GameObject::removeSelf();
}
