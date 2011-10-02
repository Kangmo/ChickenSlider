//
//  WaterDrop.h
//  rocknroll
//
//  Created by 김 강모 on 11. 9. 30..
//  Copyright 2011년 강모소프트. All rights reserved.
//

#ifndef rocknroll_WaterDrop_h
#define rocknroll_WaterDrop_h

#include "GameObject.h"
#include "GameObjectContainer.h"

class WaterDrop : public GameObject
{
private:
    static CDSoundSource * _collideSound;
public:
    WaterDrop(float x, float y, float width, float height)
    :GameObject(x,y,width,height)
    {
        if ( !_collideSound )
        {
            // BUGBUG : The object is leaked! 
            _collideSound = [[[SimpleAudioEngine sharedEngine] soundSourceForFile:@"WaterDrop.wav"] retain];
        }
        assert(_collideSound);
    };
    virtual ~WaterDrop()
    {
    }
    inline virtual void onCollideWithHero() 
    {
        // For the collided objects, remove them
        CCSprite * sprite = this->getSprite();
        
        
        [sprite removeFromParentAndCleanup:YES];
        
        //BUGBUG : Understand what happens if this objet is destroyed while the sound was playing
        assert(_collideSound);
        [_collideSound play];
        
        CCLOG(@"played");
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
};

#endif
