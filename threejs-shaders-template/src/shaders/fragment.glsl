
varying vec2 vUv;
varying vec3 vNormal;
varying vec3 vPosition;
uniform vec2 uMouse;
uniform sampler2D uNormalMap;
uniform vec3 uLightPosition;

void main()
{
    float dist = distance(vUv, uMouse);
    float strength = 1.0 - smoothstep(0.0, 0.2, dist);

    // Enhanced normal mapping
    vec3 normalMap = texture2D(uNormalMap, vUv).rgb * 2.0 - 1.0;
    vec3 mixedNormal = normalize(mix(vNormal, normalMap, strength));

    // Basic lighting
    vec3 lightDir = normalize(uLightPosition - vPosition);
    float diffuse = max(dot(mixedNormal, lightDir), 0.0);
    
    float ambient = 0.3;
    vec3 color = vec3(0.722) * (ambient + diffuse);

    gl_FragColor = vec4(color, 1.0);
}
