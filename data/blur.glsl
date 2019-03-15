// Adapted from:
// http://callumhay.blogspot.com/2010/09/gaussian-blur-shader-glsl.html

#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

#define PROCESSING_TEXTURE_SHADER

uniform sampler2D tex0;
uniform vec3 iResolution;

// The inverse of the tex0 dimensions along X and Y
uniform vec2 texOffset;

uniform int blurSize;             
uniform int horizontalPass; // 0 or 1 to indicate vertical or horizontal pass
uniform float sigma;                // The sigma value for the gaussian function: higher value means more blur
                                                        // A good value for 9x9 is around 3 to 5
                                                        // A good value for 7x7 is around 2.5 to 4
                                                        // A good value for 5x5 is around 2 to 3.5
                                                        // ... play around with this based on what you need :)

const float pi = 3.14159265;

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = fragCoord.xy / iResolution.xy;
    uv = vec2(uv.x, 1.0-uv.y);
    float numBlurPixelsPerSide = float(blurSize / 2); 
    
    vec2 blurMultiplyVec = 0 < horizontalPass ? vec2(1.0, 0.0) : vec2(0.0, 1.0);

    // Incremental Gaussian Coefficent Calculation (See GPU Gems 3 pp. 877 - 889)
    vec3 incrementalGaussian;
    incrementalGaussian.x = 1.0 / (sqrt(2.0 * pi) * sigma);
    incrementalGaussian.y = exp(-0.5 / (sigma * sigma));
    incrementalGaussian.z = incrementalGaussian.y * incrementalGaussian.y;

    vec4 avgValue = vec4(0.0, 0.0, 0.0, 0.0);
    float coefficientSum = 0.0;

    // Take the central sample first...
    avgValue += texture2D(tex0, uv) * incrementalGaussian.x;
    coefficientSum += incrementalGaussian.x;
    incrementalGaussian.xy *= incrementalGaussian.yz;

    // Go through the remaining 8 vertical samples (4 on each side of the center)
    for (float i = 1.0; i <= numBlurPixelsPerSide; i++) { 
        avgValue += texture2D(tex0, uv - i * texOffset * 
                                                    blurMultiplyVec) * incrementalGaussian.x;                 
        avgValue += texture2D(tex0, uv + i * texOffset * 
                                                    blurMultiplyVec) * incrementalGaussian.x;                 
        coefficientSum += 2.0 * incrementalGaussian.x;
        incrementalGaussian.xy *= incrementalGaussian.yz;
    }

    fragColor = avgValue / coefficientSum;
}

void main() {
    mainImage(gl_FragColor, gl_FragCoord.xy);
}