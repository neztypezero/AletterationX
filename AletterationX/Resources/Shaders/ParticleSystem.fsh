#version 410

uniform sampler2D u_tex;
uniform sampler2D u_ramp;

in vec3 v_uv;

out vec4 fragColor;

void main( void ) {
    vec4 tex = texture(u_tex, v_uv.xy);
    vec4 col = texture(u_ramp, v_uv.zx);
	fragColor = tex * col;
}
