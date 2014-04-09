//
//  NezClickable.h
//  AletterationX
//
//  Created by David Nesbitt on 2014/03/23.
//  Copyright (c) 2014 David Nesbitt. All rights reserved.
//

typedef void (^ NezMouseHandler)(SCNView *view, NSEvent *event);

@protocol NezClickable

@required

@property (nonatomic, copy) NezMouseHandler mouseMoved;
@property (nonatomic, copy) NezMouseHandler mouseDown;
@property (nonatomic, copy) NezMouseHandler mouseDragged;
@property (nonatomic, copy) NezMouseHandler mouseUp;
@property (nonatomic, copy) NezMouseHandler rightMouseDown;
@property (nonatomic, copy) NezMouseHandler rightMouseDragged;
@property (nonatomic, copy) NezMouseHandler rightMouseUp;
@property (nonatomic, copy) NezMouseHandler otherMouseDown;
@property (nonatomic, copy) NezMouseHandler otherMouseDragged;
@property (nonatomic, copy) NezMouseHandler otherMouseUp;

@end
