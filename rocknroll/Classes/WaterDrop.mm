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
    /*            
     // node2: the node that will be removed
     id action = [CCSequence actions:
     [CCMoveBy actionWithDuration:2 position:ccp(200,0)],
     [CCCallFuncND actionWithTarget:node2 selector:@selector(removeFromParentAndCleanup:) data:(void*)YES],
     nil];
     
     // node1: the node that runs the action
     [node1 runAction:action];
     */          
}
