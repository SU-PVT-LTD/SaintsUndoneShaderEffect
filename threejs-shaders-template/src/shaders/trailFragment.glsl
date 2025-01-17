
uniform sampler2D uTrailTexture;
uniform sampler2D uCurrentTexture; 
uniform float uDecay;
uniform float uTime;
varying vec2 vUv;

void main() {
    vec4 current = texture2D(uCurrentTexture, vUv);
    vec4 previous = texture2D(uTrailTexture, vUv);
    
    // Calculate motion offset
    vec2 offset = vec2(
        sin(uTime * 0.5 + vUv.y * 3.0) * 0.003,
        cos(uTime * 0.5 + vUv.x * 3.0) * 0.003
    );
    
    // Sample previous frame with offset
    vec4 offsetPrevious = texture2D(uTrailTexture, vUv + offset);
    
    // Calculate trail strength
    float strength = max(offsetPrevious.r, max(offsetPrevious.g, offsetPrevious.b));
    strength *= uDecay;
    
    // Blend between current and previous
    vec4 trail = mix(current, offsetPrevious, strength);
    
    gl_FragColor = vec4(trail.rgb, 1.0);
}
