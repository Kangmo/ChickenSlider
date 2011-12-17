#import "Terrain.h"
#import "GameConfig.h"
#import "Profiler.h"

@interface Terrain()
- (CCSprite*) generateStripesSprite;
- (CCTexture2D*) generateStripesTexture;
- (void) renderStripes;
- (void) renderGradient;
- (void) renderHighlight;
- (void) renderTopBorder;
- (void) renderNoise;
//- (void) generateHillKeyPoints;
//- (void) generateBorderVertices;
- (void) loadBorderVertices;
//- (void) createBox2DBody;
- (void) calcHillVertices;
- (ccColor4F) randomColor;
- (void) renderImage:(NSString*)imageFileName;

@end

@implementation Terrain

@synthesize textureFile;
@synthesize stripes = _stripes;
@synthesize renderUpside;
@synthesize thickness;
@synthesize maxX;

+ (id) terrainWithWorld:(b2World*)w borderPoints:(NSArray*)borderPoints canvasHeight:(int)canvasHeight xOffset:(float)xOffset yOffset:(float)yOffset{
	return [[[self alloc] initWithWorld:w borderPoints:borderPoints canvasHeight:canvasHeight xOffset:xOffset yOffset:yOffset] autorelease];
}

- (id) initWithWorld:(b2World*)w borderPoints:(NSArray*)bp canvasHeight:(int)ch xOffset:(float)xo yOffset:(float)yo{
	
	if ((self = [super init])) {
		
		world = w;

		CGSize size = [[CCDirector sharedDirector] winSize];
		screenW = size.width;
		screenH = size.height;

        startBorderIndex = 0;
        endBorderIndex = 0;
        rightBeforeHeroIndex = 0;
        
        renderUpside = NO;
        thickness = TERRAIN_TEXTURE_SIZE;
		textureSize = TERRAIN_TEXTURE_SIZE;
        
        borderPoints = bp;
        canvasHeight = ch;
        xOffset = xo;
        yOffset = yo;
        
        maxX = -kMAX_POSITION;
	}
	return self;
}

/** @brief Prepares rendering
 */
- (void) prepareRendering {
    assert(self.textureFile);
    
    self.stripes = [self generateStripesSprite];
    
    [self loadBorderVertices];
    [self calcHillVertices];
}

/** @brief Load border vertices from an NSArray of points into borderVertices array. 
 * These vertices are from svg file written by Inkscape. 
 * So the given points have (0,0) on top-left corner. We need to convert the Y value in the points to openGL by subtracting it from the canvas height of the SVG file.
 * xOffset and yOffset is added to the x,y values of poins in borderPoints. These offsets are zero for now, but in the future we might have some meaningful values for border instantation. 
 */
- (void) loadBorderVertices
{
    assert([borderPoints count]>1);

    CGPoint p;
    
    nBorderVertices = 0;
    
    for (uint32 i = 0; i< [borderPoints count]; i++) 
    {
        // BUGBUG : understand why this is needed.
        if([[borderPoints objectAtIndex:i] length]<2) continue;
            
        p = CGPointFromString([NSString stringWithFormat:@"{%@}",[borderPoints objectAtIndex:i]]);
            
        p.x += xOffset; 
        p.y += yOffset;
            
        // convert Svg(top-left is 0,0) to OpenGL(bottom left is 0,0)
        p.y = canvasHeight-p.y;
        
        borderVertices[nBorderVertices++] = p;
        
        if ( maxX < p.x )
            maxX = p.x;
        
        assert( nBorderVertices < kMaxBorderVertices );
    }
}


- (void) dealloc {

    self.textureFile = nil;
    
#ifndef DRAW_BOX2D_WORLD
	
	self.stripes = nil;
	
#endif

	[super dealloc];
}

/** @brief Is the terrain below the Hero?
 */
- (BOOL) isBelowHero:(float)heroY_withoutZoom {
    // Is the terrain within the screen?
    if ( startBorderIndex < endBorderIndex )
    {
        // Is Hero between the start point and end point of the terrain to draw on screen?
        if ( borderVertices[startBorderIndex].x <= _offsetX &&
            _offsetX <= borderVertices[endBorderIndex].x )
        {
            if (heroY_withoutZoom > borderVertices[rightBeforeHeroIndex].y)
                return YES;
        }
    }
    return NO;
}

