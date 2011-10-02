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

#endif
