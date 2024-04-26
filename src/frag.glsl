#version 330
#extension GL_ARB_gpu_shader_fp64 : enable

#define SSAMOUNT 5

in vec4 gl_FragCoord;
uniform vec2 res;
uniform vec2 pos;
uniform ivec2 zoom;
uniform vec2 speed;
uniform int iter;
uniform ivec2 chunk;
uniform int ssaa;


// Complex number such that vec2(a, bi).
// vec.y is imag and vec.x is real

vec3 palette(float t, vec3 a, vec3 b, vec3 c, vec3 d) {
    return a + b*cos( 6.28318*(c*t+d) );
}

vec2 cmplx_pow2(vec2 z) {
    return vec2(z.x * z.x - z.y * z.y, 2 * z.x * z.y);
}

vec3 mandel(vec2 c) {
    vec2 z = vec2(0);

    // Cardioid & bulb detection
    float p = sqrt((c.x*c.x - 0.5 * c.x + 1/16) + c.y*c.y);
    if (c.x <= (p - 2*p*p + 0) || ((c.x*c.x + 2*c.x + 1) + c.y*c.y) <= 1/16) {
        return vec3(0);
    }

    for (int i = 0; i < iter; i++) {
        z = cmplx_pow2(z);
        z = vec2(z.x + c.x, z.y + c.y);

        if (length(z) > 2) {
            return vec3(palette(float(i) / (0.1 * iter), vec3(0.5), vec3(0.5), vec3(1), vec3(0.00, 0.33, 0.67)));
        }
    }
    return vec3(0);
}

/* I should do a median instead
vec4 sort(vec4 vct) {
    float q;
    if (vct.x > vct.y) { q = vct.x; vct.x = vct.y; vct.y = q; }
    if (vct.z > vct.w) { q = vct.z; vct.z = vct.w; vct.w = q; }
    if (vct.x > vct.z) { q = vct.x; vct.x = vct.z; vct.z = q; }
    if (vct.y > vct.w) { q = vct.y; vct.y = vct.w; vct.w = q; }
    if (vct.y > vct.z) { q = vct.y; vct.y = vct.z; vct.z = q; }
    return vct;
}
*/

vec2 get_c(vec2 offset) {
    vec2 uv;
    if (ssaa == 1) {
        uv = ((vec2(gl_FragCoord.xy * SSAMOUNT) + offset) / vec2(res * SSAMOUNT) - 0.5) * 4;
    } else {
        uv = ((vec2(gl_FragCoord.xy) + offset) / vec2(res) - 0.5) * 4;
    }
    uv.x *= res.x / res.y;

    vec2 position = vec2(pos.x, pos.y);

    vec2 c = uv / exp2(zoom.x / 2) - position;
    return c;
}


/*
╭─────┬─────┬─────┬─────┬─────╮
│-2,2 │-1,2 │ 0,2 │ 1,2 │ 2,2 │
├─────┼─────┼─────┼─────┼─────┤
│-2,1 │-1,1 │ 0,1 │ 1,1 │ 2,1 │
├─────┼─────┼─────┼─────┼─────┤
│-2,0 │-1,0 │ 0,0 │ 1,0 │ 2,0 │
├─────┼─────┼─────┼─────┼─────┤
│-2,-1│-1,-1│ 0,-1│ 1,-1│ 2,-1│
├─────┼─────┼─────┼─────┼─────┤
│-2,-2│-1,-2│ 0,-2│ 1,-2│ 2,-2│
╰─────┴─────┴─────┴─────┴─────╯
*/

void main() {
    // kill me
    vec2 c_2_2 = get_c(vec2(2));
    vec2 c_2_1 = get_c(vec2(2,1));
    vec2 c_2_0 = get_c(vec2(2,0));
    vec2 c_2m1 = get_c(vec2(2,-1));
    vec2 c_2m2 = get_c(vec2(2,-2));
    vec2 c_1_2 = get_c(vec2(1));
    vec2 c_1_1 = get_c(vec2(1,1));
    vec2 c_1_0 = get_c(vec2(1,0));
    vec2 c_1m1 = get_c(vec2(1,-1));
    vec2 c_1m2 = get_c(vec2(1,-2));
    vec2 c_0_2 = get_c(vec2(0));
    vec2 c_0_1 = get_c(vec2(0,1));
    vec2 c_0_0 = get_c(vec2(0,0));
    vec2 c_0m1 = get_c(vec2(0,-1));
    vec2 c_0m2 = get_c(vec2(0,-2));
    vec2 cm1_2 = get_c(vec2(-1));
    vec2 cm1_1 = get_c(vec2(-1,1));
    vec2 cm1_0 = get_c(vec2(-1,0));
    vec2 cm1m1 = get_c(vec2(-1,-1));
    vec2 cm1m2 = get_c(vec2(-1,-2));
    vec2 cm2_2 = get_c(vec2(-2));
    vec2 cm2_1 = get_c(vec2(-2,1));
    vec2 cm2_0 = get_c(vec2(-2,0));
    vec2 cm2m1 = get_c(vec2(-2,-1));
    vec2 cm2m2 = get_c(vec2(-2,-2));


    if (ssaa == 1) {

        vec3 frac_2_2 = mandel(c_2_2);
        vec3 frac_2_1 = mandel(c_2_1);
        vec3 frac_2_0 = mandel(c_2_0);
        vec3 frac_2m1 = mandel(c_2m1);
        vec3 frac_2m2 = mandel(c_2m2);
        vec3 frac_1_2 = mandel(c_1_2);
        vec3 frac_1_1 = mandel(c_1_1);
        vec3 frac_1_0 = mandel(c_1_0);
        vec3 frac_1m1 = mandel(c_1m1);
        vec3 frac_1m2 = mandel(c_1m2);
        vec3 frac_0_2 = mandel(c_0_2);
        vec3 frac_0_1 = mandel(c_0_1);
        vec3 frac_0_0 = mandel(c_0_0);
        vec3 frac_0m1 = mandel(c_0m1);
        vec3 frac_0m2 = mandel(c_0m2);
        vec3 fracm1_2 = mandel(cm1_2);
        vec3 fracm1_1 = mandel(cm1_1);
        vec3 fracm1_0 = mandel(cm1_0);
        vec3 fracm1m1 = mandel(cm1m1);
        vec3 fracm1m2 = mandel(cm1m2);
        vec3 fracm2_2 = mandel(cm2_2);
        vec3 fracm2_1 = mandel(cm2_1);
        vec3 fracm2_0 = mandel(cm2_0);
        vec3 fracm2m1 = mandel(cm2m1);
        vec3 fracm2m2 = mandel(cm2m2);
    
        gl_FragColor = vec4(
            (frac_2_2 + frac_2_1 + frac_2_0 + frac_2m1 + frac_2m2
            + frac_1_2 + frac_1_1 + frac_1_0 + frac_1m1 + frac_1m2
            + frac_0_2 + frac_0_1 + frac_0_0 + frac_0m1 + frac_0m2
            + fracm1_2 + fracm1_1 + fracm1_0 + fracm1m1 + fracm1m2
            + fracm2_2 + fracm2_1 + fracm2_0 + fracm2m1 + fracm2m2) / 25, 1.0);
    } else {
        vec3 fractal = mandel(c_0_0);
        gl_FragColor = vec4(fractal, 1.0);
    }

}


