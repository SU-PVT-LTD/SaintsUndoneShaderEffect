
uniform sampler2D uTrailTexture;
uniform sampler2D uCurrentTexture;
uniform float uDecay;
varying vec2 vUv;

void main() {
    vec4 previous = texture2D(uTrailTexture, vUv);
    vec4 current = texture2D(uCurrentTexture, vUv);
    
    // More pronounced trail effect
    float decay = pow(uDecay, 1.5);
    vec4 blended = mix(previous * decay, current, 0.15);
    
    // Ensure minimum opacity
    blended.a = max(blended.a, 0.1);
    
    gl_FragColor = blended;
}
