
uniform sampler2D uCurrentTexture;
uniform sampler2D uAccumulatedTexture;
uniform float uTime;
uniform vec2 uMouse;
uniform float uDecay;
uniform float uIntensity;
varying vec2 vUv;

void main() {
    vec2 velocity = (uMouse - vUv) * 0.1;
    float dist = length(velocity);
    
    vec4 currentFrame = texture2D(uCurrentTexture, vUv);
    vec4 accumulation = vec4(0.0);
    
    // Sample multiple points along the motion vector
    const int SAMPLES = 32;
    for(int i = 0; i < SAMPLES; i++) {
        float t = float(i) / float(SAMPLES);
        vec2 offset = velocity * t;
        vec2 sampleUV = vUv - offset;
        vec4 sample = texture2D(uAccumulatedTexture, sampleUV);
        
        // Apply decay based on sample position
        float decay = pow(uDecay, t * 10.0);
        accumulation += sample * decay;
    }
    
    accumulation /= float(SAMPLES);
    
    // Blend between current frame and accumulated trail
    float blendFactor = smoothstep(0.0, 0.5, dist) * uIntensity;
    vec4 final = mix(currentFrame, accumulation, blendFactor);
    
    gl_FragColor = final;
}
