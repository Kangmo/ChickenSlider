//
//  CollisionDetector2D.h
//  rocknroll
//
//  Created by 김 강모 on 11. 9. 30..
//  Copyright 2011년 강모소프트. All rights reserved.
//

#ifndef rocknroll_CollisionDetector2D_h
#define rocknroll_CollisionDetector2D_h


/*
 
 /Users/kmkim/Games/refs//boost_trunk/boost/geometry/extensions/index/rtree/rtree.hpp
 /Users/kmkim/Games/refs//boost_trunk/boost/geometry/extensions/index/rtree/rtree_leaf.hpp
 /Users/kmkim/Games/refs//boost_trunk/boost/geometry/extensions/index/rtree/rtree_node.hpp
 */
#include "CppInfra.h"

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

#endif
