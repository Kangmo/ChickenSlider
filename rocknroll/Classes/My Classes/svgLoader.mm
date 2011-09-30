#import "svgLoader.h"
#import "Box2D.h"
#import "BodyInfo.h"
#include "InteractiveBodyNode.h"
#include "StringParser.h"
#import "ClassDictionary.h"
#include "GameConfig.h"
#import "Terrain.h"
#import "ClipFactory.h"
#import "GameObjectContainer.h"
#import "Util.h"

@implementation svgLoader
//@synthesize scaleFactor;
@synthesize classDict;

-(id) initWithWorld:(b2World*) w andStaticBody:(b2Body*) sb andLayer:(CCLayer*)l terrains:(NSMutableArray*)t  gameObjects:(GameObjectContainer *) objs
{
	self = [super init];
	if (self != nil) 
	{
		world = w;
		staticBody = sb;
        layer = l;
//		scaleFactor = 10.0f;
        scaleFactor = INIT_PTM_RATIO;
        classDict = nil;
        terrains = t;
        gameObjectContainer = objs;
	}
	return self;
}

- (void) dealloc
{
    [classDict release];
	[super dealloc];
}

-(void) initGroups:(NSArray *)shapes delayedJoints:(NSMutableSet*)delayedJoints namePrefix:(NSString*)objectNamePrefix  xOffset:(float)xOffset yOffset:(float)yOffset
{
	for(CXMLElement * curGroup in shapes)
	{
		NSArray *rects = [curGroup elementsForName:@"rect"];
		b2BodyDef bodyDef;
		CGPoint bodyPos = CGPointZero;
		
		int activeCount=0;
		float minX = FLT_MAX ,maxX = FLT_MIN ,minY = FLT_MAX, maxY = FLT_MIN;
		
		
		for (CXMLElement * curShape in rects) 
		{
			NSString * x = [[curShape attributeForName:@"x"] stringValue];
			NSString * y = [[curShape attributeForName:@"y"] stringValue];
			NSString * height = [[curShape attributeForName:@"height"] stringValue];
			NSString * width = [[curShape attributeForName:@"width"] stringValue];
			if(!x || !y || !height || !width) continue;
			
			float fx = ([x floatValue] + xOffset) / scaleFactor;
			float fy = ([y floatValue] + yOffset) / scaleFactor;
			float fWidth = [width floatValue] / scaleFactor;
			float fHeight = [height floatValue] / scaleFactor;
			fy = worldHeight - (fy + fHeight * .5f);
			
			bodyPos.x = bodyPos.x + fx;
			bodyPos.y = bodyPos.y + fy;
			
			float t = fx-fWidth/2.0f;
			if(minX >t) minX = t; 
			
			t = fx+fWidth/2.0f;
			if(maxX < t) maxX = t; 
			
			t = fy-fHeight/2.0f;
			if(minY >t) minY = t; 
			
			t = fy+fHeight/2.0f;
			if(maxY < t) maxY = t; 
			
			activeCount++;
		}
//		bodyPos.x = bodyPos.x/ activeCount;
//		bodyPos.y = bodyPos.y/ activeCount;
		BodyInfo * bi = [[BodyInfo alloc] init];
		bi.name = [[curGroup attributeForName:@"id"] stringValue];
        bi.name = [objectNamePrefix stringByAppendingString:bi.name];
		bi.data = nil;
		bi.rect = CGSizeMake(maxX-minX, maxY-minY);
		bi.spriteName = [[curGroup attributeForName:@"sprite"] stringValue];
		bi.textureName = [[curGroup attributeForName:@"texture"] stringValue];
		bi.initFrameAnim = [[curGroup attributeForName:@"initFrameAnim"] stringValue];
		bi.initClipFile = [[curGroup attributeForName:@"initClipFile"] stringValue];

		bodyPos.x = minX + bi.rect.width;
		bodyPos.y = maxY - bi.rect.height/2.0f;
		
        // by kangmo kim
        bodyDef.type = b2_dynamicBody;
		bodyDef.position.Set(bodyPos.x, bodyPos.y);

		b2Body *body = world->CreateBody(&bodyDef);
	
		

		body->SetUserData(bi);
		
		CCLOG(@"SvgLoader: Composite body created name=%@ x=%f,y=%f   rect = (%f ; %f)",bi.name, bodyPos.x, bodyPos.y,bi.rect.width,bi.rect.height);
		
		for (CXMLElement * curShape in rects) 
		{
			NSString * width = [[curShape attributeForName:@"width"] stringValue];
			NSString * height = [[curShape attributeForName:@"height"] stringValue]; 
			NSString * x = [[curShape attributeForName:@"x"] stringValue];
			NSString * y = [[curShape attributeForName:@"y"] stringValue];
			NSString * density = [[curShape attributeForName:@"phy_density"] stringValue];
			NSString * friction = [[curShape attributeForName:@"phy_friction"] stringValue];
			NSString * restitution = [[curShape attributeForName:@"phy_restitution"] stringValue]; 
			
			
			if(!x || !y || !width || !height) continue;
			
			//CCLOG(@"SvgLoader: loading shape: %@",name);
			float fx = ([x floatValue]+xOffset) / scaleFactor;
			float fy = ([y floatValue]+yOffset) / scaleFactor;
			float fWidth = [width floatValue] / scaleFactor;
			float fHeight = [height floatValue] / scaleFactor;
			fx = fx + fWidth * .5f;
			fy = worldHeight - (fy + fHeight * .5f);
			
			if([curShape attributeForName:@"sprite"])
			{
				bi.spriteOffset = CGPointMake(fx - bodyPos.x, -(fy - bodyPos.y));
				bi.spriteName = [[curShape attributeForName:@"sprite"] stringValue];
				bi.textureName = [[curShape attributeForName:@"texture"] stringValue];
                bi.initFrameAnim = [[curShape attributeForName:@"initFrameAnim"] stringValue];
                bi.initClipFile = [[curShape attributeForName:@"initClipFile"] stringValue];

			}
			
			if([curShape attributeForName:@"isCircle"])
			{
				//float r = sqrt((fWidth/2)*(fWidth/2) + (fHeight/2)*(fHeight/2));;
				float r = fWidth/2;
				
				b2CircleShape circle;
				circle.m_radius = r;
				circle.m_p = b2Vec2(fx - bodyPos.x,fy - bodyPos.y);
				
				b2FixtureDef fixtureDef;
				fixtureDef.shape = &circle;	
				
				
				if(density)	fixtureDef.density =[density floatValue];
				else fixtureDef.density = 0.0f;
				
				if(friction) fixtureDef.friction =[friction floatValue];
				else fixtureDef.friction = 0.5f;
				
				body->CreateFixture(&fixtureDef);
				CCLOG(@"SvgLoader: \tLoaded circle. x=%f,y=%f r=%f, density=%f, friction = %f", fx, fy, r,fixtureDef.density,fixtureDef.friction);
				
			}
			else
			{				
				b2PolygonShape dynamicBox;
				dynamicBox.SetAsBox(fWidth * .5f,
									fHeight * .5f,
									b2Vec2(fx - bodyPos.x ,fy - bodyPos.y),
									0.0f);
				
				
				// Define the dynamic body fixture.
				b2FixtureDef fixtureDef;
				fixtureDef.shape = &dynamicBox;
				
				if(density)	fixtureDef.density =[density floatValue];
				else fixtureDef.density = 0.0f;
				
				if(friction) fixtureDef.friction =[friction floatValue];
				else fixtureDef.friction = 0.5f;
				
				if(restitution) fixtureDef.restitution =[restitution floatValue];
				
				//fixtureDef.density = 0.0f;
				//fixtureDef.density = 0.1f;
				body->CreateFixture(&fixtureDef);
				CCLOG(@"SvgLoader: \tLoaded rectangle. w=%f h=%f at %f,%f  friction = %f, density = %f", fWidth,fHeight,fx,fy, fixtureDef.friction, fixtureDef.density);
			}
		}	
		
	}	
}

