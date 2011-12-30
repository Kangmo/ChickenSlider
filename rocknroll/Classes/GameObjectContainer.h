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

 
#include "CppInfra.h"

#include "CollisionDetector2D.h"
#include "GameObject.h"

class GameObjectContainer
{
protected:
    // Don't put REF(GameObject) because rtree.hpp used in CollisionDetector2D is leaking memory.
    CollisionDetector2D< GameObject* > cd;
 
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
    virtual ~GameObjectContainer() {
        // Iterate all game objects, remove it
        box_t allAreaBox = box_t(point_t(-kMAX_POSITION, -kMAX_POSITION), point_t(kMAX_POSITION, kMAX_POSITION));
        removeCollidingObjects(allAreaBox);
    }

    void removeCollidingObjects(const box_t & box) {
        std::deque<GameObject*> v;
        v = getCollidingObjects(box);
        
        for (std::deque<GameObject*>::iterator it = v.begin(); it != v.end(); it++)
        {
            GameObject * refGameObject = *it;
            refGameObject->deactivate();
            refGameObject->removeSelf();
        }
    }
    
    void insert( REF(GameObject) refGameObject )
    {
        assert(refGameObject);
        
        // See http://www.cplusplus.com/reference/stl/set/insert/
        std::pair<GameObjectSet::iterator,bool> ret = gameObjectSet.insert( refGameObject );
        assert(ret.second);// ret.second == true means that a new element is inserted
        
        cd.insertBox( refGameObject->getContentBox(), refGameObject.get());
        
        refGameObject->setContainer(this);
    }

    void remove( REF(GameObject) refGameObject )
    {
        assert(refGameObject);
        gameObjectSet.erase( refGameObject );
        cd.removeBox( refGameObject->getContentBox(), refGameObject.get());
    }
    
    inline std::deque< GameObject* > getCollidingObjects(const box_t & box) const {
        return cd.getCollidingValues(box);
    }
    
    inline const GameObjectSet & gameObjects() {
        return gameObjectSet;
    }
};

#endif
