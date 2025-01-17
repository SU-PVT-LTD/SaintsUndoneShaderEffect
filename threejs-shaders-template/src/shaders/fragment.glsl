
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
    
    // Create subtle grayscale gradient with deeper shadows
    float baseGray = 0.92;
    vec3 highlightColor = vec3(0.98);
    vec3 shadowColor = vec3(0.75); // Darker shadow value
    vec3 color = mix(shadowColor, highlightColor, ambient * 0.8 + diffuse * 0.6 + specular * 0.3);
    
    gl_FragColor = vec4(color, 1.0);
}
