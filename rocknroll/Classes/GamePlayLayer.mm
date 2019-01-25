//
//  GamePlayLayer.m
//  rocknroll
//
//  Created by 김 강모 on 11. 11. 21..
//  Copyright (c) 2011년 강모소프트. All rights reserved.
//

#import "GamePlayLayer.h"
#import "GameKitHelper.h"
@implementation GamePlayLayer
// initialize your instance here
-(id) initWithSceneName:(NSString*)sceneName
{
	if( (self=[super initWithSceneName:sceneName])) 
	{
        // For GamePlayLayer, we don't try to refresh ADs for the best performance.
        // GeneralScene checks this flag to refresh ads onEnterTransitionDidFinish.
        tryToRefreshAD_ = NO;

        
        // WidgetType=IntegerLabel,WidgetName=KeyCount,Font=yellow25.fnt,Align=Center
        // WidgetType=IntegerLabel,WidgetName=ChickCount,Font=yellow25.fnt,Align=Center
        // WidgetType=Label,WidgetName=SandClockSeconds,Font=white25.fnt,Align=Center
        // WidgetType=Label,WidgetName=Count,Font=white34.fnt,Align=Right
        // WidgetType=Label,WidgetName=Unit,Font=white23.fnt,Align=Left
        // WidgetType=Label,WidgetName=Message,Font=white34.fnt,Align=Left
         
        // - WidgetType=ImageArray,WidgetName=KeysAndChicks,Images=amount.png,DefaultIndex=0
        // WidgetType=SandClock,WidgetName=SandClock
        // WidgetType=FloatLabel,WidgetName=Speed,InitValue=1.0,MinValue=1.0,MaxValue=1.5,StepValue=0.005,Font=yellow34.fnt,Align=Center,Prefix=x 
        // WidgetType=IntegerLabel,WidgetName=Score,Font=yellow34.fnt,Align=Left
         

        stageName_ = (TxLabel*) widgetContainer_->getWidget("StageName").get();
        keyCount_ = (TxIntegerLabel*) widgetContainer_->getWidget("KeyCount").get();
        chickCount_ = (TxIntegerLabel*) widgetContainer_->getWidget("ChickCount").get();
        sandClockSeconds_ = (TxLabel*) widgetContainer_->getWidget("SandClockSeconds").get();
        count_ = (TxLabel*) widgetContainer_->getWidget("Count").get();
        unit_ = (TxLabel*) widgetContainer_->getWidget("Unit").get();
        message_ = (TxLabel*) widgetContainer_->getWidget("Message").get();
        sandClock_ = (TxSandClock*) widgetContainer_->getWidget("SandClock").get();
        speed_ = (TxFloatLabel*) widgetContainer_->getWidget("Speed").get();
        score_ = (TxIntegerLabel*) widgetContainer_->getWidget("Score").get();
        highScore_ = (TxLabel*) widgetContainer_->getWidget("HighScore").get();
        mapPosition_ = (TxLabel*) widgetContainer_->getWidget("MapPosition").get();

        playersGround_ = (TxImageArray*) widgetContainer_->getWidget("PlayersGround").get();
        
        // The hero on this device
        player1_ = (TxAnimationClip*) widgetContainer_->getWidget("Player1").get();
        
        // Other players on other devices (player2, player3, player4)
        player2_ = (TxAnimationClip*) widgetContainer_->getWidget("Player2").get();
        player2_->setVisible(NO);
        player2_->setEnable(NO);
        
        player3_ = (TxAnimationClip*) widgetContainer_->getWidget("Player3").get();
        player3_->setVisible(NO);
        player3_->setEnable(NO);

        player4_ = (TxAnimationClip*) widgetContainer_->getWidget("Player4").get();
        player4_->setVisible(NO);
        player4_->setEnable(NO);

        player1Alias_ = (TxLabel*) widgetContainer_->getWidget("Player1Alias").get();
        player2Alias_ = (TxLabel*) widgetContainer_->getWidget("Player2Alias").get();
        player3Alias_ = (TxLabel*) widgetContainer_->getWidget("Player3Alias").get();
        player4Alias_ = (TxLabel*) widgetContainer_->getWidget("Player4Alias").get();
        
        player2_id_ = nil;
        player3_id_ = nil;
        player4_id_ = nil;
        
        
        stageClearClip_ = (TxAnimationClip*) widgetContainer_->getWidget("StageClear").get();
        stageTimeoutClip_ = (TxAnimationClip*) widgetContainer_->getWidget("StageTimeout").get();
        touchTutorClip_ = (TxAnimationClip*) widgetContainer_->getWidget("TouchTutor").get();
        
        
        // By default we don't run the clip , we don't show the clip for StageClear and StageTimeout
        stageClearClip_->setVisible(NO);
        stageClearClip_->setEnable(NO);
        stageTimeoutClip_->setVisible(NO);
        stageTimeoutClip_->setEnable(NO);
        touchTutorClip_->setVisible(NO);
        touchTutorClip_->setEnable(NO);
        
        totalSeconds_ = 0;
        nHighScore_ = 0;
        nScore_ = 0;
        prevMapProgress = -1;

    }
    return self;
}


