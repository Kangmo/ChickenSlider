//
//  ClassDictionary.h
//  rocknroll
//
//  Created by 강모 김 on 11. 7. 27..
//  Copyright 2011 강모소프트. All rights reserved.
//

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
