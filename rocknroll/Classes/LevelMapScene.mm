//
//  LevelMapScene.m
//  rocknroll
//
//  Created by 김 강모 on 11. 10. 3..
//  Copyright 2011년 강모소프트. All rights reserved.
//

#import "LevelMapScene.h"

@implementation LevelMapScene

// initialize your instance here
-(id) initWithSceneName:(NSString*)sceneName
{
    self = [super initWithSceneName:sceneName];
    if (self) {
        // Initialization code here.
        levelCount = 0;
    }
    
    return self;
}

+(id)nodeWithSceneName:(NSString*)sceneName
{
    return [[[LevelMapScene alloc] initWithSceneName:sceneName] autorelease];
}

+(CCScene*)sceneWithName:(NSString*)sceneName
{
    // 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	GeneralScene *layer = [LevelMapScene nodeWithSceneName:sceneName];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

- (void) locateLevelObjects {
    for(id child in self.children)
    {
        if([child isKindOfClass:[InteractiveSprite class]])
        {
            InteractiveSprite * intrSprite = (InteractiveSprite*) child;
            
            NSString * sceneName = [intrSprite.touchActionDescs valueForKey:@"SceneName"];
            assert(sceneName);
                
            if ( [sceneName isEqualToString:@"StageScene"] )
            {
                // The string uniquly identifying level of stage.  
                NSString * levelNumAttr = [intrSprite.touchActionDescs valueForKey:@"Arg2"];
                assert(levelNumAttr);
                
                int levelNum = [levelNumAttr intValue];
                assert(levelNum>0);
                assert(levelNum<MAX_LEVELS_PER_MAP);
                
                intrSprites[levelCount] = intrSprite;
            }
        }
    }
}

@end
