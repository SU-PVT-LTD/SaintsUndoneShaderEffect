
uniform sampler2D uTrailTexture;
uniform sampler2D uCurrentTexture;
uniform float uDecay;
uniform vec2 uResolution;
varying vec2 vUv;

void main() {
    vec2 pixelSize = 1.0 / uResolution;
    vec4 previous = texture2D(uTrailTexture, vUv);
    vec4 current = texture2D(uCurrentTexture, vUv);
    
    // Sample neighboring pixels for diffusion
    vec4 blur = vec4(0.0);
    blur += texture2D(uTrailTexture, vUv + vec2(-1.0, 0.0) * pixelSize) * 0.2;
    blur += texture2D(uTrailTexture, vUv + vec2(1.0, 0.0) * pixelSize) * 0.2;
    blur += texture2D(uTrailTexture, vUv + vec2(0.0, -1.0) * pixelSize) * 0.2;
    blur += texture2D(uTrailTexture, vUv + vec2(0.0, 1.0) * pixelSize) * 0.2;
    blur += previous * 0.2;

    // Blend current frame with diffused previous frame
    vec4 blended = mix(blur, current, 1.0 - uDecay);
    
    // Apply decay
    blended *= 0.99;
    
    gl_FragColor = blended;
}
