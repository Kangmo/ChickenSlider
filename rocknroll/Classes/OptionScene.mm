//
//  OptionScene.m
//  rocknroll
//
//  Created by 김 강모 on 11. 11. 21..
//  Copyright (c) 2011년 강모소프트. All rights reserved.
//

#import "OptionScene.h"

#import "Util.h"
#include "TxSlideBar.h"
#include "TxToggleButton.h"
#include "AppAnalytics.h"

@implementation OptionScene


// initialize your instance here
-(id) initWithSceneName:(NSString*)sceneName
{
	if( (self=[super initWithSceneName:sceneName])) 
	{
        // TODO : Read data, set control values.
        musicVolumeLabel_ = (TxLabel*) widgetContainer_->getWidget("MusicVolumeLabel").get();
        effectVolumeLabel_ = (TxLabel*) widgetContainer_->getWidget("EffectVolumeLabel").get();
        
        int musicVolume = [Util loadMusicVolume];
        int effectVolume = [Util loadEffectVolume];
        int difficulty = [Util loadDifficulty];

        assert(musicVolume>=0 && musicVolume<=10);
        assert(effectVolume>=0 && effectVolume<=10);
        assert(difficulty == 0 || difficulty == 1);

        TxSlideBar * musicVolumeSlide = (TxSlideBar*) widgetContainer_->getWidget("MusicVolumeSlide").get();
        TxSlideBar * effectVolumeSlide = (TxSlideBar*) widgetContainer_->getWidget("EffectVolumeSlide").get();
        TxToggleButton * difficultyToggle = (TxToggleButton*) widgetContainer_->getWidget("Difficulty").get();
        
        musicVolumeLabel_->setIntValue(musicVolume);
        musicVolumeSlide->setValue((float)musicVolume / MAX_MUSIC_VOLUME );
        
        effectVolumeLabel_->setIntValue(effectVolume);
        effectVolumeSlide->setValue((float)effectVolume / MAX_MUSIC_VOLUME);
        
        difficultyToggle->setValue(difficulty);
        
        // If the OptionScene.svg is shown while the user pressed Pause button during the game play,
        // Disable the "Easy" "Hard" mode switch. 
        if ( [CCDirector sharedDirector].isPaused ) {
            difficultyToggle->disable();
        }
    }
    return self;
}

-(void)onWidgetAction:(TxWidget*)source
{
    const std::string & widgetName = source->getName();
    if ( widgetName == "MusicVolumeSlide")
    {
        TxSlideBar * musicVolumeSlide = (TxSlideBar*) source;
        float fMusicVolume = musicVolumeSlide->getValue();
        int musicVolume = (int)(fMusicVolume * MAX_MUSIC_VOLUME);
        //musicVolumeSlide->setValue(musicVolume);
        musicVolumeLabel_->setIntValue(musicVolume );
        [Util saveMusicVolume:musicVolume];
        
        [[SimpleAudioEngine sharedEngine] setBackgroundMusicVolume:fMusicVolume];
    }
    if ( widgetName == "EffectVolumeSlide")
    {
        TxSlideBar * effectVolumeSlide = (TxSlideBar*) source;
        float fEffectVolume = effectVolumeSlide->getValue();
        int effectVolume = (int)(fEffectVolume * MAX_EFFECT_VOLUME);
        //effectVolumeSlide->setValue(effectVolume);
        effectVolumeLabel_->setIntValue(effectVolume);
        [Util saveEffectVolume:effectVolume];
        
        [[SimpleAudioEngine sharedEngine] setEffectsVolume:fEffectVolume];
    }
    if ( widgetName == "Difficulty")
    {
        TxToggleButton * difficultyToggle = (TxToggleButton*) source;
        int difficulty = difficultyToggle->getValue();
        [Util saveDifficulty:difficulty];
    }
    
    AppAnalytics::sharedAnalytics().logEvent( std::string("OptionScene:") + widgetName );
}

+(id)nodeWithSceneName:(NSString*)sceneName
{
    return [[[OptionScene alloc] initWithSceneName:sceneName] autorelease];
}

+(CCScene*)sceneWithName:(NSString*)sceneName
{
    // 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	GeneralScene *layer = [OptionScene nodeWithSceneName:sceneName];
    
	// add layer as a child to scene
	[scene addChild:layer z:0 tag:0];
	
	// return the scene
	return scene;
}


@end
