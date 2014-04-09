//
//  NezAletterationGameCenterPlayer.m
//  Aletteration3
//
//  Created by David Nesbitt on 2013/10/19.
//  Copyright (c) 2013 David Nesbitt. All rights reserved.
//

#import "NezAletterationGameCenterPlayer.h"
#import "NezAletterationPlayer.h"

@implementation NezAletterationGameCenterPlayer

+(instancetype)gcPlayerWithPlayer:(NezAletterationPlayer*)player andGKPlayer:(GKPlayer*)gkPlayer {
	return [[NezAletterationGameCenterPlayer alloc] initWith:player andGKPlayer:gkPlayer];
}

-(instancetype)initWith:(NezAletterationPlayer*)player andGKPlayer:(GKPlayer*)gkPlayer {
	if ((self = [super init])) {
		_player = player;
		_gkPlayer = gkPlayer;
		_networkState = kNezAletterationNetworkStateWaitingForMatchInitialization;
	}
	return self;
}

@end
