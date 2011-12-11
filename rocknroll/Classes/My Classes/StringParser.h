#ifndef _THX_STRING_PARSER_H_
#define _THX_STRING_PARSER_H_ (1)

#import <Foundation/Foundation.h>
#import "StringParser.h"
#import "CppInfra.h"
#include "TxPropSet.h"
namespace StringParser {
    // For Objective-C
    NSString * trim(NSString * str );

    NSArray * parse(NSString * str, NSString * delim);
    
    NSMutableDictionary * getDictionaryFromKVPair(NSArray * keyValuePairArray);
             
    NSMutableDictionary * getDictionary( NSString * str );


    
    // For C++
    REF(StringVector) parse(const std::string & str, const std::string & delim);
    REF(TxPropSet) getPropSetFromKVPair(REF(StringVector) keyValuePairArray);
    REF(TxPropSet) getPropSet( const std::string & str );
}

#endif