//
//  NezAletterationPlayerPrefs.m
//  Aletteration3
//
//  Created by David Nesbitt on 2013/11/11.
//  Copyright (c) 2013 David Nesbitt. All rights reserved.
//

#import "NezAletterationPlayerPrefs.h"
#import "NezRandom.h"

@implementation NezAletterationPlayerPrefs

-(instancetype)initWithCoder:(NSCoder *)coder {
	if ((self = [super init])) {
		[self decodeRestorableStateWithCoder:coder];
	}
	return self;
}

-(void)encodeWithCoder:(NSCoder *)coder {
	[self encodeRestorableStateWithCoder:coder];
}

-(instancetype)init {
	if ((self = [super init])) {
		_name = @"anonymous";
		_nickName = @"anonymous";
		_photo = [NSImage imageNamed:@"anonymous.png"];
		_color = [NSColor colorWithRed:randomFloat() green:randomFloat() blue:randomFloat() alpha:1.0];
		
		_soundsEnabled = YES;
		_soundsVolume = 0.5;
		_musicEnabled = YES;
		_musicVolume = 0.5;
		
		_undoConfirmation = YES;
		_undoCount = 10;
		
		_isLowerCase = NO;
	}
	return self;
}

-(void)encodeRestorableStateWithCoder:(NSCoder*)coder {
	NSData *photoData = [self PNGRepresentationOfImage:_photo];
	[coder encodeObject:photoData forKey:@"photoData"];

	[coder encodeObject:_name forKey:@"_name"];
	[coder encodeObject:_nickName forKey:@"_nickName"];
	
	[coder encodeObject:_color forKey:@"_color"];

	[coder encodeBool:_soundsEnabled forKey:@"_soundsEnabled"];
	[coder encodeFloat:_soundsVolume forKey:@"_soundsVolume"];
	[coder encodeBool:_musicEnabled forKey:@"_musicEnabled"];
	[coder encodeFloat:_musicVolume forKey:@"_musicVolume"];

	[coder encodeBool:_undoConfirmation forKey:@"_undoConfirmation"];
	[coder encodeInteger:_undoCount forKey:@"_undoCount"];

	[coder encodeBool:_isLowerCase forKey:@"_isLowerCase"];
}

-(void)decodeRestorableStateWithCoder:(NSCoder*)coder {
	NSData *photoData = [coder decodeObjectForKey:@"photoData"];
	_photo = [[NSImage alloc] initWithData:photoData];

	_name = [coder decodeObjectForKey:@"_name"];
	_nickName = [coder decodeObjectForKey:@"_nickName"];
	
	_color = [coder decodeObjectForKey:@"_color"];

	_soundsEnabled = [coder decodeBoolForKey:@"_soundsEnabled"];
	_soundsVolume = [coder decodeFloatForKey:@"_soundsVolume"];
	_musicEnabled = [coder decodeBoolForKey:@"_musicEnabled"];
	_musicVolume = [coder decodeFloatForKey:@"_musicVolume"];

	_undoConfirmation = [coder decodeBoolForKey:@"_undoConfirmation"];
	_undoCount = [coder decodeIntegerForKey:@"_undoCount"];

	_isLowerCase = [coder decodeBoolForKey:@"_isLowerCase"];
}

- (NSData*)PNGRepresentationOfImage:(NSImage *) image {
	// Create a bitmap representation from the current image
	
	[image lockFocus];
	NSBitmapImageRep *bitmapRep = [[NSBitmapImageRep alloc] initWithFocusedViewRect:NSMakeRect(0, 0, image.size.width, image.size.height)];
	[image unlockFocus];
	
	return [bitmapRep representationUsingType:NSPNGFileType properties:Nil];
}

@end
