
varying vec2 vUv;
varying vec3 vNormal;
varying vec3 vPosition;
uniform vec2 uMouse;
uniform sampler2D uNormalMap;
uniform vec3 uLightPosition;
uniform sampler2D uTrailTexture;
uniform float uAmbient;
uniform float uDiffuseStrength;
uniform float uSpecularStrength;
uniform float uSpecularPower;
uniform float uWrap;
uniform float uCursorVelocity;

void main()
{
    // Calculate stronger chromatic aberration offset based on cursor velocity
    float aberrationStrength = min(uCursorVelocity * 0.3, 0.15);
    // Get accumulated mask from trail texture with sharper falloff
    vec4 accumulation = texture2D(uTrailTexture, vUv);
    float finalStrength = pow(accumulation.r, 1.5); // Sharper falloff

    // Enhanced relief effect
    vec3 normalMap = texture2D(uNormalMap, vUv).rgb * 3.0 - 1.5; // Stronger normal mapping
    vec3 mixedNormal = normalize(mix(vNormal, normalMap, finalStrength * 1.5));

    // Store the enhanced reveal strength
    gl_FragColor.a = finalStrength;

    // Enhanced lighting
    vec3 lightDir = normalize(uLightPosition - vPosition);
    vec3 viewDir = normalize(-vPosition);
    vec3 halfDir = normalize(lightDir + viewDir);

    // Profile-based lighting
    float diffuse = max((dot(mixedNormal, lightDir) + uWrap) / (1.0 + uWrap), 0.0);
    float specular = pow(max(dot(mixedNormal, halfDir), 0.0), uSpecularPower) * uSpecularStrength;
    
    // Blend the lighting components based on profile settings
    // Calculate base color
    vec3 baseColor = vec3(0.722) * (uAmbient + diffuse * uDiffuseStrength + specular);
    
    // Enhanced chromatic aberration with sharper color separation
    vec3 color = vec3(0.95); // Brighter base color for more contrast
    if (finalStrength > 0.005) { // Lower threshold for wider effect
        vec2 offsetR = vec2(aberrationStrength * 0.7, aberrationStrength * 0.2);
        vec2 offsetB = vec2(-aberrationStrength * 0.7, -aberrationStrength * 0.2);
        
        float trailR = texture2D(uTrailTexture, vUv + offsetR).r;
        float trailB = texture2D(uTrailTexture, vUv + offsetB).r;
        
        color.r = mix(color.r, trailR * 1.2, finalStrength * aberrationStrength * 100.0);
        color.b = mix(color.b, trailB * 1.2, finalStrength * aberrationStrength * 100.0);
        color.g = mix(color.g, (trailR + trailB) * 0.4, finalStrength * aberrationStrength * 70.0);
    }
    
    // Ensure we don't exceed maximum brightness
    color = min(color, vec3(1.0));
    
    gl_FragColor = vec4(color, 1.0);
}
