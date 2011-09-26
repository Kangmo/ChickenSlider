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