#version 410

layout(location = 0) in vec4 a_pos;
layout(location = 1) in vec3 a_vel;
layout(location = 1) in vec2 a_uv; // angle, life

uniform mat4 u_mv;

out vec3 v_params; // angle, scale, life
out vec4 v_pos;
out vec3 v_vel;

void main() {
	gl_Position = u_mv * vec4(a_pos.xyz, 1.0);
    v_params = vec3(a_uv.x, a_pos.w, a_uv.y);
    v_vel = mat3(u_mv) * a_vel;
}
