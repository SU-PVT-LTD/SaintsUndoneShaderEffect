varying vec2 vUv;
varying vec3 vNormal;
varying vec3 vPosition;
uniform vec2 uMouse;
uniform sampler2D uNormalMap;
uniform vec3 uLightPosition;
uniform float uDecay;

void main()
{
    vec2 toMouse = uMouse - vUv;
    float dist = length(toMouse);
    float angle = atan(toMouse.y, toMouse.x);
    
    float strength = 1.0 - smoothstep(0.0, 0.3, dist);
    strength *= (1.0 + sin(dist * 30.0 + angle * 2.0) * 0.3);
    strength *= (1.0 + sin(vUv.x * 15.0 + vUv.y * 20.0) * 0.15);

    // Enhanced normal mapping with fluid distortion
    vec2 distortedUV = vUv + vec2(
        cos(angle) * strength * 0.02,
        sin(angle) * strength * 0.02
    );
    vec3 normalMap = texture2D(uNormalMap, distortedUV).rgb * 2.0 - 1.0;
    vec3 mixedNormal = normalize(mix(vNormal, normalMap, strength * 1.2));

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