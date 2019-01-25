//
//  OnlineScene.m
//  rocknroll
//
//  Created by 김 강모 on 11. 11. 21..
//  Copyright (c) 2011년 강모소프트. All rights reserved.
//

#import "OnlineScene.h"
#import "LevelMapScene.h"
#include "AppAnalytics.h"
#import "GameKitHelper.h"

@implementation OnlineScene


// initialize your instance here
-(id) initWithSceneName:(NSString*)sceneName {
	if( (self=[super initWithSceneName:sceneName])) 
	{
        // OnlineScene receives the action message.
        self.actionListener = self;
        
        AppAnalytics::sharedAnalytics().logEvent( "OnlineScene" );
    }
    return self;
}



+(id)nodeWithSceneName:(NSString*)sceneName {
    OnlineScene * onlineLayer = [[OnlineScene alloc] initWithSceneName:sceneName];
    return [onlineLayer autorelease];
}


///////////////////////////////////////////////////////////////
// GeneralMessageProtocol
-(void)onMessage:(NSString*) message
{
    if ( [message isEqualToString:@"LeaderBoard" ] ) 
    {
        [[GameKitHelper sharedGameKitHelper] showLeaderboard];
    }    
    if ( [message isEqualToString:@"Achievement" ] ) 
    {
        [[GameKitHelper sharedGameKitHelper] showAchievements];
    }    
    if ( [message isEqualToString:@"Sync"] )
    {
        [[GameKitHelper sharedGameKitHelper] reportCachedAchievements];
    }

    AppAnalytics::sharedAnalytics().logEvent( "OnlineScene:"+[Util toStdString:message] );
}

                                   
-(void)dealloc
{
    
    [super dealloc];
}
@end
