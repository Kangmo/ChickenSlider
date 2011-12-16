//
//  EatenItem.h
//  rocknroll
//
//  Created by 김 강모 on 11. 9. 30..
//  Copyright 2011년 강모소프트. All rights reserved.
//

#ifndef rocknroll_EatenItem_h
#define rocknroll_EatenItem_h

#include "GameObject.h"
#include "GameObjectContainer.h"
#import "ScoreBoardProtocol.h"
#import "ClipFactory.h"

class EatenItem : public GameObject
{
private:
    static CDSoundSource * _collideSound;
    id<ScoreBoardProtocol> _scoreBoard;
    int _score;
    BOOL _removeWhenEaten;
public:
    EatenItem(float x, float y, float width, float height, id<ScoreBoardProtocol> sb, NSString * soundFileName, int score, BOOL removeWhenEaten)
    :GameObject(x,y,width,height)
    {
        _scoreBoard = sb;
        _score = score;  
        _removeWhenEaten = removeWhenEaten;
        
        if ( !_collideSound )
        {
            // BUGBUG : Change the sound file.
            // BUGBUG : The object is leaked! 
            _collideSound = [[ClipFactory sharedFactory] soundByFile:soundFileName];
            [_collideSound retain];
        }
        assert(_collideSound);
    };
    virtual ~EatenItem()
    {
    }
    
    virtual void onCollideWithHero(Hero * pHero);
};

#endif
