//
//  NezAletterationDefinitionBubble.m
//  AletterationX
//
//  Created by David Nesbitt on 2014/03/25.
//  Copyright (c) 2014 David Nesbitt. All rights reserved.
//

#import "NezAletterationDefinitionBubble.h"
#import "NezAletterationDefinition.h"
#import "NezAletterationRetiredWord.h"
#import "NezAletterationRetiredWordBoard.h"
#import "NezClickableNode.h"
#import "NezAletterationGraphics.h"

static const float kScale = 0.1;

static const float kMouthWidth = 12.0;
static const float kMouthHeight = 25.0;
static const float kBorderWidth = 6.0;
static const float kCornerRadius = kBorderWidth*0.5;
static const float kCircleApproximationFactor = 0.55191502449;
static const float kBubbleExtrusionDepth = 0.5;
static const float kZFactor = 1.0; // the bubble's z value will be kZFactor*letterBockSize.z

static const NSSize kNextDefArrowBaseSize = {12, 4.0};
static const NSSize kNextDefArrowTipSize = {6, 8};

typedef enum CircleQuadrant {
	kQuadrantTopRight = 0,
	kQuadrantBottomRight,
	kQuadrantBottomLeft,
	kQuadrantTopLeft,
} CircleQuadrant;

@implementation NezAletterationDefinitionBubble {
	SCNNode *_bubbleNode;
	SCNNode *_bubbleInnerNode;
	SCNNode *_bubbleMouthNode;
	SCNNode *_bubbleCornerTRNode;
	SCNNode *_bubbleCornerBRNode;
	SCNNode *_bubbleCornerBLNode;
	SCNNode *_bubbleCornerTLNode;
	
	SCNNode *_bubbleLeftSideNode;
	SCNNode *_bubbleRightSideNode;
	SCNNode *_bubbleTopSideNode;
	SCNNode *_bubbleBottomSideNode;
	
	SCNNode *_textNode;
	
	NezClickableNode *_nextDefinitionArrow;
	
	SCNMaterial *_bubbleMaterial;
	SCNMaterial *_textMaterial;
	
	BOOL _isRunning;
}

+(instancetype)bubble {
	return [[self alloc] init];
}

