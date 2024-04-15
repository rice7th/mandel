#version 330
#extension GL_ARB_gpu_shader_fp64 : enable

in vec4 gl_FragCoord;
uniform vec2 res;
uniform vec2 pos;
uniform ivec2 zoom;
uniform vec2 speed;
uniform int iter;
uniform ivec2 chunk;

// Complex number such that vec2(a, bi).
// vec.y is imag and vec.x is real

vec3 palette(float t, vec3 a, vec3 b, vec3 c, vec3 d) {
    return a + b*cos( 6.28318*(c*t+d) );
}


dvec2 cmplx_pow2(dvec2 z) {
    return dvec2(z.x * z.x - z.y * z.y, 2 * z.x * z.y);
}

dvec3 mandel(dvec2 c) {
    dvec2 z = dvec2(0);
    for (int i = 0; i < iter; i++) {
        z = cmplx_pow2(z);
        z = dvec2(z.x + c.x, z.y + c.y);
        if (z.x > 2 || z.y > 2) {
            //return mix(dvec3(1, 0, 0), dvec3(0, 1, 0), float(i) / (0.3 * iter));
            return dvec3(palette(float(i) / (0.3 * iter), vec3(0.5), vec3(0.5), vec3(1), vec3(0.00, 0.33, 0.67)));
        }
    }
    return dvec3(0);
}

void main() {
    dvec2 uv = (dvec2(gl_FragCoord.xy) / dvec2(res) - 0.5) * 4;
    uv.x *= res.x / res.y;

    dvec2 pos_d = dvec2(pos.x, pos.y);
    dvec2 position = pos_d + dvec2(chunk/2147483648);

    dvec2 c = uv / exp2(zoom.x / 2) - position;
    dvec3 fractal = mandel(c);
    //dmat2x2 fractal = dmat2x2(mandel(c), mandel(c+))
    gl_FragColor = vec4(fractal, 1);
}