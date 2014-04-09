//
//  NezAletterationPlayerPrefs.h
//  Aletteration3
//
//  Created by David Nesbitt on 2013/11/11.
//  Copyright (c) 2013 David Nesbitt. All rights reserved.
//

#import <GLKit/GLKit.h>

@interface NezAletterationPlayerPrefs : NSObject

@property (nonatomic, copy) NSImage *photo;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *nickName;
@property (nonatomic, assign) NSColor *color;
@property (nonatomic, assign) BOOL soundsEnabled;
@property (nonatomic, assign) float soundsVolume;
@property (nonatomic, assign) BOOL musicEnabled;
@property (nonatomic, assign) float musicVolume;
@property (nonatomic, assign) BOOL undoConfirmation;
@property (nonatomic, assign) NSInteger undoCount;
@property (nonatomic, assign) BOOL isLowerCase;

@end
