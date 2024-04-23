#version 330

in vec2 texcoord;
in vec4 color;

uniform vec2 res;

uniform sampler2D tex;

void main() {
    gl_FragColor = texture(tex, texcoord, 0);
}