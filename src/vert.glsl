#version 330
in vec2 pos;
in vec2 uv;
out vec4 color;
in vec4 color0;

out vec2 texcoord;

void main() {
    gl_Position = vec4(pos, 0, 1);
    texcoord = uv;
}