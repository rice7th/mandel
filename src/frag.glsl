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

    // Cardioid & bulb detection
    double p = sqrt((c.x*c.x - 0.5 * c.x + 1/16) + c.y*c.y);
    if (c.x <= (p - 2*p*p + 0) || ((c.x*c.x + 2*c.x + 1) + c.y*c.y) <= 1/16) {
        return dvec3(0);
    }

    for (int i = 0; i < iter; i++) {
        z = cmplx_pow2(z);
        z = dvec2(z.x + c.x, z.y + c.y);
        if (z.x > 2 || z.y > 2) {
            return dvec3(palette(float(i) / (0.1 * iter), vec3(0.5), vec3(0.5), vec3(1), vec3(0.00, 0.33, 0.67)));
        }
    }
    return dvec3(0);
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

dvec2 get_c(dvec2 offset) {
    dvec2 uv = ((dvec2(gl_FragCoord.xy * 3) + offset) / dvec2(res * 3) - 0.5) * 4;
    uv.x *= res.x / res.y;

    dvec2 position = dvec2(pos.x, pos.y);

    dvec2 c = uv / exp2(zoom.x / 2) - position;
    return c;
}

void main() {
    dvec2 c = get_c(dvec2(0));

    dvec2 ct = get_c(dvec2(0,1));
    dvec2 cb = get_c(dvec2(0,-1));
    dvec2 cl = get_c(dvec2(-1,0));
    dvec2 cr = get_c(dvec2(1,0));

    dvec2 ctl = get_c(dvec2(-1, 1));
    dvec2 ctr = get_c(dvec2(1));
    dvec2 cbl = get_c(dvec2(-1));
    dvec2 cbr = get_c(dvec2(1, -1));

    dvec3 fractal = mandel(c);

    dvec3 fractalt = mandel(ct);
    dvec3 fractalb = mandel(cb);
    dvec3 fractall = mandel(cl);
    dvec3 fractalr = mandel(cr);

    dvec3 fractaltl = mandel(ctl);
    dvec3 fractaltr = mandel(ctr);
    dvec3 fractalbl = mandel(cbl);
    dvec3 fractalbr = mandel(cbr);

    gl_FragColor = vec4((fractalt + fractalb + fractall + fractalr + fractaltl + fractaltr + fractalbl + fractalbr) / 9, 1.0);
    //gl_FragColor = vec4(uv.x, uv.y, 0.0, 1.0);
}


