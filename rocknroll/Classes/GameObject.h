//
//  GameObject.h
//  rocknroll
//
//  Created by 김 강모 on 11. 9. 30..
//  Copyright 2011년 강모소프트. All rights reserved.
//

#ifndef rocknroll_GameObject_h
#define rocknroll_GameObject_h

#include "CppInfra.h"
#import "Cocos2d.h"
#import "CocosDenshion.h"
#import "SimpleAudioEngine.h"
#include "CollisionDetector2D.h"
#include "Util.h"

@class Hero;
class GameObjectContainer;

class GameObject : public boost::enable_shared_from_this<GameObject>
{
protected:
    box_t _contentBox;
    CCSprite * _sprite;
    CCAction * _defaultAction;
    bool _activated;
    
    GameObjectContainer * _container;
    
    public :
    GameObject(float x, float y, float width, float height)
    :_contentBox(point_t(x,y), point_t(x+width, y+height))
    {
        _sprite = NULL;
        _defaultAction = NULL;
        _container = NULL;
        _activated = false;
    };
    
    virtual ~GameObject() {
        if ( _sprite)
        {
            [_sprite release];
            _sprite = NULL;
        }

        if ( _defaultAction)
        {
            [_defaultAction release];
            _defaultAction = NULL;
        }
    };
    
    inline void setContainer( GameObjectContainer * c )
    {
        _container = c;
    }
    
    inline const box_t & getContentBox() {
        return _contentBox;
    }
    
    inline void setSprite( CCSprite * sprite)
    {
        // The sprite can be set only once.
        assert(!_sprite);
        assert(sprite);

        _sprite = [sprite retain];
        // We will use this->x, this->y as the bottom left point of the box.
        // The sprite position will be updated using it, so we set the anchorPoint to an appropriate position.
        _sprite.anchorPoint = CGPointMake(0,0);
    }
    
    inline void setDefaultAction( CCAction * action)
    {
        // The default clip can be set only once.
        assert(!_defaultAction);
        assert(action);

        _defaultAction = [action retain];
    }
    
    inline CCSprite * getSprite()
    {
        return _sprite;
    }
    
    inline CCAction * getDefaultAction()
    {
        return _defaultAction;
    }
    
    inline const CGPoint getPosition()
    {
        float x = _contentBox.min_corner().x();
        float y = _contentBox.min_corner().y();
        CGPoint p = CGPointMake( x, y );
        return p;
    }

    inline bool isActivated() {
        return _activated;
    }
    
    inline bool isPassive() {
        return _sprite == nil ? TRUE : FALSE;
    }
    
    /** @brief Activate the game object in the game layer and run the default animation clip.
     * c.f. This is called when the game object comes in the area that can be shown on screen.
     */
    inline void activate(CCLayer * gameLayer) {
        // 100 : [60-> 60]
        // 200 : [60-> 55]
        // 550 : [38->16], [27-> 60]
        assert(_sprite);
        [gameLayer addChild:_sprite];
        
        if (_defaultAction)
        {
            // 100 : [60->60]
            // 550 : [7->15]
            Helper::runAction( shared_from_this(), _defaultAction );
        }
        
        _activated = true;
    }
    
    inline void deactivate() {
        [_sprite stopAllActions];
        
        [_sprite removeFromParentAndCleanup:YES];
        
        _activated = false;
    }
    
    void removeSelf();
    
    // Called when the GameObject collides with the Hero.
    inline virtual void onCollideWithHero(Hero * pHero) 
    {}
};


#endif
