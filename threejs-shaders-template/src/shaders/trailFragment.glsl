
uniform sampler2D uCurrentTexture;
uniform float uTime;
uniform vec2 uMouse;
uniform float uDecay;
varying vec2 vUv;

void main() {
    vec2 velocity = uMouse - vUv;
    float dist = length(velocity);
    velocity = normalize(velocity) * smoothstep(0.5, 0.0, dist);
    
    vec2 uv = vUv;
    vec4 sum = vec4(0.0);
    float blurScale = 0.05;
    
    for(float i = 0.0; i < 16.0; i++) {
        float t = i / 16.0;
        vec2 offset = velocity * (blurScale * t);
        sum += texture2D(uCurrentTexture, uv - offset);
    }
    
    sum /= 16.0;
    vec4 current = texture2D(uCurrentTexture, uv);
    
    float fadeOut = smoothstep(1.0, 0.0, dist * 2.0);
    float alpha = fadeOut * uDecay;
    
    vec4 color = mix(current, sum, alpha);
    color.a = 1.0;
    
    gl_FragColor = color;
}
