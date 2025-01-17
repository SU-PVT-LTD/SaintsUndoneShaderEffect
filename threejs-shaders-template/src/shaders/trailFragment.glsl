
uniform sampler2D uTrailTexture;
uniform sampler2D uCurrentTexture;
uniform float uDecay;
uniform float uTime;
varying vec2 vUv;

void main() {
    vec4 current = texture2D(uCurrentTexture, vUv);
    vec4 previous = texture2D(uTrailTexture, vUv);
    
    // Enhanced embossed trail effect
    float trailStrength = max(previous.r, max(previous.g, previous.b));
    
    // Stronger decay for more pronounced trail fade
    float decay = pow(uDecay, 1.5);
    trailStrength *= decay;
    
    // Smoother blend between frames
    vec4 trail = mix(previous, current, 0.15);
    
    // Add subtle wave movement
    float wave = sin(uTime * 0.5 + vUv.x * 3.0) * 0.02;
    trail.rgb += vec3(wave);
    
    // Enhance brightness of active areas
    float brightness = smoothstep(0.2, 0.8, trailStrength);
    trail.rgb *= (1.0 + brightness * 0.5);
    
    gl_FragColor = vec4(trail.rgb * trailStrength, 1.0);
}
