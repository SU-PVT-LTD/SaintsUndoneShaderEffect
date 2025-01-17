
uniform sampler2D uTrailTexture;
uniform sampler2D uCurrentTexture;
varying vec2 vUv;

void main() {
    vec4 previous = texture2D(uTrailTexture, vUv);
    vec4 current = texture2D(uCurrentTexture, vUv);
    
    // Take the maximum value between previous and current
    vec4 result = max(previous, current);
    
    gl_FragColor = result;
}
