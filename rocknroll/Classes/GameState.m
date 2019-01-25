//
//  GameState.m
//  rocknroll
//
//  Created by 김 강모 on 12. 1. 11..
//  Copyright (c) 2012년 강모소프트. All rights reserved.
//

#import "GameState.h"

@implementation GameState

@synthesize playerFlag;

static GameState *instanceOfGameState;

#pragma mark Singleton stuff
+(id) alloc
{
	@synchronized(self)	
	{
		NSAssert(instanceOfGameState == nil, @"Attempted to allocate a second instance of the singleton: GameState");
		instanceOfGameState = [[super alloc] retain];
		return instanceOfGameState;
	}
	
	// to avoid compiler warning
	return nil;
}

+(GameState*) sharedGameState
{
	@synchronized(self)
	{
		if (instanceOfGameState == nil)
		{
			[[GameState alloc] init];
		}
		
		return instanceOfGameState;
	}
	
	// to avoid compiler warning
	return nil;
}

// TM16: handles receiving of data, determines packet type and based on that executes certain code
-(void) onReceivedData:(NSData*)data fromPlayer:(NSString*)playerID
{
    /*            
    
	SBasePacket* basePacket = (SBasePacket*)[data bytes];
	CCLOG(@"onReceivedData: %@ fromPlayer: %@ - Packet type: %i", data, playerID, basePacket->type);
	
	switch (basePacket->type)
	{
		case kPacketTypeScore:
		{
			SScorePacket* scorePacket = (SScorePacket*)basePacket;
			CCLOG(@"\tscore = %i", scorePacket->score);
			break;
		}
		case kPacketTypePosition:
		{
			SPositionPacket* positionPacket = (SPositionPacket*)basePacket;
			CCLOG(@"\tposition = (%.1f, %.1f)", positionPacket->position.x, positionPacket->position.y);
			
			// instruct remote players to move their tilemap layer to this position (giving the impression that the player has moved)
			// this is just to show that it's working by "magically" moving the other device's screen/player
			if (playerID != [GKLocalPlayer localPlayer].playerID)
			{
                //                [self sendPosition:ccp(heroX_withoutZoom,heroY_withoutZoom)];
                int mapProgress =  [self getMapProgress:positionPacket->position.x];
                
                [playUI setProgress:mapProgress position:positionPacket->position player:(NSString*)playerID];
                             
                 //CCTMXTiledMap* tileMap = (CCTMXTiledMap*)[self getChildByTag:TileMapNode];
                 //[self centerTileMapOnTileCoord:positionPacket->position tileMap:tileMap];
			}
			break;
		}
		default:
			CCLOG(@"unknown packet type %i", basePacket->type);
			break;
	}
*/
}


+(void) dealloc
{
	CCLOG(@"dealloc %@", self);
	
	[instanceOfGameState release];
	instanceOfGameState = nil;
    
	[super dealloc];
}

@end
