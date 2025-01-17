
uniform sampler2D uAccumulatedTexture;
uniform vec2 uMouse;
uniform float uDecay;
uniform float uIntensity;
uniform float uTime;

varying vec2 vUv;

void main() {
    // Calculate velocity based on distance to mouse
    vec2 toMouse = uMouse - vUv;
    float dist = length(toMouse);
    vec2 velocity = toMouse * smoothstep(0.5, 0.0, dist) * 0.1;
    
    // Accumulate samples along velocity vector
    vec4 accumulation = vec4(0.0);
    float totalWeight = 0.0;
    
    const int TRAIL_STEPS = 16;
    for(int i = 0; i < TRAIL_STEPS; i++) {
        float t = float(i) / float(TRAIL_STEPS - 1);
        vec2 offset = velocity * t;
        vec2 samplePos = vUv - offset;
        
        float weight = 1.0 - t;
        weight *= weight;
        
        accumulation += texture2D(uAccumulatedTexture, samplePos) * weight;
        totalWeight += weight;
    }
    
    accumulation /= totalWeight;
    
    // Add current mouse position glow
    float mouseGlow = smoothstep(0.1, 0.0, dist) * uIntensity;
    vec4 color = max(accumulation * uDecay, vec4(mouseGlow));
    
    gl_FragColor = color;
}