-(void) initRectangles:(NSArray *)shapes delayedJoints:(NSMutableSet*)delayedJoints namePrefix:(NSString*)objectNamePrefix  xOffset:(float)xOffset yOffset:(float)yOffset
{
	for (CXMLElement * curShape in shapes) 
	{
		NSString * gameObjectClass = [[curShape attributeForName:@"gameObjectClass"] stringValue];
        
		NSString * width = [[curShape attributeForName:@"width"] stringValue];
		NSString * height = [[curShape attributeForName:@"height"] stringValue];
		NSString * x = [[curShape attributeForName:@"x"] stringValue];
		NSString * y = [[curShape attributeForName:@"y"] stringValue];
		NSString * density = [[curShape attributeForName:@"phy_density"] stringValue];
		NSString * friction = [[curShape attributeForName:@"phy_friction"] stringValue];
		NSString * restitution = [[curShape attributeForName:@"phy_restitution"] stringValue];
		NSString * name = [[curShape attributeForName:@"id"] stringValue];
		
		
		if(!x || !y) continue;
		if(!width || !height) continue;
		float orgX = [x floatValue] + xOffset ;
		float orgY = [y floatValue] + yOffset;
        float orgWidth = [width floatValue];
        float orgHeight = [height floatValue];
		float fx = orgX / scaleFactor;
		float fy = orgY / scaleFactor;
		float fWidth =  orgWidth / scaleFactor;
		float fHeight = orgHeight / scaleFactor;

		
		if( [curShape attributeForName:@"isRevoluteJoint"]) //this is revolute joint
		{
			//CCLOG(@"------------%@",[curShape stringValue]);
			JointDeclaration * curJoint = [[JointDeclaration alloc] init];
			curJoint.point1 = CGPointMake(fx + fWidth/2, worldHeight - (fy + fHeight/2) );
			//curJoint.point1 = CGPointMake(fx, fy);
			
            // Need to prefix the body names. objectNamePrefix equals to {InstanceName}_
			curJoint.body1 = [objectNamePrefix stringByAppendingString:[[curShape attributeForName:@"body1"] stringValue]];
			curJoint.body2 = [objectNamePrefix stringByAppendingString:[[curShape attributeForName:@"body2"] stringValue]];
			
			curJoint.jointType = kRevoluteJoint;
			
			if([curShape attributeForName:@"motorEnabled"]) 
				curJoint.motorEnabled = YES;
			
			if([curShape attributeForName:@"motorSpeed"]) 
				curJoint.motorSpeed = [[[curShape attributeForName:@"motorSpeed"] stringValue] floatValue];
			
			if([curShape attributeForName:@"maxTorque"]) 
				curJoint.maxTorque = [[[curShape attributeForName:@"maxTorque"] stringValue] floatValue];			
			
			
			[delayedJoints addObject:curJoint];
            [curJoint release];
			continue;
		}
		
		fx = fx + fWidth / 2;
		fy = worldHeight - (fy + fHeight / 2);
		
		//CCLOG(@"SvgLoader: loading shape: %@",name);

		
		BodyInfo * bi = [[BodyInfo alloc] init];
		bi.name = [objectNamePrefix stringByAppendingString:name];

		bi.spriteName = [[curShape attributeForName:@"sprite"] stringValue];
		bi.textureName = [[curShape attributeForName:@"texture"] stringValue];
        bi.initFrameAnim = [[curShape attributeForName:@"initFrameAnim"] stringValue];
		bi.initClipFile = [[curShape attributeForName:@"initClipFile"] stringValue];

		bi.data = nil;
        NSString * objectType = [[curShape attributeForName:@"objectType"] stringValue];
        
		if([curShape attributeForName:@"isCircle"])
		{
            // BUGBUG : Need to check "gameObjectClass" attr in other shapes as well.
            if ( gameObjectClass ) // Logic class is specified. Add a sprite into layer, instantiate the logic class, attach it to the sprite 
            {
                assert( gameObjectContainer ); // When gameObjectClass attr is specified, gameObjects should not be NULL.
                
                REF(GameObject) refGameObject((GameObject*)NULL);

                if ( [gameObjectClass isEqualToString:@"WaterDrop"] )
                {
                    float yInOpenGL = svgCanvasHeight - orgY;
                    // Don't scale.
                    refGameObject = REF(GameObject)( new WaterDrop(orgX, yInOpenGL, orgWidth, orgHeight) );
                }
                
                NSAssert1(refGameObject, @"The game object class name is not supported : %@", gameObjectClass);
                
                if ( bi.initClipFile )
                {
                    CCSprite *sprite;
                    NSDictionary * clip;
                    
                    Helper::getSpriteAndClip( bi.initClipFile, bi.initFrameAnim, &sprite, &clip);
                    
                    refGameObject->setSprite(sprite);
                    refGameObject->setDefaultClip(clip);
                    
                    [layer addChild:sprite];
                    
                    Helper::runClip( refGameObject, clip );
                }

                gameObjectContainer->insert(refGameObject);
            }
            else // No logic class. Create Box2d body.
            {
                //float r = sqrt((fWidth/2)*(fWidth/2) + (fHeight/2)*(fHeight/2));;
                float r = fWidth/2;
                
                b2BodyDef bodyDef;
                // by kangmo kim
                bodyDef.type = b2_dynamicBody;
                bodyDef.position.Set(fx, fy);
                
                b2Body *body = world->CreateBody(&bodyDef);
                
                b2CircleShape circle;
                circle.m_radius = r;
                
                b2FixtureDef fixtureDef;
                fixtureDef.shape = &circle;	
                
                if(density)	fixtureDef.density =[density floatValue];
                else fixtureDef.density = 0.0f;
                
                if(friction) fixtureDef.friction =[friction floatValue];
                else fixtureDef.friction = 0.5f;
                
                if(restitution) fixtureDef.restitution =[restitution floatValue];
                //else fixtureDef.friction = 0.5f;
                
                body->CreateFixture(&fixtureDef);
                bi.rect = CGSizeMake(fWidth, fHeight);
                
                if(name) body->SetUserData(bi);
                CCLOG(@"SvgLoader: Loaded circle. name=%@ x=%f,y=%f r=%f, density=%f, friction = %f",name, fx, fy, r,fixtureDef.density,fixtureDef.friction);
            }
        }
        else
		{
			b2BodyDef bodyDef;
            // by kangmo kim
            bodyDef.type = b2_dynamicBody;
			bodyDef.position.Set(fx, fy);
            // if "objectType" attr is defined, it is simply a game object not affected by physics
            if (objectType)
			{
                bodyDef.active = false;
                // box2d 2.0 API :
                // bodyDef.isSleeping = true;
            }
			
			//bodyDef.userData = sprite;
			b2Body *body = world->CreateBody(&bodyDef);
			
			// Define another box shape for our dynamic body.
			b2PolygonShape dynamicBox;
			dynamicBox.SetAsBox(fWidth * .5f, fHeight * .5f);//These are mid points for our 1m box
			
			
			// Define the dynamic body fixture.
			b2FixtureDef fixtureDef;
			fixtureDef.shape = &dynamicBox;
			
			if(density)	fixtureDef.density =[density floatValue];
			else fixtureDef.density = 0.0f;
			
			if(friction) fixtureDef.friction =[friction floatValue];
			else fixtureDef.friction = 0.5f;
			
			if(restitution) fixtureDef.restitution =[restitution floatValue];
			
			//fixtureDef.density = 0.0f;
			//fixtureDef.density = 0.1f;
			body->CreateFixture(&fixtureDef);
			
			bi.rect = CGSizeMake(fWidth, fHeight);
            
            // if "objectType" attr is defined, it is simply a game object not affected by physics
            if (objectType)
            {
                NSString * objectTouchAction = [[curShape attributeForName:@"objectTouchAction"] stringValue];
                NSString * objectHoverAction = [[curShape attributeForName:@"objectHoverAction"] stringValue];
                // Hmm the code is really dirty. Make it clean.
                InteractiveBodyNode * intrBody = [[InteractiveBodyNode alloc] init];
                intrBody.name = bi.name;
                intrBody.rect = bi.rect;
                intrBody.spriteName = bi.spriteName;
                intrBody.textureName = bi.textureName;
                intrBody.data = bi.data;
                
                CGSize winSize = [[CCDirector sharedDirector] winSize];
                // 1) Convert Y to GL, to get top get topLeft by subtracting Y from screen height 
                // 2) and then subtract orgHeight to get bottomLeft
                intrBody.bottomLeftCorner = CGPointMake(orgX, winSize.height - orgY - orgHeight);
                intrBody.nodeSize = CGSizeMake(orgWidth, orgHeight);
                // Set Cocos2d Layer so that hover action can show a sprite an the layer with the hovering image.
                intrBody.layer = layer;

                // Set hover action
                {
                    NSMutableDictionary * hoverActionDescs = StringParser::getDictionary(objectHoverAction);
                    body_hover_action_t hoverAction = BHA_NONE;
                    if ( [[hoverActionDescs valueForKey:@"Action"] isEqualToString:@"ShowImage"] )
                    {
                        hoverAction = BHA_SHOW_IMAGE;          
                    }
                    
                    [intrBody setHoverAction:hoverAction actionDescs:hoverActionDescs ];
                    
                }
                
                // Set touch action.
                {
                    NSMutableDictionary * touchActionDescs = StringParser::getDictionary(objectTouchAction);
                    body_touch_action_t touchAction = BTA_NONE;
                    if ( [[touchActionDescs valueForKey:@"Action"] isEqualToString:@"SceneTransition"] )
                    {
                        touchAction = BTA_SCENE_TRANSITION;          
                    }
                    [intrBody setTouchAction:touchAction actionDescs:touchActionDescs ];
                }

                // Switch the body info with the Interactive Body.
                [bi release];
                bi = intrBody;
            }
            
			if(name) body->SetUserData(bi);
			CCLOG(@"SvgLoader: Loaded rectangle. name=%@ w=%f h=%f at %f,%f  friction = %f, density = %f",name, fWidth,fHeight,fx,fy, fixtureDef.friction, fixtureDef.density);
		}
	}
}

