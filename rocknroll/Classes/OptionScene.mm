//
//  OptionScene.m
//  rocknroll
//
//  Created by 김 강모 on 11. 11. 21..
//  Copyright (c) 2011년 강모소프트. All rights reserved.
//

#import "OptionScene.h"

@implementation OptionScene


// initialize your instance here
-(id) initWithSceneName:(NSString*)sceneName
{
	if( (self=[super initWithSceneName:sceneName])) 
	{
        // TODO : Read data, set control values.
        //widgetContainer_.getWidget("");
    }
    return self;
}

-(void)onWidgetAction:(TxWidget*)source
{
    // TODO : Read control values, write data.
    CCLOG(@"OptionScene:onAction:%s", source->getName().c_str());
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
