
uniform sampler2D uPreviousTexture;
uniform vec2 uMousePos;
uniform vec2 uMouseVelocity;
uniform float uAccumulationStrength;
uniform float uTurbulenceScale;
uniform float uTurbulenceStrength;
uniform float uEdgeSharpness;
uniform float uSwirlStrength;
uniform float uTime;
varying vec2 vUv;

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
    return mix(
        mix(dot(hash(i + vec2(0.0,0.0)), f - vec2(0.0,0.0)),
            dot(hash(i + vec2(1.0,0.0)), f - vec2(1.0,0.0)), u.x),
        mix(dot(hash(i + vec2(0.0,1.0)), f - vec2(0.0,1.0)),
            dot(hash(i + vec2(1.0,1.0)), f - vec2(1.0,1.0)), u.x),
        u.y
    );
}

void main() {
    float velocityMagnitude = length(uMouseVelocity);
    float velocityFactor = smoothstep(2.0, 20.0, velocityMagnitude);
    
    // Calculate base distance to mouse
    float dist = distance(vUv, uMousePos);
    
    // Add velocity-based directional distortion
    vec2 velocityDirection = normalize(uMouseVelocity);
    float disperseStrength = velocityFactor * 0.15;
    vec2 disperseOffset = velocityDirection * disperseStrength;
    
    // Enhanced turbulence based on velocity
    float time = uTime * (1.0 + velocityFactor);
    vec2 noiseCoord = vUv * (uTurbulenceScale + velocityFactor * 4.0) + time * 0.1;
    float turbulence = noise(noiseCoord) * (uTurbulenceStrength + velocityFactor * 0.2);
    
    // Create organic, fluid-like falloff with velocity influence
    float baseStrength = 1.0 - smoothstep(0.0, 0.15 + disperseStrength, dist + turbulence);
    float edgeNoise = noise(vUv * (20.0 + velocityFactor * 10.0) + time * 0.05) * 0.2;
    float strength = baseStrength + edgeNoise * baseStrength;
    
    // Enhanced swirling based on velocity
    vec2 swirl = vec2(
        noise(noiseCoord + 1.0),
        noise(noiseCoord + 2.0)
    ) * (uSwirlStrength + velocityFactor * 0.03) * strength;
    
    // Add velocity-based dispersion to swirl
    swirl += disperseOffset * strength;
    
    // Sample previous color with enhanced swirl
    vec4 swirlPrev = texture2D(uPreviousTexture, vUv + swirl);
    
    // Create new color with organic falloff
    vec4 newColor = vec4(1.0, 1.0, 1.0, strength);
    
    // Enhanced blending with velocity influence
    float blendFactor = strength * (0.7 + velocityFactor * 0.3);
    vec4 accumulated = mix(
        swirlPrev * (uAccumulationStrength - velocityFactor * 0.1),
        max(newColor, swirlPrev),
        blendFactor
    );
    
    gl_FragColor = accumulated;
}