-(void) initShapes:(NSArray *) shapes delayedJoints:(NSMutableSet*)delayedJoints namePrefix:(NSString*)objectNamePrefix  xOffset:(float)xOffset yOffset:(float)yOffset
{
	for (CXMLElement * curShape in shapes) 
	{
		
		NSString * density = [[curShape attributeForName:@"phy_density"] stringValue];
		NSString * friction = [[curShape attributeForName:@"phy_friction"] stringValue];
		NSString * name = [[curShape attributeForName:@"id"] stringValue];
		
		
		if([curShape attributeForName:@"isCustomShape"])
		{
			NSString * tmp = [[[curShape attributeForName:@"d"] stringValue] uppercaseString];
			NSString * data = [tmp stringByReplacingOccurrencesOfString:@" L" withString:@""];
			NSArray * dataComponents =[data componentsSeparatedByString:@"M "]; 
			
			b2PolygonShape customShape;
			for (NSString * curComponent in dataComponents) 
			{
				if([curComponent length] < 3) continue;
				NSArray * points = [[[curComponent stringByReplacingOccurrencesOfString:@"  " withString:@""] stringByReplacingOccurrencesOfString:@"Z " withString:@""] componentsSeparatedByString:@" "];
				
				if([points count]>2 &&[points count]<=8)
				{
#define MAX_VECTOR_COUNT 4096
					b2Vec2 p[MAX_VECTOR_COUNT];
                    b2Vec2 avg(0,0);
					
					int vx=[points count];
                    
                    assert(vx < MAX_VECTOR_COUNT);
                    
					for (int i =0; i<vx; i++) 
					{
						CGPoint cp = CGPointFromString([NSString stringWithFormat:@"{%@}",[points objectAtIndex:i]]);
						p[i] = b2Vec2(cp.x, cp.y);
						p[i].y = worldHeight-p[i].y;
                        p[i].x += xOffset;
                        p[i].y += yOffset;
                        // BUGBUG no need to devide with scaleFactor?
						avg+=p[i];
					}
					
					avg*=1.0f/vx;
					
					///TODO: add graham scan there
					
					//std::vector <b2Vec2> inVec(p,p);
//					std::vector <b2Vec2> outVec;
//					
//					ConvexHull* hull_generator = new GrahamScanConvexHull();
//					(*hull_generator)(p, p);
					//delete hull_generator;
					
					b2BodyDef bodyDef;
                    // by kangmo kim
                    bodyDef.type = b2_dynamicBody;
					bodyDef.position.Set(avg.x, avg.y);
					
					//bodyDef.userData = sprite;
					b2Body *body = world->CreateBody(&bodyDef);
					
					// Define another box shape for our dynamic body.
					b2PolygonShape dynamicBox;
					
					dynamicBox.Set(p,vx);
					
					
					// Define the dynamic body fixture.
					b2FixtureDef fixtureDef;
					fixtureDef.shape = &dynamicBox;	
					
					if(density)	fixtureDef.density =[density floatValue];
					else fixtureDef.density = 0.0f;
					
					if(friction) fixtureDef.friction =[friction floatValue];
					else fixtureDef.friction = 0.5f;
					
					//fixtureDef.density = 0.0f;
					//fixtureDef.density = 0.1f;
					body->CreateFixture(&fixtureDef);
					
					if(name) body->SetUserData(name);
					CCLOG(@"SvgLoader: Loaded custom shape. name=%@ at %f,%f  friction = %f, density = %f",name, avg.x, avg.y, fixtureDef.friction, fixtureDef.density);
				}
			}
			
		}
		else if([curShape attributeForName:@"isDistanceJoint"])
		{
			
			NSString * tmp = [[[curShape attributeForName:@"d"] stringValue] uppercaseString];
			NSString * data = [[tmp stringByReplacingOccurrencesOfString:@" L" withString:@""]  stringByReplacingOccurrencesOfString:@"M " withString:@""];
			NSArray * points =[data componentsSeparatedByString:@" "];
			//CCLOG(@"joint data : %@",points);
			if([points count]==2)
			{
				CGPoint p1,p2;
				p1 = CGPointFromString([NSString stringWithFormat:@"{%@}",[points objectAtIndex:0]]);
				p2 = CGPointFromString([NSString stringWithFormat:@"{%@}",[points objectAtIndex:1]]);
                p1.x += xOffset; p1.y += yOffset;
                p2.x += xOffset; p2.y += yOffset;

				JointDeclaration * curJoint = [[JointDeclaration alloc] init];
				p1.x /=scaleFactor;
				p2.x /=scaleFactor;
				p1.y /=scaleFactor;
				p2.y /=scaleFactor;
                
                p1.y = worldHeight-p1.y;
                p2.y = worldHeight-p2.y;

				curJoint.point1 = p1;
				curJoint.point2 = p2;

				curJoint.body1 = [objectNamePrefix stringByAppendingString:[[curShape attributeForName:@"body1"] stringValue]];
				curJoint.body2 = [objectNamePrefix stringByAppendingString:[[curShape attributeForName:@"body2"] stringValue]];
				
				curJoint.jointType = kDistanceJoint;
				[delayedJoints addObject:curJoint];
                [curJoint release];

			}
		}
		else // by default, a shape is an edge.
//            if([curShape attributeForName:@"isEdge"])
        {
            NSString * tmp = [[[curShape attributeForName:@"d"] stringValue] uppercaseString];
            NSString * data = [tmp stringByReplacingOccurrencesOfString:@" L" withString:@""];
            
            // After converting nodes to cusps, " C" or " c" is added to the svg document. We can simply remove it.
            data = [data stringByReplacingOccurrencesOfString:@" C" withString:@""];
            data = [data stringByReplacingOccurrencesOfString:@" c" withString:@""];
            NSArray * dataComponents =[data componentsSeparatedByString:@"M "]; 
            b2EdgeShape edgeShape;
            // v2.1.2
            //b2PolygonShape edgeShape;
            for (NSString * curComponent in dataComponents) 
            {
                if([curComponent length] < 3) continue;
                NSArray * points = [[[curComponent stringByReplacingOccurrencesOfString:@"  " withString:@""] stringByReplacingOccurrencesOfString:@"Z " withString:@""] componentsSeparatedByString:@" "];
                //CCLOG(@"%@",points);
                if([points count]>1)
                {
                    CGPoint p1,p2;
                    
                    for (uint32 i = 1; i< [points count]; i++) 
                    {
                        if([[points objectAtIndex:i] length]<2) continue;
                        
                        p1 = CGPointFromString([NSString stringWithFormat:@"{%@}",[points objectAtIndex:i-1]]);
                        p2 = CGPointFromString([NSString stringWithFormat:@"{%@}",[points objectAtIndex:i]]);
                        
                        p1.x += xOffset; p1.y += yOffset;
                        p2.x += xOffset; p2.y += yOffset;
                        
                        p1.y /=scaleFactor;
                        p2.y /=scaleFactor;
                        
                        p1.y = worldHeight-p1.y;
                        p2.y = worldHeight-p2.y;
                        p1.x /=scaleFactor;
                        p2.x /=scaleFactor;
                        
                        edgeShape.Set( b2Vec2(p1.x,p1.y), b2Vec2(p2.x,p2.y));
                        // 2.1.2
                        //edgeShape.SetAsEdge(b2Vec2(p1.x,p1.y), b2Vec2(p2.x,p2.y));
                        
                        float32 staticBodyDensity = 0;
                        b2Fixture* edgeFixture = staticBody->CreateFixture(&edgeShape, staticBodyDensity);
                        
                        if(friction)	edgeFixture->SetFriction([friction floatValue]);
                        else edgeFixture->SetFriction(0.5f);
                    }

                    if ( terrains )
                    {
                        // x, y offset should be zero, because we don't instantiate terrain yet.
                        assert(xOffset == 0);
                        assert(yOffset == 0);
                        
                        // If "upTerrain" attribute exists, rendering is done on the upper part of the terrain border.
                        NSString * renderUpsideAttr = [[curShape attributeForName:@"upTerrain"] stringValue];

                        BOOL renderUpside = renderUpsideAttr ? TRUE : FALSE;
                        Terrain * terrain = [Terrain terrainWithWorld:world borderPoints:(NSArray*)points canvasHeight:svgCanvasHeight xOffset:xOffset yOffset:yOffset renderUpside:renderUpside];
                        [terrains addObject:terrain];
                    }
                }
            }
            //NSArray * points = [data componentsSeparatedByString:@" "];
            // Define the ground box shape.
            
            CCLOG(@"SvgLoader: loaded static edge: %@",name);
            //CCLOG(@"Static Edge : %@",data);
        }
	}
}

