//
//  ResultScene.m
//  rocknroll
//
//  Created by 김 강모 on 11. 11. 21..
//  Copyright (c) 2011년 강모소프트. All rights reserved.
//

#import "ResultScene.h"
#import "LevelMapScene.h"
#include "AppAnalytics.h"

@implementation ResultScene

-(NSString*) getTimeText:(float)timeSpent
{
    int seconds = (int)timeSpent;
    int minPart = seconds / 60;
    int secPart = seconds % 60;
    NSString * timeText = [NSString stringWithFormat:@"%02d:%02d", minPart, secPart ];
    return timeText;
}


// initialize your instance here
-(id) initWithMap:(NSString*)m 
            level:(int)l
        lastStage:(BOOL)lastStage
            score:(int)score 
             keys:(int)keys 
           chicks:(int)chicks 
            stars:(int)stars 
         maxCombo:(int)maxComboCount
        timeSpent:(float)timeSpent
         timeLeft:(float)timeLeft
{
	if( (self=[super initWithSceneName:@"ResultScene"])) 
	{
        assert(m);
        assert(l>0);
        
        mapName_ = [m retain];
        level_ = l;
        lastStage_ = lastStage;
/*        
        WidgetType=ImageArray,WidgetName=StarPoints,Images=B_Star_0.png|B_Star_1.png|B_Star_2.png|B_Star_3.png
        WidgetType=ImageArray,WidgetName=ClearMessage,Images=new_high_score.png,DefaultIndex=-1
        WidgetType=Label,WidgetName=Keys,Font=yellow25.fnt
        WidgetType=Label,WidgetName=Chicks,Font=yellow25.fnt
        WidgetType=Label,WidgetName=TotalChicks,Font=yellow25.fnt
        WidgetType=Label,WidgetName=Time,Font=yellow25.fnt
        WidgetType=Label,WidgetName=MaxCombo,Font=yellow25.fnt
        WidgetType=IntegerLabel,WidgetName=Score,Font=yellow34.fnt
*/
        clearMessage_ = (TxImageArray*) widgetContainer_->getWidget("ClearMessage").get();
        player1Name_ = (TxLabel*) widgetContainer_->getWidget("Player1Name").get();
        player1Time_ = (TxLabel*) widgetContainer_->getWidget("Player1Time").get();
        player2Name_ = (TxLabel*) widgetContainer_->getWidget("Player2Name").get();
        player2Time_ = (TxLabel*) widgetContainer_->getWidget("Player2Time").get();
        player3Name_ = (TxLabel*) widgetContainer_->getWidget("Player3Name").get();
        player3Time_ = (TxLabel*) widgetContainer_->getWidget("Player3Time").get();
        player4Name_ = (TxLabel*) widgetContainer_->getWidget("Player4Name").get();
        player4Time_ = (TxLabel*) widgetContainer_->getWidget("Player4Time").get();
        
        // BUGBUG : Set multiplay points instead of score.
        score_ = (TxIntegerLabel*) widgetContainer_->getWidget("Score").get();
        
        // BUGBUG : Hide Try Again and Next Stage for everyone except the multiplayer initiator.
        
        // BUGBUG : Get Next stage button
//        nextStageButton_ = (TxImageArray*) widgetContainer_->getWidget("NextStageButton").get();
        
//        starPoints_->setValue(stars);
        if ( [Util loadStarCount:m level:l] < stars ) { // Save the new star count only if the user has got more stars than the saved one.
            [Util saveStarCount:(NSString*)m level:(int)l starCount:stars];
        }
        
        int highScore = [Util loadHighScore:m level:l];
        
        if (highScore < score)
        {
            clearMessage_->setValue(0); // Show "New High Score! message"
            [Util saveHighScore:m level:l highScore:score];
        }


        score_->getWidgetImpl()->setTargetCount(score);

        // ResultScene receives the action message.
        self.actionListener = self;
        
        // log App analysis event.
        {
            int totalChicks = [Util loadTotalChickCount];
            
            AppAnalytics::sharedAnalytics().beginEventProperty();
            AppAnalytics::sharedAnalytics().addStageNameEventProperty(m, l);
            AppAnalytics::sharedAnalytics().addEventProperty("score", score);
            AppAnalytics::sharedAnalytics().addEventProperty("highScore", highScore);
            AppAnalytics::sharedAnalytics().addEventProperty("keys", keys);
            AppAnalytics::sharedAnalytics().addEventProperty("chicks", chicks);
            AppAnalytics::sharedAnalytics().addEventProperty("totalChicks", totalChicks);
            AppAnalytics::sharedAnalytics().addEventProperty("stars", stars);
            AppAnalytics::sharedAnalytics().addEventProperty("maxCombo", maxComboCount);
            AppAnalytics::sharedAnalytics().addEventProperty("timeSpent", timeSpent);
            AppAnalytics::sharedAnalytics().addEventProperty("timeLeft", timeLeft);
            AppAnalytics::sharedAnalytics().endEventProperty();
            
            AppAnalytics::sharedAnalytics().logEvent( "ResultScene:Cleared" );
        }
        
    }
    
    return self;
}

