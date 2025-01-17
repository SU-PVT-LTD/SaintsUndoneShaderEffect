varying vec2 vUv;
varying vec3 vNormal;
varying vec3 vPosition;
uniform vec2 uMouse;
uniform sampler2D uNormalMap;
uniform vec3 uLightPosition;
uniform float uDecay;
uniform float time;

void main()
{
    float dist = distance(vUv, uMouse);
    float strength = 1.0 - smoothstep(0.0, 0.2, dist);

    // Water surface normal mapping
    vec2 waterUV = vUv + vec2(
        sin(vUv.y * 10.0 + time * 0.5) * 0.02,
        cos(vUv.x * 10.0 + time * 0.5) * 0.02
    );
    vec3 normalMap = texture2D(uNormalMap, waterUV).rgb * 2.0 - 1.0;
    vec3 mixedNormal = normalize(mix(vNormal, normalMap, 0.8 + strength * 0.2));

    // Enhanced water lighting
    vec3 lightDir = normalize(uLightPosition - vPosition);
    vec3 viewDir = normalize(-vPosition);
    vec3 reflectDir = reflect(-lightDir, mixedNormal);

    float diffuse = max(dot(mixedNormal, lightDir), 0.0);
    float specular = pow(max(dot(viewDir, reflectDir), 0.0), 64.0);

    float fresnel = pow(1.0 - max(dot(viewDir, mixedNormal), 0.0), 3.0);

    // Water color
    vec3 waterColor = vec3(0.2, 0.5, 0.7);
    float ambient = 0.2;
    vec3 color = waterColor * (ambient + diffuse) + vec3(1.0) * specular * 0.8 + vec3(0.8, 0.9, 1.0) * fresnel * 0.5;

    gl_FragColor = vec4(color, 0.9);
}