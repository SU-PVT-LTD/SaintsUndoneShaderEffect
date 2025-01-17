uniform sampler2D uAccumulatedTexture;
uniform vec2 uMouse;
uniform float uDecay;
uniform float uIntensity;

varying vec2 vUv;

void main() {
    vec4 current = texture2D(uAccumulatedTexture, vUv);
    float dist = length(uMouse - vUv);
    float mouseMask = smoothstep(0.05, 0.0, dist);

    vec4 mouseColor = vec4(1.0, 1.0, 1.0, 1.0) * mouseMask * uIntensity;
    vec4 trail = current * uDecay + mouseColor;

    gl_FragColor = trail;
}