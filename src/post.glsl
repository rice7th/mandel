#version 330

in vec2 texcoord;
in vec4 color;

uniform vec2 res;
uniform sampler2D tex;
uniform int filter_;


// ALL CREDIT GOES TO mrharicot ON SHADERTOY (https://www.shadertoy.com/view/XdfGDH)

float normpdf(float x, float sigma) {
	return 0.39894*exp(-0.5*x*x/(sigma*sigma))/sigma;
}


void main() {
    if (filter_ == 1) {
        vec3 c = texture(tex, gl_FragCoord.xy / res.xy).rgb;
        
        //declare values
        const int mSize = 11;
        int kSize = (mSize-1)/2;
        float kernel[mSize];
        vec3 final_colour = vec3(0.0);
        
        //create the 1-D kernel
        float sigma = 0.5; // Blur amount
        float Z = 0.0;
        for (int j = 0; j <= kSize; ++j)
        {
            kernel[kSize+j] = kernel[kSize-j] = normpdf(float(j), sigma);
        }
        
        //get the normalization factor (as the gaussian has been clamped)
        for (int j = 0; j < mSize; ++j)
        {
            Z += kernel[j];
        }
        
        //read out the texels
        for (int i=-kSize; i <= kSize; ++i)
        {
            for (int j=-kSize; j <= kSize; ++j)
            {
                final_colour += kernel[kSize+j]*kernel[kSize+i]*texture(tex, (gl_FragCoord.xy+vec2(float(i),float(j))) / res.xy).rgb;

            }
        }
        
        
        gl_FragColor = vec4(final_colour/(Z*Z), 1.0);
    } else {
        gl_FragColor = texture(tex, texcoord, 0.0);
    }
}