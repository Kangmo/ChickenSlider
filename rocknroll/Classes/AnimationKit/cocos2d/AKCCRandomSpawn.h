#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface AKCCRandomSpawn : CCActionInterval <NSCopying>
{
    NSArray *spawnItems;
    CCFiniteTimeAction *currentAction;
}

+ (id)actionWithItems:(NSArray*)items;
- (id)initWithItems:(NSArray*)items;

@end
