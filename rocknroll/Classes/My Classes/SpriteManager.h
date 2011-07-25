//
//  SpriteManager.h
//  Castlecrush
//
//  Created by skeeet on 11.05.09.
//  Copyright 2009 Munky Interactive/munkyinteractive.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "TouchXML.h"

@interface SpriteInfo : NSObject 
{
	CGRect rect;
	NSString * textureName;
	NSString * name;
}
@property(nonatomic,retain) NSString * textureName;
@property(nonatomic,retain) NSString * name;
@property CGRect rect;
@end




@interface SpriteManager : NSObject 
{
	NSMutableDictionary * spriteDescriptions;
	NSMutableDictionary * managers;
	NSMutableArray * sprites;
	CCNode * attachNode;
	int attachZ;
}


-(id) initWithNode:(CCNode*)node z:(int)zVal;
-(CCSprite*) getSpriteWithName:(NSString*)name;
-(CCSprite*) getSpriteWithName:(NSString*)name fromTexture:(NSString*)texName;
-(CCSprite*) getSpriteWithName:(NSString*)name fromTexture:(NSString*)texName withAnchorPoint:(CGPoint)anchor;
-(void) detachWithCleanup:(BOOL)needCleanup;
-(void) clearSprites;
-(void) parseSvgFile:(NSString*)filename;
-(void) parsePlistFile:(NSString*)filename;

@end