-(instancetype)init {
	if ((self = [super init])) {
		_bubbleNode = [SCNNode node];
		
		_textMaterial = [NezAletterationGraphics colorMaterial:[NSColor whiteColor]];
		_bubbleMaterial = [NezAletterationGraphics colorMaterial:[NSColor blackColor]];

		self.scale = SCNVector3Make(kScale, kScale, kScale);
		
		float innerWidth = kMouthWidth+kBorderWidth*12.0;
		float innerHeight = kMouthHeight+kBorderWidth*2.0;

		_bubbleInnerNode = [SCNNode nodeWithGeometry:[self rectangleShapeWithWidth:1.0 andHeight:1.0]];
		_bubbleInnerNode.scale = SCNVector3Make(innerWidth, innerHeight, 1.0);
		_bubbleInnerNode.geometry.firstMaterial = _bubbleMaterial;
		_bubbleInnerNode.renderingOrder = NEZ_ALETTERATION_GRAPHICS_RENDERING_ORDER_DEFINITION_BUBBLE;
		[_bubbleNode addChildNode:_bubbleInnerNode];
		
		_bubbleMouthNode = [SCNNode nodeWithGeometry:[self bubbleMouthShape]];
		_bubbleMouthNode.geometry.firstMaterial = _bubbleMaterial;
		_bubbleMouthNode.renderingOrder = NEZ_ALETTERATION_GRAPHICS_RENDERING_ORDER_DEFINITION_BUBBLE;
		_bubbleMouthNode.position = SCNVector3Make(innerWidth*0.5+kMouthWidth*0.48, 0.0, 0.0);
		[_bubbleNode addChildNode:_bubbleMouthNode];
		
		_bubbleCornerTLNode = [SCNNode nodeWithGeometry:[self bubbleCornerShapeWithQuadrant:kQuadrantTopLeft]];
		_bubbleCornerTLNode.geometry.firstMaterial = _bubbleMaterial;
		_bubbleCornerTLNode.renderingOrder = NEZ_ALETTERATION_GRAPHICS_RENDERING_ORDER_DEFINITION_BUBBLE;
		_bubbleCornerTLNode.position = SCNVector3Make(-innerWidth*0.5, innerHeight*0.5, 0.0);
		[_bubbleNode addChildNode:_bubbleCornerTLNode];
		
		_bubbleCornerBLNode = [SCNNode nodeWithGeometry:[self bubbleCornerShapeWithQuadrant:kQuadrantBottomLeft]];
		_bubbleCornerBLNode.geometry.firstMaterial = _bubbleMaterial;
		_bubbleCornerBLNode.renderingOrder = NEZ_ALETTERATION_GRAPHICS_RENDERING_ORDER_DEFINITION_BUBBLE;
		_bubbleCornerBLNode.position = SCNVector3Make(-innerWidth*0.5, -innerHeight*0.5, 0.0);
		[_bubbleNode addChildNode:_bubbleCornerBLNode];
		
		_bubbleCornerTRNode = [SCNNode nodeWithGeometry:[self bubbleCornerShapeWithQuadrant:kQuadrantTopRight]];
		_bubbleCornerTRNode.geometry.firstMaterial = _bubbleMaterial;
		_bubbleCornerTRNode.renderingOrder = NEZ_ALETTERATION_GRAPHICS_RENDERING_ORDER_DEFINITION_BUBBLE;
		_bubbleCornerTRNode.position = SCNVector3Make(innerWidth*0.5, innerHeight*0.5, 0.0);
		[_bubbleNode addChildNode:_bubbleCornerTRNode];
		
		_bubbleCornerBRNode = [SCNNode nodeWithGeometry:[self bubbleCornerShapeWithQuadrant:kQuadrantBottomRight]];
		_bubbleCornerBRNode.geometry.firstMaterial = _bubbleMaterial;
		_bubbleCornerBRNode.renderingOrder = NEZ_ALETTERATION_GRAPHICS_RENDERING_ORDER_DEFINITION_BUBBLE;
		_bubbleCornerBRNode.position = SCNVector3Make(innerWidth*0.5, -innerHeight*0.5, 0.0);
		[_bubbleNode addChildNode:_bubbleCornerBRNode];
		
		_bubbleLeftSideNode = [SCNNode nodeWithGeometry:[self rectangleShapeWithWidth:kBorderWidth andHeight:1.0]];
		_bubbleLeftSideNode.geometry.firstMaterial = _bubbleMaterial;
		_bubbleLeftSideNode.renderingOrder = NEZ_ALETTERATION_GRAPHICS_RENDERING_ORDER_DEFINITION_BUBBLE;
		_bubbleLeftSideNode.scale = SCNVector3Make(1.0, innerHeight, 1.0);
		_bubbleLeftSideNode.position = SCNVector3Make(-innerWidth*0.5-kCornerRadius, 0.0, 0.0);
		[_bubbleNode addChildNode:_bubbleLeftSideNode];
		
		_bubbleRightSideNode = [SCNNode nodeWithGeometry:[self rectangleShapeWithWidth:kBorderWidth andHeight:1.0]];
		_bubbleRightSideNode.geometry.firstMaterial = _bubbleMaterial;
		_bubbleRightSideNode.renderingOrder = NEZ_ALETTERATION_GRAPHICS_RENDERING_ORDER_DEFINITION_BUBBLE;
		_bubbleRightSideNode.scale = SCNVector3Make(1.0, innerHeight, 1.0);
		_bubbleRightSideNode.position = SCNVector3Make(innerWidth*0.5+kCornerRadius, 0.0, 0.0);
		[_bubbleNode addChildNode:_bubbleRightSideNode];
		
		_bubbleTopSideNode = [SCNNode nodeWithGeometry:[self rectangleShapeWithWidth:1.0 andHeight:kBorderWidth]];
		_bubbleTopSideNode.geometry.firstMaterial = _bubbleMaterial;
		_bubbleTopSideNode.renderingOrder = NEZ_ALETTERATION_GRAPHICS_RENDERING_ORDER_DEFINITION_BUBBLE;
		_bubbleTopSideNode.scale = SCNVector3Make(innerWidth, 1.0, 1.0);
		_bubbleTopSideNode.position = SCNVector3Make(0.0, innerHeight*0.5+kCornerRadius, 0.0);
		[_bubbleNode addChildNode:_bubbleTopSideNode];
		
		_bubbleBottomSideNode = [SCNNode nodeWithGeometry:[self rectangleShapeWithWidth:1.0 andHeight:kBorderWidth]];
		_bubbleBottomSideNode.geometry.firstMaterial = _bubbleMaterial;
		_bubbleBottomSideNode.renderingOrder = NEZ_ALETTERATION_GRAPHICS_RENDERING_ORDER_DEFINITION_BUBBLE;
		_bubbleBottomSideNode.scale = SCNVector3Make(innerWidth, 1.0, 1.0);
		_bubbleBottomSideNode.position = SCNVector3Make(0.0, -innerHeight*0.5-kCornerRadius, 0.0);
		[_bubbleNode addChildNode:_bubbleBottomSideNode];
		
		_nextDefinitionArrow = [NezClickableNode nodeWithGeometry:[self nextDefinitionArrow:kNextDefArrowBaseSize tipSize:kNextDefArrowTipSize hollow:0]];
		_nextDefinitionArrow.renderingOrder = NEZ_ALETTERATION_GRAPHICS_RENDERING_ORDER_DEFINITION_TEXT;
		_nextDefinitionArrow.geometry.firstMaterial = _textMaterial;
		_nextDefinitionArrow.position = SCNVector3Make(innerWidth*0.5-kNextDefArrowBaseSize.width*0.5-kBorderWidth, innerHeight*0.5-kNextDefArrowTipSize.height*0.5-kBorderWidth*0.25, 0.0);
//		[_bubbleNode addChildNode:_nextDefinitionArrow];
	}
	return self;
}

