//
//  Util.h
//  rocknroll
//
//  Created by 강모 김 on 11. 7. 21..
//  Copyright 2011 강모소프트. All rights reserved.
//

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
