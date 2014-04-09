//
//  NezAletterationSaveGame.m
//  Aletteration3
//
//  Created by David Nesbitt on 2013/10/10.
//  Copyright (c) 2013 David Nesbitt. All rights reserved.
//

#import "NezAletterationSaveGame.h"
#import "NezAletterationGameState.h"
#import "NezAletterationGraphics.h"

#define NEZ_ALETTERATION_SAVED_SINGLE_PLAYER @"NEZ_ALETTERATION_SAVED_SINGLE_PLAYER"
#define NEZ_ALETTERATION_SAVED_GRAPHICS @"NEZ_ALETTERATION_SAVED_GRAPHICS"

@implementation NezAletterationSaveGame

+(void)saveSinglePlayerGameState:(NezAletterationGameState*)gameState {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSArray *saveGameStateList = @[gameState];
	NSData *savedData = [NSKeyedArchiver archivedDataWithRootObject:saveGameStateList];
	[defaults setObject:savedData forKey:NEZ_ALETTERATION_SAVED_SINGLE_PLAYER];
	
	[defaults synchronize];
}

+(void)saveSinglePlayerViewState:(NezAletterationGameState*)gameState {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSArray *saveGameStateList = @[gameState];
	NSData *savedData = [NSKeyedArchiver archivedDataWithRootObject:saveGameStateList];
	[defaults setObject:savedData forKey:NEZ_ALETTERATION_SAVED_SINGLE_PLAYER];
	
	[defaults synchronize];
}

+(NSArray*)loadSinglePlayerGameStateList {
	NSArray *saveGameStateList = nil;
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

	[defaults removeObjectForKey:NEZ_ALETTERATION_SAVED_SINGLE_PLAYER];
//	[defaults synchronize];
	
	NSData *savedData = [defaults objectForKey:NEZ_ALETTERATION_SAVED_SINGLE_PLAYER];
	if (savedData != nil) {
		saveGameStateList = [NSKeyedUnarchiver unarchiveObjectWithData:savedData];
	}
	return saveGameStateList;
}

+(NezAletterationGraphics*)loadSavedGraphics {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

	[defaults removeObjectForKey:NEZ_ALETTERATION_SAVED_GRAPHICS];
	[defaults synchronize];
	
	NSData *savedData = [defaults objectForKey:NEZ_ALETTERATION_SAVED_GRAPHICS];
	if (savedData != nil) {
		return [NSKeyedUnarchiver unarchiveObjectWithData:savedData];
	}
	return nil;
}

@end
