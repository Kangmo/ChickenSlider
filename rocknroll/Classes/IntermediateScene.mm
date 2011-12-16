//
//  IntermediateScene.m
//  rocknroll
//
//  Created by 김 강모 on 11. 12. 14..
//  Copyright (c) 2011년 강모소프트. All rights reserved.
//

#import "IntermediateScene.h"

@implementation IntermediateScene


// initialize your instance here
-(id) initWithSceneName:(NSString*)sceneName nextScene:(CCScene*)nextScene
{
    self = [super initWithSceneName:sceneName];
    if (self) {
        // We should have a background image to show and
        assert( ! loopParallax_ );
        // Should scroll only once.
        assert( backgroundWidth_ > 0);
        
        nextScene_ = [nextScene retain];
        self.actionListener = self;
    }
    
    return self;
}

-(void) dealloc {
    [nextScene_ release];
    nextScene_ = nil;
    [super dealloc];
}

+(id)nodeWithSceneName:(NSString*)sceneName nextScene:(CCScene*)nextScene
{
    return [[[IntermediateScene alloc] initWithSceneName:sceneName nextScene:nextScene] autorelease];
}


+(CCScene*)sceneWithName:(NSString*)sceneName nextScene:(CCScene*)nextScene
{
    // 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	CCLayer *layer = [IntermediateScene nodeWithSceneName:sceneName nextScene:nextScene];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

-(void) onMessage:(NSString*)message 
{
    // OpeningScene.svg receives "NextScene" message from when the user presses "Skip" button.
    if ( [message isEqualToString:@"NextScene"] )
    {
        [[CCDirector sharedDirector] replaceScene:[Util defaultSceneTransition:nextScene_]];
    }
}

@end

