#version 330
in vec2 in_pos;
in vec2 in_uv;

void main() {
    gl_Position = vec4(in_pos, 0, 1);
}