/** @brief Calculate the index to the borderVertices array for the point right before the hero X( _offsetX ), 
    set it to heroIndex.
 */
- (void) calcRightBeforeHeroIndex
{
	while (rightBeforeHeroIndex < nBorderVertices-1) {
        if ( borderVertices[rightBeforeHeroIndex+1].x >= _offsetX)
            break;
		rightBeforeHeroIndex++;
	}
}


/** @brief Calculate the starting index to the borderVertices array to draw on screen based on _offsetX, set it to startBorderIndex.
 */
- (void) calcStartBorderIndex:(int)windowLeftX
{

	while (startBorderIndex < nBorderVertices-1) {
        if ( borderVertices[startBorderIndex+1].x >= windowLeftX)
            break;
		startBorderIndex++;
	}

    if ( startBorderIndex >= nBorderVertices )
        startBorderIndex = nBorderVertices -1;
}

/** @brief Calculate the ending index to the borderVertices array to draw on screen based on _offsetX, set it to endBorderIndex.
 */
-(void) calcEndBorderIndex:(int)windowRightX
{
    while (endBorderIndex < nBorderVertices) 
    {
        if (borderVertices[endBorderIndex].x >= windowRightX)
            break;
		endBorderIndex++;
    }
    
    if ( endBorderIndex >= nBorderVertices )
        endBorderIndex = nBorderVertices -1;
}

/** @brief Convert the index of borderVertices to the one of hillVertices and hillTexCoords
 */
inline int getVertexIndexFromBorderIndex(int borderIndex)
{
    // For each point in a border, hillVertices and hillTextCoords have (kTerrainVerticalSegments+1) points.
    // Ex> 1 segment = 4 points, 2 segments = 8 points.
    
    assert(kTerrainVerticalSegments == 1);
    //return borderIndex * (kTerrainVerticalSegments+1) * 2;
    return borderIndex << 2;
}

- (void) calcHillVertices {
#ifdef DRAW_BOX2D_WORLD
	return;
#endif
    assert( self.thickness <= textureSize);
    float thicknessRatio = self.thickness/(float)textureSize;
    
    // vertices for visible area
    nHillVertices = 0;
    CGPoint p0, p1;
    p0 = borderVertices[0];
    for (int i=1; i<nBorderVertices; i++) {
        p1 = borderVertices[i];
        
        int vSegments = kTerrainVerticalSegments;
        
        for (int k=0; k<vSegments+1; k++) {
            float vSegOffset = (float)textureSize/vSegments * k * thicknessRatio;

            // The direction of rendering terrain.
            if ( ! renderUpside )
                vSegOffset = -vSegOffset;
            
            hillVertices[nHillVertices] = ccp(p0.x, p0.y + vSegOffset);
            // To map the texture from top to bottom, we subtract Y coord from 1. (OpenGL coord system => TOP=1, BOTTOM=0)
            hillTexCoords[nHillVertices++] = ccp(p0.x/(float)textureSize, 1-(float)(k)/vSegments * thicknessRatio);
            hillVertices[nHillVertices] = ccp(p1.x, p1.y + vSegOffset);
            hillTexCoords[nHillVertices++] = ccp(p1.x/(float)textureSize, 1-(float)(k)/vSegments * thicknessRatio);
        }
        
        p0 = p1;
    }
}



- (ccColor4F) randomColor {
	const int minSum = 450;
	const int minDelta = 150;
	int r, g, b, min, max;
	while (true) {
		r = arc4random()%256;
		g = arc4random()%256;
		b = arc4random()%256;
		min = MIN(MIN(r, g), b);
		max = MAX(MAX(r, g), b);
		if (max-min < minDelta) continue;
		if (r+g+b < minSum) continue;
		break;
	}
	return ccc4FFromccc3B(ccc3(r, g, b));
}

