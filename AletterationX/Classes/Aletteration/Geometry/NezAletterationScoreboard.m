//
//  NezAletterationScoreboard.m
//  Aletteration3
//
//  Created by David Nesbitt on 2013/10/09.
//  Copyright (c) 2013 David Nesbitt. All rights reserved.
//

#import "NezAletterationScoreboard.h"
#import "NezAletterationGraphics.h"
#import "NezAletterationRetiredWord.h"

@implementation NezAletterationScoreboard

-(instancetype)init {
	if ((self = [super init])) {
		_retiredWordList = [NSMutableArray array];
		_letterBlockDimensions = [NezAletterationGraphics sharedInstance].letterBlockDimensions;
		_dimensions = GLKVector3Make(0.0f, 0.0f, _letterBlockDimensions.z);
	}
	return self;
}

-(void)addRetiredWord:(NezAletterationRetiredWord*)retiredWord {
	[_retiredWordList addObject:retiredWord];
	GLKVector3 retiredWordDimensions = retiredWord.dimensions;
	if (_dimensions.x < retiredWordDimensions.x) {
		_dimensions.x  = retiredWordDimensions.x;
	}
	_dimensions.y = _letterBlockDimensions.y*_retiredWordList.count;
}

-(GLKMatrix4)nextWordMatrix {
	return GLKMatrix4Translate(_modelMatrix, 0.0f, _letterBlockDimensions.y*_retiredWordList.count, _letterBlockDimensions.z/2.0f);
}

@end
