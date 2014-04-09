//
//  NezAletterationScoreboard.h
//  Aletteration3
//
//  Created by David Nesbitt on 2013/10/09.
//  Copyright (c) 2013 David Nesbitt. All rights reserved.
//

#import "NezGeometry.h"

@class NezAletterationRetiredWord;

@interface NezAletterationScoreboard : NezGeometry {
	NSMutableArray *_retiredWordList;
	GLKVector3 _letterBlockDimensions;
}

-(void)addRetiredWord:(NezAletterationRetiredWord*)retiredWord;

@end