-(void) initJoints:(NSMutableSet*)delayedJoints
{
	for (JointDeclaration * curJointData in delayedJoints) 
	{
		//CCLOG(@"joint data : %@",curJointData);
		b2Body *b1 = [self getBodyByName:curJointData.body1];
		b2Body *b2 = [self getBodyByName:curJointData.body2];
		if(curJointData.jointType==kDistanceJoint && b1)
		{
			CGPoint p1 = curJointData.point1;
			CGPoint p2 = curJointData.point2;

			b2DistanceJointDef jointDef;
			
			if(b2) jointDef.Initialize(b1, b2, b2Vec2(p1.x,p1.y), b2Vec2(p2.x,p2.y));
			else jointDef.Initialize(b1, staticBody, b2Vec2(p1.x,p1.y), b2Vec2(p2.x,p2.y));
			
			jointDef.collideConnected = true;
			world->CreateJoint(&jointDef);
			CCLOG(@"SvgLoader: Loaded DistanceJoint. body1=\"%@\" body2=\"%@\" at %f,%f  %f,%F",
				  curJointData.body1,curJointData.body2==nil?@"static":curJointData.body2,p1.x,p1.y,p2.x,p2.y);
		}
		else if(curJointData.jointType==kRevoluteJoint && b1)
		{
			CGPoint p1 = curJointData.point1;

			b2RevoluteJointDef jointDef;
			
			if(b2) jointDef.Initialize(b1, b2, b2Vec2(p1.x,p1.y));
			else jointDef.Initialize(b1, staticBody, b2Vec2(p1.x,p1.y));

            jointDef.enableMotor= curJointData.motorEnabled?true:false;
			jointDef.motorSpeed = curJointData.motorSpeed;
			jointDef.maxMotorTorque = curJointData.maxTorque;

			world->CreateJoint(&jointDef);
			CCLOG(@"SvgLoader: Loaded RevoluteJoint. body1=\"%@\" body2=\"%@\" at %f,%f ",
				  curJointData.body1,curJointData.body2==nil?@"static":curJointData.body2,p1.x,p1.y);
		}
	}
}

