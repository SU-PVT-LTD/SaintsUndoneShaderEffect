
varying vec2 vUv;
varying vec3 vNormal;
varying vec3 vPosition;
uniform vec2 uMouse;
uniform sampler2D uNormalMap;
uniform vec3 uLightPosition;
uniform sampler2D uTrailTexture;
uniform float uAmbient;
uniform float uDiffuseStrength;
uniform float uSpecularStrength;
uniform float uSpecularPower;
uniform float uWrap;
uniform float uCursorVelocity;

void main()
{
    // Calculate chromatic aberration offset based on cursor velocity
    float aberrationStrength = min(uCursorVelocity * 0.15, 0.08);
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

    // Profile-based lighting
    float diffuse = max((dot(mixedNormal, lightDir) + uWrap) / (1.0 + uWrap), 0.0);
    float specular = pow(max(dot(mixedNormal, halfDir), 0.0), uSpecularPower) * uSpecularStrength;
    
    // Blend the lighting components based on profile settings
    // Calculate base color
    vec3 baseColor = vec3(0.722) * (uAmbient + diffuse * uDiffuseStrength + specular);
    
    // Apply chromatic aberration only along the trail
    vec3 color = baseColor;
    if (finalStrength > 0.01) {
        vec2 offsetR = vec2(aberrationStrength * 0.5, 0.0);
        vec2 offsetB = vec2(-aberrationStrength * 0.5, 0.0);
        
        float trailR = texture2D(uTrailTexture, vUv + offsetR).r;
        float trailB = texture2D(uTrailTexture, vUv + offsetB).r;
        
        color.r = mix(baseColor.r, trailR, finalStrength * aberrationStrength * 60.0);
        color.b = mix(baseColor.b, trailB, finalStrength * aberrationStrength * 60.0);
        color.g = mix(baseColor.g, (trailR + trailB) * 0.5, finalStrength * aberrationStrength * 40.0);
    }
    
    // Ensure we don't exceed maximum brightness
    color = min(color, vec3(1.0));
    
    gl_FragColor = vec4(color, 1.0);
}
