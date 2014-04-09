#version 410

layout(points) in;
layout(triangle_strip, max_vertices = 4) out;

varying in vec3 v_params[]; // angle, scale, life
varying in vec3 v_vel[]; // velocity

out vec3 v_uv;

uniform mat4 u_p;
uniform float u_trailFactor;


void main() {
	mat4 m = ProjectionMatrix;  // Reassign for brevity
	gl_Position = m * (vec4(-Size2,-Size2,0.0,0.0) + gl_in[0].gl_Position);
	TexCoord = vec2(0.0,0.0);
	EmitVertex();
	gl_Position = m * (vec4(Size2,-Size2,0.0,0.0) + gl_in[0].gl_Position);
	TexCoord = vec2(1.0,0.0);
	EmitVertex();
	gl_Position = m * (vec4(-Size2,Size2,0.0,0.0) + gl_in[0].gl_Position);
	TexCoord = vec2(0.0,1.0);
	EmitVertex();
	gl_Position = m * (vec4(Size2,Size2,0.0,0.0) + gl_in[0].gl_Position);
	TexCoord = vec2(1.0,1.0);
	EmitVertex();
	EndPrimitive();
}

#version 410

uniform mat4 u_p;
uniform float u_trailFactor;

varying in vec3 v_params[]; // angle, scale, life
varying in vec3 v_vel[]; // velocity
varying out vec3 v_uv;

void main(void)
{
    float sn = sin(v_params[0].x);
    float cs = cos(v_params[0].x);
    
    if (u_trailFactor > 0.) {
        vec2 v = vec2(v_vel[0].x, v_vel[0].y);
        float vlen = length(v);
        v /= vlen;
        vec2 t = vec2(-v.y, v.x);
        // scale factor
        v *= v_params[0].y;
        t *= v_params[0].y;
        
        // generate a billboard sprite from a point
        v_uv = vec3(-1.,  1., v_params[0].z);
        gl_Position = gl_PositionIn[0];
        gl_Position.xy += v;
        gl_Position = u_p * gl_Position;
        v_uv.xy = vec2( v_uv.x * cs - v_uv.y * sn,  v_uv.y * cs + v_uv.x * sn) * 0.5 + 0.5;
        EmitVertex();
        
        v_uv = vec3( 1.,  1., v_params[0].z);
        gl_Position = gl_PositionIn[0];
        gl_Position.xy += t;
        gl_Position = u_p * gl_Position;
        v_uv.xy = vec2( v_uv.x * cs - v_uv.y * sn,  v_uv.y * cs + v_uv.x * sn) * 0.5 + 0.5;
        EmitVertex();
        
        v_uv = vec3(-1., -1., v_params[0].z);
        gl_Position = gl_PositionIn[0];
        gl_Position.xy -= t;
        gl_Position = u_p * gl_Position;
        v_uv.xy = vec2( v_uv.x * cs - v_uv.y * sn,  v_uv.y * cs + v_uv.x * sn) * 0.5 + 0.5;
        EmitVertex();
        
        v_uv = vec3( 1., -1., v_params[0].z);
        gl_Position = gl_PositionIn[0];
        gl_Position.xy -= v * (1. + vlen * u_trailFactor);
        gl_Position = u_p * gl_Position;
        v_uv.xy = vec2( v_uv.x * cs - v_uv.y * sn,  v_uv.y * cs + v_uv.x * sn) * 0.5 + 0.5;
        EmitVertex();

        EndPrimitive();
        return;
    }
    
    sn *= v_params[0].y;
    cs *= v_params[0].y;
    
    v_uv = vec3(-1.,  1., v_params[0].z);
    gl_Position = gl_PositionIn[0];
    gl_Position.xy += vec2( v_uv.x * cs - v_uv.y * sn,  v_uv.y * cs + v_uv.x * sn);
    gl_Position = u_p * gl_Position;
    v_uv.xy = v_uv.xy * 0.5 + 0.5;
    EmitVertex();

    v_uv = vec3(-1., -1., v_params[0].z);
    gl_Position = gl_PositionIn[0];
    gl_Position.xy += vec2( v_uv.x * cs - v_uv.y * sn,  v_uv.y * cs + v_uv.x * sn);
    gl_Position = u_p * gl_Position;
    v_uv.xy = v_uv.xy * 0.5 + 0.5;
    EmitVertex();

    v_uv = vec3( 1.,  1., v_params[0].z);
    gl_Position = gl_PositionIn[0];
    gl_Position.xy += vec2( v_uv.x * cs - v_uv.y * sn,  v_uv.y * cs + v_uv.x * sn);
    gl_Position = u_p * gl_Position;
    v_uv.xy = v_uv.xy * 0.5 + 0.5;
    EmitVertex();

    v_uv = vec3( 1., -1., v_params[0].z);
    gl_Position = gl_PositionIn[0];
    gl_Position.xy += vec2( v_uv.x * cs - v_uv.y * sn,  v_uv.y * cs + v_uv.x * sn);
    gl_Position = u_p * gl_Position;
    v_uv.xy = v_uv.xy * 0.5 + 0.5;
    EmitVertex();

    // End the one primitive with the original vertices
    EndPrimitive();
}
