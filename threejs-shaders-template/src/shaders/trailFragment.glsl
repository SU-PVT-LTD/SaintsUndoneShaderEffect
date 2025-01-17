
uniform sampler2D uCurrentTexture;
uniform sampler2D uAccumulatedTexture;
uniform float uTime;
uniform vec2 uMouse;
uniform float uDecay;
uniform float uIntensity;
varying vec2 vUv;

void main() {
    // Get current and previous frames
    vec4 current = texture2D(uCurrentTexture, vUv);
    vec4 previous = texture2D(uAccumulatedTexture, vUv);
    
    // Calculate distance to mouse
    float dist = length(uMouse - vUv);
    float mouseMask = smoothstep(0.03, 0.0, dist);
    
    // Create trail effect
    vec4 mouseGlow = vec4(1.0, 1.0, 1.0, 1.0) * mouseMask * uIntensity;
    
    // Blend previous frame with decay
    vec4 trail = max(previous * uDecay, mouseGlow);
    
    gl_FragColor = trail;
}
