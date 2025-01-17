uniform sampler2D uTrailTexture;
uniform sampler2D uCurrentTexture;
uniform float uDecay;
varying vec2 vUv;

void main() {
    vec4 previous = texture2D(uTrailTexture, vUv); // Previous frame
    vec4 current = texture2D(uCurrentTexture, vUv); // Current frame

    // Blend the previous frame with the current frame
    vec4 blended = mix(previous, current, 1.0 - uDecay);

    gl_FragColor = blended;
}
