#import "svgLoader.h"
#import "Box2D.h"
#import "BodyInfo.h"
#include "InteractiveSprite.h"
#include "StringParser.h"
#import "ClassDictionary.h"
#include "GameConfig.h"
#import "Terrain.h"
#import "ClipFactory.h"
#import "Util.h"
#include "GameObjectContainer.h"
#include "Feather.h"
#include "Bomb.h"
#include "Hen.h"
#include "Chick.h"
#include "Remedy.h"
#include "TutorialBox.h"

@implementation svgLoader
//@synthesize scaleFactor;
@synthesize classDict;

-(id) initWithWorld:(b2World*) w andStaticBody:(b2Body*) sb andLayer:(AdLayer*)l terrains:(NSMutableArray*)t  gameObjects:(GameObjectContainer *) objs scoreBoard:(id<ScoreBoardProtocol>)sboard tutorialBoard:(id<TutorialBoardProtocol>)tboard;
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
        scoreBoard = sboard;
        tutorialBoard = tboard;
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

        assert(world);
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

        float bottomInOpenGL = svgCanvasHeight - orgY - orgHeight;

		
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
/*
                static int c = 0;
                c++;
                if ( c >= 100 )
                {
                    CCLOG(@"c=%d", c);
                    continue;
                }
  */              
                if ( [gameObjectClass isEqualToString:@"Feather"] )
                {
                    // Don't scale.
                    refGameObject = REF(GameObject)( new Feather(orgX, bottomInOpenGL, orgWidth, orgHeight, scoreBoard) );
                }

                if ( [gameObjectClass isEqualToString:@"Bomb"] )
                {
                    // Don't scale.
                    refGameObject = REF(GameObject)( new Bomb(orgX, bottomInOpenGL, orgWidth, orgHeight, scoreBoard) );
                }

                if ( [gameObjectClass isEqualToString:@"Hen"] )
                {
                    // Don't scale.
                    refGameObject = REF(GameObject)( new Hen(orgX, bottomInOpenGL, orgWidth, orgHeight, scoreBoard) );
                }

                if ( [gameObjectClass isEqualToString:@"Chick"] )
                {
                    // Don't scale.
                    refGameObject = REF(GameObject)( new Chick(orgX, bottomInOpenGL, orgWidth, orgHeight, scoreBoard) );
                }

                if ( [gameObjectClass isEqualToString:@"Remedy"] )
                {
                    // Don't scale.
                    refGameObject = REF(GameObject)( new Remedy(orgX, bottomInOpenGL, orgWidth, orgHeight, scoreBoard) );
                }

                NSAssert1(refGameObject, @"The game object class name is not supported : %@", gameObjectClass);
                
                if ( bi.initClipFile )
                {
                    CCSprite * sprite;
                    CCAction * action;
                    
                    Helper::getSpriteAndAction( bi.initClipFile, bi.initFrameAnim, &sprite, &action);
                    
                    refGameObject->setSprite(sprite);
                    refGameObject->setDefaultAction(action);
                    
                    // Do not add sprite, do not run the default clip yet. 
                    // It will be done in GameObject::activate while running tick() of the StageScene when the object gets to show on screen.
                    /*
                    // 100 : [60-> 60]
                    // 200 : [60-> 55]
                    // 550 : [38->16], [27-> 60]
                    [layer addChild:sprite];

                    // 100 : [60->60]
                    // 550 : [7->15]
                    Helper::runClip( refGameObject, clip );
                     */
                    
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
                
                assert(world);
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
            if (objectType)
            {
                // if "objectType" attr is defined, it is simply a game object not affected by physics
                if ([objectType isEqualToString:@"MenuItem"])
                {
                    NSString * objectTouchAction = [[curShape attributeForName:@"objectTouchAction"] stringValue];
                    NSString * objectHoverAction = [[curShape attributeForName:@"objectHoverAction"] stringValue];
                    NSString * hoveringSpriteFile = nil;
                    
                    // Set hover action
                    NSMutableDictionary * hoverActionDescs = StringParser::getDictionary(objectHoverAction);
                    body_hover_action_t hoverAction = BHA_NULL;
                    if ( [[hoverActionDescs valueForKey:@"Action"] isEqualToString:@"ShowImage"] )
                    {
                        hoverAction = BHA_SHOW_IMAGE;
                        if ( [[hoverActionDescs valueForKey:@"Action"] isEqualToString:@"ShowImage"] )
                            
                            hoveringSpriteFile = [hoverActionDescs valueForKey:@"ImageFile"];
                        assert(hoveringSpriteFile);
                    }
                    
                    if ( hoverAction == BHA_NULL ) // If no hovering action is specified
                    {
                        hoverAction = BHA_SHOW_PARTICLE;
                        // If the hovering sprite is nil, use transparent dummy sprite for hovering.
                        hoveringSpriteFile = @"Dummy.png";
                        // Set the default touch sound.
                        [hoverActionDescs setValue:@"WaterDrop.wav" forKey:@"Sound"];
                    }
                    
                    // Set touch action.
                    NSMutableDictionary * touchActionDescs = StringParser::getDictionary(objectTouchAction);
                    body_touch_action_t touchAction = BTA_NULL;
                    NSString * actionName = [touchActionDescs valueForKey:@"Action"];
                    if ( [actionName isEqualToString:@"SceneTransition"] )
                    {
                        touchAction = BTA_SCENE_TRANSITION;
                    }
                    else if ( [actionName isEqualToString:@"None"] )
                    {
                        touchAction = BTA_NONE; // Do nothing. But process some optional actions specified "Option" field in the action descs.
                    }
                    else if ( [actionName isEqualToString:@"GiveUpStage"] )
                    {
                        touchAction = BTA_GIVEUP_STAGE; // Give up the current stage, move to the map scene where this stage exists.
                    }
                    
                    assert(hoveringSpriteFile);
                    
                    InteractiveSprite * intrSprite = [[[InteractiveSprite alloc] initWithFile:hoveringSpriteFile] autorelease];
                    assert(intrSprite);
                    
                    [intrSprite setHoverAction:hoverAction actionDescs:hoverActionDescs ];
                    [intrSprite setTouchAction:touchAction actionDescs:touchActionDescs ];
                    
                    CGSize winSize = [[CCDirector sharedDirector] winSize];
                    // 1) Convert Y to GL, to get top get topLeft by subtracting Y from screen height 
                    // 2) and then subtract orgHeight to get bottomLeft
                    intrSprite.bottomLeftCorner = CGPointMake(orgX, winSize.height - orgY - orgHeight);
                    intrSprite.nodeSize = CGSizeMake(orgWidth, orgHeight);
                    intrSprite.position = ccp( intrSprite.bottomLeftCorner.x + intrSprite.nodeSize.width * 0.5 , 
                                              intrSprite.bottomLeftCorner.y + intrSprite.nodeSize.height * 0.5 );
                    
                    [layer addChild:intrSprite];
                }
                
                // if "objectType" attr is defined, it is simply a game object not affected by physics
                if ([objectType isEqualToString:@"Advertisement"])
                {
                    // Enable AD only if no feature is not purchased
                    if ( ! [Util didPurchaseAny ] )
                    {
                        layer.enableAD = YES;
                    }
                }

                if ([objectType isEqualToString:@"TutorialBox"])
                {
                    assert( gameObjectContainer ); // When gameObjectClass attr is specified, gameObjects should not be NULL.
                    
                    REF(GameObject) refGameObject((GameObject*)NULL);

                    NSString * tutorialText = [[curShape attributeForName:@"tutorialText"] stringValue];
                    
                    // Replace @@ to New Line. In SVG file of our game, we use @@ as the line saparator.
                    tutorialText = [tutorialText stringByReplacingOccurrencesOfString:@"@@" withString:@"\n"];
                    
                    // Don't scale.
                    refGameObject = REF(GameObject)( new TutorialBox(orgX,bottomInOpenGL, orgWidth, orgHeight, tutorialText, tutorialBoard) );
                    
                    gameObjectContainer->insert(refGameObject);
         
                }
                continue;
            }

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
            assert(world);
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
            
            // BUGBUG : Memory Leak? check who deallocates bi attached to the body.
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
            CCLOG(@"BEGIN : SvgLoader loading custom shape : %@",name);

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
                    assert(world);
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
					CCLOG(@"END : SvgLoader: Loaded custom shape. name=%@ at %f,%f  friction = %f, density = %f",name, avg.x, avg.y, fixtureDef.friction, fixtureDef.density);
				}
			}
			
		}
		else if([curShape attributeForName:@"isDistanceJoint"])
		{
            CCLOG(@"BEGIN : SvgLoader loading distance joint: %@",name);
            
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

            CCLOG(@"END : SvgLoader loaded distance joint: %@",name);

		}
		else // by default, a shape is an edge.
