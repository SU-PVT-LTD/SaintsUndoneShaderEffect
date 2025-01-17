
uniform sampler2D uPreviousTexture;
uniform sampler2D uCurrentTexture;
uniform float uDecay;
uniform float uTime;
varying vec2 vUv;

void main() {
    // Sample current and previous frame
    vec4 current = texture2D(uCurrentTexture, vUv);
    
    // Add motion blur effect
    vec2 velocity = vec2(
        sin(uTime + vUv.y * 4.0) * 0.001,
        cos(uTime + vUv.x * 4.0) * 0.001
    );
    
    vec4 previous = vec4(0.0);
    float samples = 5.0;
    
    // Accumulate samples with motion blur
    for(float i = 0.0; i < samples; i++) {
        vec2 offset = velocity * (i / samples);
        previous += texture2D(uPreviousTexture, vUv + offset);
    }
    previous /= samples;
    
    // Blend current frame with previous frames
    float blend = uDecay;
    vec4 color = mix(current, previous, blend);
    
    // Add subtle glow
    float brightness = max(color.r, max(color.g, color.b));
    color.rgb += color.rgb * brightness * 0.2;
    
    gl_FragColor = color;
}
