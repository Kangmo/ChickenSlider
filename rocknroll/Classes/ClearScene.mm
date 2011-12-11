//
//  ClearScene.m
//  rocknroll
//
//  Created by 김 강모 on 11. 11. 21..
//  Copyright (c) 2011년 강모소프트. All rights reserved.
//

#import "ClearScene.h"
#import "LevelMapScene.h"

@implementation ClearScene
-(BOOL) checkHighestScore:(int)score
{
    // No score board for now.
    return FALSE;
}

-(NSString*) getTimeText:(float)timeSpent
{
    int seconds = (int)timeSpent;
    int minPart = seconds / 60;
    int secPart = seconds % 60;
    NSString * timeText = [NSString stringWithFormat:@"%02d:%02d", minPart, secPart ];
    return timeText;
}

-(void) setIntValue:(int)value to:(REF(TxLabel))label
{
    NSString * intString = [NSString stringWithFormat:@"%d", value];
    [label->getWidgetImpl() setString:intString];
}

// initialize your instance here
-(id) initWithMap:(NSString*)m 
            level:(int)l
            score:(int)score 
             keys:(int)keys 
           chicks:(int)chicks 
            stars:(int)stars 
         maxCombo:(int)maxComboCount
        timeSpent:(float)timeSpent
{
	if( (self=[super initWithSceneName:@"ClearScene"])) 
	{
        assert(m);
        assert(l>0);
        
        mapName_ = [m retain];
        level_ = l;
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
        starPoints_ = boost::static_pointer_cast<TxImageArray>( widgetContainer_.getWidget("StarPoints") );
        clearMessage_ = boost::static_pointer_cast<TxImageArray>( widgetContainer_.getWidget("ClearMessage") );
        keys_ = boost::static_pointer_cast<TxLabel>( widgetContainer_.getWidget("Keys") );
        chicks_ = boost::static_pointer_cast<TxLabel>( widgetContainer_.getWidget("Chicks") );
        totalChicks_ = boost::static_pointer_cast<TxLabel>( widgetContainer_.getWidget("TotalChicks") );
        time_ = boost::static_pointer_cast<TxLabel>( widgetContainer_.getWidget("Time") );
        maxCombo_ = boost::static_pointer_cast<TxLabel>( widgetContainer_.getWidget("MaxCombo") );
        score_ = boost::static_pointer_cast<TxIntegerLabel>( widgetContainer_.getWidget("Score") );
        
        starPoints_->setValue(stars);
        BOOL isHighestScore = [self checkHighestScore:score];
        if (isHighestScore)
            clearMessage_->setValue(0); // Show "New High Score! message"

        [self setIntValue:keys to:keys_];
        [self setIntValue:chicks to:chicks_];
        
        int totalChicks = [Util loadTotalChickCount];
        [self setIntValue:totalChicks to:totalChicks_];
        [self setIntValue:maxComboCount to:maxCombo_];

        NSString * timeSpentString = [self getTimeText:(float)timeSpent];
        [time_->getWidgetImpl() setString:timeSpentString];
        score_->getWidgetImpl()->setTargetCount(score);
        
        [self schedule: @selector(tick:)];

        // ClearScene receives the action message.
        self.actionListener = self;
    }
    
    return self;
}

+(id)nodeWithMap:(NSString*)mapName 
           level:(int)level
           score:(int)score 
            keys:(int)keys 
          chicks:(int)chicks 
           stars:(int)stars 
        maxCombo:(int)maxComboCount
       timeSpent:(float)timeSpent
{
    ClearScene * clearLayer = [[ClearScene alloc] initWithMap:mapName 
                                                        level:level
                                                        score:score 
                                                         keys:keys 
                                                       chicks:chicks 
                                                        stars:stars 
                                                     maxCombo:maxComboCount
                                                    timeSpent:timeSpent
                               ];
    return [clearLayer autorelease];
}

+(CCScene*) sceneWithMap:(NSString*)mapName 
                   level:(int)level
                   score:(int)score 
                    keys:(int)keys 
                  chicks:(int)chicks 
                   stars:(int)stars 
                maxCombo:(int)maxComboCount
               timeSpent:(float)timeSpent
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	ClearScene *layer = [ClearScene nodeWithMap:mapName 
                                          level:level
                                          score:score 
                                           keys:keys 
                                         chicks:chicks 
                                          stars:stars 
                                       maxCombo:maxComboCount
                                      timeSpent:timeSpent
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
        // BUGBUG : check if the next level exists.
        // BUGBUG : unlock the next level if it exists
        CCScene * loadingScene = [GeneralScene loadingSceneOfMap:mapName_ levelNum:level_+1];
        [[CCDirector sharedDirector] replaceScene:loadingScene];
    }
    
    if ( [message isEqualToString:@"SelectStage"] )
    {
        CCScene * levelMapScene = [LevelMapScene sceneWithName:mapName_ level:level_ cleared:YES];
        assert(levelMapScene);
        
        [[CCDirector sharedDirector] replaceScene:[Util defaultSceneTransition:levelMapScene]];
    }
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
