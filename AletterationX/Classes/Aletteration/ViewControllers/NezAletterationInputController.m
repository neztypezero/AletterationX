//
//  NezAletterationInputController.m
//  AletterationX
//
//  Created by David Nesbitt on 2014/02/12.
//  Copyright (c) 2014 David Nesbitt. All rights reserved.
//

#import "NezAletterationInputController.h"
#import "NezAletterationSCNView.h"
#import "NezClickableNode.h"

@implementation NezAletterationInputController {
	NezAletterationSCNView *_nezSCNAletterationView;
}

-(instancetype)initWithNezAletterationSCNView:(NezAletterationSCNView*)nezSCNAletterationView {
	if ((self = [super init])) {
		_nezSCNAletterationView = nezSCNAletterationView;
	}
	return self;
}

-(NezAletterationSCNView*)nezSCNAletterationView {
	return _nezSCNAletterationView;
}

-(void)keyDown:(NSEvent *)theEvent {}
-(void)keyUp:(NSEvent *)theEvent {}

-(void)controllerAdded {}
-(void)controllerRemoved {}

-(NSArray*)hitTestEvent:(NSEvent*)event {
	NSPoint winp = [event locationInWindow];
	NSPoint p = [self.nezSCNAletterationView convertPoint:winp fromView:nil];
	
	CGPoint p2 = CGPointMake(p.x, p.y);
	NSArray *hitItems = [(SCNView *)self.nezSCNAletterationView hitTest:p2 options:@{SCNHitTestSortResultsKey:@YES}];
	if (hitItems.count == 0 || (hitItems.count == 1 && ![hitItems.firstObject isKindOfClass:[NezClickableNode class]])) {
		[self nothingHitForEvent:event];
	}
	return hitItems;
}

-(void)nothingHitForEvent:(NSEvent*)event {}

-(void)mouseEntered:(NSEvent*)event {}
-(void)mouseExited:(NSEvent *)event {}

-(void)mouseMoved:(NSEvent*)event {
	NSArray *hitTestResults = [self hitTestEvent:event];
	for (SCNHitTestResult *result in hitTestResults) {
		if ([result.node isKindOfClass:[NezClickableNode class]]) {
			NezClickableNode *clickableObject = (NezClickableNode*)result.node;
			if (clickableObject.mouseMoved) {
				clickableObject.mouseMoved(self.nezSCNAletterationView, event);
			}
		}
	}
}

-(void)mouseDown:(NSEvent*)event {
	NSArray *hitTestResults = [self hitTestEvent:event];
	for (SCNHitTestResult *result in hitTestResults) {
		if ([result.node isKindOfClass:[NezClickableNode class]]) {
			NezClickableNode *clickableObject = (NezClickableNode*)result.node;
			if (clickableObject.mouseDown) {
				clickableObject.mouseDown(self.nezSCNAletterationView, event);
			}
		}
	}
}

-(void)mouseDragged:(NSEvent *)event {
	NSArray *hitTestResults = [self hitTestEvent:event];
	for (SCNHitTestResult *result in hitTestResults) {
		if ([result.node isKindOfClass:[NezClickableNode class]]) {
			NezClickableNode *clickableObject = (NezClickableNode*)result.node;
			if (clickableObject.mouseDragged) {
				clickableObject.mouseDragged(self.nezSCNAletterationView, event);
			}
		}
	}
}

-(void)mouseUp:(NSEvent *)event {
	NSArray *hitTestResults = [self hitTestEvent:event];
	for (SCNHitTestResult *result in hitTestResults) {
		if ([result.node isKindOfClass:[NezClickableNode class]]) {
			NezClickableNode *clickableObject = (NezClickableNode*)result.node;
			if (clickableObject.mouseUp) {
				clickableObject.mouseUp(self.nezSCNAletterationView, event);
			}
		}
	}
}

-(void)rightMouseDown:(NSEvent *)event {
	NSArray *hitTestResults = [self hitTestEvent:event];
	for (SCNHitTestResult *result in hitTestResults) {
		if ([result.node isKindOfClass:[NezClickableNode class]]) {
			NezClickableNode *clickableObject = (NezClickableNode*)result.node;
			if (clickableObject.rightMouseDown) {
				clickableObject.rightMouseDown(self.nezSCNAletterationView, event);
			}
		}
	}
}

-(void)rightMouseDragged:(NSEvent *)event {
	NSArray *hitTestResults = [self hitTestEvent:event];
	for (SCNHitTestResult *result in hitTestResults) {
		if ([result.node isKindOfClass:[NezClickableNode class]]) {
			NezClickableNode *clickableObject = (NezClickableNode*)result.node;
			if (clickableObject.rightMouseDragged) {
				clickableObject.rightMouseDragged(self.nezSCNAletterationView, event);
			}
		}
	}
}

-(void)rightMouseUp:(NSEvent *)event {
	NSArray *hitTestResults = [self hitTestEvent:event];
	for (SCNHitTestResult *result in hitTestResults) {
		if ([result.node isKindOfClass:[NezClickableNode class]]) {
			NezClickableNode *clickableObject = (NezClickableNode*)result.node;
			if (clickableObject.rightMouseUp) {
				clickableObject.rightMouseUp(self.nezSCNAletterationView, event);
			}
		}
	}
}

-(void)otherMouseDown:(NSEvent *)event {
	NSArray *hitTestResults = [self hitTestEvent:event];
	for (SCNHitTestResult *result in hitTestResults) {
		if ([result.node isKindOfClass:[NezClickableNode class]]) {
			NezClickableNode *clickableObject = (NezClickableNode*)result.node;
			if (clickableObject.otherMouseDown) {
				clickableObject.otherMouseDown(self.nezSCNAletterationView, event);
			}
		}
	}
}

-(void)otherMouseDragged:(NSEvent *)event {
	NSArray *hitTestResults = [self hitTestEvent:event];
	for (SCNHitTestResult *result in hitTestResults) {
		if ([result.node isKindOfClass:[NezClickableNode class]]) {
			NezClickableNode *clickableObject = (NezClickableNode*)result.node;
			if (clickableObject.otherMouseDragged) {
				clickableObject.otherMouseDragged(self.nezSCNAletterationView, event);
			}
		}
	}
}

-(void)otherMouseUp:(NSEvent *)event {
	NSArray *hitTestResults = [self hitTestEvent:event];
	for (SCNHitTestResult *result in hitTestResults) {
		if ([result.node isKindOfClass:[NezClickableNode class]]) {
			NezClickableNode *clickableObject = (NezClickableNode*)result.node;
			if (clickableObject.otherMouseUp) {
				clickableObject.otherMouseUp(self.nezSCNAletterationView, event);
			}
		}
	}
}

@end
