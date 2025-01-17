
uniform sampler2D uPreviousTexture;
uniform vec2 uMousePos;
uniform float uAccumulationStrength;
varying vec2 vUv;

// Noise function
vec2 hash2(vec2 p) {
    p = vec2(dot(p,vec2(127.1,311.7)), dot(p,vec2(269.5,183.3)));
    return -1.0 + 2.0 * fract(sin(p) * 43758.5453123);
}

float noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    
    vec2 u = f * f * (3.0 - 2.0 * f);
    
    float n = mix(
        mix(dot(hash2(i + vec2(0.0,0.0)), f - vec2(0.0,0.0)),
            dot(hash2(i + vec2(1.0,0.0)), f - vec2(1.0,0.0)), u.x),
        mix(dot(hash2(i + vec2(0.0,1.0)), f - vec2(0.0,1.0)),
            dot(hash2(i + vec2(1.0,1.0)), f - vec2(1.0,1.0)), u.x),
        u.y
    );
    return 0.5 + 0.5 * n;
}

void main() {
    vec4 prevColor = texture2D(uPreviousTexture, vUv);
    
    // Calculate base distance to mouse
    float dist = distance(vUv, uMousePos);
    
    // Add turbulence
    float turbulence = noise(vUv * 10.0 + uMousePos * 2.0);
    dist += (turbulence - 0.5) * 0.1;
    
    // Create eddy effect
    float angle = atan(vUv.y - uMousePos.y, vUv.x - uMousePos.x);
    float eddy = sin(angle * 8.0 + turbulence * 4.0) * 0.1;
    dist += eddy * (1.0 - smoothstep(0.0, 0.2, dist));
    
    // Softer falloff
    float strength = 1.0 - smoothstep(0.0, 0.15 + turbulence * 0.1, dist);
    
    // Create new color with turbulent edges
    vec4 newColor = vec4(1.0, 1.0, 1.0, strength);
    
    // Blend with previous frame
    vec4 accumulated = mix(
        prevColor * uAccumulationStrength,
        max(newColor, prevColor),
        strength * (0.8 + turbulence * 0.4)
    );
    
    gl_FragColor = accumulated;
}
