#ifndef GLES_RENDER_H
#define GLES_RENDER_H

#import <Availability.h>

#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
#import <OpenGLES/EAGL.h>
#elif defined(__MAC_OS_X_VERSION_MAX_ALLOWED)
#import <OpenGL/OpenGL.h>
#endif

#include "Box2D.h"

struct b2AABB;

// This class implements debug drawing callbacks that are invoked
// inside b2World::Step.
class GLESDebugDraw : public b2Draw
{
public:
	float32 mRatio;
    
	GLESDebugDraw();

	GLESDebugDraw( float32 ratio );

	void DrawPolygon(const b2Vec2* vertices, int32 vertexCount, const b2Color& color);

	void DrawSolidPolygon(const b2Vec2* vertices, int32 vertexCount, const b2Color& color);

	void DrawCircle(const b2Vec2& center, float32 radius, const b2Color& color);

	void DrawSolidCircle(const b2Vec2& center, float32 radius, const b2Vec2& axis, const b2Color& color);

	void DrawSegment(const b2Vec2& p1, const b2Vec2& p2, const b2Color& color);

	void DrawTransform(const b2Transform& xf);

    void DrawPoint(const b2Vec2& p, float32 size, const b2Color& color);

    void DrawString(int x, int y, const char* string, ...); 

    void DrawAABB(b2AABB* aabb, const b2Color& color);
};


#endif // GLES_RENDER_H