-(void)setDefinitionWithRetiredWord:(NezAletterationRetiredWord*)retiredWord {
	if (_isRunning) {
		return;
	}
	_isRunning = YES;
	SCNNode *oldTextNode = _textNode;
	SCNVector3 oldPosition = oldTextNode.position;
	_textNode = retiredWord.definition.nextTextNode;
	SCNText *text = (SCNText*)_textNode.geometry;
	CGSize textSize = text.textSize;
	if (textSize.height < kMouthHeight) {
		textSize.height = kMouthHeight;
	}
	SCNVector3 letterBlockSize = [NezAletterationGraphics letterBlockSize];
	SCNVector3 newPosition = SCNVector3Make(-textSize.width*0.5, textSize.height*0.5+2.5, 1.5);

	if (_textNode == oldTextNode) {
		return;
	}
	if (oldTextNode) {
		float scale1 = newPosition.x/oldPosition.x;
		float scale2 = newPosition.y/oldPosition.y;
		float scale = scale1<scale2?scale1:scale2;

		[SCNTransaction begin];
		[SCNTransaction setCompletionBlock:^{
			[oldTextNode removeFromParentNode];
		}];
		[SCNTransaction setAnimationDuration:1.0];
		oldTextNode.opacity = 0.0;
		oldTextNode.scale = SCNVector3Make(scale, scale, scale);
		oldTextNode.position = SCNVector3Make(oldPosition.x*scale, oldPosition.y*scale, oldPosition.z);
		[SCNTransaction commit];
	}
	if (!retiredWord.definition) {
		_textNode = nil;
		return;
	}
	
	CATransform3D newTransform = CATransform3DTranslate(CATransform3DScale(retiredWord.transform, kScale, kScale, kScale), (textSize.width+kMouthWidth*2.0+kBorderWidth+retiredWord.length*letterBlockSize.x*(1.0/kScale))*0.5, 0.0, letterBlockSize.z*(kZFactor/kScale));
	GLKMatrix4 m = GLKMatrix4FromCATransform3D(newTransform);
	GLKVector4 v = GLKMatrix4MultiplyVector4(m, GLKVector4Make(0.0, textSize.height*0.5, 0.0, 1.0));
	NezAletterationRetiredWordBoard *wb = (NezAletterationRetiredWordBoard*)self.parentNode;
	SCNVector3 wbSize = wb.dimensions;
	float y = v.y-wbSize.y*0.5;
	if (y > 0.0) {
		newTransform = CATransform3DTranslate(newTransform, 0.0, -y*(1.0/kScale), 0.0);
	} else {
		y = 0.0;
	}
	if (oldTextNode && _bubbleNode.parentNode) {
		float scale1 = oldPosition.x/newPosition.x;
		float scale2 = oldPosition.y/newPosition.y;
		float scale = scale1<scale2?scale1:scale2;
		
		_textNode.scale = SCNVector3Make(scale, scale, scale);
		_textNode.position = SCNVector3Make(newPosition.x*scale, newPosition.y*scale, newPosition.z);
	} else {
		_textNode.scale = SCNVector3Make(1.0, 1.0, 1.0);
		_textNode.position = newPosition;
		self.transform = newTransform;
		
		_bubbleNode.opacity = 0.0;
		[self addChildNode:_bubbleNode];
		[SCNTransaction begin];
		[SCNTransaction setAnimationDuration:1.0];
		_bubbleNode.opacity = 1.0;
		[SCNTransaction commit];
	}
	_textNode.geometry.firstMaterial = _textMaterial;
	_textNode.opacity = 0.0;
	[_bubbleNode addChildNode:_textNode];
	
	if (oldTextNode) {
		[SCNTransaction begin];
		[SCNTransaction setAnimationDuration:1.0];
	}
	_bubbleInnerNode.scale = SCNVector3Make(textSize.width, textSize.height, 1.0);
	_bubbleMouthNode.position = SCNVector3Make(-textSize.width*0.5-kMouthWidth*0.5, y*(1.0/kScale), 0.0);
	
	_bubbleCornerTRNode.position = SCNVector3Make(textSize.width*0.5, textSize.height*0.5, 0.0);
	_bubbleCornerBRNode.position = SCNVector3Make(textSize.width*0.5, -textSize.height*0.5, 0.0);
	_bubbleCornerBLNode.position = SCNVector3Make(-textSize.width*0.5, -textSize.height*0.5, 0.0);
	_bubbleCornerTLNode.position = SCNVector3Make(-textSize.width*0.5, textSize.height*0.5, 0.0);
	
	_bubbleLeftSideNode.scale = SCNVector3Make(1.0, textSize.height, 1.0);
	_bubbleLeftSideNode.position = SCNVector3Make(-textSize.width*0.5-kCornerRadius, 0.0, 0.0);
	_bubbleRightSideNode.scale = SCNVector3Make(1.0, textSize.height, 1.0);
	_bubbleRightSideNode.position = SCNVector3Make(textSize.width*0.5+kCornerRadius, 0.0, 0.0);
	_bubbleTopSideNode.scale = SCNVector3Make(textSize.width, 1.0, 1.0);
	_bubbleTopSideNode.position = SCNVector3Make(0.0, textSize.height*0.5+kCornerRadius, 0.0);
	_bubbleBottomSideNode.scale = SCNVector3Make(textSize.width, 1.0, 1.0);
	_bubbleBottomSideNode.position = SCNVector3Make(0.0, -textSize.height*0.5-kCornerRadius, 0.0);

	//	_nextDefinitionArrow.position = SCNVector3Make(textSize.width*0.5-kNextDefArrowBaseSize.width*0.5-kBorderWidth, textSize.height*0.5-kNextDefArrowTipSize.height*0.5-kBorderWidth*0.25, 0.0);
	
	_textNode.opacity = 1.0;
	_textNode.scale = SCNVector3Make(1.0, 1.0, 1.0);
	_textNode.position = newPosition;
	
	self.transform = newTransform;
	
	if (oldTextNode) {
		[SCNTransaction setCompletionBlock:^{
			_isRunning = NO;
		}];
		[SCNTransaction commit];
	} else {
		_isRunning = NO;
	}
}

