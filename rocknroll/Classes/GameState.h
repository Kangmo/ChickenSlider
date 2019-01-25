//
//  GameState.h
//  rocknroll
//
//  Created by 김 강모 on 12. 1. 11..
//  Copyright (c) 2012년 강모소프트. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GameKitHelper.h"

// Meaning of "All players" : We wait for 10 seconds for players to respond. 
// If timeout happens not all players responded. But we say "All players" responded. 
#define MULTIPLAY_TIME_OUT_SEC (10)

@protocol InvitationProtocol
-(void) onAllPlayersReady:(BOOL)didTimeout;
@end

@protocol PlayerControlProtocol
-(void) onUpdatePosition:(CGPoint)position forPlayer:(NSString*)playerId;
-(void) onUpdateTouch:(BOOL)touched position:(CGPoint)position forPlayer:(NSString*)playerId;
@end

@protocol GameCordinatorProtocol
-(void) loadMap:(NSString*)map level:(int)level; // Called when the level should be loaded.
//-(void) showResultScene:(SAllPlayersClearedPacket)player1;
-(void) showMainMenu;
@end

typedef enum GamePlayerFlag {
    GF_SingleInitiator = 0,
    GF_MultiplayInitiator,
    GF_MultiplayInvited
}GamePlayerFlag;

@interface GameState : NSObject<GameKitCommProtocol> 

+(GameState*) sharedGameState;
-(void) invitePlayers;

@property (nonatomic, assign) GamePlayerFlag playerFlag;

@end
