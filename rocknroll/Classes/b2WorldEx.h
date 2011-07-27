//
//  b2WorldEx.h
//  rocknroll
//
//  Created by 강모 김 on 11. 7. 27..
//  Copyright 2011 강모소프트. All rights reserved.
//

#ifndef _B2_WORLD_EX_H_
#define _B2_WORLD_EX_H_ (1)

#include <Box2D/Dynamics/b2World.h>

class b2WorldEx : public b2World 
{
public:    
    /// Construct a world object.
    /// @param gravity the world gravity vector.
    /// @param doSleep improve performance by not simulating inactive bodies.
    b2WorldEx(const b2Vec2& gravity, bool doSleep);
    
    /// Destruct the world. All physics entities are destroyed and all heap memory is released.
    virtual ~b2WorldEx();

    void DrawDebugData(b2Vec2 * cameraPosition);
    b2AABB GetAABBForBody(b2Body * b);
protected:
    void DrawSegmentWithCam(const b2Vec2& p1, const b2Vec2& p2, const b2Color& color, const b2Vec2& cameraPosition);
    
    void DrawJoint(b2Joint* joint, const b2Vec2& cameraPosition);
};


#endif /*_B2_WORLD_EX_H_*/