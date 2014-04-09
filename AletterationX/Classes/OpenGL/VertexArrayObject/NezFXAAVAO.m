//
//  NezFXAAVAO.m
//  AletterationX
//
//  Created by David Nesbitt on 2014/03/28.
//  Copyright (c) 2014 David Nesbitt. All rights reserved.
//

#import "NezFXAAVAO.h"
#import "NezVboVertexP4T2.h"
#import "NezGLSLProgramFXAA.h"

@implementation NezFXAAVAO

-(NezVboVertexP4T2*)vertexBufferObject {
	return _vertexBufferObject;
}

-(void)draw {
	NezGLSLProgramFXAA *p = self.program;
	glBindVertexArray(self.vertexArrayObject);
	glUseProgram(p.program);

	bindTexture2D(_texture0, GL_TEXTURE0, p.u_texture0);

	glDrawElements(GL_TRIANGLES, self.vertexBufferObject.indexCount, GL_UNSIGNED_SHORT, 0);

	unbindTexture2D(GL_TEXTURE0);
	glUseProgram(0);
	glBindVertexArray(0);
}

@end