//            if([curShape attributeForName:@"isEdge"])
        {
            CCLOG(@"BEGIN : SvgLoader loading static edge: %@",name);

            NSString * tmp = [[[curShape attributeForName:@"d"] stringValue] uppercaseString];
            NSString * data = [tmp stringByReplacingOccurrencesOfString:@" L" withString:@""];
            
            // After converting nodes to cusps, " C" or " c" is added to the svg document. We can simply remove it.
            data = [data stringByReplacingOccurrencesOfString:@" C" withString:@""];
            data = [data stringByReplacingOccurrencesOfString:@" c" withString:@""];
            NSArray * dataComponents =[data componentsSeparatedByString:@"M "]; 
            b2EdgeShape edgeShape;
            
            CCLOG(@"MID : before FOR");
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
                   
                    CCLOG(@"MID : before Parsing Points");
                    
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
                        
                        assert(staticBody);
                        
                        b2Fixture* edgeFixture = staticBody->CreateFixture(&edgeShape, staticBodyDensity);
                        
                        if(friction)	edgeFixture->SetFriction([friction floatValue]);
                        else edgeFixture->SetFriction(0.5f);
                    }

                    CCLOG(@"MID : before creating Terrain");

                    if ( terrains )
                    {
                        // x, y offset should be zero, because we don't instantiate terrain yet.
                        assert(xOffset == 0);
                        assert(yOffset == 0);

                        assert(world);
                        // Create Terrain
                        Terrain * terrain = [Terrain terrainWithWorld:world borderPoints:(NSArray*)points canvasHeight:svgCanvasHeight xOffset:xOffset yOffset:yOffset];

                        // Read Attributes
                        // If "upTerrain" attribute exists, rendering is done on the upper part of the terrain border.
                        NSString * renderUpsideAttr = [[curShape attributeForName:@"upTerrain"] stringValue];
                        
                        // If "upTerrain" attribute exists, rendering is done on the upper part of the terrain border.
                        NSString * thicknessAttr = [[curShape attributeForName:@"thickness"] stringValue];

                        if (renderUpsideAttr)
                        {
                            terrain.renderUpside = YES;
                        }
                        if (thicknessAttr)
                        {
                            float thickness = [thicknessAttr floatValue];
                            assert( thickness );
                            terrain.thickness = thickness;
                        }
                        CCLOG(@"MID : BEGIN : prepareRendering");
                        [terrain prepareRendering];
                        CCLOG(@"MID : END : prepareRendering");
                        [terrains addObject:terrain];
                        
                    }
                }
            }
            //NSArray * points = [data componentsSeparatedByString:@" "];
            // Define the ground box shape.

            //CCLOG(@"Static Edge : %@",data);
            CCLOG(@"END : SvgLoader loaded static edge: %@",name);
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
			else {
                assert( staticBody );
                jointDef.Initialize(b1, staticBody, b2Vec2(p1.x,p1.y), b2Vec2(p2.x,p2.y));
            }
            
			jointDef.collideConnected = true;
            assert(world);
			world->CreateJoint(&jointDef);
			CCLOG(@"SvgLoader: Loaded DistanceJoint. body1=\"%@\" body2=\"%@\" at %f,%f  %f,%F",
				  curJointData.body1,curJointData.body2==nil?@"static":curJointData.body2,p1.x,p1.y,p2.x,p2.y);
		}
		else if(curJointData.jointType==kRevoluteJoint && b1)
		{
			CGPoint p1 = curJointData.point1;

			b2RevoluteJointDef jointDef;
			
			if(b2) jointDef.Initialize(b1, b2, b2Vec2(p1.x,p1.y));
			else {
                assert(staticBody);
                jointDef.Initialize(b1, staticBody, b2Vec2(p1.x,p1.y));
            }
            jointDef.enableMotor= curJointData.motorEnabled?true:false;
			jointDef.motorSpeed = curJointData.motorSpeed;
			jointDef.maxMotorTorque = curJointData.maxTorque;

            assert(world);
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
#define MIN_CLASS_NAME_LEN (1)
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
    assert(data);
    
	CXMLDocument *svgDocument  = [[[CXMLDocument alloc] initWithData:data options:0 error:nil] autorelease];
    assert(svgDocument);
    
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
    assert(world);
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
    assert(world);

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
                    CCAction *action;
                    CCSprite *sprite;

                    // BUGBUG : GameObjects does not delay getting sprite and clip like this. Think about unifying the behavior.
                    Helper::getSpriteAndAction( bi.initClipFile, bi.initFrameAnim, &sprite, &action);
                    
                    [layer addChild:sprite];
                    
                    bi.data = sprite;
                    bi.defaultAction = action;
                                                                        
                    //[AKHelpers applyAnimationClip:clip toNode:sprite];
                }
            }
		}
	}
}

-(void) doCleanupShapes
{
    assert(world);

	for (b2Body* b = world->GetBodyList(); b; b = b->GetNext())
	{
		b->SetUserData(NULL);
	}
}
@end
