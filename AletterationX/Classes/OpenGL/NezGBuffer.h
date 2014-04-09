//
//  NezGBuffer.h
//  AletterationX
//
//  Created by David Nesbitt on 2014/03/31.
//  Copyright (c) 2014 David Nesbitt. All rights reserved.
//

enum NEZ_GBUFFER_TEXTURE_TYPE {
	NEZ_GBUFFER_TEXTURE_TYPE_POSITION,
	NEZ_GBUFFER_TEXTURE_TYPE_DIFFUSE,
	NEZ_GBUFFER_TEXTURE_TYPE_NORMAL,
	NEZ_GBUFFER_NUM_TEXTURES
};

@interface NezGBuffer : NSObject

+(instancetype)gbufferWithWidth:(GLsizei)width andHeight:(GLsizei)height;
-(instancetype)initWithWidth:(GLsizei)width andHeight:(GLsizei)height;

@end
