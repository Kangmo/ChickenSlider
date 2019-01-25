//
//  TxImageSwitch.h
//  rocknroll
//
//  Created by 김 강모 on 11. 11. 13..
//  Copyright (c) 2011년 강모소프트. All rights reserved.
//

#ifndef rocknroll_TxScrollLayer_h
#define rocknroll_TxScrollLayer_h

#include "TxLabel.h"
#import "ActionRelayer.h"
#import "LevelMapScene.h"
#import "CCScrollLayer.h"

/*
 options :
 WidgetType=ScrollLayer,WidgetName=StageScrollLayer,Layers=MAP01_01|MAP01_02,Align=Center,DefaultIndex=0,IsPersistent=YES
 */
class TxScrollLayer : public TxWidget//, ActionRelayListener
{
protected:
//    ActionRelayer * relayer_;
    CCScrollLayer * scrollLayer_;
public :
    TxScrollLayer(TxWidgetOwner * parentNode, const TxRect & rect, REF(TxPropSet) propSetRef) : TxWidget(rect, propSetRef)    
    {
//        relayer_ = [[ActionRelayer actionRelayerWithTarget:parentNode source:this] retain];
        
        REF(StringVector) imageStringVector = getPropArray("Layers");
        NSMutableArray * layersArray = [NSMutableArray arrayWithCapacity:10];
        {
            BOOST_FOREACH(std::string & layerNameCString, *imageStringVector)
            {
                NSString * layerName = [Util toNSString:layerNameCString];
                
                CCLayer * newLayer;
                
                if ( [[layerName substringWithRange:NSMakeRange(0,3)] isEqualToString:@"MAP"] )
                {
                    newLayer = [LevelMapScene nodeWithSceneName:layerName];
                }
                else
                {
                    newLayer = [GeneralScene nodeWithSceneName:layerName];
                }
                
                [layersArray addObject:newLayer];
            }
        }
        float offsetWidthRatio = getFloatPropValue("OffsetWidthRatio", 1);
        float contentWidthRatio = getFloatPropValue("ContentWidthRatio", 1);
        float contentHeightRatio = getFloatPropValue("ContentHeightRatio", 1);

        
        scrollLayer_ = [[CCScrollLayer nodeWithLayers:layersArray widthOffset:rect.size.width * offsetWidthRatio] retain];
		scrollLayer_.minimumTouchLengthToSlide = 15.0f;
		scrollLayer_.minimumTouchLengthToChangePage = 25.0f;
        
        scrollLayer_.contentSize = CGSizeMake(rect.size.width * contentWidthRatio, rect.size.height * contentHeightRatio);

        [scrollLayer_ updatePages];
        
        
/*        
        CGSize screenSize = [CCDirector sharedDirector].winSize;
        
        // PAGE 1 - Simple Label in the center.
        CCLayer *pageOne = [CCLayer node];
        CCLabelTTF *label = [CCLabelTTF labelWithString:@"Page 1" fontName:@"Arial Rounded MT Bold" fontSize:44];
        label.position =  ccp( screenSize.width /2 , screenSize.height/2 );
        [pageOne addChild:label];
        
        // PAGE 2 - Custom Font Menu in the center.
        CCLayer *pageTwo = [CCLayer node];
        CCLabelTTF *labelTwo = [CCLabelTTF labelWithString:@"Add Page!" fontName:@"Marker Felt" fontSize:44];		
        CCMenuItemLabel *titem = [CCMenuItemLabel itemWithLabel:labelTwo target:nil selector:nil];
        CCLabelTTF *labelTwo2 = [CCLabelTTF labelWithString:@"Remove Page!" fontName:@"Marker Felt" fontSize:44];		
        CCMenuItemLabel *titem2 = [CCMenuItemLabel itemWithLabel:labelTwo2 target:nil selector:nil];
        CCLabelTTF *labelTwo3 = [CCLabelTTF labelWithString:@"Change dots color!" fontName:@"Marker Felt" fontSize:40];		
        CCMenuItemLabel *titem3 = [CCMenuItemLabel itemWithLabel:labelTwo3 target:nil selector:nil];
        CCMenu *menu = [CCMenu menuWithItems: titem, titem2, titem3, nil];
        [menu alignItemsVertically];
        menu.position = ccp(screenSize.width/2, screenSize.height/2);
        [pageTwo addCh-[ild:menu];	
        scrollLayer_ = [CCScrollLayer nodeWithLayers:[NSArray arrayWithObjects: pageOne,pageTwo,nil] widthOffset:screenSize.width *0.48];
 */
        
        [parentNode addChild:scrollLayer_];
        
        // BUGBUG : Align of TxScrollLayer does not work.
        //TxWidget::align(scrollLayer_);
        
        
        /*
        int defaultIndex = -1;
        if (getIsPersistent()) {
            // The default value is -1 : Don't show any image if the persistent attribute does not exist.
            defaultIndex = [Util loadIntAttr:[Util toNSString:getName()] default:-1];
            
            relayer_.actionRelayListener = this;
        }
        
        if (defaultIndex == -1)
        {
            NSString * defaultIndexString = getPropNSString("DefaultIndex");
            if (defaultIndexString)
                defaultIndex = [defaultIndexString intValue];
        }

        setValue(defaultIndex);
         */
    }
    
    virtual ~TxScrollLayer()
    {
        assert(scrollLayer_);
        [scrollLayer_ release];
        scrollLayer_ = NULL;
/*        
        assert(relayer_);
        [relayer_ release];
        relayer_ = NULL;
*/
    }
    
    virtual CCNode * getNode() {
        return scrollLayer_;
    }
/*
    // Implements ActionRelayListener. 
    // Called whenever ActionRelayer relays touch messages to the toggle button to CCLayer that has the CCMenu
    virtual void onActionRelay() {
         // The default value is -1 : Don't show any image if the persistent attribute does not exist.
         int imageIndex = getValue();
         
         [Util saveIntAttr:[Util toNSString:getName()] value:imageIndex];
    }

    int getValue()
    {
        if ( toggleButton_.visible )
        {
            return toggleButton_.selectedIndex;
        }
        // If the toggle button is invisible, return false.
        return -1;
    }
    
    int getImageCount()
    {
        int count = [[toggleButton_ subItems] count];
        return count;
    }
    void disable() {
        menu_.isTouchEnabled= NO;
    }
    void setValue(int value)
    {
#if defined(DEBUG)
        int maxValue = getImageCount();
        assert( value < maxValue );
#endif
        if ( value < 0 )
        {
            toggleButton_.visible = NO;
        }
        else
        {
            toggleButton_.visible = YES;
            toggleButton_.selectedIndex = value;
        }
    }
 */  

};

#endif
