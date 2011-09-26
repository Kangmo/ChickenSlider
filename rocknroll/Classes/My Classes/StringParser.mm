#import <UIKit/UIKit.h>
#include "StringParser.h"

namespace StringParser {
    NSString * trim(NSString * str )
    {
        NSString *trimmed =
        [str stringByTrimmingCharactersInSet:
         [NSCharacterSet whitespaceAndNewlineCharacterSet]];
        return trimmed;
    }
    
    NSArray * parse(NSString * str, NSString * delim)
    {
        // "a,b" becomes NSArry["a", "b"] if delim were ","
        NSArray * tokenArray = [str componentsSeparatedByString:delim];
        return tokenArray;
    }
    
    NSMutableDictionary * getDictionaryFromKVPair(NSArray * keyValuePairArray)
    {
        NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithCapacity:1];
        for(NSString* keyValueStr in keyValuePairArray)
        {
            NSArray * keyValue = [keyValueStr componentsSeparatedByString:@"="];
            
            NSString * key = trim( [keyValue objectAtIndex:0] );
            NSString * value = trim( [keyValue objectAtIndex:1] );
            
            [dict setValue:value forKey:key];
        }
        return dict;
    }
    
    NSMutableDictionary * getDictionary( NSString * str )
    {
        NSArray * keyValueArray = parse(str, @",");
        NSMutableDictionary * dic = getDictionaryFromKVPair(keyValueArray);
        return dic;
    }
    
}
