#import <Foundation/Foundation.h>

#import "TouchXML.h"

@interface ClassInfo : NSObject {
    CXMLElement * svgLayer;
}
@property (nonatomic, retain) CXMLElement * svgLayer;

@end

/** @brief The dictionary that has the mapping from a class name to a layer  XML node of an SVG file
 */
@interface ClassDictionary : NSObject {
	NSMutableDictionary * classLayers;
}

- (void) loadClassesFrom:(NSString *)svgFileName;

- (ClassInfo*) getClassByName:(NSString *)className;

@end
