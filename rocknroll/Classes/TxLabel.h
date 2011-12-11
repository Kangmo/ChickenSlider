//
//  TxLabel.h
//  rocknroll
//
//  Created by 김 강모 on 11. 11. 13..
//  Copyright (c) 2011년 강모소프트. All rights reserved.
//

#ifndef rocknroll_TxLabel_h
#define rocknroll_TxLabel_h

#include "TxWidget.h"
#import "PersistentGameState.h"

/*
 stageclear:
 WidgetType=Label,WidgetName=Score01,Font=yellow34.fnt,Align=Left,IsPersistent=YES
 default alignment = Right.

 scoreboard:
 WidgetType=Label,WidgetName=Score01,Font=yellow34.fnt,Align=Left,IsPersistent=YES
 default alignment = Right.

 play :
 WidgetType=Label,WidgetName=SandClockSeconds,Font=white25.fnt,Align=Center
 */
class TxLabel : public TxWidget
{
protected:
    CCLabelBMFont *label_;
public :
    TxLabel(TxWidgetOwner * parentNode, const TxRect & rect, REF(TxPropSet) propSetRef) : TxWidget(rect, propSetRef)
    {
        NSString * fontFileName = getFont();
        label_ = [CCLabelBMFont labelWithString:@"" fntFile:fontFileName];
        
        [label_ retain];
        
        if ( getIsPersistent() )
        {
            NSString * labelText = [[PersistentGameState sharedPersistentGameState] readStringAttr:[Util toNSString:getName()]];
            if (labelText)
            {
                [label_ setString:labelText];
            }
        }
        
        [parentNode addChild:label_];

        TxWidget::align(label_);
        
    }
    
    virtual ~TxLabel()
    {
        assert(label_);
        [label_ release];
        label_ = NULL;
    }
    
    NSString * getFont()
    {
        const std::string & fontName = getPropValue("Font");
        assert(fontName != "");
        return [Util toNSString:fontName];
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

    /** @brief Show message for two seconds gradually enlarging the message 
     */
    void showMessage( NSString * message ) 
    {
        CCLabelBMFont *newLabel = [CCLabelBMFont labelWithString:message fntFile:getFont()];

        [newLabel runAction:[CCScaleTo actionWithDuration:2.0f scale:1.4f]];
        [newLabel runAction:[CCSequence actions:
                          [CCFadeOut actionWithDuration:2.0f],
                          [CCCallFuncND actionWithTarget:newLabel selector:@selector(removeFromParentAndCleanup:) data:(void*)YES],
                          nil]];
        // Get the parent of this label.
        CCNode * parent = [label_ parent];
        [parent addChild:newLabel];        
        TxWidget::align(newLabel);
    }

    CCLabelBMFont * getWidgetImpl() {
        return label_;
    }
};


#endif
