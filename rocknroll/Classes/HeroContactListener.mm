/*
 *  Tiny Wings Remake
 *  http://github.com/haqu/tiny-wings
 *
 *  Created by Sergey Tikhonov http://haqu.net
 *  Released under the MIT License
 *
 */

#import "HeroContactListener.h"
#import "Hero.h"

#include "PointQueue.h"
/** @brief The singletone to keep track of the ground points. Points are added whenever the Hero hits on the ground. The minimum Y value is used to calculate the Zoom level making the Y level positioned on the bottom of the screen.
 */
extern PointQueue theGroundPoints;


HeroContactListener::HeroContactListener(Hero* hero) {
	_hero = [hero retain];
}

HeroContactListener::~HeroContactListener() {
	[_hero release];
}

void HeroContactListener::BeginContact(b2Contact* contact) {}

void HeroContactListener::EndContact(b2Contact* contact) {}

void HeroContactListener::PreSolve(b2Contact* contact, const b2Manifold* oldManifold) {
	b2WorldManifold wm;
	contact->GetWorldManifold(&wm);
	b2PointState state1[2], state2[2];
	b2GetPointStates(state1, state2, oldManifold, contact->GetManifold());
	if (state2[0] == b2_addState) {
        // Add the hero position to the point queue for calulating the ground level.
        b2Vec2 heroPos = _hero.body->GetPosition();
        // getLastPoint returns kMAX_POSITION if no point was added before. 
        // In this case we set the lastPointX to 0 assuming that the ground level starts from 0.
        //float32 lastPointX = (theGroundPoints.getLastPoint().x == kMAX_POSITION)?0:theGroundPoints.getLastPoint().x;
        // Add the position only if the hero moved enoughly.
//        if ( heroPos.x - lastPointX > 3 )
        {
            theGroundPoints.addPoint( heroPos );
            CCLOG(@"AddPoint Y:%f", heroPos.y );
        }
        
		const b2Body *b = contact->GetFixtureB()->GetBody();
		b2Vec2 vel = b->GetLinearVelocity();
		float va = atan2f(vel.y, vel.x);
		float na = atan2f(wm.normal.y, wm.normal.x);
//		NSLog(@"na = %.3f",na);
		if (na - va > kMaxAngleDiff) {
			[_hero hit];
		}
	}
}

void HeroContactListener::PostSolve(b2Contact* contact, const b2ContactImpulse* impulse) {}
