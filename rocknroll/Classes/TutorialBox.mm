//
//  TutorialBox.cpp
//  rocknroll
//
//  Created by 김 강모 on 11. 10. 1..
//  Copyright 2011년 강모소프트. All rights reserved.
//
#include "TutorialBox.h"

CDSoundSource * TutorialBox::_collideSound = NULL;

void TutorialBox::onCollideWithHero() 
{
    [_tutorialBoard showTutorialText:_tutorialText];
    
    assert(_collideSound);
    [_collideSound play];
    
    GameObject::removeSelf();
}
