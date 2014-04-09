//
//  NezAppDelegate.h
//  AletterationX
//
//  Created by David Nesbitt on 2014/02/05.
//  Copyright (c) 2014 David Nesbitt. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <SceneKit/SceneKit.h>
#import "NezAletterationGraphics.h"

@interface NezAppDelegate : NSObject <NSApplicationDelegate, SCNSceneRendererDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (weak) IBOutlet SCNView *view;

@end
