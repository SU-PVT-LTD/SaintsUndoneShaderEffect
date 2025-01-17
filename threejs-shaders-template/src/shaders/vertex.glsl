
varying vec2 vUv;
varying vec3 vNormal;
varying vec3 vPosition;
uniform vec2 uMouse;
uniform sampler2D uNormalMap;
uniform float uDisplacementStrength;
uniform float uEffectRadius;
uniform sampler2D uRevealMap;

void main()
{
    vUv = uv;
    
    // Get the reveal value from the reveal map
    float revealValue = texture2D(uRevealMap, vUv).r;
    
    // Sample normal map and convert to world space normal
    vec3 normalColor = texture2D(uNormalMap, vUv).rgb * 2.0 - 1.0;
    vec3 surfaceNormal = normalize(normalMatrix * normalColor);
    
    // Calculate displacement using normal map direction
    float displacement = dot(normalColor, vec3(0.0, 0.0, 1.0));
    
    // Apply displacement using revealed areas
    vec3 displacementVector = mix(normal, surfaceNormal, 0.5);
    vec3 newPosition = position + displacementVector * displacement * revealValue * uDisplacementStrength;
    
    vNormal = normalMatrix * normal;
    vPosition = (modelViewMatrix * vec4(newPosition, 1.0)).xyz;
    gl_Position = projectionMatrix * modelViewMatrix * vec4(newPosition, 1.0);
}
