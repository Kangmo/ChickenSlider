//
//  GamePlayLayer.m
//  rocknroll
//
//  Created by 김 강모 on 11. 11. 21..
//  Copyright (c) 2011년 강모소프트. All rights reserved.
//

#import "GamePlayLayer.h"
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

/** @brief Set the X position of the map. This is for designing levels. 
 */
-(void) setMapProgress:(int)mapProgress
{

    if ( mapProgress != prevMapProgress )
    {
        NSString *positionString = [NSString stringWithFormat:@"%d%%",mapProgress];
        [mapPosition_->getWidgetImpl() setString:positionString];
        prevMapProgress = mapProgress;
    }
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
