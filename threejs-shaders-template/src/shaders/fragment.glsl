varying vec2 vUv;
varying vec3 vNormal;
varying vec3 vPosition;
uniform vec2 uMouse;
uniform sampler2D uNormalMap;
uniform sampler2D uTrailTexture;
uniform vec3 uLightPosition;
uniform float uDecay;

void main()
{
    vec4 trailColor = texture2D(uTrailTexture, vUv);
    float dist = distance(vUv, uMouse);
    float strength = 1.0 - smoothstep(0.0, 0.2, dist);
    strength = max(strength, trailColor.r * uDecay);

    // Enhanced normal mapping
    vec3 normalMap = texture2D(uNormalMap, vUv).rgb * 2.0 - 1.0;
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