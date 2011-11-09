//
//  TutorialBox.h
//  rocknroll
//
//  Created by 김 강모 on 11. 9. 30..
//  Copyright 2011년 강모소프트. All rights reserved.
//

#ifndef rocknroll_TutorialBox_h
#define rocknroll_TutorialBox_h

#include "GameObject.h"
#include "GameObjectContainer.h"
#import "TutorialBoardProtocol.h"

class TutorialBox : public GameObject
{
private:
    static CDSoundSource * _collideSound;
    id<TutorialBoardProtocol> _tutorialBoard;
    NSString * _tutorialText;
public:
    TutorialBox(float x, float y, float width, float height, NSString * tt, id<TutorialBoardProtocol> tb)
    :GameObject(x,y,width,height)
    {
        if ( !_collideSound )
        {
            // BUGBUG : The object is leaked! 
            // BUGBUG : Change the sound!
            _collideSound = [[[SimpleAudioEngine sharedEngine] soundSourceForFile:@"WaterDrop.wav"] retain];
        }
        assert(_collideSound);

        assert(tt);
        _tutorialText = [tt retain];
        _tutorialBoard = tb;
    };
    virtual ~TutorialBox()
    {
        assert(_tutorialText);
        [_tutorialText release];
        _tutorialText = nil;
    }
    
    virtual void onCollideWithHero(Hero * pHero);
};

#endif
