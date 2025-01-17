
import { useEffect, useRef } from 'react';
import * as THREE from 'three';
import { OrbitControls } from 'three/examples/jsm/controls/OrbitControls';
import vertexShader from '../shaders/vertex.glsl';
import fragmentShader from '../shaders/fragment.glsl';
import trailFragmentShader from '../shaders/trailFragment.glsl';
import trailVertexShader from '../shaders/trailVertex.glsl';

export default function ShaderPlane({ width = window.innerWidth, height = window.innerHeight }) {
  const canvasRef = useRef(null);
  const rendererRef = useRef(null);
  const sceneRef = useRef(null);
  const mouseRef = useRef(new THREE.Vector2());

  useEffect(() => {
    if (!canvasRef.current) return;

    const scene = new THREE.Scene();
    sceneRef.current = scene;

    const camera = new THREE.PerspectiveCamera(75, width / height, 0.1, 100);
    camera.position.set(0.25, -0.25, 1);
    scene.add(camera);

    const renderer = new THREE.WebGLRenderer({
      canvas: canvasRef.current,
    });
    renderer.setSize(width, height);
    renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2));
    rendererRef.current = renderer;

    // Create geometry and materials
    const geometry = new THREE.PlaneGeometry(1, 1, 256, 256);
    const light = new THREE.PointLight(0xffffff, 1);
    light.position.set(2, 2, 3);
    scene.add(light);

    const normalMap = new THREE.TextureLoader().load('/T_tfilfair_2K_N.png');
    
    const material = new THREE.ShaderMaterial({
      vertexShader,
      fragmentShader,
      uniforms: {
        uMouse: { value: mouseRef.current },
        uTrailTexture: { value: null },
        uNormalMap: { value: normalMap },
        uLightPosition: { value: light.position },
        uDecay: { value: 0.95 },
        uDisplacementStrength: { value: 0.05 },
        uEffectRadius: { value: 0.15 },
      },
      side: THREE.DoubleSide,
    });

    const mesh = new THREE.Mesh(geometry, material);
    scene.add(mesh);

    const controls = new OrbitControls(camera, canvasRef.current);
    controls.enableDamping = true;

    const handleMouseMove = (event) => {
      mouseRef.current.x = event.clientX / width;
      mouseRef.current.y = 1 - event.clientY / height;
    };

    const handleResize = () => {
      camera.aspect = width / height;
      camera.updateProjectionMatrix();
      renderer.setSize(width, height);
    };

    window.addEventListener('mousemove', handleMouseMove);
    window.addEventListener('resize', handleResize);

    const animate = () => {
      controls.update();
      renderer.render(scene, camera);
      requestAnimationFrame(animate);
    };

    animate();

    return () => {
      window.removeEventListener('mousemove', handleMouseMove);
      window.removeEventListener('resize', handleResize);
      geometry.dispose();
      material.dispose();
      renderer.dispose();
    };
  }, [width, height]);

  return <canvas ref={canvasRef} />;
}
