
uniform sampler2D uTrailTexture;
uniform sampler2D uCurrentTexture;
uniform float uDecay;
uniform float uTime;
varying vec2 vUv;

void main() {
    // Get current and previous frame
    vec4 current = texture2D(uCurrentTexture, vUv);
    vec4 previous = texture2D(uTrailTexture, vUv);
    
    // Calculate trail strength
    float strength = max(previous.r, max(previous.g, previous.b));
    
    // Apply decay
    strength *= uDecay;
    
    // Add motion effect
    vec2 offset = vec2(
        sin(uTime + vUv.y * 5.0) * 0.002,
        cos(uTime + vUv.x * 5.0) * 0.002
    );
    
    // Sample with offset for motion effect
    vec4 offsetPrevious = texture2D(uTrailTexture, vUv + offset);
    
    // Blend between current and previous frames
    vec4 trail = mix(current, offsetPrevious, strength);
    
    // Output final color
    gl_FragColor = vec4(trail.rgb, 1.0);
}
