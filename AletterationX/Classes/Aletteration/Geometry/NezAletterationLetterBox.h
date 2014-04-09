//
//  NezAletterationLetterBox.h
//  Aletteration3
//
//  Created by David Nesbitt on 2013/10/25.
//  Copyright (c) 2013 David Nesbitt. All rights reserved.
//

#import "NezAletterationBox.h"
#import "NezAletterationGameState.h"

@class NezAletterationLetterBlock;
@class NezAletterationLetterGroup;

@interface NezAletterationLetterBox : NezAletterationBox

@property (readonly) BOOL blocksAttached;
@property (readonly) NSMutableArray *row1GroupList;
@property (readonly) NSMutableArray *row2GroupList;

-(void)attachBlocks;
-(void)detachBlocks;

-(GLKMatrix4)matrixForLetterGroup:(NezAletterationLetterGroup*)letterGroup withMatrix:(GLKMatrix4)matrix;
-(GLKMatrix4)matrixForLetterGroup:(NezAletterationLetterGroup*)letterGroup withOrientation:(GLKQuaternion)orientation andPosition:(GLKVector3)center;
-(void)addLetterBlock:(NezAletterationLetterBlock*)letterBlock;
-(void)removeAllLetterBlocks;

@end
