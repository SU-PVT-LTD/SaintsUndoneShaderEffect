
uniform sampler2D uTrailTexture;
uniform sampler2D uCurrentTexture;
varying vec2 vUv;

void main() {
    vec4 previous = texture2D(uTrailTexture, vUv);
    vec4 current = texture2D(uCurrentTexture, vUv);
    
    // Store the maximum alpha value
    float alpha = max(previous.a, current.a);
    
    // Output the result with accumulated alpha
    gl_FragColor = vec4(current.rgb, alpha);
}
