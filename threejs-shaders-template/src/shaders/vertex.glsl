
varying vec2 vUv;
varying vec3 vNormal;
varying vec3 vPosition;
uniform vec2 uMouse;
uniform sampler2D uNormalMap;

void main()
{
    vUv = uv;
    
    // Calculate distance from mouse
    float dist = distance(vUv, uMouse);
    float strength = 1.0 - smoothstep(0.0, 0.2, dist);
    
    // Sample normal map for displacement
    vec3 normalColor = texture2D(uNormalMap, vUv).rgb;
    float displacement = (normalColor.r + normalColor.g + normalColor.b) / 3.0;
    
    // Apply displacement along normal
    vec3 newPosition = position + normal * displacement * strength * 0.1;
    
    vNormal = normalMatrix * normal;
    vPosition = (modelViewMatrix * vec4(newPosition, 1.0)).xyz;
    gl_Position = projectionMatrix * modelViewMatrix * vec4(newPosition, 1.0);
}
