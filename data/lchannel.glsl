// Adapted from:
// http://callumhay.blogspot.com/2010/09/gaussian-blur-shader-glsl.html

#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

#define PROCESSING_TEXTURE_SHADER

uniform sampler2D tex0;
uniform vec3 iResolution;

vec4 desaturate(vec3 color) {
  vec3 grayXfer = vec3(1,0,0); //vec3(0.3, 0.59, 0.11);
  vec3 gray = vec3(dot(grayXfer, color));
  return vec4(mix(color, gray, 1.0), 1.0);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = fragCoord.xy / iResolution.xy;
    uv = vec2(uv.x, 1.0-uv.y);

    fragColor = texture2D(tex0, uv) * vec4(1,0,0,1);
    fragColor = desaturate(fragColor.rgb);
}

void main() {
    mainImage(gl_FragColor, gl_FragCoord.xy);
}