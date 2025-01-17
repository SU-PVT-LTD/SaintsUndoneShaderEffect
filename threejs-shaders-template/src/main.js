
import * as THREE from "three";
import { OrbitControls } from "three/examples/jsm/controls/OrbitControls.js";
import GUI from "lil-gui";
import vertexShader from "./shaders/vertex.glsl";
import fragmentShader from "./shaders/fragment.glsl";
import trailVertexShader from "./shaders/trailVertex.glsl";
import trailFragmentShader from "./shaders/trailFragment.glsl";
import "./style.css";

class ShaderRenderer {
  constructor() {
    this.gui = new GUI();
    this.mouse = new THREE.Vector2();
    this.canvas = document.querySelector("canvas.webgl");
    this.scene = new THREE.Scene();
    this.clock = new THREE.Clock();
    this.sizes = {
      width: window.innerWidth,
      height: window.innerHeight,
    };

    // Create ping-pong buffers
    this.bufferA = new THREE.WebGLRenderTarget(
      this.sizes.width,
      this.sizes.height,
      {
        minFilter: THREE.LinearFilter,
        magFilter: THREE.LinearFilter,
        format: THREE.RGBAFormat,
        type: THREE.FloatType,
      }
    );
    
    this.bufferB = this.bufferA.clone();
    this.currentBuffer = this.bufferA;

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
    this.trailMaterial = new THREE.ShaderMaterial({
      vertexShader: trailVertexShader,
      fragmentShader: trailFragmentShader,
      uniforms: {
        uAccumulatedTexture: { value: null },
        uCurrentTexture: { value: null },
        uTime: { value: 0 },
        uMouse: { value: this.mouse },
        uDecay: { value: 0.98 },
        uIntensity: { value: 1.0 },
      },
      blending: THREE.AdditiveBlending,
      transparent: true,
    });

    const trailFolder = this.gui.addFolder('Trail Controls');
    trailFolder.add(this.trailMaterial.uniforms.uDecay, 'value', 0.9, 0.999, 0.001).name('Decay');
    trailFolder.add(this.trailMaterial.uniforms.uIntensity, 'value', 0, 1, 0.01).name('Intensity');

    this.trailQuad = new THREE.Mesh(
      new THREE.PlaneGeometry(2, 2),
      this.trailMaterial
    );
    
    this.trailScene = new THREE.Scene();
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
    
    this.accumulationRenderTarget.setSize(this.sizes.width, this.sizes.height);
  }

  animate() {
    this.controls.update();

    // Swap buffers
    const temp = this.currentBuffer;
    this.currentBuffer = this.currentBuffer === this.bufferA ? this.bufferB : this.bufferA;
    
    // Update trail uniforms
    this.trailMaterial.uniforms.uAccumulatedTexture.value = temp.texture;
    
    // Render trail
    this.renderer.setRenderTarget(this.currentBuffer);
    this.renderer.render(this.trailScene, this.trailCamera);
    
    // Final scene render
    this.renderer.setRenderTarget(null);
    this.renderer.render(this.scene, this.camera);

    requestAnimationFrame(() => this.animate());
  }

  startAnimationLoop() {
    this.animate();
  }
}

new ShaderRenderer();