-(void)dealloc {

    [player2_id_ release];
    [player3_id_ release];
    [player4_id_ release];

    [super dealloc];
}

-(void)onWidgetAction:(TxWidget*)source
{
    // TODO : Read control values, write data.
    CCLOG(@"GamePlayLayer:onAction:%s", source->getName().c_str());
}

+(id)layerWithSceneName:(NSString*)sceneName
{
    return [[[GamePlayLayer alloc] initWithSceneName:sceneName] autorelease];
}

-(void)update: (ccTime) dt
{
    // Update counters to look like they are increasing by 1 until they reach the target count. 
    keyCount_->getWidgetImpl()->update();
    chickCount_->getWidgetImpl()->update();
    speed_->getWidgetImpl()->update();
    score_->getWidgetImpl()->update();
}


-(void) startStageClearAnim {
    stageClearClip_->setVisible(YES);
    stageClearClip_->setEnable(YES);
}

-(void) startStageTimeoutAnim {
    stageTimeoutClip_->setVisible(YES);
    stageTimeoutClip_->setEnable(YES);
}

-(void) showTouchTutor:(BOOL)bShow {
    touchTutorClip_->setVisible(bShow);
    touchTutorClip_->setEnable(bShow);
}

-(void) setSpeedRatio:(float) speedRatio
{
    speed_->getWidgetImpl()->setTargetValue(speedRatio);
}


-(BOOL) isNewHighScore {
    if (nScore_ >= nHighScore_)
    {
        return YES;
    }
    return NO;
}

-(void) setHighScore:(int)highScore
{
    nHighScore_ = highScore;
    NSString * highScoreString = [NSString stringWithFormat:@"%d", nHighScore_];
    [highScore_->getWidgetImpl() setString:highScoreString];
}

-(void) setScore:(int) score
{
    nScore_ = score;
    if (nScore_ >= nHighScore_) // is New high score?
    {
        [self setHighScore:nScore_];
    }
    score_->getWidgetImpl()->setTargetCount(score);
}

-(void) setKeys:(int)keys
{
    keyCount_->getWidgetImpl()->setTargetCount(keys);
}

-(void) setChicks:(int)chicks
{
    chickCount_->getWidgetImpl()->setTargetCount(chicks);
}

-(void) setSecondsLeft:(float)secondsLeft
{
    int seconds = (int)secondsLeft;
    NSString * secondsString = [NSString stringWithFormat:@"%d",seconds];
    [sandClockSeconds_->getWidgetImpl() setString:secondsString];

    if ( totalSeconds_ == 0 )
    {
        totalSeconds_ = seconds;
    }
    assert( totalSeconds_ > 0 );
    sandClock_->setProgress(seconds, totalSeconds_);
}

/** @brief Set the GameCenter ID of hero on this device 
 */