-(BOOL)isShowing {
	return (_bubbleNode.parentNode != nil);
}

-(SCNShape*)rectangleShapeWithWidth:(float)width andHeight:(float)height {
	NSBezierPath *path = [NSBezierPath bezierPath];
	
	float hw = width*0.5;
	float hh = height*0.5;
	
	[path moveToPoint:NSMakePoint( hw, hh)];
	[path lineToPoint:NSMakePoint( hw,-hh)];
	[path lineToPoint:NSMakePoint(-hw,-hh)];
	[path lineToPoint:NSMakePoint(-hw, hh)];
	
	[path closePath];
	path.flatness = 0.025;
	
	SCNShape *shape = [SCNShape shapeWithPath:path extrusionDepth:kBubbleExtrusionDepth];
	
	return shape;
}

-(SCNShape*)bubbleMouthShape {
	NSBezierPath *bubblePath = [NSBezierPath bezierPath];
	
	float mouthW = kMouthWidth;
	float mouthHH = kMouthHeight*0.5;
	
	[bubblePath moveToPoint:NSMakePoint(-mouthW, 0.0)];
	[bubblePath curveToPoint:NSMakePoint(0.0, mouthHH) controlPoint1:NSMakePoint(0.0, mouthHH*0.25) controlPoint2:NSMakePoint(0.0, mouthHH*0.75)];
	[bubblePath lineToPoint:NSMakePoint(0.0, -mouthHH)];
	[bubblePath curveToPoint:NSMakePoint(-mouthW, 0.0) controlPoint1:NSMakePoint(0.0, -mouthHH*0.75) controlPoint2:NSMakePoint(0.0, -mouthHH*0.25)];
	
	[bubblePath closePath];
	bubblePath.flatness = 0.025;
	
	SCNShape *shape = [SCNShape shapeWithPath:bubblePath extrusionDepth:kBubbleExtrusionDepth];
	
	return shape;
}

