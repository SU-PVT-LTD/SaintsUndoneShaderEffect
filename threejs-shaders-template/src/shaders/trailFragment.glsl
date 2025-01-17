uniform sampler2D uCurrentTexture;
uniform sampler2D uAccumulatedTexture;
uniform float uTime;
uniform vec2 uMouse;
uniform float uDecay;
uniform float uIntensity;
varying vec2 vUv;

void main() {
    vec2 velocity = (uMouse - vUv) * 0.1;
    vec4 current = texture2D(uCurrentTexture, vUv);
    vec4 previous = texture2D(uAccumulatedTexture, vUv);

    // Apply motion blur
    vec2 offset = velocity * 0.1;
    vec4 blurred = texture2D(uAccumulatedTexture, vUv - offset);

    // Blend with decay
    vec4 trail = mix(current, blurred, uDecay);
    trail *= uIntensity;

    gl_FragColor = trail;
}