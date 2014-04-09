//
//  NezAletterationGameStateLineStateStack.m
//  Aletteration3
//
//  Created by David Nesbitt on 2013/10/15.
//  Copyright (c) 2013 David Nesbitt. All rights reserved.
//

#import "NezAletterationGameStateLineStateStack.h"
#import "NezAletterationGameStateLineState.h"

@implementation NezAletterationGameStateLineStateStack

-(instancetype)init {
	if ((self = [super init])) {
		_lineStateList = [NSMutableArray array];
	}
	return self;
}

-(instancetype)initWithCoder:(NSCoder*)decoder {
	if ((self = [super init])) {
		_lineStateList = [decoder decodeObjectForKey:@"_lineStateList"];
	}
	return self;
}

-(void)encodeWithCoder:(NSCoder*)encoder {
	[encoder encodeObject:_lineStateList forKey:@"_lineStateList"];
}

-(void)pushLineState:(NezAletterationGameStateLineState*)lineState {
	[_lineStateList addObject:[NSMutableArray arrayWithObject:lineState]];
}

-(void)pushUpdatedState:(NezAletterationGameStateLineState*)lineState {
	NSMutableArray *stack = _lineStateList.lastObject;
	[stack addObject:lineState];
}

-(void)pushLineStateList:(NSArray*)lineStateList {
	[_lineStateList addObjectsFromArray:lineStateList];
}

-(void)removeTopLineState {
	[_lineStateList removeLastObject];
}

-(void)removeLineStatesForTurn:(NSInteger)turn {
	while (self.topLineState.turn >= turn) {
		NSMutableArray *stack = _lineStateList.lastObject;
		if (stack.count > 1) {
			[stack removeLastObject];
		} else {
			break;
		}
	}
	if (self.topLineState.state == -1) {
		[_lineStateList removeLastObject];
	}
}

-(NezAletterationGameStateLineState*)getTopLineState {
	NSMutableArray *stack = _lineStateList.lastObject;
	return stack.lastObject;
}

-(NSArray*)getStateList {
	NSMutableArray *stateList = [NSMutableArray arrayWithCapacity:_lineStateList.count];
	for (NSMutableArray *stack in _lineStateList) {
		[stateList addObject:stack.lastObject];
	}
	return stateList;
}

-(NSInteger)getCount {
	return _lineStateList.count;
}

-(NSArray*)removeStatesInRange:(NSRange)range {
	NSArray *stateList = [_lineStateList subarrayWithRange:range];
	[_lineStateList removeObjectsInRange:range];
	return stateList;
}

@end