-(void) setHeroAlias:(NSString*)heroAlias 
{
    player1Alias_->setStringValue(heroAlias);
}

/** @brief Set the X position of a specific player. 
 */
-(void) setMapProgress:(int)mapProgress player:(TxAnimationClip*)playerClip alias:(TxLabel*)playerAlias{
    const TxRect & playersGroundRect = playersGround_->getRect();
    const CGPoint playerPosition = playerClip->getPosition();
    
    float newPlayerPosX = playersGroundRect.origin.x + playersGroundRect.size.width * mapProgress / 100.0f;
    playerClip->setPosition( ccp(newPlayerPosX, playerPosition.y) );
    
    const CGPoint playerAliasPosision = playerAlias->getPosition();
    playerAlias->setPosition( ccp(newPlayerPosX, playerAliasPosision.y) );
}

/** @brief Set the X position of the map. This is for designing levels. 
 */
-(void) setMapProgress:(int)mapProgress
{
    if ( mapProgress != prevMapProgress )
    {
        NSString *positionString = [NSString stringWithFormat:@"%d%%",mapProgress];
        [mapPosition_->getWidgetImpl() setString:positionString];
        prevMapProgress = mapProgress;

        [self setMapProgress:mapProgress player:player1_ alias:player1Alias_];
    }
}

/** @brief Set the players alias.
 */
-(void) doubleCheckAlias:(TxLabel*)playerAlias playerID:(NSString*)playerID {
    NSString * aliasString = playerAlias->getStringValue();
    if ( aliasString == nil || [aliasString isEqualToString:@""] ) {
        GKPlayer * player = [[GameKitHelper sharedGameKitHelper] getPlayerByID:playerID];
        // Because GKPlayer objects in the current match are retrieved asynchronously, 
        // We may get nil for the player.
        if (player) // If we have the player data retrieved,
        {
            // Set the player alias 
            playerAlias->setStringValue(player.alias);
        }
    }
}


/** @brief Set position of other players.
 */
-(void) setProgress:(int)mapProgress position:(CGPoint)position player:(NSString*)playerID {
    CCLOG(@"Player[%@] = (%f,%f)", playerID, position.x, position.y);
    if ( !player2_id_ )
        player2_id_ = [playerID retain];
    if ([player2_id_ isEqualToString:playerID]) {
        [self doubleCheckAlias:player2Alias_ playerID:playerID];
        [self setMapProgress:mapProgress player:player2_ alias:player2Alias_];
        player2_->setVisible(YES);
        player2_->setEnable(YES);
        return;
    }

    if ( !player3_id_ )
        player3_id_ = [playerID retain];
    if ([player3_id_ isEqualToString:playerID]) {
        [self doubleCheckAlias:player3Alias_ playerID:playerID];
        [self setMapProgress:mapProgress player:player3_ alias:player3Alias_];
        player3_->setVisible(YES);
        player3_->setEnable(YES);
        return;
    }
    
    if ( !player4_id_ )
        player4_id_ = [playerID retain];
    if ([player4_id_ isEqualToString:playerID]) {
        [self doubleCheckAlias:player4Alias_ playerID:playerID];
        [self setMapProgress:mapProgress player:player4_ alias:player4Alias_];
        player4_->setVisible(YES);
        player4_->setEnable(YES);
        return;
    }
    
    // Should never come here. 
    // TODO : Add Flurry 
    NSLog(@"ERROR:All 4 player IDs are filled, but we received a new ID : %@", playerID);
    assert(0);
}

/** @brief Set the stage name.
 */
-(void) setStageName:(NSString*)stageName
{
    if(stageName) {
        [stageName_->getWidgetImpl() setString:stageName];
    }
}

- (void) showMessage:(NSString*) message {
    message_->showMessage( message );
}

-(void) showCombo:(int)combo
{
    NSString * comboCountString = [NSString stringWithFormat:@"%d",combo];
    count_->showMessage( comboCountString );
    unit_->showMessage( @"COMBO" );
}

@end
