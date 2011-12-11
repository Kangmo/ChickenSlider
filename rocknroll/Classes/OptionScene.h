//
//  OptionScene.h
//  rocknroll
//
//  Created by 김 강모 on 11. 11. 21..
//  Copyright (c) 2011년 강모소프트. All rights reserved.
//

#import "GeneralScene.h"
#import "TxLabel.h"

/*
 WidgetType=SlideBar,WidgetName=MusicVolumeSlide,SlideImage=gage.png,SlideMin=0,SlideMax=10,SlideDefault=10,Align=Center
 WidgetType=SlideBar,WidgetName=EffectVolumeSlide,SlideImage=gage.png,SlideMin=0,SlideMax=10,SlideDefault=10,Align=Center
 
 WidgetType=Label,WidgetName=MusicVolumeLabel,Font=yellow34.fnt,Align=Center
 WidgetType=Label,WidgetName=EffectVolumeLabel,Font=yellow34.fnt,Align=Center
 
 WidgetType=ToggleButton,WidgetName=Difficulty,Images=Sel_Easy.png|Sel_Hard.png,Align=Center
 */
@interface OptionScene : GeneralScene
{
    REF(TxLabel) musicVolumeLabel_;
    REF(TxLabel) effectVolumeLabel_;
}
+(CCScene*)sceneWithName:(NSString*)sceneName;

@end
