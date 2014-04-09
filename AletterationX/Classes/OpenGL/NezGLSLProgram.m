//
//  NezGLSLProgram.m
//  Aletteration3
//
//  Created by David Nesbitt on 2013-12-19.
//  Copyright 2013 David Nesbitt. All rights reserved.
//

#import "NezGLSLProgram.h"
#import "NezGLSLCompiler.h"

@implementation NezGLSLProgram

+(instancetype)programWithShaderName:(NSString*)shaderName {
	return [[self alloc] initWithShaderName:shaderName];
}

+(instancetype)programWithVertexShaderName:(NSString*)vsh andFragmentShaderName:(NSString*)fsh {
	return [[self alloc] initWithVertexShaderName:vsh andFragmentShaderName:fsh];
}

+(instancetype)programWithVertexShaderName:(NSString*)vsh FragmentShaderName:(NSString*)fsh andGeometryShader:(NSString*)gsh {
	return [[self alloc] initWithVertexShaderName:vsh FragmentShaderName:fsh andGeometryShader:gsh];
}

+(instancetype)programWithVertexShaderCompiler:(NezGLSLCompiler*)vertexShaderCompiler andFragmentShaderCompiler:(NezGLSLCompiler*)fragmentShaderCompiler {
	return [[self alloc] initWithVertexShaderCompiler:vertexShaderCompiler andFragmentShaderCompiler:fragmentShaderCompiler];
}

+(instancetype)programWithVertexShaderCompiler:(NezGLSLCompiler*)vertexShaderCompiler FragmentShaderCompiler:(NezGLSLCompiler*)fragmentShaderCompiler andGeometryShaderCompiler:(NezGLSLCompiler*)geometryShaderCompiler {
	return [[self alloc] initWithVertexShaderCompiler:vertexShaderCompiler FragmentShaderCompiler:fragmentShaderCompiler andGeometryShaderCompiler:geometryShaderCompiler];
}

-(instancetype)initWithShaderName:(NSString*)shaderName {
	return [self initWithVertexShaderName:shaderName FragmentShaderName:shaderName andGeometryShader:shaderName];
}

-(instancetype)initWithVertexShaderName:(NSString*)vsh andFragmentShaderName:(NSString*)fsh {
	return [self initWithVertexShaderCompiler:[NezGLSLCompiler compilerWithVertexShader:vsh] andFragmentShaderCompiler:[NezGLSLCompiler compilerWithFragmentShader:fsh]];
}

-(instancetype)initWithVertexShaderName:(NSString*)vsh FragmentShaderName:(NSString*)fsh andGeometryShader:(NSString*)gsh {
	return [self initWithVertexShaderCompiler:[NezGLSLCompiler compilerWithVertexShader:vsh] FragmentShaderCompiler:[NezGLSLCompiler compilerWithFragmentShader:fsh] andGeometryShaderCompiler:[NezGLSLCompiler compilerWithGeometryShader:gsh]];
}

-(instancetype)initWithVertexShaderCompiler:(NezGLSLCompiler*)vertexShaderCompiler andFragmentShaderCompiler:(NezGLSLCompiler*)fragmentShaderCompiler {
	return [self initWithVertexShaderCompiler:vertexShaderCompiler FragmentShaderCompiler:fragmentShaderCompiler andGeometryShaderCompiler:nil];
}

-(instancetype)initWithVertexShaderCompiler:(NezGLSLCompiler*)vertexShaderCompiler FragmentShaderCompiler:(NezGLSLCompiler*)fragmentShaderCompiler andGeometryShaderCompiler:(NezGLSLCompiler*)geometryShaderCompiler {
	if ((self = [super init])) {
		[self initializeValues];
		if (vertexShaderCompiler && fragmentShaderCompiler && vertexShaderCompiler.shader && fragmentShaderCompiler.shader) {
			if (geometryShaderCompiler && geometryShaderCompiler.shader) {
				if (![self loadProgramWithVertexShader:vertexShaderCompiler.shader FragmentShader:fragmentShaderCompiler.shader andGeometryShader:geometryShaderCompiler.shader]) {
					return nil;
				}
			} else {
				if (![self loadProgramWithVertexShader:vertexShaderCompiler.shader FragmentShader:fragmentShaderCompiler.shader andGeometryShader:0]) {
					return nil;
				}
			}
		} else {
			return nil;
		}
	}
	return self;
}

-(void)initializeValues {
}

-(BOOL)loadProgramWithVertexShader:(GLuint)vertexShader FragmentShader:(GLuint)fragmentShader andGeometryShader:(GLuint)geometryShader {
	_program = glCreateProgram();

	glAttachShader(_program, vertexShader);
	glAttachShader(_program, fragmentShader);
	if (geometryShader) {
		glAttachShader(_program, geometryShader);

		if (geometryShader) {
			[self configureGeometryShader];
		}
	}
	// Link program
	if (![self linkProgram:_program]) {
		NSLog(@"Failed to link program: %d", _program);
		if (_program) {
			glDeleteProgram(_program);
			_program = 0;
		}
		return FALSE;
	}
	[self loadAttributesAndUniforms];
	
	return TRUE;
}

-(BOOL)linkProgram:(GLuint)prog {
	GLint status;

	glLinkProgram(prog);

	GLint logLength;
	glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
	if (logLength > 0) {
		GLchar *log = (GLchar *)malloc(logLength);
		glGetProgramInfoLog(prog, logLength, &logLength, log);
		NSLog(@"Program link log:\n%s", log);
		free(log);
	}

	glGetProgramiv(prog, GL_LINK_STATUS, &status);
	if (status == 0) {
		return FALSE;
	}
	return TRUE;
}

-(BOOL)validateProgram:(GLuint)prog {
	GLint logLength, status;

	glValidateProgram(prog);
	glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
	if (logLength > 0) {
		GLchar *log = (GLchar *)malloc(logLength);
		glGetProgramInfoLog(prog, logLength, &logLength, log);
		NSLog(@"Program validate log:\n%s", log);
		free(log);
	}

	glGetProgramiv(prog, GL_VALIDATE_STATUS, &status);
	if (status == 0) {
		return FALSE;
	}
	return TRUE;
}

-(void)configureGeometryShader {}
-(void)loadAttributesAndUniforms {}

-(void)dealloc {
	if (_program) {
		glDeleteProgram(_program);
	}
}

@end

