//
//  Bomb.h
//  rocknroll
//
//  Created by 김 강모 on 11. 9. 30..
//  Copyright 2011년 강모소프트. All rights reserved.
//

#ifndef rocknroll_Bomb_h
#define rocknroll_Bomb_h

#include "GameObject.h"
#include "GameObjectContainer.h"
#import "ScoreBoardProtocol.h"
#import "ClipFactory.h"

class Bomb : public GameObject
{
private:
    static CDSoundSource * _collideSound;
    id<ScoreBoardProtocol> _scoreBoard;
    CCAction * _explosionAction;
    bool _exploded;
public:
    Bomb(float x, float y, float width, float height, id<ScoreBoardProtocol> sb)
    :GameObject(x,y,width,height)
    {
        _scoreBoard = sb;
        _exploded = false;
        
        if ( !_collideSound )
        {
            // BUGBUG : Change the sound file.
            // BUGBUG : The object is leaked! 
            _collideSound = [[ClipFactory sharedFactory] soundByFile:@"key"SND_EXT];
            [_collideSound retain];
        }
        assert(_collideSound);
        
        _explosionAction = [[[ClipFactory sharedFactory] clipActionByFile:@"clip_explosion.plist"] retain];
        assert(_explosionAction);
    };
    virtual ~Bomb()
    {
        assert(_explosionAction);
        [_explosionAction release];
        _explosionAction = nil;
    }
    
    virtual void onCollideWithHero(Hero * pHero);
};

#endif
