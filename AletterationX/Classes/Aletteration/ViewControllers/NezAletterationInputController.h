//
//  NezAletterationInputController.h
//  AletterationX
//
//  Created by David Nesbitt on 2014/02/12.
//  Copyright (c) 2014 David Nesbitt. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class NezAletterationSCNView;

@interface NezAletterationInputController : NSObject

@property (readonly, getter = nezSCNAletterationView) NezAletterationSCNView *nezSCNAletterationView;

-(instancetype)initWithNezAletterationSCNView:(NezAletterationSCNView*)nezSCNAletterationView;

-(void)mouseDown:(NSEvent *)event;
-(void)mouseDragged:(NSEvent *)event;
-(void)mouseUp:(NSEvent *)event;
-(void)rightMouseDown:(NSEvent *)event;
-(void)rightMouseDragged:(NSEvent *)event;
-(void)rightMouseUp:(NSEvent *)event;
-(void)otherMouseDown:(NSEvent *)event;
-(void)otherMouseDragged:(NSEvent *)event;
-(void)otherMouseUp:(NSEvent *)event;
-(void)mouseMoved:(NSEvent *)event;
-(void)mouseEntered:(NSEvent *)event;
-(void)mouseExited:(NSEvent *)event;

-(void)keyDown:(NSEvent *)theEvent;
-(void)keyUp:(NSEvent *)theEvent;

-(void)controllerAdded;
-(void)controllerRemoved;

-(NSArray*)hitTestEvent:(NSEvent*)event;
-(void)nothingHitForEvent:(NSEvent*)event;

@end
