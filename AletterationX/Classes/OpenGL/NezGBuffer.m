//
//  NezGBuffer.m
//  AletterationX
//
//  Created by David Nesbitt on 2014/03/31.
//  Copyright (c) 2014 David Nesbitt. All rights reserved.
//

#import <OpenGL/gl3.h>
#import "NezGBuffer.h"

@implementation NezGBuffer {
	GLuint _fbo;
	GLuint _textures[NEZ_GBUFFER_NUM_TEXTURES];
	GLuint _depthTexture;
}

+(instancetype)gbufferWithWidth:(GLsizei)width andHeight:(GLsizei)height {
	return [[self alloc] initWithWidth:width andHeight:height];
}

-(instancetype)initWithWidth:(GLsizei)width andHeight:(GLsizei)height {
	if ((self = [super init])) {
		// Create the FBO
		glGenFramebuffers(1, &_fbo);
		glBindFramebuffer(GL_DRAW_FRAMEBUFFER, _fbo);
		
		// Create the gbuffer textures
		glGenTextures(NEZ_GBUFFER_NUM_TEXTURES, _textures);
		glGenTextures(1, &_depthTexture);
		
		for (unsigned int i = 0 ; i < NEZ_GBUFFER_NUM_TEXTURES ; i++) {
			glBindTexture(GL_TEXTURE_2D, _textures[i]);
			glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB32F, width, height, 0, GL_RGB, GL_FLOAT, NULL);
			glFramebufferTexture2D(GL_DRAW_FRAMEBUFFER, GL_COLOR_ATTACHMENT0 + i, GL_TEXTURE_2D, _textures[i], 0);
		}
		
		// depth
		glBindTexture(GL_TEXTURE_2D, _depthTexture);
		glTexImage2D(GL_TEXTURE_2D, 0, GL_DEPTH_COMPONENT32F, width, height, 0, GL_DEPTH_COMPONENT, GL_FLOAT, NULL);
		glFramebufferTexture2D(GL_DRAW_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_TEXTURE_2D, _depthTexture, 0);
		
		GLenum drawBuffers[] = { GL_COLOR_ATTACHMENT0, GL_COLOR_ATTACHMENT1, GL_COLOR_ATTACHMENT2, GL_COLOR_ATTACHMENT3 };
		glDrawBuffers(NEZ_GBUFFER_NUM_TEXTURES, drawBuffers);
		
		GLenum status = glCheckFramebufferStatus(GL_FRAMEBUFFER);
		
		if (status != GL_FRAMEBUFFER_COMPLETE) {
			printf("FB error, status: 0x%x\n", status);
			return nil;
		}
		
		// restore default FBO
		glBindFramebuffer(GL_DRAW_FRAMEBUFFER, 0);
	}
	return self;
}

@end