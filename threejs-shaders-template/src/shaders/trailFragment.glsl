
uniform sampler2D uPreviousTexture;
uniform vec2 uMousePos;
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
    // Get previous frame
    vec4 prevColor = texture2D(uPreviousTexture, vUv);
    
    // Calculate base distance to current point
    float dist = distance(vUv, uMousePos);
    
    // Add turbulence
    vec2 noiseCoord = vUv * uTurbulenceScale + uTime * 0.1;
    float turbulence = noise(noiseCoord) * uTurbulenceStrength;
    
    // Create organic falloff
    float baseStrength = 1.0 - smoothstep(0.0, uEdgeSharpness, dist + turbulence);
    baseStrength = pow(baseStrength, 2.0); // Sharper falloff
    
    // Add swirl effect
    vec2 swirl = vec2(
        noise(noiseCoord + 1.0),
        noise(noiseCoord + 2.0)
    ) * uSwirlStrength * baseStrength;
    
    // Sample previous with swirl
    vec4 swirlColor = texture2D(uPreviousTexture, vUv + swirl);
    
    // Create new trail
    vec4 newColor = vec4(1.0, 1.0, 1.0, baseStrength);
    
    // Blend with decay
    vec4 finalColor = mix(
        swirlColor * uAccumulationStrength,
        max(newColor, swirlColor),
        baseStrength
    );
    
    gl_FragColor = finalColor;
}