-(SCNShape*)bubbleCornerShapeWithQuadrant:(CircleQuadrant)quadrant {
	NSBezierPath *bubblePath = [NSBezierPath bezierPath];
	
	float r = kBorderWidth;
	float c = kBorderWidth*kCircleApproximationFactor;
/*
	 P_0 = ( 0, r), P_1 = ( c, r), P_2 = ( r, c), P_3 = ( r, 0) TR
	 P_0 = ( r, 0), P_1 = ( r,-c), P_2 = ( c,-r), P_3 = ( 0,-r) BR
	 P_0 = ( 0,-r), P_1 = (-c,-r), P_3 = (-r,-c), P_4 = (-r, 0) BL
	 P_0 = (-r, 0), P_1 = (-r, c), P_2 = (-c, r), P_3 = ( 0, r) TL
*/
	
	switch (quadrant) {
		case kQuadrantTopRight: {
			[bubblePath moveToPoint:NSMakePoint(0, r)];
			[bubblePath curveToPoint:NSMakePoint(r, 0) controlPoint1:NSMakePoint(c, r) controlPoint2:NSMakePoint(r, c)];
			break;
		} case kQuadrantBottomRight: {
			[bubblePath moveToPoint:NSMakePoint(r, 0)];
			[bubblePath curveToPoint:NSMakePoint(0, -r) controlPoint1:NSMakePoint(r, -c) controlPoint2:NSMakePoint(c, -r)];
			break;
		} case kQuadrantBottomLeft: {
			[bubblePath moveToPoint:NSMakePoint(0, -r)];
			[bubblePath curveToPoint:NSMakePoint(-r, 0) controlPoint1:NSMakePoint(-c, -r) controlPoint2:NSMakePoint(-r, -c)];
			break;
		} case kQuadrantTopLeft: default: {
			[bubblePath moveToPoint:NSMakePoint(-r, 0)];
			[bubblePath curveToPoint:NSMakePoint(0, r) controlPoint1:NSMakePoint(-r, c) controlPoint2:NSMakePoint(-c, r)];
			break;
		}
	}
	[bubblePath lineToPoint:NSMakePoint(0, 0)];
	[bubblePath closePath];
	bubblePath.flatness = 0.025;
	
	SCNShape *shape = [SCNShape shapeWithPath:bubblePath extrusionDepth:kBubbleExtrusionDepth];
	
	return shape;
}

-(SCNShape*)nextDefinitionArrow:(NSSize)baseSize tipSize:(NSSize)tipSize hollow:(CGFloat)hollow {
	NSBezierPath *arrow = [NSBezierPath bezierPath];
	
	float h[5];
	float w[4];
	
	w[0] = 0;
	w[1] = baseSize.width - tipSize.width - hollow;
	w[2] = baseSize.width - tipSize.width;
	w[3] = baseSize.width;
	
	h[0] = 0;
	h[1] = (tipSize.height - baseSize.height) * 0.5;
	h[2] = (tipSize.height) * 0.5;
	h[3] = (tipSize.height + baseSize.height) * 0.5;
	h[4] = tipSize.height;
	
	[arrow moveToPoint:NSMakePoint(0, h[1])];
	[arrow lineToPoint:NSMakePoint(0, h[3])];
	
	[arrow lineToPoint:NSMakePoint(w[2], h[3])];
	[arrow lineToPoint:NSMakePoint(w[1], h[4])];
	[arrow lineToPoint:NSMakePoint(w[3], h[2])];
	[arrow lineToPoint:NSMakePoint(w[1], h[0])];
	[arrow lineToPoint:NSMakePoint(w[2], h[1])];
	
	[arrow closePath];
	arrow.flatness = 0.025;
	
	SCNShape *shape = [SCNShape shapeWithPath:arrow extrusionDepth:kBubbleExtrusionDepth];
	
	return shape;
}

-(void)reset {
	if (_bubbleNode.parentNode) {
		[SCNTransaction begin];
		[SCNTransaction setCompletionBlock:^{
			[_bubbleNode removeFromParentNode];
			[_textNode removeFromParentNode];
			_textNode = nil;
		}];
		[SCNTransaction setAnimationDuration:1.0];
		_bubbleNode.opacity = 0.0;
		[SCNTransaction commit];
	}
	
}

@end
