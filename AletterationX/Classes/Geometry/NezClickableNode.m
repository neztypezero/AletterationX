//
//  NezClickableNode.m
//  AletterationX
//
//  Created by David Nesbitt on 2014/03/23.
//  Copyright (c) 2014 David Nesbitt. All rights reserved.
//

#import "NezClickableNode.h"

@implementation NezClickableNode

@synthesize mouseDown;
@synthesize mouseMoved;
@synthesize mouseDragged;
@synthesize mouseUp;
@synthesize rightMouseDown;
@synthesize rightMouseDragged;
@synthesize rightMouseUp;
@synthesize otherMouseDown;
@synthesize otherMouseDragged;
@synthesize otherMouseUp;

+(instancetype)nodeWithGeometry:(SCNGeometry*)geometry {
	NezClickableNode *node = [[NezClickableNode alloc] init];
	node.geometry = geometry;
	return node;
}

@end
