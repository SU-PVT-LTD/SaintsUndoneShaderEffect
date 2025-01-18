import React, { useEffect, useRef } from 'react';
import * as THREE from 'three';
import vertexShader from './shaders/vertex.glsl';
import fragmentShader from './shaders/fragment.glsl';
import trailFragmentShader from './shaders/trailFragment.glsl';
import trailVertexShader from './shaders/trailVertex.glsl';

const ShaderBackground = ({ className = '' }) => {
  const canvasRef = useRef(null);
  const rendererRef = useRef(null);

  useEffect(() => {
    const canvas = canvasRef.current;
    const renderer = new THREE.WebGLRenderer({ canvas, alpha: true });
    rendererRef.current = renderer;

    const scene = new THREE.Scene();
    const mouse = new THREE.Vector2();

    const sizes = {
      width: window.innerWidth,
      height: window.innerHeight,
    };

    // Initialize geometry
    const geometry = new THREE.PlaneGeometry(2, 2, 256, 256);
    const light = new THREE.PointLight(0xffffff, 1);
    light.position.set(0, 0, 2);
    scene.add(light);

    const normalMap = new THREE.TextureLoader().load('/T_tfilfair_2K_N.png');

    const material = new THREE.ShaderMaterial({
      vertexShader,
      fragmentShader,
      uniforms: {
        uMouse: { value: mouse },
        uTrailTexture: { value: null },
        uNormalMap: { value: normalMap },
        uLightPosition: { value: light.position },
        uDecay: { value: 0.95 },
        uDisplacementStrength: { value: 0.05 },
        uEffectRadius: { value: 0.15 },
        uAmbient: { value: 0.5 },
        uDiffuseStrength: { value: 0.7 },
        uSpecularStrength: { value: 0.3 },
        uSpecularPower: { value: 16.0 },
        uWrap: { value: 0.5 }
      },
      side: THREE.DoubleSide,
    });

    const mesh = new THREE.Mesh(geometry, material);
    scene.add(mesh);

      // Create GUI controls
      const gui = new GUI();
      
      // Effect controls folder
      const effectFolder = gui.addFolder('Effect Controls');
      effectFolder.add(material.uniforms.uDisplacementStrength, 'value', 0, 0.2, 0.001).name('Displacement');
      effectFolder.add(material.uniforms.uEffectRadius, 'value', 0.05, 0.5, 0.01).name('Radius');
      effectFolder.add(material.uniforms.uAmbient, 'value', 0, 1, 0.01).name('Ambient Light');
      effectFolder.add(material.uniforms.uDiffuseStrength, 'value', 0, 2, 0.01).name('Diffuse Strength');
      effectFolder.add(material.uniforms.uSpecularStrength, 'value', 0, 2, 0.01).name('Specular Strength');
      effectFolder.add(material.uniforms.uSpecularPower, 'value', 1, 64, 1).name('Specular Power');
      effectFolder.add(material.uniforms.uWrap, 'value', 0, 1, 0.01).name('Light Wrap');

      // Fluid controls folder
      const fluidFolder = gui.addFolder('Fluid Controls');
      fluidFolder.add(trailMaterial.uniforms.uAccumulationStrength, 'value', 0.9, 0.999, 0.001).name('Trail Length');
      fluidFolder.add(trailMaterial.uniforms.uTurbulenceScale, 'value', 1, 20, 0.1).name('Turbulence Scale');
      fluidFolder.add(trailMaterial.uniforms.uTurbulenceStrength, 'value', 0, 0.5, 0.01).name('Turbulence Strength');
      fluidFolder.add(trailMaterial.uniforms.uEdgeSharpness, 'value', 0.01, 0.3, 0.01).name('Edge Sharpness');
      fluidFolder.add(trailMaterial.uniforms.uSwirlStrength, 'value', 0, 0.1, 0.001).name('Swirl Strength');

    // Initialize camera
    const camera = new THREE.PerspectiveCamera(45, sizes.width / sizes.height, 0.1, 100);
    camera.position.z = 2;
    scene.add(camera);

    // Initialize trail render targets
    const rtParams = {
      minFilter: THREE.LinearFilter,
      magFilter: THREE.LinearFilter,
      format: THREE.RGBAFormat,
      type: THREE.FloatType,
    };

    const accumulationTargetA = new THREE.WebGLRenderTarget(
      sizes.width,
      sizes.height,
      rtParams
    );

    const accumulationTargetB = new THREE.WebGLRenderTarget(
      sizes.width,
      sizes.height,
      rtParams
    );

    const trailMaterial = new THREE.ShaderMaterial({
      vertexShader: trailVertexShader,
      fragmentShader: trailFragmentShader,
      uniforms: {
        uPreviousTexture: { value: null },
        uCurrentTexture: { value: null },
        uMousePos: { value: mouse },
        uAccumulationStrength: { value: 0.98 },
        uTurbulenceScale: { value: 8.0 },
        uTurbulenceStrength: { value: 0.15 },
        uEdgeSharpness: { value: 0.15 },
        uSwirlStrength: { value: 0.02 },
        uTime: { value: 0.0 }
      },
    });

    const trailPlane = new THREE.Mesh(
      new THREE.PlaneGeometry(2, 2),
      trailMaterial
    );
    const trailScene = new THREE.Scene();
    trailScene.add(trailPlane);

    const trailCamera = new THREE.OrthographicCamera(-1, 1, 1, -1, 0.1, 10);
    trailCamera.position.z = 1;

    // Clear initial render targets
    renderer.setRenderTarget(accumulationTargetA);
    renderer.clear();
    renderer.setRenderTarget(accumulationTargetB);
    renderer.clear();
    renderer.setRenderTarget(null);

    const handleResize = () => {
      sizes.width = window.innerWidth;
      sizes.height = window.innerHeight;

      camera.aspect = sizes.width / sizes.height;
      camera.updateProjectionMatrix();

      renderer.setSize(sizes.width, sizes.height);
      renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2));

      accumulationTargetA.setSize(sizes.width, sizes.height);
      accumulationTargetB.setSize(sizes.width, sizes.height);
    };

    const updateMousePosition = (x, y) => {
      // Get canvas bounds for correct coordinate mapping
      const rect = canvas.getBoundingClientRect();
      mouse.x = (x - rect.left) / rect.width;
      mouse.y = 1 - (y - rect.top) / rect.height;
    };

    const handleMouseMove = (event) => {
      event.preventDefault();
      updateMousePosition(event.clientX, event.clientY);
    };

    const handleTouchMove = (event) => {
      event.preventDefault();
      event.stopPropagation();
      const touch = event.touches[0];
      if (touch) {
        updateMousePosition(touch.clientX, touch.clientY);
      }
    };

    const handleTouchStart = (event) => {
      event.preventDefault();
      event.stopPropagation();
      const touch = event.touches[0];
      if (touch) {
        updateMousePosition(touch.clientX, touch.clientY);
      }
    };

    // Initial size setup
    handleResize();

    // Add event listeners directly to canvas
    canvas.style.touchAction = 'none'; // Prevent default touch actions
    canvas.addEventListener('mousemove', handleMouseMove);
    canvas.addEventListener('touchstart', handleTouchStart);
    canvas.addEventListener('touchmove', handleTouchMove);
    canvas.addEventListener('touchend', (e) => e.preventDefault());
    canvas.addEventListener('touchcancel', (e) => e.preventDefault());
    window.addEventListener('resize', handleResize);

    // Start animation
    animate();

    const updateTrailTexture = () => {
      trailMaterial.uniforms.uTime.value += 0.01;

      const currentTarget = accumulationTargetA;
      const previousTarget = accumulationTargetB;

      trailMaterial.uniforms.uPreviousTexture.value = previousTarget.texture;
      trailMaterial.uniforms.uMousePos.value = mouse;

      renderer.setRenderTarget(currentTarget);
      renderer.render(trailScene, trailCamera);
      renderer.setRenderTarget(null);

      material.uniforms.uTrailTexture.value = currentTarget.texture;

      [accumulationTargetA, accumulationTargetB] = [accumulationTargetB, accumulationTargetA];
    };

    const animate = () => {
      updateTrailTexture();
      renderer.render(scene, camera);
      requestAnimationFrame(animate);
    };


    return () => {
      window.removeEventListener('resize', handleResize);
      window.removeEventListener('mousemove', handleMouseMove);
      window.removeEventListener('touchstart', handleTouchMove);
      window.removeEventListener('touchmove', handleTouchMove);
      renderer.dispose();
      material.dispose();
      geometry.dispose();
    };
  }, []);

  return (
    <canvas 
      ref={canvasRef} 
      className={`fixed top-0 left-0 w-full h-full outline-none touch-auto -z-10 ${className}`}
    />
  );
};

export default ShaderBackground;