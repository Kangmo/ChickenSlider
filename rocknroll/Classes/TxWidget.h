//
//  TxWidget.h
//  rocknroll
//
//  Created by 김 강모 on 11. 11. 13..
//  Copyright (c) 2011년 강모소프트. All rights reserved.
//

#ifndef rocknroll_TxWidget_h
#define rocknroll_TxWidget_h

#import "Util.h"

typedef struct TxPoint {
    float x;
    float y;
} TxPoint;

typedef struct TxSize {
    float width;
    float height;
} TxSize;

typedef struct TxRect {
    CGPoint origin; // The bottom left point
    CGSize size;
} TxRect;

inline TxRect
TxRectMake(float x, float y, float width, float height)
{
    TxRect rect;
    rect.origin.x = x; rect.origin.y = y;
    rect.size.width = width; rect.size.height = height;
    return rect;
}

class TxWidget;

@protocol TxWidgetListener 
-(void)onWidgetAction:(TxWidget*)sender;
@end


#define TxWidgetOwner CCLayer<TxWidgetListener>


#include "TxPropSet.h"
class TxWidget
{
protected:
    /** @brief The location and size of the widget described in the svg file */
    TxRect    rect_;
    /** @brief The Attr=Value list in the objectDesc attribute in the svg file */
    REF(TxPropSet) propSetRef_;

    const std::string & getPropValue(const std::string & propName)
    {
        return propSetRef_->getPropString(propName);
    }
    
    REF(StringVector) getPropArray(const std::string & propName)
    {
        return propSetRef_->getPropArray(propName);
    }
    
    NSString * getPropNSString(const char * propName)
    {
        const std::string & propValue = getPropValue(propName);
        // If the propName does not exist, @"" is returned.
        return [Util toNSString:propValue];
    }
    float getFloatPropValue(const char * propName, float defaultValue)
    {
        NSString * propValueString = getPropNSString(propName);
        
        float floatValue = defaultValue;
        if(propValueString) {
            floatValue = [propValueString floatValue];
            
            if ( floatValue == 0.0 )
            {
                assert( [propValueString isEqualToString:@""] || 
                       [propValueString isEqualToString:@"0"] || 
                       [propValueString isEqualToString:@"0.0"] );
            }
        }
        return floatValue;
    }
    int getIntPropValue(const char * propName, int defaultValue)
    {
        NSString * propValueString = getPropNSString(propName);
        int intValue = defaultValue;
        
        if ( propValueString ) {
            intValue = [propValueString intValue];
            if ( intValue == 0 )
            {
                assert( [propValueString isEqualToString:@""] || 
                       [propValueString isEqualToString:@"0"] );
            }
        }

        return intValue;
    }

    const BOOL getIsPersistent()
    {
        const std::string & isPersistent = getPropValue("IsPersistent");
        
        if ( isPersistent == "YES" || isPersistent == "Yes" || isPersistent == "yes" || 
            isPersistent == "TRUE" || isPersistent == "True" || isPersistent == "true" )
        {
            return YES;
        }
        return NO;
    }

public :
    TxWidget(const TxRect & rect, REF(TxPropSet) propSetRef) : rect_(rect), propSetRef_(propSetRef)
    {
    }
    virtual ~TxWidget()
    {
    }

    const std::string & getName()
    {
        return getPropValue("WidgetName");
    }

    /** @brief Align the CCNode owned by an TxWidget based on the "Align" property */
    void align(CCNode * node)
    {
        std::string align = propSetRef_->getPropString("Align");
        if (align == "Center")
        {
            node.anchorPoint = ccp( 0.5, 0.5 );
            node.position = CGPointMake( rect_.origin.x + rect_.size.width * 0.5,
                                        rect_.origin.y + rect_.size.height * 0.5 );
        }
        else if (align == "Left")
        {
            node.anchorPoint = ccp( 0, 0.5 );
            node.position = CGPointMake( rect_.origin.x,
                                        rect_.origin.y + rect_.size.height * 0.5 );
        }
        // Default is right.
        else if (align == "Right" || align == "")
        {
            node.anchorPoint = ccp( 1, 0.5 );
            node.position = CGPointMake( rect_.origin.x + rect_.size.width,
                                        rect_.origin.y + rect_.size.height * 0.5 );
        }
        else
        {
            // Should never come here.
            assert(0);
        }
        
        int AdShiftY = getIntPropValue("AdShiftY", 0);
        // AdShiftY is either -1 or 1. For Ad banners on top, we use AdShiftY==-1 to move widgets down by LANDSCAPE_AD_HEIGHT;
        if (AdShiftY) {
            node.position = CGPointMake( node.position.x, node.position.y + [Util getAdHeight] * AdShiftY);
        }
    }
};

#endif
