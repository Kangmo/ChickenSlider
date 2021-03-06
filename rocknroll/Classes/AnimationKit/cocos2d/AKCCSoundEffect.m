#import "AKCCSoundEffect.h"
#import "SimpleAudioEngine.h"
#import "ClipFactory.h"

@implementation AKCCSoundEffect

+ (id)actionWithEffectName:(NSString*)name
{
    return [[[self alloc] initWithEffectName:name] autorelease];
}

- (id)initWithEffectName:(NSString*)name
{
    effectName = [NSString stringWithString:name];
    [effectName retain];
    
    effect = [[ClipFactory sharedFactory] soundByFile:effectName];
    [effect retain];
    
    if (effect && (self = [super initWithDuration:effect.durationInSeconds])) {
        [effectName retain];
        [effect retain];
    }
    return self;
}

- (void)dealloc 
{
    [effectName release];
    [effect release];
    [super dealloc];
}

- (id)copyWithZone: (NSZone*)zone
{
	CCAction *copy = [[[self class] allocWithZone: zone] initWithEffectName:effectName];
	return copy;
}

- (CCActionInterval *) reverse
{
	return [[self class] actionWithEffectName:effectName];
}

-(void) startWithTarget:(id)aTarget
{
    [effect play];
}

- (void)stop
{
    [effect stop];
}

-(void) update: (ccTime) t
{
    
}

@end
