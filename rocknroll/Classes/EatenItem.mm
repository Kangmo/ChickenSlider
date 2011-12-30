//
//  EatenItem.cpp
//  rocknroll
//
//  Created by 김 강모 on 11. 10. 1..
//  Copyright 2011년 강모소프트. All rights reserved.
//
#include "EatenItem.h"
#include "Util.h"
#include "ParticleManager.h"
#include "Hero.h"

CDSoundSource * EatenItem::_collideSound = NULL;


void EatenItem::onCollideWithHero(Hero * pHero) 
{
    // For the collided objects, remove them
    CCSprite * sprite = this->getSprite();

    if ( [_particleWhenEaten isEqualToString:@"RotatingStars"] ) {
        ARCH_OPTIMAL_PARTICLE_SYSTEM * emitter = ParticleManager::createRotatingStars();
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        [[sprite parent] addChild:emitter ];
        // Add the particle at the center of the screen. This is shown when the user clears stage by hitting on the FinishBar.
        emitter.position = ccp(winSize.width * 0.5 , winSize.height * 0.5); 
    }

    [_scoreBoard increaseScore:_score];

    assert(_collideSound);
    [_collideSound play];

    if (_removeWhenEaten)
    {
        [sprite removeFromParentAndCleanup:YES];
        
        GameObject::removeSelf();
    }
}
