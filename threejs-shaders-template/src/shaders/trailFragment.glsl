
uniform sampler2D uTrailTexture;
uniform sampler2D uCurrentTexture;
uniform float uDecay;
varying vec2 vUv;

void main() {
    vec4 previous = texture2D(uTrailTexture, vUv);
    vec4 current = texture2D(uCurrentTexture, vUv);
    
    // More pronounced trail effect
    float decay = pow(uDecay, 1.2);
    vec4 blended = mix(previous * decay, current, 0.2);
    
    // Enhance trail brightness
    blended *= 1.2;
    blended.a = 1.0;
    
    gl_FragColor = blended;
}
