
varying vec2 vUv;
varying vec3 vNormal;
varying vec3 vPosition;
uniform vec2 uMouse;
uniform sampler2D uTrailTexture;
uniform sampler2D uNormalMap;
uniform vec3 uLightPosition;
uniform float uDecay;

void main()
{
    // Distance from the mouse
    float dist = distance(vUv, uMouse);
    float strength = 0.05 / dist;
    strength = clamp(strength, 0.0, 1.0);

    // Sample normal map
    vec3 normalMap = texture2D(uNormalMap, vUv).rgb * 2.0 - 1.0;
    normalMap = normalize(normalMap);
    
    // Apply mouse-based normal map strength
    normalMap = mix(vec3(0.0, 0.0, 1.0), normalMap, strength);

    // Lighting calculation
    vec3 lightDir = normalize(uLightPosition - vPosition);
    float diffuse = max(dot(normalMap, lightDir), 0.0);
    
    // Basic ambient light
    float ambient = 0.3;

    // Final lighting
    float lighting = ambient + diffuse * strength;
    
    // Get the previous frame's color
    vec4 previousColor = texture2D(uTrailTexture, vUv);

    // Create base white color with lighting
    vec3 currentColor = vec3(lighting);

    // Blend current and previous colors with decay
    vec3 blendedColor = mix(previousColor.rgb, currentColor, strength);
    blendedColor *= uDecay;

    gl_FragColor = vec4(blendedColor, 1.0);
}