-(void) setTimeLabel:(TxLabel*)label time:(float)timeSpent {
    NSString * timeSpentString = [self getTimeText:(float)timeSpent];
    [label->getWidgetImpl() setString:timeSpentString];
}

-(void) onEnterTransitionDidFinish {
    // Schedule tick to gradually increase score.
    [self schedule: @selector(tick:)];
    
    [super onEnterTransitionDidFinish];
}

+(id)nodeWithMap:(NSString*)mapName 
           level:(int)level
       lastStage:(BOOL)lastStage
           score:(int)score 
            keys:(int)keys 
          chicks:(int)chicks 
           stars:(int)stars 
        maxCombo:(int)maxComboCount
       timeSpent:(float)timeSpent
        timeLeft:(float)timeLeft
{
    ResultScene * clearLayer = [[ResultScene alloc] initWithMap:mapName 
                                                        level:level
                                                    lastStage:lastStage
                                                        score:score 
                                                         keys:keys 
                                                       chicks:chicks 
                                                        stars:stars 
                                                     maxCombo:maxComboCount
                                                    timeSpent:timeSpent
                                                     timeLeft:timeLeft
                               ];
    return [clearLayer autorelease];
}

+(CCScene*) sceneWithMap:(NSString*)mapName 
                   level:(int)level
               lastStage:(BOOL)lastStage
                   score:(int)score 
                    keys:(int)keys 
                  chicks:(int)chicks 
                   stars:(int)stars 
                maxCombo:(int)maxComboCount
               timeSpent:(float)timeSpent
                timeLeft:(float)timeLeft
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	ResultScene *layer = [ResultScene nodeWithMap:mapName 
                                          level:level
                                      lastStage:lastStage
                                          score:score 
                                           keys:keys 
                                         chicks:chicks 
                                          stars:stars 
                                       maxCombo:maxComboCount
                                      timeSpent:timeSpent
                                       timeLeft:timeLeft
                         ];
	
	// add layer as a child to scene
	[scene addChild:layer z:0 tag:0];
    
	// return the scene
	return scene;
}

///////////////////////////////////////////////////////////////
// GeneralMessageProtocol
-(void)onMessage:(NSString*) message
{
    if ( [message isEqualToString:@"NextStage"] )
    {
        if (lastStage_) {
            // Do nothing.
        } else {
            int newLevel = level_ + 1;
            
            CCScene * loadingScene = [GeneralScene loadingSceneOfMap:mapName_ levelNum:newLevel];
            [[CCDirector sharedDirector] replaceScene:loadingScene];
        }
    }
    
    if ( [message isEqualToString:@"SelectStage"] )
    {
        // LevelMapScene will unlock the next level if it exists.
        CCScene * levelMapScene = [LevelMapScene sceneWithName:mapName_ level:level_ cleared:YES];
        assert(levelMapScene);
        
        [[CCDirector sharedDirector] replaceScene:[Util defaultSceneTransition:levelMapScene]];
        
        // BUGBUG : Disconnect Multiplay.
    }
    
    if ( [message isEqualToString:@"Retry" ] ) {
        CCScene * newScene = [GeneralScene loadingSceneOfMap:mapName_ levelNum:level_];
        [[CCDirector sharedDirector] replaceScene:[Util defaultSceneTransition:newScene] ];
    }
    
    AppAnalytics::sharedAnalytics().beginEventProperty();
    AppAnalytics::sharedAnalytics().addStageNameEventProperty(mapName_, level_);
    AppAnalytics::sharedAnalytics().endEventProperty();
    
    AppAnalytics::sharedAnalytics().logEvent( "ResultScene:"+[Util toStdString:message] );
}

-(void) tick: (ccTime) dt
{
    // increase the score gradually.
    score_->getWidgetImpl()->update();
}

- (void) onExit {
	// in case you have something to dealloc, do it in this method
    [self unschedule: @selector(tick:)];
    
    [super onExit];
}

                                   
-(void)dealloc
{
    [mapName_ release];
    mapName_ = nil;
    
    [super dealloc];
}
@end
