//
//  StringParser.h
//  rocknroll
//
//  Created by 강모 김 on 11. 7. 21..
//  Copyright 2011 강모소프트. All rights reserved.
//



#ifndef _THX_STRING_PARSER_H_
#define _THX_STRING_PARSER_H_ (1)

#import <Foundation/Foundation.h>
#import "StringParser.h"

namespace StringParser {
    NSString * trim(NSString * str );

    NSArray * parse(NSString * str, NSString * delim);
    
    NSMutableDictionary * getDictionaryFromKVPair(NSArray * keyValuePairArray);
             
    NSMutableDictionary * getDictionary( NSString * str );
}

#endif