/**@brief
   Input : http://.../aa/bb/ClassName.png'
   Output : ClassName
 */
-(NSString *) getClassNameFromURL:(NSString *) url
{
    assert(url);
    NSRange lastSlashRange = [url rangeOfString:@"/" options:NSBackwardsSearch];
    NSRange lastDotRange = [url rangeOfString:@"." options:NSBackwardsSearch];
    const int MIN_CLASS_NAME_LEN=1;
    assert( lastSlashRange.location + MIN_CLASS_NAME_LEN < lastDotRange.location );
    NSString * className = [url substringWithRange:NSMakeRange(lastSlashRange.location +1, lastDotRange.location - lastSlashRange.location - 1) ];
    return className;
  
    return @"Car";
}

-(void) initGameObjects:(NSArray *) gameObjects
{
	for (CXMLElement * gameObject in gameObjects) 
	{
		
		NSString * instanceName = [[gameObject attributeForName:@"id"] stringValue];
		NSString * xOffset = [[gameObject attributeForName:@"x"] stringValue];
		NSString * yOffset = [[gameObject attributeForName:@"y"] stringValue];
//        NSString * height = [[gameObject attributeForName:@"height"] stringValue];
//        NSString * gameObjectImageFile = [[gameObject attributeForLocalName:@"href" URI:nil] stringValue];

		NSString * gameObjectImageFile = [[gameObject attributeForName:@"xlink:href"] stringValue];
        NSString * className = [self getClassNameFromURL:gameObjectImageFile];
        
        assert(classDict);
        
        ClassInfo * classInfo = [classDict getClassByName:className];
        

        NSString * namePrefix = [instanceName stringByAppendingString:@"_"];
        // Not true:(x,y) is the top left corner. We need to provide bottm left corner for the offset.
        // Not true:So we add height from the y position. ( Y value grows from top to bottom in svg files )
        [self instantiateObjects:classInfo.svgLayer namePrefix:namePrefix xOffset:[xOffset floatValue] yOffset:[yOffset floatValue]];
    }    
}
-(void) instantiateObjects:(CXMLElement*)svgLayer namePrefix:(NSString*)objectNamePrefix xOffset:(float)xOffset yOffset:(float)yOffset
{
    NSMutableSet * delayedJoints = [[NSMutableSet alloc] initWithCapacity:10];
    
    //add boxes first
    NSArray *rects = [svgLayer elementsForName:@"rect"];
    [self initRectangles:rects delayedJoints:delayedJoints namePrefix:objectNamePrefix xOffset:xOffset yOffset:yOffset];
    
    NSArray *nonrectangles = [svgLayer elementsForName:@"path"];
    [self initShapes:nonrectangles delayedJoints:delayedJoints namePrefix:objectNamePrefix xOffset:xOffset yOffset:yOffset];
    
    NSArray *groups = [svgLayer elementsForName:@"g"];
    [self initGroups:groups delayedJoints:delayedJoints namePrefix:objectNamePrefix xOffset:xOffset yOffset:yOffset];

    /** Treat images as objects of classes
     If the image has 'xlink:href' attribute with 'http://.../aa/bb/ClassName.png'
     We need to parse the attribute to get the ClassName, and then pass it to classDict to get the svg layer containing the definition of the class. 
     */
    NSArray *gameObjects = [svgLayer elementsForName:@"image"];
    [self initGameObjects:gameObjects];

    [self initJoints:delayedJoints];
    
    [delayedJoints release];
}

