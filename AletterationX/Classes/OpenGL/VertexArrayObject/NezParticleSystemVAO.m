//
//  NezParticleSystemVAO.m
//  AletterationX
//
//  Created by David Nesbitt on 2014/03/28.
//  Copyright (c) 2014 David Nesbitt. All rights reserved.
//

#import "NezParticleSystemVAO.h"
#import "NezGLSLProgramParticleSystem.h"

@implementation NezParticleSystemVAO

-(void)draw {
	// Bind the VAO
	glBindVertexArray(self.vertexArrayObject);
	// Bind our program
	glUseProgram(self.program.program);
	
	// Fill Uniforms
	
	glUniformMatrix4fv(self.program.u_mv, 1, NO, _mv.m);
	glUniformMatrix4fv(self.program.u_p, 1, NO, _proj.m);
	
	// trail factor (length of stretched particles)
	glUniform1f(self.program.u_trailFactor, _trailFactor);
	
	// Bind samplers
	bindTexture2D(_tex, GL_TEXTURE0, self.program.u_tex);
	bindTexture2D(_ramp, GL_TEXTURE1, self.program.u_ramp);
	
	// Draw the particles
	glDrawElements(GL_POINTS, _liveParticlesCount * 3, GL_UNSIGNED_INT, 0);
	
	// restore default VAO
	glBindVertexArray(0);
}

@end
