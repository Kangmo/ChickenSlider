#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "CocosDenshion.h"

@interface AKCCSoundEffect : CCActionInterval <NSCopying> {
    NSString *effectName;
    CDSoundSource *effect;
}

+ (id)actionWithEffectName:(NSString*)name;
- (id)initWithEffectName:(NSString*)name;

@end
