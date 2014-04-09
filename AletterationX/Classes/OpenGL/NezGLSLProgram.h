//
//  NezGLSLProgram.h
//  Aletteration3
//
//  Created by David Nesbitt on 2013-12-19.
//  Copyright 2013 David Nesbitt. All rights reserved.
//

#import <OpenGL/gl3.h>
#import "NezGLSLProgramProtocols.h"

#define MAX_NAME_LENGTH 128

#define NEZ_GLSL_ITEM_NOT_SET -1

static inline void bindTexture2D(GLuint texture, GLenum unit, GLenum samplerLocation) {
	glActiveTexture(unit);
	glBindTexture(GL_TEXTURE_2D, texture);
	glUniform1i(samplerLocation, unit-GL_TEXTURE0);
}

static inline void unbindTexture2D(GLenum unit) {
	glActiveTexture(unit);
	glBindTexture(GL_TEXTURE_2D, 0);
}

static inline void bindTexture2DMultisample(GLuint texture, GLenum unit, GLenum samplerLocation) {
	glActiveTexture(unit);
	glBindTexture(GL_TEXTURE_2D_MULTISAMPLE, texture);
	glUniform1i(samplerLocation, unit-GL_TEXTURE0);
}

static inline void unbindTexture2DMultisample(GLenum unit) {
	glActiveTexture(unit);
	glBindTexture(GL_TEXTURE_2D_MULTISAMPLE, 0);
}

@class NezGLSLCompiler;

@interface NezGLSLProgram : NSObject {
}

@property (readonly) GLuint program;

+(instancetype)programWithShaderName:(NSString*)shaderName;
+(instancetype)programWithVertexShaderName:(NSString*)vsh andFragmentShaderName:(NSString*)fsh;
+(instancetype)programWithVertexShaderName:(NSString*)vsh FragmentShaderName:(NSString*)fsh andGeometryShader:(NSString*)gsh;
+(instancetype)programWithVertexShaderCompiler:(NezGLSLCompiler*)vertexShaderCompiler andFragmentShaderCompiler:(NezGLSLCompiler*)fragmentShaderCompiler;
+(instancetype)programWithVertexShaderCompiler:(NezGLSLCompiler*)vertexShaderCompiler FragmentShaderCompiler:(NezGLSLCompiler*)fragmentShaderCompiler andGeometryShaderCompiler:(NezGLSLCompiler*)geometryShaderCompiler;

-(instancetype)initWithShaderName:(NSString*)shaderName;
-(instancetype)initWithVertexShaderName:(NSString*)vsh andFragmentShaderName:(NSString*)fsh;
-(instancetype)initWithVertexShaderName:(NSString*)vsh FragmentShaderName:(NSString*)fsh andGeometryShader:(NSString*)gsh;
-(instancetype)initWithVertexShaderCompiler:(NezGLSLCompiler*)vertexShaderCompiler andFragmentShaderCompiler:(NezGLSLCompiler*)fragmentShaderCompiler;
-(instancetype)initWithVertexShaderCompiler:(NezGLSLCompiler*)vertexShaderCompiler FragmentShaderCompiler:(NezGLSLCompiler*)fragmentShaderCompiler andGeometryShaderCompiler:(NezGLSLCompiler*)geometryShaderCompiler;

-(void)configureGeometryShader;
-(void)loadAttributesAndUniforms;

@end

