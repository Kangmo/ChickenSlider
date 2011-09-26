#include "PointQueue.h"

/** @brief Invalidate a point.
 */
void PointQueue::invalidate(b2Vec2 & point)
{
    point.x = kMAX_POSITION;
    point.y = kMAX_POSITION;
}
/** @brief Check if a point has a valid value.
 */
bool PointQueue::isValid(const b2Vec2 & point)
{
    if (point.x == kMAX_POSITION && point.y == kMAX_POSITION)
    {
        return false;
    }
    return true;
}
/** @brief Clear the added points.
 */
void PointQueue::clear() 
{
    // This class assumes that we have at least two elements in the points array.
    assert( MAX_POINTS >= 2 );
    
    for (int i=0; i<MAX_POINTS; i++ )
    {
        invalidate( points[i] );
    }
    
    lastPointIndex = -1;
}

/** @brief Add a point.
 */
void PointQueue::addPoint(const b2Vec2 & point)
{
    assert( point.x < kMAX_POSITION );
    assert( point.y < kMAX_POSITION );

    // Move the index to the next position to add a point.
    if ( ++ lastPointIndex ==  MAX_POINTS )
    {
        lastPointIndex = 0;
    }
    assert( lastPointIndex < MAX_POINTS );
    
    points[lastPointIndex] = point;
}

/** @brief Get the point that was added lastly.
 */
const b2Vec2 & PointQueue::getLastPoint()
{
    if ( lastPointIndex >= 0 ) 
    {
        assert( lastPointIndex < MAX_POINTS );
        return points[lastPointIndex];
    }
    
    return b2Vec2(kMAX_POSITION, kMAX_POSITION);
}

/** @brief The the average Y value of all valid point. Returns kMAX_POSITION if there is no valid point.
 */
float32 PointQueue::getAverageY()
{
    float32 sumOfValidY=0;
    int validPointCount = 0;
    
    for (int i=0; i<MAX_POINTS; i++ )
    {
        if ( isValid(points[i] ) )
        {
            validPointCount++;
            sumOfValidY += points[i].y;
        }
    }
    
    if ( validPointCount == 0 )
        return kMAX_POSITION;
    
    // Assuming that the division by constant value is faster, we do a little bit of optimization here trying to divide the sum by constant value if possible.
    return (validPointCount == MAX_POINTS) ? (sumOfValidY / MAX_POINTS) : (sumOfValidY / validPointCount);
}
