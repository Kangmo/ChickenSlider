#include "b2WorldEx.h"
#include "Box2D.h"

/// Construct a world object.
/// @param gravity the world gravity vector.
/// @param doSleep improve performance by not simulating inactive bodies.
b2WorldEx::b2WorldEx(const b2Vec2& gravity) : b2World(gravity)
{
}

/// Destruct the world. All physics entities are destroyed and all heap memory is released.
b2WorldEx::~b2WorldEx()
{
}

void b2WorldEx::DrawDebugData(b2Vec2 * cameraPosition)
{
	if (m_debugDraw == NULL)
	{
		return;
	}
    
	uint32 flags = m_debugDraw->GetFlags();
    
	if (flags & b2Draw::e_shapeBit)
	{
		for (b2Body* b = m_bodyList; b; b = b->GetNext())
		{
			b2Transform xf = b->GetTransform();
            xf.p.x += cameraPosition->x;
            xf.p.y += cameraPosition->y;
			for (b2Fixture* f = b->GetFixtureList(); f; f = f->GetNext())
			{
				if (b->IsActive() == false)
				{
					DrawShape(f, xf, b2Color(0.5f, 0.5f, 0.3f));
				}
				else if (b->GetType() == b2_staticBody)
				{
					DrawShape(f, xf, b2Color(0.5f, 0.9f, 0.5f));
				}
				else if (b->GetType() == b2_kinematicBody)
				{
					DrawShape(f, xf, b2Color(0.5f, 0.5f, 0.9f));
				}
				else if (b->IsAwake() == false)
				{
					DrawShape(f, xf, b2Color(0.6f, 0.6f, 0.6f));
				}
				else
				{
					DrawShape(f, xf, b2Color(0.9f, 0.7f, 0.7f));
				}
			}
		}
	}
    
	if (flags & b2Draw::e_jointBit)
	{
		for (b2Joint* j = m_jointList; j; j = j->GetNext())
		{
			DrawJoint(j, b2Vec2(cameraPosition->x,cameraPosition->y));
		}
	}
    
	if (flags & b2Draw::e_pairBit)
	{
		b2Color color(0.3f, 0.9f, 0.9f);
		for (b2Contact* c = m_contactManager.m_contactList; c; c = c->GetNext())
		{
			//b2Fixture* fixtureA = c->GetFixtureA();
			//b2Fixture* fixtureB = c->GetFixtureB();
            
			//b2Vec2 cA = fixtureA->GetAABB().GetCenter();
			//b2Vec2 cB = fixtureB->GetAABB().GetCenter();
            
			//m_debugDraw->DrawSegment(cA, cB, color);
		}
	}
    
	if (flags & b2Draw::e_aabbBit)
	{
		b2Color color(0.9f, 0.3f, 0.9f);
		b2BroadPhase* bp = &m_contactManager.m_broadPhase;
        
		for (b2Body* b = m_bodyList; b; b = b->GetNext())
		{
			if (b->IsActive() == false)
			{
				continue;
			}
            
			for (b2Fixture* f = b->GetFixtureList(); f; f = f->GetNext())
			{
				for (int32 i = 0; i < f->m_proxyCount; ++i)
				{
					b2FixtureProxy* proxy = f->m_proxies + i;
					b2AABB aabb = bp->GetFatAABB(proxy->proxyId);
					b2Vec2 vs[4];
					vs[0].Set(aabb.lowerBound.x+cameraPosition->x, aabb.lowerBound.y+cameraPosition->y);
					vs[1].Set(aabb.upperBound.x+cameraPosition->x, aabb.lowerBound.y+cameraPosition->y);
					vs[2].Set(aabb.upperBound.x+cameraPosition->x, aabb.upperBound.y+cameraPosition->y);
					vs[3].Set(aabb.lowerBound.x+cameraPosition->x, aabb.upperBound.y+cameraPosition->y);
                    
					m_debugDraw->DrawPolygon(vs, 4, color);
				}
			}
		}
	}
    
	if (flags & b2Draw::e_centerOfMassBit)
	{
		for (b2Body* b = m_bodyList; b; b = b->GetNext())
		{
			b2Transform xf = b->GetTransform();
			xf.p = b->GetWorldCenter();
            xf.p.x += cameraPosition->x;
            xf.p.y += cameraPosition->y;
			m_debugDraw->DrawTransform(xf);
		}
	}

}

b2AABB b2WorldEx::GetAABBForBody(b2Body * b)
{
    b2BroadPhase* bp = &m_contactManager.m_broadPhase;
	b2AABB ret;
	ret.lowerBound = b2Vec2(MAXFLOAT,MAXFLOAT);
	ret.upperBound = b2Vec2(-MAXFLOAT,-MAXFLOAT);
	for (b2Fixture* f = b->GetFixtureList(); f; f = f->GetNext())
	{
        for (int32 i = 0; i < f->m_proxyCount; ++i)
        {
            b2FixtureProxy* proxy = f->m_proxies + i;
            b2AABB aabb = bp->GetFatAABB(proxy->proxyId);
            ret.Combine(ret,aabb);
        }
	}
	return ret;
}

void b2WorldEx::DrawSegmentWithCam(const b2Vec2& p1, const b2Vec2& p2, const b2Color& color, const b2Vec2& cameraPosition)
{
    m_debugDraw->DrawSegment(b2Vec2(p1.x+cameraPosition.x,p1.y+cameraPosition.y), 
                             b2Vec2(p2.x+cameraPosition.x,p2.y+cameraPosition.y), 
                             color);        
}

void b2WorldEx::DrawJoint(b2Joint* joint, const b2Vec2& cameraPosition)
{
	b2Body* bodyA = joint->GetBodyA();
	b2Body* bodyB = joint->GetBodyB();
	const b2Transform& xf1 = bodyA->GetTransform();
	const b2Transform& xf2 = bodyB->GetTransform();
	b2Vec2 x1 = xf1.p;
	b2Vec2 x2 = xf2.p;
	b2Vec2 p1 = joint->GetAnchorA();
	b2Vec2 p2 = joint->GetAnchorB();
    
	b2Color color(0.5f, 0.8f, 0.8f);
    
	switch (joint->GetType())
	{
        case e_distanceJoint:
            DrawSegmentWithCam(p1, p2, color, cameraPosition);
            break;
            
        case e_pulleyJoint:
		{
			b2PulleyJoint* pulley = (b2PulleyJoint*)joint;
			b2Vec2 s1 = pulley->GetGroundAnchorA();
			b2Vec2 s2 = pulley->GetGroundAnchorB();
			DrawSegmentWithCam(s1, p1, color, cameraPosition);
			DrawSegmentWithCam(s2, p2, color, cameraPosition);
			DrawSegmentWithCam(s1, s2, color, cameraPosition);
		}
            break;
            
        case e_mouseJoint:
            // don't draw this
            break;
            
        default:
            DrawSegmentWithCam(x1, p1, color, cameraPosition);
            DrawSegmentWithCam(p1, p2, color, cameraPosition);
            DrawSegmentWithCam(x2, p2, color, cameraPosition);
	}    
}
