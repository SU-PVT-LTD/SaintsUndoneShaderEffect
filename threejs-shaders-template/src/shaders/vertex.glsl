
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
    strength = pow(strength, 2.0); // Sharper falloff
    
    // Sample normal map for displacement with enhanced depth
    vec3 normalColor = texture2D(uNormalMap, vUv).rgb;
    float displacement = (normalColor.r + normalColor.g + normalColor.b) / 3.0;
    displacement = pow(displacement, 1.5); // Enhance depth contrast
    
    // Apply displacement along normal with configurable strength
    vec3 newPosition = position + normal * displacement * strength * uDisplacementStrength;
    
    vNormal = normalMatrix * normal;
    vPosition = (modelViewMatrix * vec4(newPosition, 1.0)).xyz;
    gl_Position = projectionMatrix * modelViewMatrix * vec4(newPosition, 1.0);
}
