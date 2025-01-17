
varying vec2 vUv;
varying vec3 vNormal;
varying vec3 vPosition;
uniform vec2 uMouse;
uniform sampler2D uNormalMap;
uniform float uDisplacementStrength;
uniform float uEffectRadius;

void main()
{
    vUv = uv;
    
    // Calculate distance from mouse with smoother transition
    float dist = distance(vUv, uMouse);
    float strength = 1.0 - smoothstep(0.0, uEffectRadius, dist);
    
    // Create ripple effect
    float ripple = sin(dist * 30.0 - time * 2.0) * 0.5 + 0.5;
    strength = strength * ripple;
    
    // Sample normal map and create fluid-like normals
    vec3 normalColor = texture2D(uNormalMap, vUv + vec2(time * 0.05)).rgb * 2.0 - 1.0;
    vec3 surfaceNormal = normalize(normalMatrix * normalColor);
    
    // Smooth wave displacement
    float displacement = sin(dot(normalColor, vec3(0.5)) * 3.14159 + time);
    displacement *= strength;
    
    // Apply displacement with fluid-like behavior
    vec3 displacementVector = mix(normal, surfaceNormal, 0.7);
    vec3 newPosition = position + displacementVector * displacement * uDisplacementStrength;
    
    vNormal = normalMatrix * normal;
    vPosition = (modelViewMatrix * vec4(newPosition, 1.0)).xyz;
    gl_Position = projectionMatrix * modelViewMatrix * vec4(newPosition, 1.0);
}
