//
//  NezAletterationGameTable.h
//  AletterationX
//
//  Created by David Nesbitt on 2014/03/11.
//  Copyright (c) 2014 David Nesbitt. All rights reserved.
//

#import "NezNode.h"
#import "NezAletterationGeometry.h"
#import "NezAletterationPlayer.h"

#define NEZ_ALETTERATION_MAX_PLAYERS_PER_TABLE 4

@interface NezAletterationGameTable : NezNode

@property NezAletterationBigBox *box;
@property NezAletterationBox *lid;
@property (readonly, getter = boxTransform) CATransform3D boxTransform;

@property (readonly, getter = playerList) NSArray *playerList;
@property (readonly, getter = playerCount) NSUInteger playerCount;
@property (readonly, getter = currentPlayerList) NSArray *currentPlayerList;
@property (readonly, getter = currentPlayerCount) NSUInteger currentPlayerCount;

+(instancetype)table;

-(void)setupNewGameForPlayerCount:(NSUInteger)playerCount withGameController:(NezAletterationGameController*)gameController;

-(NezAletterationPlayer*)playerForIndex:(NSUInteger)playerIndex;

@end
