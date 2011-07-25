//
//  Car.cpp
//  rocknroll
//
//  Created by 강모 김 on 11. 7. 25..
//  Copyright 2011 강모소프트. All rights reserved.
//

#include "Car.h"

/** @brief Set the speed of the wheel in radians per second 
 */
void Car::setWheelSpeed(float32 radiansPerSec) {
    assert(body_);
    // For each joint, 
    for (b2JointEdge *jointEdge = body_->GetJointList();
         jointEdge;
         jointEdge = jointEdge->next )
    {
        if (jointEdge->joint->GetType() == e_revoluteJoint)
        {
            b2RevoluteJoint * revoluteJoint = (b2RevoluteJoint*)jointEdge->joint;
            assert( revoluteJoint->IsMotorEnabled() );
            revoluteJoint->SetMotorSpeed(radiansPerSec);
        }
    }
}
