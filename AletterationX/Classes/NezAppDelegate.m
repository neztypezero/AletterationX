//
//  NezAppDelegate.m
//  AletterationX
//
//  Created by David Nesbitt on 2014/02/05.
//  Copyright (c) 2014 David Nesbitt. All rights reserved.
//

#import "NezAppDelegate.h"
#import "NezAletterationGraphics.h"
#import "NezAletterationGeometry.h"
#import "NezSimpleObjLoader.h"
#import "NezAletterationBulletPhysics.h"
#import "NezAletterationSCNView.h"
#import "NezGCD.h"
#import "NezRandom.h"
#import <sqlite3.h>

#define NEZ_ALETTERATION_GAME_WINDOW @"NEZ_ALETTERATION_GAME_WINDOW"

@implementation NezAppDelegate

+ (void)restoreWindowWithIdentifier:(NSString *)identifier state:(NSCoder *)state completionHandler:(void (^)(NSWindow *, NSError *))completionHandler {
	NSWindow *window = nil;
	if ([identifier isEqualToString:NEZ_ALETTERATION_GAME_WINDOW]) {
		NezAppDelegate *appDelegate = [NSApp delegate];
		window = appDelegate.window;
	}
	completionHandler(window, nil);
}

- (void)applicationWillFinishLaunching:(NSNotification *)notification {
	if (sqlite3_config(SQLITE_CONFIG_SERIALIZED) == SQLITE_OK) {
		NSLog(@"Can now use sqlite on multiple threads, using the same connection");
	}
//	self.window.restorable = YES;
//	self.window.restorationClass = [self class];
//	self.window.identifier = NEZ_ALETTERATION_GAME_WINDOW;
//	[self.window toggleFullScreen:nil];
}

#pragma mark -
#pragma mark NSApplicationDelegate

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
	return YES;
}

@end
