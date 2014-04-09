//
//  NezAletterationWordState.m
//  Aletteration3
//
//  Created by David Nesbitt on 2013-10-01.
//  Copyright (c) 2013 David Nesbitt. All rights reserved.
//

#import "NezAletterationGameStateLineState.h"
#import "NezAletterationGameState.h"

@implementation NezAletterationGameStateLineState

+(NezAletterationGameStateLineState*)lineState {
	return [[NezAletterationGameStateLineState alloc] init];
}

+(NezAletterationGameStateLineState*)lineStateCopy:(NezAletterationGameStateLineState*)lineState {
	NezAletterationGameStateLineState *newState = [NezAletterationGameStateLineState lineState];
	newState.state = lineState.state;
	newState.index = lineState.index;
	newState.length = lineState.length;
	newState.turn = lineState.turn;
	return newState;
}

+(NezAletterationGameStateLineState*)lineStateWithState:(int64_t)state index:(int64_t)index length:(int64_t)length andTurn:(int64_t)turn {
	return [[NezAletterationGameStateLineState alloc] initWithState:state index:index length:length andTurn:turn];
}

+(NezAletterationGameStateLineState*)nextLineState:(NezAletterationGameStateLineState*)lineState {
	NezAletterationGameStateLineState *newState = [NezAletterationGameStateLineState lineState];
	if (lineState) {
		newState.index = lineState.index;
		newState.length = lineState.length+1;
	} else {
		newState.length = 1;
	}
	newState.turn = -1;
	return newState;
}

-(id)init {
	if ((self = [super init])) {
		_state = NEZ_ALETTERATION_INPUT_ISNOT_SET;
		_index = 0;
		_length = 0;
		_turn = -1;
	}
	return self;
}

-(id)initWithState:(int64_t)state index:(int64_t)index length:(int64_t)length andTurn:(int64_t)turn {
	if ((self = [super init])) {
		_state = state;
		_index = index;
		_length = length;
		_turn = turn;
	}
	return self;
}

-(id)initWithCoder:(NSCoder*)decoder {
	if ((self = [super init])) {
		_state = [decoder decodeInt64ForKey:@"_state"];
		_index = [decoder decodeInt64ForKey:@"_index"];
		_length = [decoder decodeInt64ForKey:@"_length"];
		_turn = [decoder decodeInt64ForKey:@"_turn"];
	}
	return self;
}

-(void)encodeWithCoder:(NSCoder*)encoder {
	[encoder encodeInt64:_state forKey:@"_state"];
	[encoder encodeInt64:_index forKey:@"_index"];
	[encoder encodeInt64:_length forKey:@"_length"];
	[encoder encodeInt64:_turn forKey:@"_turn"];
}

-(NSString*)description {
	return [NSString stringWithFormat:@"state:%lld, index:%lld, length:%lld, turn:%lld", self.state, self.index, self.length, self.turn];
}

-(BOOL)isEqual:(NezAletterationGameStateLineState*)lineState {
	if (lineState.state != self.state) {
		return NO;
	}
	if (lineState.index != self.index) {
		return NO;
	}
	if (lineState.length != self.length) {
		return NO;
	}
	return YES;
}

@end