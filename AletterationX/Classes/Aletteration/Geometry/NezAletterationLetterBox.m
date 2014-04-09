//
//  NezAletterationLetterBox.m
//  Aletteration3
//
//  Created by David Nesbitt on 2013/10/25.
//  Copyright (c) 2013 David Nesbitt. All rights reserved.
//

#import "NezAletterationLetterBox.h"
#import "NezAletterationAppDelegate.h"
#import "NezAletterationGraphics.h"
#import "NezAletterationLetterGroup.h"
#import "NezAletterationLetterBlock.h"

@interface NezAletterationLetterBox() {
	NSMutableArray *_letterGroupList;
}

@end

@implementation NezAletterationLetterBox

-(instancetype)initWithLid:(NezAletterationLid*)lid instanceAbo:(NezInstanceAttributeBufferObjectColor*)instanceAbo index:(NSInteger)instanceAttributeIndex andDimensions:(GLKVector3)dimensions {
	if ((self = [super initWithLid:lid instanceAbo:instanceAbo index:instanceAttributeIndex andDimensions:dimensions])) {
		_letterGroupList = [NSMutableArray arrayWithCapacity:NEZ_ALETTERATION_ALPHABET_COUNT];
		for (char letter='a'; letter <= 'z'; letter++) {
			[_letterGroupList addObject:[[NezAletterationLetterGroup alloc] initWithLetter:letter]];
		}
		_row1GroupList = [self addRowGroupsWithLetterList:"abcdefghijkl"   rowX: dimensions.x/4.0];
		_row2GroupList = [self addRowGroupsWithLetterList:"nopqrstuvwxmyz" rowX:-dimensions.x/4.0];
		[self attachBlocks];
	}
	return self;
}

-(void)encodeRestorableStateWithCoder:(NSCoder*)coder {
	[super encodeRestorableStateWithCoder:coder];
	
	[coder encodeBool:_blocksAttached forKey:@"_blocksAttached"];
	[coder encodeObject:_letterGroupList forKey:@"_letterGroupList"];
	[coder encodeObject:_row1GroupList forKey:@"_row1GroupList"];
	[coder encodeObject:_row2GroupList forKey:@"_row2GroupList"];
}

-(void)decodeRestorableStateWithCoder:(NSCoder*)coder {
	[super decodeRestorableStateWithCoder:coder];
	
	_blocksAttached = [coder decodeBoolForKey:@"_blocksAttached"];
	_letterGroupList = [coder decodeObjectForKey:@"_letterGroupList"];
	_row1GroupList = [coder decodeObjectForKey:@"_row1GroupList"];
	_row2GroupList = [coder decodeObjectForKey:@"_row2GroupList"];
}

-(void)registerChildObjectsForStateRestoration {
	[super registerChildObjectsForStateRestoration];
	
	[_letterGroupList enumerateObjectsUsingBlock:^(NezAletterationLetterGroup *letterGroup, NSUInteger idx, BOOL *stop) {
		[self registerChildObject:letterGroup withRestorationIdentifier:[NSString stringWithFormat:@"_letterGroupList[%lu]", (unsigned long)idx]];
	}];
}

-(void)setModelMatrix:(GLKMatrix4)modelMatrix {
	[super setModelMatrix:modelMatrix];
	if (_blocksAttached) {
		for (NezAletterationLetterGroup *letterGroup in _letterGroupList) {
			letterGroup.modelMatrix = [self matrixForLetterGroup:letterGroup withMatrix:_modelMatrix];
		}
	}
}

-(GLKMatrix4)matrixForLetterGroup:(NezAletterationLetterGroup*)letterGroup withMatrix:(GLKMatrix4)matrix {
	GLKMatrix4 rotMat = GLKMatrix4MakeRotation(M_PI_2, 1.0, 0.0, 0.0);
	GLKVector3 offset = letterGroup.offset;
	rotMat.m30 = offset.x;
	rotMat.m31 = offset.y;
	rotMat.m32 = offset.z;
	return GLKMatrix4Multiply(matrix, rotMat);
}

-(GLKMatrix4)matrixForLetterGroup:(NezAletterationLetterGroup*)letterGroup withOrientation:(GLKQuaternion)orientation andPosition:(GLKVector3)center {
	GLKMatrix4 matrix = GLKMatrix4MakeWithQuaternionAndPostion(orientation, center);
	return [self matrixForLetterGroup:letterGroup withMatrix:matrix];
}

-(void)attachBlocks {
	_blocksAttached = YES;
}

-(void)detachBlocks {
	_blocksAttached = NO;
}

-(NSMutableArray*)addRowGroupsWithLetterList:(char*)letterList rowX:(float)rowX {
	unsigned long letterCount = strlen(letterList);
	NSMutableArray *rowGroupList = [NSMutableArray arrayWithCapacity:letterCount];
	NezAletterationLetterBag letterCounts = [NezAletterationGameState fullLetterBag];
	GLKVector3 letterBlockDimensions = [NezAletterationAppDelegate sharedAppDelegate].graphics.letterBlockDimensions;
	float rowHeight = letterCount*letterBlockDimensions.z;
	float y = (_dimensions.y-rowHeight)/2.0;
	float rowZ = -_dimensions.z/2.0+letterBlockDimensions.y/2.0+0.05;
	for (unsigned long i=0; i<letterCount; i++) {
		char letter = letterList[i];
		int index = letter-'a';
		NezAletterationLetterGroup *letterGroup = _letterGroupList[index];
		letterGroup.offset = GLKVector3Make(rowX, y, rowZ);
		[rowGroupList addObject:letterGroup];
		y -= letterCounts.count[index]*letterBlockDimensions.z;
	}
	return rowGroupList;
}

-(void)addLetterBlock:(NezAletterationLetterBlock*)letterBlock {
	int index = letterBlock.letter-'a';
	[_letterGroupList[index] push:letterBlock];
}

-(void)removeAllLetterBlocks {
	for (int i=0; i<NEZ_ALETTERATION_ALPHABET_COUNT; i++) {
		[_letterGroupList[i] removeAllLetterBlocks];
	}
}

@end
