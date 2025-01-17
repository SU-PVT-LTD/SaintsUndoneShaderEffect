
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

    // Softer diffuse lighting with wrap-around term
    float wrap = 0.5; // Controls how much light wraps around edges
    float diffuse = max((dot(mixedNormal, lightDir) + wrap) / (1.0 + wrap), 0.0);
    
    // Softer specular with adjusted power
    float specular = pow(max(dot(mixedNormal, halfDir), 0.0), 16.0) * 0.3;
    
    // Increased ambient light for softer shadows
    float ambient = 0.5;
    
    // Blend the lighting components with softer transitions
    vec3 color = vec3(0.722) * (ambient + diffuse * 0.7 + specular * 0.3);
    
    // Ensure we don't exceed maximum brightness
    color = min(color, vec3(1.0));
    
    gl_FragColor = vec4(color, 1.0);
}
