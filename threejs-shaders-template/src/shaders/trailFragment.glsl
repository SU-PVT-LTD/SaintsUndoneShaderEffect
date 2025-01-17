
uniform sampler2D uTrailTexture;
uniform sampler2D uCurrentTexture;
uniform float uDecay;
varying vec2 vUv;

void main() {
    vec4 previous = texture2D(uTrailTexture, vUv);
    vec4 current = texture2D(uCurrentTexture, vUv);
    
    // More pronounced trail effect
    float decay = pow(uDecay, 1.05);
    vec4 blended = mix(previous * decay, current, 0.15);
    
    // Enhanced ethereal effect
    blended *= 1.4;
    blended += vec4(0.05) * pow(length(blended.rgb), 2.0);
    blended.a = 1.0;
    
    gl_FragColor = blended;
}
