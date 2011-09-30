//
//  GameObjectContainer.h
//  rocknroll
//
//  Created by 김 강모 on 11. 9. 28..
//  Copyright 2011년 강모소프트. All rights reserved.
//

#ifndef rocknroll_GameObjectContainer_h
#define rocknroll_GameObjectContainer_h

#include <Foundation/Foundation.h>
#include <iostream>
#include <set>
#import "Cocos2d.h"
#import "CocosDenshion.h"
#import "SimpleAudioEngine.h"
#include "CppInfra.h"

/*
 
 /Users/kmkim/Games/refs//boost_trunk/boost/geometry/extensions/index/rtree/rtree.hpp
 /Users/kmkim/Games/refs//boost_trunk/boost/geometry/extensions/index/rtree/rtree_leaf.hpp
 /Users/kmkim/Games/refs//boost_trunk/boost/geometry/extensions/index/rtree/rtree_node.hpp
 */
#include <boost/geometry.hpp>
#include <boost/geometry/extensions/index/rtree/rtree.hpp>

typedef boost::geometry::model::d2::point_xy<float> point_t;
//const size_t dimension = 2;
//typedef boost::geometry::cs::cartesian coordinate_system_type;
//typedef boost::geometry::model::point<coordinate_type, dimension, coordinate_system_type> point;
typedef boost::geometry::model::box<point_t> box_t;


template<typename Value> 
class CollisionDetector2D
{
    public :    
    typedef typename boost::geometry::index::rtree<box_t, Value> rtree_t;
    
#define MAX_ITEMS_PER_NODE (16)
#define MIN_ITEMS_PER_NODE (4)
    CollisionDetector2D() : rtree(MAX_ITEMS_PER_NODE, MIN_ITEMS_PER_NODE)
    {
    }
    
    inline void insertBox(const box_t & box, Value value) {
        rtree.insert(box, value);
    }

    inline void removeBox(const box_t & box, Value value) {
        rtree.remove(box, value);
    }
    
    inline std::deque<Value> getCollidingValues(const box_t & box) const {
        return rtree.find(box);
    }
private:
    rtree_t rtree;
};

class GameObjectContainer;

class GameObject : public boost::enable_shared_from_this<GameObject>
{
protected:
    box_t _contentBox;
    CCSprite * _sprite;
    NSDictionary * _defaultClip;
    
    GameObjectContainer * _container;

public :
    GameObject(float x, float y, float width, float height)
    :_contentBox(point_t(x,y), point_t(x+width, y+height))
    {
        _sprite = NULL;
        _defaultClip = NULL;
        _container = NULL;
    };
    
    virtual ~GameObject() {};

    inline void setContainer( GameObjectContainer * c )
    {
        _container = c;
    }

    inline const box_t & getContentBox() {
        return _contentBox;
    }
    
    inline void setSprite( CCSprite * sprite)
    {
        _sprite = sprite;
    }

    inline void setDefaultClip( NSDictionary * clip)
    {
        _defaultClip = clip;
    }
    
    inline CCSprite * getSprite()
    {
        return _sprite;
    }
    
    inline NSDictionary * getDefaultClip()
    {
        return _defaultClip;
    }
    
    inline const CGPoint getPosition()
    {
        float x = _contentBox.min_corner().x();
        float y = _contentBox.min_corner().y();
        CGPoint p = CGPointMake( x, y );
        return p;
    }
  
    // Called when the GameObject collides with the Hero.
    inline virtual void onCollideWithHero() 
    {}
};


class GameObjectContainer
{
protected:
    
    CollisionDetector2D< REF(GameObject) > cd;
 
public :
    struct ltGameObject
    {
        bool operator()(REF(GameObject) o1, REF(GameObject) o2) const
        {
            return o1.get() < o2.get();
        }
    };

    typedef std::set< REF(GameObject),ltGameObject> GameObjectSet;
    
    GameObjectSet gameObjectSet;
public :
    GameObjectContainer() {}
    ~GameObjectContainer() {}
    
    void insert( REF(GameObject) refGameObject )
    {
        assert(refGameObject);
        
        // See http://www.cplusplus.com/reference/stl/set/insert/
        std::pair<GameObjectSet::iterator,bool> ret = gameObjectSet.insert( refGameObject );
        assert(ret.second);// ret.second == true means that a new element is inserted
        
        cd.insertBox( refGameObject->getContentBox(), refGameObject);
        
        refGameObject->setContainer(this);
    }

    void remove( REF(GameObject) refGameObject )
    {
        assert(refGameObject);
        gameObjectSet.erase( refGameObject );
        cd.removeBox( refGameObject->getContentBox(), refGameObject);
    }
    
    inline std::deque< REF(GameObject) > getCollidingObjects(const box_t & box) const {
        return cd.getCollidingValues(box);
    }
    
    inline const GameObjectSet & gameObjects() {
        return gameObjectSet;
    }
};


class WaterDrop : public GameObject
{
private:
    CDSoundSource * _collideSound;
public:
    WaterDrop(float x, float y, float width, float height)
    :GameObject(x,y,width,height)
    {
        _collideSound = [[[SimpleAudioEngine sharedEngine] soundSourceForFile:@"WaterDrop.wav"] retain];
    };
    virtual ~WaterDrop()
    {
        [_collideSound release];
    }
    inline virtual void onCollideWithHero() 
    {
        // For the collided objects, remove them
        CCSprite * sprite = this->getSprite();
        
        [sprite removeFromParentAndCleanup:YES];
        
        //BUGBUG : Understand what happens if this objet is destroyed while the sound was playing
        [_collideSound play];
        
        assert(_container);
        
        //_container->remove( refMe );
        _container->remove( shared_from_this() );
        /*            
         // node2: the node that will be removed
         id action = [CCSequence actions:
         [CCMoveBy actionWithDuration:2 position:ccp(200,0)],
         [CCCallFuncND actionWithTarget:node2 selector:@selector(removeFromParentAndCleanup:) data:(void*)YES],
         nil];
         
         // node1: the node that runs the action
         [node1 runAction:action];
         */          
    }
};

#endif
