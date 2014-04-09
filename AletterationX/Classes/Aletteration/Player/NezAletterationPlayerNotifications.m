//
//  NezAletterationPlayerNotifications.m
//  AletterationX
//
//  Created by David Nesbitt on 2014/03/14.
//  Copyright (c) 2014 David Nesbitt. All rights reserved.
//

#import "NezAletterationPlayerNotifications.h"

@implementation NezAletterationPlayerNotification

+(instancetype)notificationWithPlayerIndex:(NSUInteger)playerIndex {
	return [[self alloc] initWithPlayerIndex:playerIndex];
}

-(instancetype)initWithPlayerIndex:(NSUInteger)playerIndex {
	if ((self = [super init])) {
		self.playerIndex = playerIndex;
	}
	return self;
}

@end

@implementation NezAletterationPlayerNotificationMoveLetterBlock

+(instancetype)notificationWithPlayerIndex:(NSUInteger)playerIndex Position:(GLKVector3)position andOrientation:(GLKQuaternion)orientation {
	return [[self alloc] initWithPlayerIndex:playerIndex Position:position andOrientation:orientation];
}

-(instancetype)initWithPlayerIndex:(NSUInteger)playerIndex Position:(GLKVector3)position andOrientation:(GLKQuaternion)orientation {
	if ((self = [super initWithPlayerIndex:playerIndex])) {
		self.position = position;
		self.orientation = orientation;
	}
	return self;
}

@end

@implementation NezAletterationPlayerNotificationLine

+(instancetype)notificationWithPlayerIndex:(NSUInteger)playerIndex andLineIndex:(NSUInteger)lineIndex {
	return [[self alloc] initWithPlayerIndex:playerIndex andLineIndex:lineIndex];
}

-(instancetype)initWithPlayerIndex:(NSUInteger)playerIndex andLineIndex:(NSUInteger)lineIndex {
	if ((self = [super initWithPlayerIndex:playerIndex])) {
		self.lineIndex = lineIndex;
	}
	return self;
}

@end

