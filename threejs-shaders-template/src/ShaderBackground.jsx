import React, { useEffect, useRef } from 'react';
import * as THREE from 'three';
import { GUI } from 'lil-gui';
import vertexShader from './shaders/vertex.glsl';
import fragmentShader from './shaders/fragment.glsl';
import trailFragmentShader from './shaders/trailFragment.glsl';
import trailVertexShader from './shaders/trailVertex.glsl';

const ShaderBackground = ({ className = '' }) => {
  const canvasRef = useRef(null);
  const mouseRef = useRef(new THREE.Vector2());
  const rendererRef = useRef(null);
  const isPointerActiveRef = useRef(false);
  const frameRef = useRef(null);

  useEffect(() => {
    const canvas = canvasRef.current;
    if (!canvas) return;

    const renderer = new THREE.WebGLRenderer({
      canvas,
      alpha: true,
      antialias: true,
      powerPreference: 'high-performance'
    });
    rendererRef.current = renderer;

    const scene = new THREE.Scene();
    const mouse = mouseRef.current;

    // Setup
    const sizes = {
      width: window.innerWidth,
      height: window.innerHeight
    };

    // Geometry setup
    const geometry = new THREE.PlaneGeometry(2, 2, 256, 256);
    const light = new THREE.PointLight(0xffffff, 1);
    light.position.set(0, 0, 2);
    scene.add(light);

    const normalMap = new THREE.TextureLoader().load('/T_tfilfair_2K_N.png');

    // Material setup
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

    // Camera setup
    const camera = new THREE.PerspectiveCamera(45, sizes.width / sizes.height, 0.1, 100);
    camera.position.z = 2;
    scene.add(camera);

    // Trail setup
    const rtParams = {
      minFilter: THREE.LinearFilter,
      magFilter: THREE.LinearFilter,
      format: THREE.RGBAFormat,
      type: THREE.FloatType,
      stencilBuffer: false,
      depthBuffer: false
    };

    const accumulationTargetA = new THREE.WebGLRenderTarget(sizes.width, sizes.height, rtParams);
    const accumulationTargetB = new THREE.WebGLRenderTarget(sizes.width, sizes.height, rtParams);

    const trailMaterial = new THREE.ShaderMaterial({
      vertexShader: trailVertexShader,
      fragmentShader: trailFragmentShader,
      uniforms: {
        uPreviousTexture: { value: null },
        uMousePos: { value: mouse },
        uAccumulationStrength: { value: 0.98 },
        uTurbulenceScale: { value: 8.0 },
        uTurbulenceStrength: { value: 0.15 },
        uEdgeSharpness: { value: 0.15 },
        uSwirlStrength: { value: 0.02 },
        uTime: { value: 0.0 }
      },
    });

    const trailScene = new THREE.Scene();
    const trailPlane = new THREE.Mesh(new THREE.PlaneGeometry(2, 2), trailMaterial);
    trailScene.add(trailPlane);

    const trailCamera = new THREE.OrthographicCamera(-1, 1, 1, -1, 0.1, 10);
    trailCamera.position.z = 1;

    // Clear initial targets
    renderer.setRenderTarget(accumulationTargetA);
    renderer.clear();
    renderer.setRenderTarget(accumulationTargetB);
    renderer.clear();
    renderer.setRenderTarget(null);

    const updatePointerPosition = (clientX, clientY) => {
      const rect = canvas.getBoundingClientRect();
      const x = (clientX - rect.left) / rect.width;
      const y = 1.0 - (clientY - rect.top) / rect.height;

      mouse.x = Math.max(0, Math.min(1, x));
      mouse.y = Math.max(0, Math.min(1, y));
    };

    // Touch handling
    const handleTouch = (e) => {
      e.preventDefault();
      const touch = e.touches[0];
      if (touch) {
        updatePointerPosition(touch.clientX, touch.clientY);
      }
    };

    // Mouse handling
    const handleMouse = (e) => {
      e.preventDefault();
      updatePointerPosition(e.clientX, e.clientY);
    };

    // Add event listeners with specific handlers
    canvas.addEventListener('touchstart', handleTouch, { passive: false });
    canvas.addEventListener('touchmove', handleTouch, { passive: false });
    canvas.addEventListener('mousemove', handleMouse, { passive: false });
    window.addEventListener('resize', handleResize);

    // Prevent default touch behaviors
    canvas.style.touchAction = 'none';
    canvas.style.userSelect = 'none';
    canvas.style.webkitUserSelect = 'none';


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
      frameRef.current = requestAnimationFrame(animate);
    };

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


    // Initial setup
    handleResize();
    animate();

    return () => {
      frameRef.current && cancelAnimationFrame(frameRef.current);
      canvas.removeEventListener('touchstart', handleTouch);
      canvas.removeEventListener('touchmove', handleTouch);
      canvas.removeEventListener('mousemove', handleMouse);
      window.removeEventListener('resize', handleResize);

      renderer.dispose();
      material.dispose();
      geometry.dispose();
      accumulationTargetA.dispose();
      accumulationTargetB.dispose();
    };
  }, []);

  return (
    <canvas
      ref={canvasRef}
      className={`fixed top-0 left-0 w-full h-full outline-none -z-10 ${className}`}
      style={{
        touchAction: 'none',
        userSelect: 'none',
        WebkitUserSelect: 'none',
        WebkitTouchCallout: 'none'
      }}
    />
  );
};

export default ShaderBackground;