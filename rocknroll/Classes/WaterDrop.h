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
#import "ScoreBoardProtocol.h"

class WaterDrop : public GameObject
{
private:
    static CDSoundSource * _collideSound;
    id<ScoreBoardProtocol> _scoreBoard;
public:
    WaterDrop(float x, float y, float width, float height, id<ScoreBoardProtocol> sb)
    :GameObject(x,y,width,height)
    {
        if ( !_collideSound )
        {
            // BUGBUG : The object is leaked! 
            _collideSound = [[[SimpleAudioEngine sharedEngine] soundSourceForFile:@"WaterDrop.wav"] retain];
        }
        assert(_collideSound);
        
        _scoreBoard = sb;
    };
    virtual ~WaterDrop()
    {
    }
    
    virtual void onCollideWithHero();
};

#endif
