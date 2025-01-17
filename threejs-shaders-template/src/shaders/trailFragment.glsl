
uniform sampler2D uTrailTexture;
uniform sampler2D uCurrentTexture;
uniform float uDecay;
uniform float uTime;
varying vec2 vUv;

void main() {
    vec4 current = texture2D(uCurrentTexture, vUv);
    vec4 previous = texture2D(uTrailTexture, vUv);
    
    // Enhanced trail effect
    float trailStrength = max(previous.r, max(previous.g, previous.b));
    trailStrength = pow(trailStrength * uDecay, 0.5) * 2.0;
    
    // Smoother blend between frames
    vec4 trail = mix(previous, current, 0.2);
    trail *= 0.98; // Subtle fade out
    
    // Add time-based modulation for more organic feel
    float modulation = 0.97 + 0.03 * sin(uTime * 0.5);
    trail *= modulation;
    
    // Apply trail strength
    gl_FragColor = vec4(trail.rgb * trailStrength, 1.0);
}
