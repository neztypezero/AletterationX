//
//  NezAletterationGameCenterPlayer.h
//  Aletteration3
//
//  Created by David Nesbitt on 2013/10/19.
//  Copyright (c) 2013 David Nesbitt. All rights reserved.
//

#import "NezGameCenter.h"

typedef enum {
	kNezAletterationNetworkStateWaitingForMatchInitialization = 0,
	kNezAletterationNetworkStateReadyForMatchInitialization,
	kNezAletterationNetworkStateWaitingForMatchStart,
	kNezAletterationNetworkStateGameActive,
	kNezAletterationNetworkStateDone
} NezAletterationNetworkState;

@class NezAletterationPlayer;

@interface NezAletterationGameCenterPlayer : NSObject

@property (nonatomic, readonly) NezAletterationPlayer *player;
@property (nonatomic, readonly) GKPlayer *gkPlayer;
@property NezAletterationNetworkState networkState;

+(instancetype)gcPlayerWithPlayer:(NezAletterationPlayer*)player andGKPlayer:(GKPlayer*)gkPlayer;

@end
