
uniform sampler2D uTrailTexture;
uniform sampler2D uCurrentTexture;
uniform float uDecay;
varying vec2 vUv;

void main() {
    vec4 previous = texture2D(uTrailTexture, vUv);
    vec4 current = texture2D(uCurrentTexture, vUv);
    
    // More pronounced trail effect
    float decay = pow(uDecay, 0.95);
    vec4 blended = mix(previous * decay, current, 0.1);
    
    // Enhance trail brightness
    blended *= 1.8;
    blended = pow(blended, vec4(0.8));
    blended.a = 1.0;
    
    gl_FragColor = blended;
}
