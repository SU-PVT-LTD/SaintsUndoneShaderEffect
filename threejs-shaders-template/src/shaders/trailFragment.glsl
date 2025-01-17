
uniform sampler2D uTrailTexture;
uniform sampler2D uCurrentTexture;
uniform float uDecay;
varying vec2 vUv;

void main() {
    vec4 previous = texture2D(uTrailTexture, vUv);
    vec4 current = texture2D(uCurrentTexture, vUv);
    
    // Exponential decay for smoother fade
    float decay = pow(uDecay, 2.0);
    vec4 blended = mix(previous * decay, current, 0.1);
    
    gl_FragColor = blended;
}
