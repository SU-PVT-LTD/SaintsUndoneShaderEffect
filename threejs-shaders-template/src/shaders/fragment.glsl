
varying vec2 vUv;
varying vec3 vNormal;
varying vec3 vPosition;
uniform vec2 uMouse;
uniform sampler2D uNormalMap;
uniform vec3 uLightPosition;
uniform sampler2D uRevealMap;

void main()
{
    float revealValue = texture2D(uRevealMap, vUv).r;
    revealValue = smoothstep(0.0, 1.0, revealValue); // Smooth out the reveal effect

    // Enhanced normal mapping
    vec3 normalMap = texture2D(uNormalMap, vUv).rgb * 2.0 - 1.0;
    vec3 mixedNormal = normalize(mix(vNormal, normalMap, revealValue));

    // Enhanced lighting
    vec3 lightDir = normalize(uLightPosition - vPosition);
    vec3 viewDir = normalize(-vPosition);
    vec3 halfDir = normalize(lightDir + viewDir);

    float diffuse = max(dot(mixedNormal, lightDir), 0.0);
    float specular = pow(max(dot(mixedNormal, halfDir), 0.0), 32.0);

    float ambient = 0.3;
    vec3 color = vec3(0.722) * (ambient + diffuse + specular * 0.5);
    
    // Mix between dark and lit based on reveal value
    color = mix(vec3(0.1), color, revealValue);

    gl_FragColor = vec4(color, 1.0);
}
