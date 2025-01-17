
varying vec2 vUv;
varying vec3 vNormal;
varying vec3 vPosition;
uniform vec2 uMouse;
uniform sampler2D uNormalMap;
uniform vec3 uLightPosition;
uniform sampler2D uTrailTexture;

void main()
{
    // Get the accumulated reveal mask
    vec4 revealMask = texture2D(uTrailTexture, vUv);
    
    // Calculate current mouse influence
    float dist = distance(vUv, uMouse);
    float currentStrength = 1.0 - smoothstep(0.0, 0.2, dist);
    
    // Use the maximum between current and previous reveal
    float finalStrength = max(currentStrength, revealMask.r);

    // Apply reveal mask more strongly
    vec3 normalMap = texture2D(uNormalMap, vUv).rgb * 2.0 - 1.0;
    vec3 mixedNormal = normalize(mix(vNormal, normalMap, finalStrength));

    // Store the reveal strength
    gl_FragColor.a = finalStrength;

    // Enhanced lighting
    vec3 lightDir = normalize(uLightPosition - vPosition);
    vec3 viewDir = normalize(-vPosition);
    vec3 halfDir = normalize(lightDir + viewDir);

    float diffuse = max(dot(mixedNormal, lightDir), 0.0);
    float specular = pow(max(dot(mixedNormal, halfDir), 0.0), 32.0);

    float ambient = 0.3;
    vec3 color = vec3(0.722) * (ambient + diffuse + specular * 0.5);

    gl_FragColor = vec4(color, 1.0);
}
