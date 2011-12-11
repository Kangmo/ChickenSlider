//
//  TxLabel.h
//  rocknroll
//
//  Created by 김 강모 on 11. 11. 13..
//  Copyright (c) 2011년 강모소프트. All rights reserved.
//

#ifndef rocknroll_TxAnimationClip_h
#define rocknroll_TxAnimationClip_h

#include "TxWidget.h"
#import "PersistentGameState.h"

class TxAnimationClip : public TxWidget
{
protected:
    CCAction *clipAction_;
    CCSprite *sprite_;
public :
    TxAnimationClip(TxWidgetOwner * parentNode, const TxRect & rect, REF(TxPropSet) propSetRef) : TxWidget(rect, propSetRef)
    {
        NSString * amimClipFile = getPropNSString("ClipFile");
        assert(amimClipFile);
        NSString * initFrameAnim = getPropNSString("InitFrameAnimation");
        assert(initFrameAnim);
        
        sprite_ = nil;
        clipAction_ = nil;
        
        Helper::getSpriteAndAction(amimClipFile, initFrameAnim, &sprite_, &clipAction_);
        assert(sprite_);
        assert(clipAction_);
        [sprite_ retain];
        [clipAction_ retain];
        
        [parentNode addChild:sprite_];

        TxWidget::align(sprite_);
        
        Helper::runAction(sprite_, clipAction_);
    }
    virtual ~TxAnimationClip()
    {
        assert(sprite_);
        [sprite_ release];
        sprite_ = NULL;
        
        assert(clipAction_);
        [clipAction_ release];
        clipAction_ = NULL;
    }
};


#endif
