#ifndef _THX_CAR_H_
#define _THX_CAR_H_ (1)

#include "Box2D.h"

class Car
{
public :    
    Car( b2Body *body )
    {
        body_ = body;
    }
    ~Car()
    {
    }
    
    b2Body * getBody() {
        return body_;
    }
    
    void setWheelSpeed(float32 radiansPerSec);

private:
    b2Body * body_;
    
};

#endif /* _THX_CAR_H_ */