- (void) draw {

#ifdef DRAW_BOX2D_WORLD
	
	glDisable(GL_TEXTURE_2D);
	glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	glDisableClientState(GL_COLOR_ARRAY);
	
	world->DrawDebugData();
	
	glEnableClientState(GL_COLOR_ARRAY);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	glEnable(GL_TEXTURE_2D);	
	
#else
    if ( endBorderIndex - startBorderIndex <= 0  )
    {
        return;
    }
    
PROF_BEGIN(terrain_draw);

    CGPoint * hillVerticesToDraw = nil;
    CGPoint * hillTexCoordsToDraw = nil;
    int drawingVertexCount = 0;
    
    // calculate the pointers to pass OpenGL API based on calcStartBorderIndex and calcEndBorderIndex
    {
        assert( startBorderIndex < nBorderVertices );
        assert( endBorderIndex < nBorderVertices );

        int startHillVertexIndex = getVertexIndexFromBorderIndex(startBorderIndex);
        int endHillVertexIndex_Exclusive = getVertexIndexFromBorderIndex(endBorderIndex);
        assert( startHillVertexIndex <= nHillVertices );
        assert( endHillVertexIndex_Exclusive <= nHillVertices );

        drawingVertexCount = endHillVertexIndex_Exclusive - startHillVertexIndex;
    //    assert( drawingVertexCount>=0 );
        
        hillVerticesToDraw  = & hillVertices[startHillVertexIndex];
        hillTexCoordsToDraw = & hillTexCoords[startHillVertexIndex];
    }
    
    // Actual drawing routine : Draw only if we have some terrain to draw. (We may not have any terrain to draw if _offsetX went too far.
    assert (drawingVertexCount > 0);
    {
        glBindTexture(GL_TEXTURE_2D, _stripes.texture.name);
        
        
        glDisableClientState(GL_COLOR_ARRAY);
        
        glColor4f(1, 1, 1, 1);
        glVertexPointer(2, GL_FLOAT, 0, hillVerticesToDraw);
        
        glTexCoordPointer(2, GL_FLOAT, 0, hillTexCoordsToDraw);
        
        glDrawArrays(GL_TRIANGLE_STRIP, 0, drawingVertexCount);
        
        glEnableClientState(GL_COLOR_ARRAY);
        
        //CCLOG(@"Drawing vertexes:%d", drawingVertexCount);
        
        //for (int i=0; i<drawingVertexCount; i++ )
        //{
        //    CCLOG(@"V(%f,%f)", hillVerticesToDraw[i].x, hillVerticesToDraw[i].y);
        //    CCLOG(@"T(%f,%f)", hillTexCoordsToDraw[i].x, hillTexCoordsToDraw[i].y);
        //}
    }
PROF_END(terrain_draw);
#endif
 
}

- (float) borderMinX {
    return borderVertices[0].x;
}
- (float) borderMaxX {
    return borderVertices[nBorderVertices-1].x;
}

/** @brief Calculate minimum Y value of the border we are drawing now!
 */
- (float) calcBorderMinY {
    float minBorderY = kMAX_POSITION;
    if ( startBorderIndex < endBorderIndex )
    {
        for (int i=startBorderIndex; i<endBorderIndex; i++)
        {
            float borderY = borderVertices[i].y;
            if (minBorderY > borderY)
                minBorderY = borderY;
        }
    }
    return minBorderY;
}

- (void) setHeroX:(float)offsetX position:(CGPoint)position windowLeftX:(int)windowLeftX windowRightX:(int)windowRightX{
	static BOOL firstTime = YES;
	if (_offsetX != offsetX || firstTime) {
		firstTime = NO;
		_offsetX = offsetX;
        
		self.position = position;
        
        // calculate the range of border indexes to borderVertices array to draw on screen. 
        [self calcStartBorderIndex:windowLeftX];
        [self calcEndBorderIndex:windowRightX];
        [self calcRightBeforeHeroIndex];
        //CCLOG(@"StartBorderIndex: %d, EndBorderIndex:%d", startBorderIndex, endBorderIndex);
//		[self resetHillVertices];
	}
}

