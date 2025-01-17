
uniform sampler2D uTrailTexture;
uniform sampler2D uCurrentTexture;
uniform float uDecay;
varying vec2 vUv;

void main() {
    vec4 current = texture2D(uCurrentTexture, vUv);
    vec4 previous = texture2D(uTrailTexture, vUv);
    
    // Blend current frame with decayed previous frame
    gl_FragColor = max(current, previous * uDecay);
}
