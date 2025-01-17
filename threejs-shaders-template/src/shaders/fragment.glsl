
varying vec2 vUv;
varying vec3 vNormal;
varying vec3 vPosition;
uniform vec2 uMouse;
uniform sampler2D uNormalMap;
uniform vec3 uLightPosition;
uniform sampler2D uTrailTexture;

void main()
{
    // Get accumulated mask from trail texture
    vec4 accumulation = texture2D(uTrailTexture, vUv);
    float finalStrength = accumulation.r;

    // Apply reveal mask more strongly
    vec3 normalMap = texture2D(uNormalMap, vUv).rgb * 2.0 - 1.0;
    vec3 mixedNormal = normalize(mix(vNormal, normalMap, finalStrength));

    // Store the reveal strength
    gl_FragColor.a = finalStrength;

    // Enhanced lighting
    vec3 lightDir = normalize(uLightPosition - vPosition);
    vec3 viewDir = normalize(-vPosition);
    vec3 halfDir = normalize(lightDir + viewDir);

    // Softer diffuse lighting with smoother falloff
    float diffuse = smoothstep(0.0, 1.0, max(dot(mixedNormal, lightDir), 0.0));
    
    // Softer specular with wider spread
    float specular = pow(max(dot(mixedNormal, halfDir), 0.0), 16.0) * 0.3;
    
    // Increased ambient light for softer shadows
    float ambient = 0.5;
    
    // Create a gradient color based on lighting
    vec3 baseColor = mix(
        vec3(0.1, 0.2, 0.4),  // Dark blue
        vec3(0.4, 0.2, 0.8),  // Purple
        diffuse
    );
    
    // Add subtle glow
    vec3 glowColor = vec3(0.6, 0.4, 1.0) * specular;
    
    // Blend the components
    vec3 color = baseColor * (ambient + diffuse * 0.7) + glowColor;

    gl_FragColor = vec4(color, 1.0);
}
