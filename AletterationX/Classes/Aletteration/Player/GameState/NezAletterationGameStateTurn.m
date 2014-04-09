//
//  NezAletterationGameStateTurn.m
//  Aletteration3
//
//  Created by David Nesbitt on 2013-10-01.
//  Copyright (c) 2013 David Nesbitt. All rights reserved.
//

#import "NezAletterationGameStateTurn.h"
#import "NezAletterationGameStateRetiredWord.h"

@implementation NezAletterationGameStateTurn

+(NezAletterationGameStateTurn*)turn {
	return [[NezAletterationGameStateTurn alloc] init];
}

-(id)init {
	if ((self = [super init])) {
		_lineIndex = -1;
		_temporaryLineIndex = -1;
		_retiredWordList = [NSMutableArray array];
	}
	return self;
}

-(id)initWithCoder:(NSCoder*)decoder {
	if ((self = [super init])) {
		_lineIndex = [decoder decodeInt64ForKey:@"_lineIndex"];
		_temporaryLineIndex = [decoder decodeInt64ForKey:@"_temporaryLineIndex"];
		_retiredWordList = [decoder decodeObjectForKey:@"_retiredWordList"];
	}
	return self;
}

-(void)encodeWithCoder:(NSCoder*)encoder {
	[encoder encodeInt64:_lineIndex forKey:@"_lineIndex"];
	[encoder encodeInt64:_temporaryLineIndex forKey:@"_temporaryLineIndex"];
	[encoder encodeObject:_retiredWordList forKey:@"_retiredWordList"];
}

-(NSString*)description {
	NSString *description = [NSString stringWithFormat:@"lineIndex:%lld temporaryLineIndex:%lld wordList.count:%lu", self.lineIndex, self.temporaryLineIndex, (unsigned long)self.retiredWordList.count];
	for (NezAletterationGameStateRetiredWord *retiredWord in self.retiredWordList) {
		description = [NSString stringWithFormat:@"%@ [%@] ", description, retiredWord];
	}
	return description;
}

@end

