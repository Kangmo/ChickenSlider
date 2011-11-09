//
//  Hen.h
//  rocknroll
//
//  Created by 김 강모 on 11. 9. 30..
//  Copyright 2011년 강모소프트. All rights reserved.
//

#ifndef rocknroll_Hen_h
#define rocknroll_Hen_h

#include "GameObject.h"
#include "GameObjectContainer.h"
#import "ScoreBoardProtocol.h"
#import "ClipFactory.h"

class Hen : public GameObject
{
private:
    static CDSoundSource * _collideSound;
    id<ScoreBoardProtocol> _scoreBoard;
    CCAction * _releasingAction;
    bool _released;
public:
    Hen(float x, float y, float width, float height, id<ScoreBoardProtocol> sb)
    :GameObject(x,y,width,height)
    {
        _scoreBoard = sb;
        _released = false;
        
        if ( !_collideSound )
        {
            // BUGBUG : Change the sound file.
            // BUGBUG : The object is leaked! 
            _collideSound = [[[SimpleAudioEngine sharedEngine] soundSourceForFile:@"WaterDrop.wav"] retain];
        }
        // BUGBUG : The assertion hits. Find out why.
//        assert(_collideSound);
        
        _releasingAction = [[[ClipFactory sharedFactory] clipActionByFile:@"clip_hen_released.plist"] retain];
        assert(_releasingAction);
    };
    virtual ~Hen()
    {
        assert(_releasingAction);
        [_releasingAction release];
        _releasingAction = nil;
    }
    
    virtual void onCollideWithHero(Hero * pHero);
};

#endif
