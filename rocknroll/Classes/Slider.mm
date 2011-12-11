//
//  Slider.m
//  Trundle
//
//  Created by Robert Blackwood on 11/13/09.
//  Copyright 2009 Mobile Bros. All rights reserved.
//

#import "Slider.h"
#import "ActionRelayer.h"

@implementation SliderThumb
@synthesize sliderWidth;

-(id) init
{
	return [self initWithTarget:nil selector:nil];
}

-(id) initWithTarget:(id)t selector:(SEL)sel
{
	[super initFromNormalImage:@"sliderthumb.png" selectedImage:@"sliderthumbsel.png" disabledImage:nil target:t selector:sel];
	
	
	return self;
}

-(float) value
{
	return (position_.x+(self.sliderWidth/2))/self.sliderWidth;
}

-(void) setValue:(float)val
{
	self.position = ccp(val*self.sliderWidth-(self.sliderWidth/2), position_.y);
}

@end

@interface SliderTouchLogic : CCMenu
{
	SliderThumb* _thumb;
	BOOL _liveDragging;
}

@property (readwrite, assign) float sliderWidth;
@property (readonly) SliderThumb* thumb;
@property (readwrite, assign) BOOL liveDragging;

-(id) initWithTarget:(id)t selector:(SEL)sel;

@end


@implementation SliderTouchLogic

@synthesize liveDragging = _liveDragging;
@synthesize sliderWidth;

-(id) init
{
	return [self initWithTarget:nil selector:nil];
}

-(id) initWithTarget:(id)t selector:(SEL)sel
{
	[super initWithItems:nil vaList:nil];
	self.position = ccp(0,0);
	
	_liveDragging = NO;
	_thumb = [[[SliderThumb alloc] initWithTarget:t selector:sel] autorelease];
	[self addChild:_thumb];
	
	return self;
}

-(SliderThumb*) thumb
{
	return _thumb;
}

-(BOOL) ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
	if ([super ccTouchBegan:touch withEvent:event])
	{
		[self ccTouchMoved:touch withEvent:event];
		return YES;
	}
	else
		return NO;
}

-(void) ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
	[super ccTouchEnded:touch withEvent:event];
}

-(void) ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
	CGPoint pt = [self convertTouchToNodeSpace:touch];
	
	float x = pt.x;
	
	if (x < -self.sliderWidth/2)
		_thumb.position = ccp(-self.sliderWidth/2, 0);
	else if (x > self.sliderWidth/2)
		_thumb.position = ccp(self.sliderWidth/2, 0);
	else
		_thumb.position = ccp(x, 0);
	
	if (_liveDragging)
		[_thumb activate];
}

@end



@implementation Slider

-(id) initWithActionRelayer:(ActionRelayer*)relayer
{
	[super init];
	
	CCSprite * sliderSprite = [CCSprite spriteWithFile:@"slidergroove.png"];
    
	_touchLogic = [[[SliderTouchLogic alloc] initWithTarget:relayer selector:@selector(relayAction:)] autorelease];
    _relayer = [relayer retain];
    
    float sliderWidth = sliderSprite.contentSize.width;
    _touchLogic.sliderWidth = sliderWidth;
    _touchLogic.thumb.sliderWidth = sliderWidth;
    
	[self addChild:sliderSprite];
	[self addChild:_touchLogic];
	
	return self;
}

-(SliderThumb*) thumb
{
	return _touchLogic.thumb;
}

-(float) value
{
	return self.thumb.value;
}

-(void) setValue:(float)val
{
	[self.thumb setValue:val];
}

-(BOOL) liveDragging
{
	return _touchLogic.liveDragging;
}

-(void) setLiveDragging:(BOOL)live
{
	_touchLogic.liveDragging = live;
}

-(void)dealloc {
    assert(_relayer);
    [_relayer release];
    _relayer = nil;
    
    [super dealloc];
}
@end
