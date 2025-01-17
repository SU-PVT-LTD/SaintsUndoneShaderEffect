
uniform sampler2D uPreviousTexture;
uniform vec2 uMousePos;
uniform float uAccumulationStrength;
varying vec2 vUv;

void main() {
    vec4 prevColor = texture2D(uPreviousTexture, vUv);
    
    // Calculate distance to mouse
    float dist = distance(vUv, uMousePos);
    float strength = 1.0 - smoothstep(0.0, 0.1, dist);
    
    // Create new color based on mouse position
    vec4 newColor = vec4(1.0, 1.0, 1.0, strength);
    
    // Blend with previous frame
    vec4 accumulated = mix(
        prevColor * uAccumulationStrength,
        max(newColor, prevColor),
        strength
    );
    
    gl_FragColor = accumulated;
}
