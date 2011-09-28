#import <Foundation/Foundation.h>

#include "Box2D.h"

@interface Util : NSObject {
}

+(NSString*) getResourcePath:(NSString*)fileName;
+(NSString*) retrieveResourceFile:(NSString*)fileName fromWeb:(NSString*)urlPrefix;
+(void) setBody:(b2Body*)body withClip:(NSDictionary*)clip;

@end

class b2World;
namespace Helper
{
    void removeAttachedBodyNodes(b2World * world );
}
