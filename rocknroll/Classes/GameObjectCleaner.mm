//
//  GameObjectCleaner.m
//  rocknroll
//
//  Created by 김 강모 on 11. 11. 2..
//  Copyright 2011년 강모소프트. All rights reserved.
//

#import "GameObjectCleaner.h"
#import "GameObject.h"

@implementation GameObjectCleaner
/** @brief destroy the object 
 */
-(void)destroyObject:(id)sender data:(void*)gameObjectPointer 
{
    CCLOG(@"destroyObject:%p", gameObjectPointer);
    
    GameObject * gameObject = (GameObject*)gameObjectPointer;
    
    // For the collided objects, remove them
    CCSprite * sprite = gameObject->getSprite();
    assert(sprite);
    
    [sprite removeFromParentAndCleanup:YES];
    
    gameObject->removeSelf();
    
    CCLOG(@"destroyObject:end");
    
    [self release];
}
@end