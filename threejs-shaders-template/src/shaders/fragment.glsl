varying vec2 vUv;
uniform vec2 uMouse;
uniform sampler2D uTrailTexture; // The trail texture (previous frame)
uniform float uDecay; // Decay factor

void main()
{
    // Distance from the mouse
    float dist = distance(vUv, uMouse);
    float strength = 0.05 / dist;
    strength = clamp(strength, 0.0, 1.0);

    // Current color from the mouse
    vec3 currentColor = vec3(strength);

    // Get the previous frame's color
    vec4 previousColor = texture2D(uTrailTexture, vUv);

    // Blend current and previous colors with decay
    vec3 blendedColor = mix(previousColor.rgb, currentColor, strength);
    blendedColor *= uDecay;

    // Output the final color
    gl_FragColor = vec4(blendedColor, 1.0);
}
