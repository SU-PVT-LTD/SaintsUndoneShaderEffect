
uniform sampler2D uPreviousTexture;
uniform vec2 uMousePos;
uniform float uAccumulationStrength;
uniform float uTurbulenceScale;
uniform float uTurbulenceStrength;
uniform float uEdgeSharpness;
uniform float uSwirlStrength;
uniform float uTime;
uniform vec2 uVelocity;
varying vec2 vUv;

float getVelocityFactor() {
    float speed = length(uVelocity);
    return clamp(speed * 2.0, 0.0, 1.0);
}

// Noise functions
float random(vec2 st) {
    return fract(sin(dot(st.xy, vec2(12.9898,78.233))) * 43758.5453123);
}

vec2 hash(vec2 p) {
    p = vec2(dot(p,vec2(127.1,311.7)), dot(p,vec2(269.5,183.3)));
    return -1.0 + 2.0*fract(sin(p)*43758.5453123);
}

float noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    
    vec2 u = f*f*(3.0-2.0*f);

    return mix(mix(dot(hash(i + vec2(0.0,0.0)), f - vec2(0.0,0.0)),
                   dot(hash(i + vec2(1.0,0.0)), f - vec2(1.0,0.0)), u.x),
               mix(dot(hash(i + vec2(0.0,1.0)), f - vec2(0.0,1.0)),
                   dot(hash(i + vec2(1.0,1.0)), f - vec2(1.0,1.0)), u.x), u.y);
}

void main() {
    vec4 prevColor = texture2D(uPreviousTexture, vUv);
    
    // Calculate base distance to mouse
    float dist = distance(vUv, uMousePos);
    
    // Add turbulence
    float time = float(uMousePos.x + uMousePos.y) * 10.0;
    vec2 noiseCoord = vUv * 8.0 + time * 0.1;
    float velocityFactor = getVelocityFactor();
    float baseTurbulence = noise(noiseCoord) * 0.15;
    float velocityTurbulence = noise(noiseCoord * 2.0 + uVelocity * 0.5) * velocityFactor * 0.3;
    float turbulence = mix(baseTurbulence, velocityTurbulence, velocityFactor);
    
    // Create organic, fluid-like falloff
    float baseStrength = 1.0 - smoothstep(0.0, 0.15, dist + turbulence);
    float edgeNoise = noise(vUv * 20.0 + time * 0.05) * 0.2;
    float strength = baseStrength + edgeNoise * baseStrength;
    
    // Add some swirling motion
    vec2 swirl = vec2(
        noise(noiseCoord + 1.0),
        noise(noiseCoord + 2.0)
    ) * (0.02 + velocityFactor * 0.05) * strength;
    
    // Sample previous color with swirl offset
    vec4 swirlPrev = texture2D(uPreviousTexture, vUv + swirl);
    
    // Create new color with organic falloff
    vec4 newColor = vec4(1.0, 1.0, 1.0, strength);
    
    // Blend with previous frame
    vec4 accumulated = mix(
        swirlPrev * uAccumulationStrength,
        max(newColor, swirlPrev),
        strength * 0.7
    );
    
    gl_FragColor = accumulated;
}
