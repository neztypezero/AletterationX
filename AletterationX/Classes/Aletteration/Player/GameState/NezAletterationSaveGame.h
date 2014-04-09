//
//  NezAletterationSaveGame.h
//  Aletteration3
//
//  Created by David Nesbitt on 2013/10/10.
//  Copyright (c) 2013 David Nesbitt. All rights reserved.
//

@class NezAletterationGameState;
@class NezAletterationGraphics;

@interface NezAletterationSaveGame : NSObject

+(void)saveSinglePlayerGameState:(NezAletterationGameState*)gameState;
+(NSArray*)loadSinglePlayerGameStateList;
+(NezAletterationGraphics*)loadSavedGraphics;

@end
