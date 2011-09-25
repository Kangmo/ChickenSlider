#ifndef _THX_POINT_QUEUE_H_
#define _THX_POINT_QUEUE_H_ (1)

#include "Box2D.h"

/** @brief The maximum number of points that the PointQueue keeps. */
#define MAX_POINTS (2)

/** @brief The maximum position for X or Y axis for a valid point.
 */
const float32 kMAX_POSITION=9999999.0f;

/** @brief A fixed size circular point queue containing points. We use this class for calculating the position to show on the bottom of the screen when the Hero flies, the points are added whenever the Hero hits the ground.  
 */
class PointQueue
{
public : 
    PointQueue() { clear(); }
    ~PointQueue() {}
    void clear();
    void addPoint(const b2Vec2 & point);
    float32 getAverageY();
    const b2Vec2 & getLastPoint();

protected : 
    static void invalidate(b2Vec2 & point);
    static bool isValid(const b2Vec2 & point);

    /** @brief Contains the added points. Invalid points are invalidated by the invalidate() member function.
     */
    b2Vec2 points[MAX_POINTS];
    /** @brief The index to the points for the one that was lastly added.
     */
    int lastPointIndex;
};

extern PointQueue theGroundPoints;

#endif /* _THX_POINT_QUEUE_H_ */