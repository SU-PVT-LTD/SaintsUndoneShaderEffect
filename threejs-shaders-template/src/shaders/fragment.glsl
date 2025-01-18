varying vec2 vUv;
varying vec3 vNormal;
varying vec3 vPosition;
uniform vec2 uMouse;
uniform vec2 uMouseVelocity;
uniform sampler2D uNormalMap;
uniform vec3 uLightPosition;
uniform sampler2D uTrailTexture;
uniform float uAmbient;
uniform float uDiffuseStrength;
uniform float uSpecularStrength;
uniform float uSpecularPower;
uniform float uWrap;
uniform float uChromaticStrength;

void main()
{
    float velocity = length(uMouseVelocity);
    float chromatic = velocity * uChromaticStrength;

    // Sample with chromatic aberration
    vec2 redOffset = vUv + chromatic * normalize(uMouseVelocity);
    vec2 blueOffset = vUv - chromatic * normalize(uMouseVelocity);

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

    // Profile-based lighting
    float diffuse = max((dot(mixedNormal, lightDir) + uWrap) / (1.0 + uWrap), 0.0);
    float specular = pow(max(dot(mixedNormal, halfDir), 0.0), uSpecularPower) * uSpecularStrength;

    // Blend the lighting components based on profile settings
    vec3 baseColor = vec3(0.722) * (uAmbient + diffuse * uDiffuseStrength + specular);

    // Apply chromatic aberration with enhanced edge definition
    float edgeIntensity = pow(length(normalMap.xy), 1.5); // Sharper edge falloff
    vec3 color = baseColor;
    
    if (finalStrength > 0.0) {
        vec3 trailColor = vec3(
            texture2D(uTrailTexture, redOffset).r,
            texture2D(uTrailTexture, vUv).g,
            texture2D(uTrailTexture, blueOffset).b
        );
        // Sharper blend transition
        float blendStrength = smoothstep(0.1, 0.9, finalStrength * edgeIntensity);
        color = mix(color, trailColor, blendStrength);
    }

    // Ensure we don't exceed maximum brightness
    color = min(color, vec3(1.0));

    gl_FragColor = vec4(color, 1.0);
}