- (void) reset {
#ifndef DRAW_BOX2D_WORLD
	self.stripes = [self generateStripesSprite];
#endif
	
	startBorderIndex = 0;
	endBorderIndex = 0;
    rightBeforeHeroIndex = 0;
}



- (CCSprite*) generateStripesSprite {
	
	CCTexture2D *texture = [self generateStripesTexture];
	CCSprite *sprite = [CCSprite spriteWithTexture:texture];
	ccTexParams tp = {GL_LINEAR, GL_LINEAR, GL_REPEAT, GL_CLAMP_TO_EDGE};
	[sprite.texture setTexParameters:&tp];
	
	return sprite;
}

- (CCTexture2D*) generateStripesTexture {
	
	CCRenderTexture *rt = [CCRenderTexture renderTextureWithWidth:textureSize height:textureSize];
	[rt begin];
    
    assert(self.textureFile);
    [self renderImage:self.textureFile];
	//[self renderStripes];
	[self renderGradient];
	[self renderHighlight];
	[self renderTopBorder];
	[self renderNoise];
    
	[rt end];
	
	return rt.sprite.texture;
}

- (void) renderStripes {
	
	const int minStripes = 4;
	const int maxStripes = 30;
	
	// random even number of stripes
	int nStripes = arc4random()%(maxStripes-minStripes)+minStripes;
	if (nStripes%2) {
		nStripes++;
	}
    //	NSLog(@"nStripes = %d", nStripes);
	
	CGPoint *vertices = (CGPoint*)malloc(sizeof(CGPoint)*nStripes*6);
	ccColor4F *colors = (ccColor4F*)malloc(sizeof(ccColor4F)*nStripes*6);
	int nVertices = 0;
	
	float x1, x2, y1, y2, dx, dy;
	ccColor4F c;
	
	if (arc4random()%2) {
		
		// diagonal stripes
		
		dx = (float)textureSize*2 / (float)nStripes;
		dy = 0;
		
		x1 = -textureSize;
		y1 = 0;
		
		x2 = 0;
		y2 = textureSize;
		
		for (int i=0; i<nStripes/2; i++) {
			c = [self randomColor];
			for (int j=0; j<2; j++) {
				for (int k=0; k<6; k++) {
					colors[nVertices+k] = c;
				}
				vertices[nVertices++] = ccp(x1+j*textureSize, y1);
				vertices[nVertices++] = ccp(x1+j*textureSize+dx, y1);
				vertices[nVertices++] = ccp(x2+j*textureSize, y2);
				vertices[nVertices++] = vertices[nVertices-2];
				vertices[nVertices++] = vertices[nVertices-2];
				vertices[nVertices++] = ccp(x2+j*textureSize+dx, y2);
			}
			x1 += dx;
			x2 += dx;
		}
		
	} else {
		
		// horizontal stripes
		
		dx = 0;
		dy = (float)textureSize / (float)nStripes;
		
		x1 = 0;
		y1 = 0;
		
		x2 = textureSize;
		y2 = 0;
		
		for (int i=0; i<nStripes; i++) {
			c = [self randomColor];
			for (int k=0; k<6; k++) {
				colors[nVertices+k] = c;
			}
			vertices[nVertices++] = ccp(x1, y1);
			vertices[nVertices++] = ccp(x2, y2);
			vertices[nVertices++] = ccp(x1, y1+dy);
			vertices[nVertices++] = vertices[nVertices-2];
			vertices[nVertices++] = vertices[nVertices-2];
			vertices[nVertices++] = ccp(x2, y2+dy);
			y1 += dy;
			y2 += dy;
		}
		
	}
	
	glDisable(GL_TEXTURE_2D);
	glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	
	glColor4f(1, 1, 1, 1);
	glVertexPointer(2, GL_FLOAT, 0, vertices);
	glColorPointer(4, GL_FLOAT, 0, colors);
	glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
	glDrawArrays(GL_TRIANGLES, 0, (GLsizei)nVertices);
	
	free(vertices);
	free(colors);
}

