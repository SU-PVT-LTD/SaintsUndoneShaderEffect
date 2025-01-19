import * as THREE from "three";
import GUI from "lil-gui";
import vertexShader from "./shaders/vertex.glsl";
import fragmentShader from "./shaders/fragment.glsl";
import trailFragmentShader from "./shaders/trailFragment.glsl";
import trailVertexShader from "./shaders/trailVertex.glsl";
import "./style.css";

class ShaderRenderer {
  constructor() {
    this.gui = new GUI();
    this.mouse = new THREE.Vector2(-1, -1);
    this.trails = [];
    this.maxTrails = 3;
    this.trailSpeed = 0.005;

    // Trail generator
    setInterval(() => {
      if (this.trails.length < this.maxTrails) {
        const startX = Math.random();
        const startY = Math.random();
        const angle = Math.random() * Math.PI * 2;
        this.trails.push({
          position: new THREE.Vector2(startX, startY),
          angle: angle,
          life: 1.0
        });
      }
    }, 2000);

    this.canvas = document.querySelector("canvas.webgl");
    this.scene = new THREE.Scene();
    this.sizes = {
      width: window.innerWidth,
      height: window.innerHeight,
    };
    this.clock = new THREE.Clock();

    this.initRenderer();
    this.initGeometry();
    this.initTrailRenderTarget();
    this.initCamera();
    this.initEventListeners();
    this.startAnimationLoop();
  }

  initGeometry() {
    this.geometry = new THREE.PlaneGeometry(1.5, 1.5, 256, 256);

    const sizeFolder = this.gui.addFolder('Size Controls');
    sizeFolder.add({ width: 1.5 }, 'width', 0.1, 4.0, 0.1)
      .onChange((value) => {
        this.mesh.scale.x = value;
      });
    sizeFolder.add({ height: 1.5 }, 'height', 0.1, 4.0, 0.1)
      .onChange((value) => {
        this.mesh.scale.y = value;
      });

    this.light = new THREE.PointLight(0xffffff, 1);
    this.light.position.set(2, 2, 2);
    this.scene.add(this.light);

    const normalMap = new THREE.TextureLoader().load('/NormalMap7.png');

    this.profiles = {
      original: {
        ambient: 0.3,
        diffuseStrength: 1.0,
        specularStrength: 0.5,
        specularPower: 32.0,
        wrap: 0.0,
      },
      soft: {
        ambient: 0.5,
        diffuseStrength: 0.7,
        specularStrength: 0.3,
        specularPower: 16.0,
        wrap: 0.5,
      },
      purple: {
        ambient: 0.4,
        diffuseStrength: 0.6,
        specularStrength: 0.8,
        specularPower: 24.0,
        wrap: 0.2,
        color: new THREE.Color('#ec3249'),
      },
    };

    this.currentProfile = 'soft';

    this.material = new THREE.ShaderMaterial({
      vertexShader: vertexShader,
      fragmentShader: fragmentShader,
      uniforms: {
        uMouse: { value: this.mouse },
        uTrailTexture: { value: null },
        uNormalMap: { value: normalMap },
        uLightPosition: { value: this.light.position },
        uDecay: { value: 0.95 },
        uDisplacementStrength: { value: 0.05 },
        uEffectRadius: { value: 0.15 },
        uAmbient: { value: this.profiles.soft.ambient },
        uDiffuseStrength: { value: this.profiles.soft.diffuseStrength },
        uSpecularStrength: { value: this.profiles.soft.specularStrength },
        uSpecularPower: { value: this.profiles.soft.specularPower },
        uWrap: { value: this.profiles.soft.wrap },
        uColor: { value: new THREE.Color(1, 1, 1) },
      },
      side: THREE.DoubleSide,
    });

    this.mesh = new THREE.Mesh(this.geometry, this.material);
    this.scene.add(this.mesh);

    const effectFolder = this.gui.addFolder('Effect Controls');
    effectFolder
      .add({ profile: this.currentProfile }, 'profile', ['original', 'soft', 'purple'])
      .onChange((value) => {
        this.currentProfile = value;
        const profile = this.profiles[value];
        this.material.uniforms.uAmbient.value = profile.ambient;
        this.material.uniforms.uDiffuseStrength.value = profile.diffuseStrength;
        this.material.uniforms.uSpecularStrength.value = profile.specularStrength;
        this.material.uniforms.uSpecularPower.value = profile.specularPower;
        this.material.uniforms.uWrap.value = profile.wrap;
        this.material.uniforms.uColor.value = profile.color || new THREE.Color(1, 1, 1);
      });
    effectFolder.add(this.material.uniforms.uDisplacementStrength, "value", 0.0, 0.2, 0.001).name("Displacement");
    effectFolder.add(this.material.uniforms.uEffectRadius, "value", 0.1, 0.5, 0.01).name("Radius");
    effectFolder.add(this.material.uniforms.uDecay, "value", 0.0, 1.0, 0.01).name("Decay");
  }

