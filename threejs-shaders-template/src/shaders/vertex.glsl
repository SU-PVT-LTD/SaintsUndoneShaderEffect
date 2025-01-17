
varying vec2 vUv;
varying vec3 vNormal;
varying vec3 vPosition;
uniform vec2 uMouse;
uniform sampler2D uNormalMap;
uniform float uDisplacementStrength;
uniform float uEffectRadius;
uniform float uTime;

void main()
{
    vUv = uv;
    
    // Calculate distance from mouse with smoother transition
    float dist = distance(vUv, uMouse);
    float strength = 1.0 - smoothstep(0.0, uEffectRadius, dist);
    strength = pow(strength, 2.0); // Sharper falloff
    
    // Sample normal map and convert to world space normal
    vec3 normalColor = texture2D(uNormalMap, vUv).rgb * 2.0 - 1.0;
    vec3 surfaceNormal = normalize(normalMatrix * normalColor);
    
    // Calculate displacement using normal map direction
    float displacement = dot(normalColor, vec3(0.0, 0.0, 1.0));
    
    // Apply displacement using both surface normal and base normal
    vec3 displacementVector = mix(normal, surfaceNormal, 0.5);
    vec3 newPosition = position + displacementVector * displacement * strength * uDisplacementStrength;
    
    vNormal = normalMatrix * normal;
    vPosition = (modelViewMatrix * vec4(newPosition, 1.0)).xyz;
    gl_Position = projectionMatrix * modelViewMatrix * vec4(newPosition, 1.0);
}
