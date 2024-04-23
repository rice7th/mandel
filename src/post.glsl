#version 330

in vec2 texcoord;
in vec4 color;

uniform sampler2D tex;
uniform vec2 res;

void main() {
    gl_FragColor = texture(tex, texcoord, 0);
}