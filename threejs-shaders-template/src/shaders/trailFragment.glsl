
uniform sampler2D uCurrentTexture;
uniform sampler2D uAccumulatedTexture;
uniform float uTime;
uniform vec2 uMouse;
uniform float uDecay;
uniform float uIntensity;
varying vec2 vUv;

void main() {
    vec4 previous = texture2D(uAccumulatedTexture, vUv);
    
    // Calculate distance to mouse
    float dist = length(uMouse - vUv);
    float mouseMask = smoothstep(0.05, 0.0, dist);
    
    // Create trail effect
    vec4 mouseGlow = vec4(1.0, 1.0, 1.0, 1.0) * mouseMask * uIntensity;
    
    // Add new position to previous frame with decay
    vec4 trail = previous * uDecay + mouseGlow;
    
    gl_FragColor = trail;
}
