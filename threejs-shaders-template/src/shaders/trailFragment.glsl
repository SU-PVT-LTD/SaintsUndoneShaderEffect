uniform sampler2D uTrailTexture;
uniform sampler2D uCurrentTexture;
uniform float uDecay;
uniform float uTime;
varying vec2 vUv;

void main() {
    vec4 current = texture2D(uCurrentTexture, vUv);
    vec4 previous = texture2D(uTrailTexture, vUv);
    
    // Apply time-based decay
    float decay = uDecay * (0.95 + 0.05 * sin(uTime));
    vec4 blended = mix(previous, current, 1.0 - decay);
    
    // Add fade out effect
    blended *= 0.98;
    
    gl_FragColor = blended;
}