- (void) renderGradient {
	
	float gradientAlpha = 0.5f;
	float gradientWidth = textureSize;
	
	CGPoint vertices[6];
	ccColor4F colors[6];
	int nVertices = 0;
	
	vertices[nVertices] = ccp(0, 0);
	colors[nVertices++] = (ccColor4F){0, 0, 0, 0};
	vertices[nVertices] = ccp(textureSize, 0);
	colors[nVertices++] = (ccColor4F){0, 0, 0, 0};
	
	vertices[nVertices] = ccp(0, gradientWidth);
	colors[nVertices++] = (ccColor4F){0, 0, 0, gradientAlpha};
	vertices[nVertices] = ccp(textureSize, gradientWidth);
	colors[nVertices++] = (ccColor4F){0, 0, 0, gradientAlpha};
	
	if (gradientWidth < textureSize) {
		vertices[nVertices] = ccp(0, textureSize);
		colors[nVertices++] = (ccColor4F){0, 0, 0, gradientAlpha};
		vertices[nVertices] = ccp(textureSize, textureSize);
		colors[nVertices++] = (ccColor4F){0, 0, 0, gradientAlpha};
	}
	
	glVertexPointer(2, GL_FLOAT, 0, vertices);
	glColorPointer(4, GL_FLOAT, 0, colors);
	glDrawArrays(GL_TRIANGLE_STRIP, 0, (GLsizei)nVertices);
}

- (void) renderHighlight {
	
	float highlightAlpha = 0.5f;
	float highlightWidth = textureSize/4;
	
	CGPoint vertices[4];
	ccColor4F colors[4];
	int nVertices = 0;
	
	vertices[nVertices] = ccp(0, 0);
	colors[nVertices++] = (ccColor4F){1, 1, 0.5f, highlightAlpha}; // yellow
	vertices[nVertices] = ccp(textureSize, 0);
	colors[nVertices++] = (ccColor4F){1, 1, 0.5f, highlightAlpha};
	
	vertices[nVertices] = ccp(0, highlightWidth);
	colors[nVertices++] = (ccColor4F){0, 0, 0, 0};
	vertices[nVertices] = ccp(textureSize, highlightWidth);
	colors[nVertices++] = (ccColor4F){0, 0, 0, 0};
	
	glVertexPointer(2, GL_FLOAT, 0, vertices);
	glColorPointer(4, GL_FLOAT, 0, colors);
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	glDrawArrays(GL_TRIANGLE_STRIP, 0, (GLsizei)nVertices);
}

- (void) renderTopBorder {
	
	float borderAlpha = 0.5f;
	float borderWidth = 2.0f;
	
	CGPoint vertices[2];
	int nVertices = 0;
	
	vertices[nVertices++] = ccp(0, borderWidth/2);
	vertices[nVertices++] = ccp(textureSize, borderWidth/2);
	
	glDisableClientState(GL_COLOR_ARRAY);
	
	glLineWidth(borderWidth);
	glColor4f(0, 0, 0, borderAlpha);
	glVertexPointer(2, GL_FLOAT, 0, vertices);
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	glDrawArrays(GL_LINE_STRIP, 0, (GLsizei)nVertices);
}

- (void) renderNoise {
	
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	glEnable(GL_TEXTURE_2D);
	
	CCSprite *s = [CCSprite spriteWithFile:@"noise.png"];
	[s setBlendFunc:(ccBlendFunc){GL_DST_COLOR, GL_ZERO}];
	s.position = ccp(textureSize/2, textureSize/2);
	s.scale = (float)textureSize/512.0f;
	glColor4f(1, 1, 1, 1);
	[s visit];
	[s visit]; // more contrast
}


- (void) renderImage:(NSString*)imageFileName {
	
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	glEnable(GL_TEXTURE_2D);
	
	CCSprite *s = [CCSprite spriteWithFile:imageFileName];
    
	//[s setBlendFunc:(ccBlendFunc){GL_DST_COLOR, GL_ZERO}];
	s.position = ccp(s.contentSize.width/2, s.contentSize.height/2);
	s.scale = 1;
	glColor4f(1, 1, 1, 1);
	[s visit];
	[s visit]; // more contrast
}

@end
