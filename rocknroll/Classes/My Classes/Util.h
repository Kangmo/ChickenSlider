#import <Foundation/Foundation.h>


@interface Util : NSObject {
}

+(NSString*) getResourcePath:(NSString*)fileName;
+(NSString*) retrieveResourceFile:(NSString*)fileName fromWeb:(NSString*)urlPrefix;

@end

class b2World;
namespace Helper
{
    void removeAttachedBodyNodes(b2World * world );
}