  initTrailRenderTarget() {
    const rtParams = {
      minFilter: THREE.LinearFilter,
      magFilter: THREE.LinearFilter,
      format: THREE.RGBAFormat,
      type: THREE.FloatType,
    };

    this.accumulationTargetA = new THREE.WebGLRenderTarget(
      this.sizes.width,
      this.sizes.height,
      rtParams
    );

    this.accumulationTargetB = new THREE.WebGLRenderTarget(
      this.sizes.width,
      this.sizes.height,
      rtParams
    );

    this.trailMaterial = new THREE.ShaderMaterial({
      vertexShader: trailVertexShader,
      fragmentShader: trailFragmentShader,
      uniforms: {
        uPreviousTexture: { value: null },
        uMousePos: { value: new THREE.Vector2(-1, -1) },
        uAccumulationStrength: { value: 0.98 },
        uTurbulenceScale: { value: 8.0 },
        uTurbulenceStrength: { value: 0.15 },
        uEdgeSharpness: { value: 0.15 },
        uSwirlStrength: { value: 0.02 },
        uTime: { value: 0.0 }
      },
      transparent: true,
      blending: THREE.AdditiveBlending,
    });

    const fluidFolder = this.gui.addFolder('Fluid Controls');
    fluidFolder.add(this.trailMaterial.uniforms.uTurbulenceScale, 'value', 1.0, 20.0, 0.1).name('Turbulence Scale');
    fluidFolder.add(this.trailMaterial.uniforms.uTurbulenceStrength, 'value', 0.0, 0.5, 0.01).name('Turbulence Strength');
    fluidFolder.add(this.trailMaterial.uniforms.uEdgeSharpness, 'value', 0.01, 0.3, 0.01).name('Edge Sharpness');
    fluidFolder.add(this.trailMaterial.uniforms.uSwirlStrength, 'value', 0.0, 0.1, 0.001).name('Swirl Strength');
    fluidFolder.add(this.trailMaterial.uniforms.uAccumulationStrength, 'value', 0.9, 0.999, 0.001).name('Trail Persistence');

    this.trailPlane = new THREE.Mesh(
      new THREE.PlaneGeometry(2, 2),
      this.trailMaterial
    );
    this.trailScene = new THREE.Scene();
    this.trailScene.add(this.trailPlane);

    this.trailCamera = new THREE.OrthographicCamera(-1, 1, 1, -1, 0.1, 10);
    this.trailCamera.position.z = 1;

    this.renderer.setRenderTarget(this.accumulationTargetA);
    this.renderer.clear();
    this.renderer.setRenderTarget(this.accumulationTargetB);
    this.renderer.clear();
    this.renderer.setRenderTarget(null);
  }

  initCamera() {
    this.camera = new THREE.PerspectiveCamera(
      45,
      this.sizes.width / this.sizes.height,
      0.1,
      100
    );
    this.camera.position.z = 2;
    this.scene.add(this.camera);
  }

  initRenderer() {
    this.renderer = new THREE.WebGLRenderer({
      canvas: this.canvas,
      alpha: true,
    });
    this.renderer.setSize(this.sizes.width, this.sizes.height);
    this.renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2));
  }

  initEventListeners() {
    window.addEventListener("resize", () => this.handleResize());
    window.addEventListener("mousemove", (event) => this.handleMouseMove(event));
  }

  handleMouseMove(event) {
    this.mouse.x = event.clientX / this.sizes.width;
    this.mouse.y = 1 - event.clientY / this.sizes.height;
  }

  updateTrails() {
    this.trails = this.trails.filter(trail => {
      trail.position.x += Math.cos(trail.angle) * this.trailSpeed;
      trail.position.y += Math.sin(trail.angle) * this.trailSpeed;
      trail.life -= 0.001;
      return trail.life > 0 && 
             trail.position.x >= 0 && trail.position.x <= 1 &&
             trail.position.y >= 0 && trail.position.y <= 1;
    });
  }

  handleResize() {
    this.sizes.width = window.innerWidth;
    this.sizes.height = window.innerHeight;

    this.camera.aspect = this.sizes.width / this.sizes.height;
    this.camera.updateProjectionMatrix();

    this.renderer.setSize(this.sizes.width, this.sizes.height);
    this.renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2));

    this.accumulationTargetA.setSize(this.sizes.width, this.sizes.height);
    this.accumulationTargetB.setSize(this.sizes.width, this.sizes.height);
  }

  updateTrailTexture() {
    this.trailMaterial.uniforms.uTime.value += 0.01;

    const currentTarget = this.accumulationTargetA;
    const previousTarget = this.accumulationTargetB;

    // Set up for accumulation
    this.trailMaterial.uniforms.uPreviousTexture.value = previousTarget.texture;
    this.renderer.setRenderTarget(currentTarget);

    // First render previous frame with decay
    this.renderer.render(this.trailScene, this.trailCamera);

    // Handle autonomous trails
    if (this.trails.length > 0) {
      this.trails.forEach(trail => {
        this.trailMaterial.uniforms.uMousePos.value.copy(trail.position);
        this.renderer.render(this.trailScene, this.trailCamera);
      });
    }

    // Handle mouse trail separately
    if (this.mouse.x >= 0 && this.mouse.x <= 1 && this.mouse.y >= 0 && this.mouse.y <= 1) {
      this.trailMaterial.uniforms.uMousePos.value.copy(this.mouse);
      this.renderer.render(this.trailScene, this.trailCamera);
    }

    // Update trails for next frame
    this.updateTrails();

    // Update main material
    this.renderer.setRenderTarget(null);
    this.material.uniforms.uTrailTexture.value = currentTarget.texture;

    // Swap buffers
    [this.accumulationTargetA, this.accumulationTargetB] = [this.accumulationTargetB, this.accumulationTargetA];
  }

  animate() {
    this.updateTrailTexture();
    this.renderer.render(this.scene, this.camera);
    window.requestAnimationFrame(() => this.animate());
  }

  startAnimationLoop() {
    this.animate();
  }
}

const shaderRenderer = new ShaderRenderer();