-(void) instantiateObjectsIn:(NSString*)filename;
{
    CCLOG(@"The file :%@", filename);
	NSData *data = [NSData dataWithContentsOfFile:filename]; 
	CXMLDocument *svgDocument  = [[[CXMLDocument alloc] initWithData:data options:0 error:nil] autorelease];
    
	//get world space dimensions
	if([[svgDocument rootElement] attributeForName:@"width"])
	{
		worldWidth = [[[[svgDocument rootElement] attributeForName:@"width"] stringValue] floatValue] / scaleFactor;
	}
	else
	{
        assert(0);
	}
	if([[svgDocument rootElement] attributeForName:@"height"])
	{
        svgCanvasHeight = [[[[svgDocument rootElement] attributeForName:@"height"] stringValue] floatValue];
        
		worldHeight = svgCanvasHeight / scaleFactor;
	}
	else
	{
		assert(0);
	}
	
    NSArray *layers = NULL;
	
    // root groups are layers for geometry
    layers = [[svgDocument rootElement] elementsForName:@"g"];
	for (CXMLElement * curLayer in layers) 
	{
		//layers with "ignore" attribute not loading
		if([curLayer attributeForName:@"ignore"])
		{
			CCLOG(@"SvgLoader: layer ignored: %@",[[curLayer attributeForName:@"id"] stringValue]);
			continue;
		}
		CCLOG(@"SvgLoader: loading layer: %@",[[curLayer attributeForName:@"id"] stringValue]);
        
        [self instantiateObjects:curLayer namePrefix:@"" xOffset:0.0f yOffset:0.0f];
        
		CCLOG(@"SvgLoader: layer loaded: %@",[[curLayer attributeForName:@"id"] stringValue]);
	}
}


