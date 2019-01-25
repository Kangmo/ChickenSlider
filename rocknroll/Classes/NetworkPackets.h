/*
 *  NetworkPackets.h
 *  Tilemap
 *
 *  Created by Steffen Itterheim on 22.01.11.
 */

// TM16: note that all changes made to this send/receive example are prefixed with a // TM16: comment, to make the changes easier to find.

// Defines individual types of messages that can be sent over the network. One type per packet.
typedef enum
{
	kPacketTypeGetReady = 1,        // Inviter sends to invitees to get ready
	kPacketTypeReadyToPlay,     // Invitee sends to inviter when he is ready
	kPacketTypeAllPlayersReady, // Inviter sends to invitees when all players are ready.
	kPacketTypePosition,        // All players broadcast its position periodically.
	kPacketTypeTouchEvent,      // All players broadcast its touch event whenever the touch state changes
	kPacketTypeAllPlayersCleared,       // Inviter sends to invitees when all players cleared stages.
} EPacketTypes;

// Note: EPacketType type; must always be the first entry of every Packet struct
// The receiver will first assume the received data to be of type SBasePacket, so it can identify the actual packet by type.
typedef struct
{
	EPacketTypes type;
} SBasePacket;

typedef struct
{
	EPacketTypes type;
} SGetReadyPacket;

typedef struct
{
	EPacketTypes type;
} SReadyToPlayPacket;

typedef struct
{
	EPacketTypes type;
} SAllPlayersReadyPacket;


#define MAX_PLAYER_ID_LEN (256)
#define MAX_PLAYERS (4)

typedef struct PlayerResult {
    char playerId[MAX_PLAYER_ID_LEN]; // from GameKit player ID
    float timeSpentSec;
}PlayerResult;

// the packet for transmitting a score variable
typedef struct
{
	EPacketTypes type;
	int playerCount; // the number of players
	PlayerResult result[MAX_PLAYERS]; // the player result ordered by rank
} SAllPlayersClearedPacket;

// packet to transmit a position
typedef struct
{
	EPacketTypes type;
	
	CGPoint position;
} SPositionPacket;

// packet to transmit a touch event happens
typedef struct
{
	EPacketTypes type;
	
	CGPoint position;
    BOOL    touched; // YES if untouched->touched  NO if touched->untouched
} STouchEventPacket;

// TODO for you: add more packets as needed. 

/*
 Note that Packets can contain several variables at once. So if you have a bunch of variables
 that you always send out together, put them in a single packet.
 
 But generally try to only send data when you really need to send it, to conserve bandwidth.
 For example, the position information in this example is only sent when the player position actually changed.
*/