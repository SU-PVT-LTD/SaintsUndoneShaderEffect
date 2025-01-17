varying vec2 vUv;
varying vec3 vNormal;
varying vec3 vPosition;
uniform vec2 uMouse;
uniform sampler2D uNormalMap;
uniform vec3 uLightPosition;
uniform float uDecay;

void main()
{
    float dist = distance(vUv, uMouse);
    float strength = 1.0 - smoothstep(0.0, 0.2, dist);
    
    // Add turbulence
    float time = uDecay * 10.0;
    float turbulence = sin(dist * 40.0 + time) * 0.05;
    strength *= (1.0 + turbulence);

    // Enhanced normal mapping with fluid effect
    vec2 distortedUv = vUv + vec2(turbulence * 0.1);
    vec3 normalMap = texture2D(uNormalMap, distortedUv).rgb * 2.0 - 1.0;
    vec3 mixedNormal = normalize(mix(vNormal, normalMap, strength));

    // Enhanced lighting
    vec3 lightDir = normalize(uLightPosition - vPosition);
    vec3 viewDir = normalize(-vPosition);
    vec3 halfDir = normalize(lightDir + viewDir);

    float diffuse = max(dot(mixedNormal, lightDir), 0.0);
    float specular = pow(max(dot(mixedNormal, halfDir), 0.0), 32.0);

    float ambient = 0.3;
    vec3 color = vec3(0.722) * (ambient + diffuse + specular * 0.5); // 0.722 is equivalent to #b8b8b8 in normalized RGB

    gl_FragColor = vec4(color, 1.0);
}