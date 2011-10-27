//
//  Remedy.h
//  rocknroll
//
//  Created by 김 강모 on 11. 9. 30..
//  Copyright 2011년 강모소프트. All rights reserved.
//

#ifndef rocknroll_Remedy_h
#define rocknroll_Remedy_h

#include "GameObject.h"
#include "GameObjectContainer.h"
#import "ScoreBoardProtocol.h"
#import "ClipFactory.h"

class Remedy : public GameObject
{
private:
    static CDSoundSource * _collideSound;
    id<ScoreBoardProtocol> _scoreBoard;
public:
    Remedy(float x, float y, float width, float height, id<ScoreBoardProtocol> sb)
    :GameObject(x,y,width,height)
    {
        _scoreBoard = sb;
        
        if ( !_collideSound )
        {
            // BUGBUG : Change the sound file.
            // BUGBUG : The object is leaked! 
            _collideSound = [[[SimpleAudioEngine sharedEngine] soundSourceForFile:@"WaterDrop.wav"] retain];
        }
        assert(_collideSound);
    };
    virtual ~Remedy()
    {
    }
    
    virtual void onCollideWithHero(Hero * pHero);
};

#endif
