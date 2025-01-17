
import { useEffect, useRef } from 'react';
import * as THREE from 'three';
import { OrbitControls } from 'three/examples/jsm/controls/OrbitControls';
import GUI from 'lil-gui';
import vertexShader from '../shaders/vertex.glsl';
import fragmentShader from '../shaders/fragment.glsl';

export default function ShaderPlane({ width = window.innerWidth, height = window.innerHeight }) {
  const canvasRef = useRef(null);
  const rendererRef = useRef(null);
  const sceneRef = useRef(null);
  const mouseRef = useRef(new THREE.Vector2());
  const guiRef = useRef(null);

  useEffect(() => {
    if (!canvasRef.current) return;

    const scene = new THREE.Scene();
    sceneRef.current = scene;

    const camera = new THREE.PerspectiveCamera(75, width / height, 0.1, 100);
    camera.position.set(0.25, -0.25, 1);
    scene.add(camera);

    const renderer = new THREE.WebGLRenderer({
      canvas: canvasRef.current,
      antialias: true
    });
    renderer.setSize(width, height);
    renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2));
    rendererRef.current = renderer;

    // Create geometry and materials
    const geometry = new THREE.PlaneGeometry(1, 1, 32, 32);
    const light = new THREE.PointLight(0xffffff, 1);
    light.position.set(2, 2, 3);
    scene.add(light);

    const normalMap = new THREE.TextureLoader().load('/T_tfilfair_2K_N.png');
    
    const material = new THREE.ShaderMaterial({
      vertexShader,
      fragmentShader,
      uniforms: {
        uMouse: { value: mouseRef.current },
        uNormalMap: { value: normalMap },
        uLightPosition: { value: light.position },
        uDisplacementStrength: { value: 0.05 },
        uEffectRadius: { value: 0.15 },
      },
      side: THREE.DoubleSide,
    });

    const mesh = new THREE.Mesh(geometry, material);
    scene.add(mesh);

    // Add GUI
    if (!guiRef.current) {
      guiRef.current = new GUI();
      const folder = guiRef.current.addFolder('Effect Controls');
      folder.add(material.uniforms.uDisplacementStrength, 'value', 0, 0.2, 0.001).name('Displacement');
      folder.add(material.uniforms.uEffectRadius, 'value', 0.1, 0.5, 0.01).name('Radius');
    }

    const controls = new OrbitControls(camera, canvasRef.current);
    controls.enableDamping = true;

    const handleMouseMove = (event) => {
      mouseRef.current.x = event.clientX / width;
      mouseRef.current.y = 1 - event.clientY / height;
      material.uniforms.uMouse.value = mouseRef.current;
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
      if (guiRef.current) {
        guiRef.current.destroy();
        guiRef.current = null;
      }
    };
  }, [width, height]);

  return <canvas ref={canvasRef} />;
}
