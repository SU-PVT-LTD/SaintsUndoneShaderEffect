import * as THREE from "three";
import { OrbitControls } from "three/examples/jsm/controls/OrbitControls.js";
import GUI from "lil-gui";
import vertexShader from "./shaders/vertex.glsl";
import fragmentShader from "./shaders/fragment.glsl";
import trailFragmentShader from "./shaders/trailFragment.glsl";
import trailVertexShader from "./shaders/trailVertex.glsl";
import "./style.css";

class ShaderRenderer {
  constructor() {
    this.gui = new GUI();
    this.mouse = new THREE.Vector2();
    this.canvas = document.querySelector("canvas.webgl");
    this.scene = new THREE.Scene();
    this.sizes = {
      width: window.innerWidth,
      height: window.innerHeight,
    };
    this.clock = new THREE.Clock();

    // Create ping-pong buffers
    this.bufferA = new THREE.WebGLRenderTarget(this.sizes.width, this.sizes.height);
    this.bufferB = new THREE.WebGLRenderTarget(this.sizes.width, this.sizes.height);

    this.initGeometry();
    this.initTrailEffect();
    this.initCamera();
    this.initRenderer();
    this.initControls();
    this.initEventListeners();
    this.startAnimationLoop();
  }

  initGeometry() {
    this.geometry = new THREE.PlaneGeometry(1, 1, 256, 256);
    this.light = new THREE.PointLight(0xffffff, 1);
    this.light.position.set(2, 2, 3);
    this.scene.add(this.light);

    const normalMap = new THREE.TextureLoader().load('/T_tfilfair_2K_N.png');

    this.material = new THREE.ShaderMaterial({
      vertexShader: vertexShader,
      fragmentShader: fragmentShader,
      uniforms: {
        uMouse: { value: this.mouse },
        uNormalMap: { value: normalMap },
        uLightPosition: { value: this.light.position },
        uDisplacementStrength: { value: 0.05 },
        uEffectRadius: { value: 0.15 },
      },
      side: THREE.DoubleSide,
    });

    this.mesh = new THREE.Mesh(this.geometry, this.material);
    this.scene.add(this.mesh);

    const effectFolder = this.gui.addFolder('Effect Controls');
    effectFolder.add(this.material.uniforms.uDisplacementStrength, "value", 0.0, 0.2, 0.001).name("Displacement");
    effectFolder.add(this.material.uniforms.uEffectRadius, "value", 0.1, 0.5, 0.01).name("Radius");
  }

  initTrailEffect() {
    // Create two render targets for ping-pong buffering
    this.renderTargetA = new THREE.WebGLRenderTarget(
      this.sizes.width,
      this.sizes.height,
      {
        minFilter: THREE.LinearFilter,
        magFilter: THREE.LinearFilter,
        format: THREE.RGBAFormat,
        type: THREE.FloatType
      }
    );
    
    this.renderTargetB = this.renderTargetA.clone();
    
    this.trailMaterial = new THREE.ShaderMaterial({
      vertexShader: trailVertexShader,
      fragmentShader: trailFragmentShader,
      uniforms: {
        uCurrentTexture: { value: null },
        uTime: { value: 0 },
        uMouse: { value: new THREE.Vector2() },
        uDecay: { value: 0.98 },
      },
    });

    this.trailScene = new THREE.Scene();
    this.trailQuad = new THREE.Mesh(
      new THREE.PlaneGeometry(2, 2),
      this.trailMaterial
    );
    this.trailScene.add(this.trailQuad);

    this.trailCamera = new THREE.OrthographicCamera(-1, 1, 1, -1, 0, 1);
  }

  initCamera() {
    this.camera = new THREE.PerspectiveCamera(75, this.sizes.width / this.sizes.height, 0.1, 100);
    this.camera.position.set(0.25, -0.25, 1);
    this.scene.add(this.camera);
  }

  initRenderer() {
    this.renderer = new THREE.WebGLRenderer({ canvas: this.canvas });
    this.renderer.setSize(this.sizes.width, this.sizes.height);
    this.renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2));
  }

  initControls() {
    this.controls = new OrbitControls(this.camera, this.canvas);
    this.controls.enableDamping = true;
  }

  initEventListeners() {
    window.addEventListener("resize", () => this.handleResize());
    window.addEventListener("mousemove", (event) => this.handleMouseMove(event));
  }

  handleMouseMove(event) {
    this.mouse.x = event.clientX / this.sizes.width;
    this.mouse.y = 1 - event.clientY / this.sizes.height;
  }

  handleResize() {
    this.sizes.width = window.innerWidth;
    this.sizes.height = window.innerHeight;
    this.camera.aspect = this.sizes.width / this.sizes.height;
    this.camera.updateProjectionMatrix();
    this.renderer.setSize(this.sizes.width, this.sizes.height);
    this.renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2));

    this.bufferA.setSize(this.sizes.width, this.sizes.height);
    this.bufferB.setSize(this.sizes.width, this.sizes.height);
  }

  animate() {
    this.controls.update();
    
    // Update uniforms
    this.trailMaterial.uniforms.uTime.value = this.clock.getElapsedTime();
    this.trailMaterial.uniforms.uMouse.value.set(this.mouse.x, this.mouse.y);
    
    // Render scene to current render target
    this.renderer.setRenderTarget(this.renderTargetA);
    this.renderer.render(this.scene, this.camera);
    
    // Update trail material with current frame
    this.trailMaterial.uniforms.uCurrentTexture.value = this.renderTargetA.texture;
    
    // Render trail effect
    this.renderer.setRenderTarget(this.renderTargetB);
    this.renderer.render(this.trailScene, this.trailCamera);
    
    // Final output to screen
    this.renderer.setRenderTarget(null);
    this.renderer.render(this.trailScene, this.trailCamera);
    
    // Swap render targets
    const temp = this.renderTargetA;
    this.renderTargetA = this.renderTargetB;
    this.renderTargetB = temp;
    
    requestAnimationFrame(() => this.animate());
  }

  startAnimationLoop() {
    this.animate();
  }
}

const shaderRenderer = new ShaderRenderer();