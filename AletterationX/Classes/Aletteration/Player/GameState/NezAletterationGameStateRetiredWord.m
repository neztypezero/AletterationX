//
//  NezAletterationGameStateRetiredWord.m
//  Aletteration3
//
//  Created by David Nesbitt on 2013-10-01.
//  Copyright (c) 2013 David Nesbitt. All rights reserved.
//

#import "NezAletterationGameStateRetiredWord.h"

@implementation NezAletterationGameStateRetiredWord

+(NezAletterationGameStateRetiredWord*)retiredWord {
	return [[NezAletterationGameStateRetiredWord alloc] init];
}

-(id)init {
	if ((self = [super init])) {
		self.lineIndex = -1;
		self.range = NSMakeRange(-1, -1);
		self.stateList = nil;
	}
	return self;
}

-(id)initWithCoder:(NSCoder*)decoder {
	if ((self = [super init])) {
		self.lineIndex = [decoder decodeInt64ForKey:@"_lineIndex"];
		self.range = [[decoder decodeObjectForKey:@"_range"] rangeValue];
		self.stateList = [decoder decodeObjectForKey:@"_stateList"];
	}
	return self;
}

-(void)encodeWithCoder:(NSCoder*)encoder {
	[encoder encodeInt64:_lineIndex forKey:@"_lineIndex"];
	[encoder encodeObject:[NSValue valueWithRange:self.range] forKey:@"_range"];
	[encoder encodeObject:_stateList forKey:@"_stateList"];
}

-(NSString*)description {
	return [NSString stringWithFormat:@"NezAletterationGameStateRetiredWord:%lld, {%lu, %lu}, %@", self.lineIndex, (unsigned long)self.range.location, (unsigned long)self.range.length, self.stateList];
}

@end
