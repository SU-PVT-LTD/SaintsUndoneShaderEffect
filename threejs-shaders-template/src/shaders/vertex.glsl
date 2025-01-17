
varying vec2 vUv;
varying vec3 vNormal;
varying vec3 vPosition;
uniform vec2 uMouse;
uniform sampler2D uNormalMap;
uniform float uDisplacementStrength;
uniform float uEffectRadius;
uniform float time;

void main()
{
    vUv = uv;
    
    // Calculate distance from mouse with smoother transition
    float dist = distance(vUv, uMouse);
    float strength = 1.0 - smoothstep(0.0, uEffectRadius, dist);
    
    // Create water ripple effect with multiple waves
    float ripple = sin(dist * 20.0 - time * 1.5) * 0.5;
    ripple += sin(dist * 10.0 - time * 0.8) * 0.25;
    strength = strength * (ripple + 1.0);
    
    // Animated water surface
    vec2 waterUV = vUv + vec2(
        sin(vUv.y * 10.0 + time * 0.5) * 0.02,
        cos(vUv.x * 10.0 + time * 0.5) * 0.02
    );
    
    // Sample normal map for water surface detail
    vec3 normalColor = texture2D(uNormalMap, waterUV).rgb * 2.0 - 1.0;
    vec3 surfaceNormal = normalize(normalMatrix * normalColor);
    
    // Water wave displacement
    float baseWave = sin(vUv.x * 5.0 + time * 0.5) * 0.05 + 
                    cos(vUv.y * 5.0 + time * 0.3) * 0.05;
    float displacement = baseWave + strength;
    
    // Fluid-like displacement
    vec3 displacementVector = mix(normal, surfaceNormal, 0.8);
    vec3 newPosition = position + displacementVector * displacement * uDisplacementStrength;
    
    vNormal = normalMatrix * mix(normal, surfaceNormal, 0.5);
    vPosition = (modelViewMatrix * vec4(newPosition, 1.0)).xyz;
    gl_Position = projectionMatrix * modelViewMatrix * vec4(newPosition, 1.0);
}
