#import <UIKit/UIKit.h>
#include "StringParser.h"

namespace StringParser {
    /** For Objective-C */
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
    
    /** For C++ */
    
    REF(StringVector) parse(const std::string & str, const char * delim)
    {
        REF(StringVector) stringVectorRef = (REF(StringVector)) ( new StringVector() );
        
        boost::char_separator<char> sep(delim);
        boost::tokenizer< boost::char_separator<char> > tokens(str, sep);
        BOOST_FOREACH(std::string t, tokens)
        {
            stringVectorRef->push_back(t);
        }
        return stringVectorRef;
    }
    
    REF(TxPropSet) getPropSetFromKVPair(REF(StringVector) keyValuesPairArray)
    {
        REF(TxPropSet) propSetRef = (REF(TxPropSet))( new TxPropSet() );
        BOOST_FOREACH(std::string & keyValuesPair, *keyValuesPairArray)
        {
            REF(StringVector) keyValuesVectorRef = parse(keyValuesPair, "=");
            assert(keyValuesVectorRef->size() == 2);
            const std::string & key = keyValuesVectorRef->at(0);
            const std::string & values = keyValuesVectorRef->at(1);

            REF(StringVector) valuesVectorRef = parse(values, "|");

            propSetRef->addPropArray( key, valuesVectorRef );
        }
        return propSetRef;
    }
    
    /** @brief Parse AttrA=ValueA1|ValueA2, AttrB=ValueB1 
     */
    REF(TxPropSet) getPropSet( const std::string & str )
    {
        REF(StringVector) keyValuesArrayRef = parse(str, ",");
        REF(TxPropSet) propSetRef = getPropSetFromKVPair(keyValuesArrayRef);
        return propSetRef;
    }
    
    /** For parsing float pairs and putting them into a vector 
     M -170.79104,-37.50073 C -170.79104,-37.50073 -165.73754,-32.39133  */
    BOOL isFloatChar(unichar ch) {
        return ((ch>='0' && ch<='9') || ch == '.' || ch == '-') ? YES : NO;
    }
    
    int eatSpaces(NSString * pointListStr, int pointListStrLen, int index) {
        assert (pointListStr);
        assert (pointListStrLen > 0);
        assert (index >= 0);
        assert (index < pointListStrLen);
        
        if (index >= pointListStrLen)
            return index;
        
        unichar ch; 
        do {
            ch = [pointListStr characterAtIndex:index];
            if (!isFloatChar(ch))
                index ++;
        } while ( (!isFloatChar(ch)) && index < pointListStrLen );
        
        return index;
    }
    
    int parseFloatValue(NSString * pointListStr, int pointListStrLen, int index, CGFloat * floatValue) {
        assert (pointListStr);
        assert (pointListStrLen > 0);
        assert (index >= 0);
        assert (index < pointListStrLen);
        assert (floatValue);
        
        NSMutableString * floatStr = [[[NSMutableString alloc] initWithCapacity:10] autorelease];
        unichar ch; 
        do {
            ch = [pointListStr characterAtIndex:index++];
            if (isFloatChar(ch)) {
                [floatStr appendFormat:@"%c", (char)ch];
            }
        } while ( isFloatChar(ch) && index < pointListStrLen );
        assert( [floatStr length] > 0 );
        *floatValue = [floatStr floatValue];
        
        return index;
    }
    
    /** @brief Return an array containing CGPoint(s)
     */
    REF(PointVector) parsePointList(NSString * pointListStr) {
        int strLen = [pointListStr length];
        REF(PointVector) vec = REF(PointVector)(new PointVector()); 
        for (int i=0; i<strLen; ) {
            CGPoint p;
            i = eatSpaces(pointListStr, strLen, i);
            if (i>=strLen) 
                break;
            
            i = parseFloatValue(pointListStr, strLen, i, &p.x);
            assert(i<strLen);
            i = eatSpaces(pointListStr, strLen, i);
            assert(i<strLen);
            i = parseFloatValue(pointListStr, strLen, i, &p.y);
            assert(i<=strLen);
            
            vec->push_back(p);
        }
        return vec;
    }
}