-(b2Body*) getBodyByName:(NSString*) bodyName
{
	//Iterate over the bodies in the physics world
	for (b2Body* b = world->GetBodyList(); b; b = b->GetNext())
	{
		if (b->GetUserData() != NULL) 
		{
			BodyInfo * bi = (BodyInfo*)b->GetUserData();
			if(bi && [bi.name isEqualToString:bodyName]) return b;
		}
	}
	return NULL;
}


-(void) assignSpritesFromSheet:(CCSpriteBatchNode*)spriteSheet
{
	for (b2Body* b = world->GetBodyList(); b; b = b->GetNext())
	{
		if (b->GetUserData() != NULL) 
		{
			BodyInfo *bi = (BodyInfo*)b->GetUserData();
            if (bi)
            {
                if(bi.textureName && bi.spriteName)
                {
                    NSAssert2(0, @"svg parser : textureName is not supported yet (Sprite=%@, Texture=%@).", bi.spriteName, bi.textureName);
                    
                    //				bi.data = [manager getSpriteWithName:bi.spriteName fromTexture:bi.textureName];
                }
                else if(bi.spriteName)
                {
                    CCSprite * sprite = [CCSprite spriteWithSpriteFrameName:bi.spriteName];
                    bi.data = sprite;
                    [spriteSheet addChild:sprite];
                }
                else if (bi.initClipFile)
                {
                    NSDictionary *clip;
                    CCSprite *sprite;

                    // BUGBUG : GameObjects does not delay getting sprite and clip like this. Think about unifying the behavior.
                    Helper::getSpriteAndClip( bi.initClipFile, bi.initFrameAnim, &sprite, &clip);
                    
                    [layer addChild:sprite];
                    
                    bi.data = sprite;
                    bi.defaultClip = clip;
                                                                        
                    //[AKHelpers applyAnimationClip:clip toNode:sprite];
                }
            }
		}
	}
}

-(void) doCleanupShapes
{
	for (b2Body* b = world->GetBodyList(); b; b = b->GetNext())
	{
		b->SetUserData(NULL);
	}
}
@end
