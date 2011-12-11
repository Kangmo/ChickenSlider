//
//  Slider.h
//  Trundle
//
//  Created by Robert Blackwood on 11/13/09.
//  Copyright 2009 Mobile Bros. All rights reserved.
//


#import "cocos2d.h"

/*
  Code copied from here: 
  http://mobile-bros.com/index.php?option=com_content&view=article&id=12:slider-in-cocos2d-iphone&catid=383:category-technical-articles&Itemid=3
 */

@interface SliderThumb : CCMenuItemImage
{
}
@property (readwrite, assign) float value;
@property (readwrite, assign) float sliderWidth;

-(id) initWithTarget:(id)t selector:(SEL)sel;

@end

/* Internal class only */
@class SliderTouchLogic;
@class ActionRelayer;

@interface Slider : CCLayer 
{
	SliderTouchLogic* _touchLogic;
    ActionRelayer * _relayer;
}

@property (readonly) SliderThumb* thumb;
@property (readwrite, assign) float value;
@property (readwrite, assign) BOOL liveDragging;

-(id) initWithActionRelayer:(ActionRelayer*)relayer;

@end


