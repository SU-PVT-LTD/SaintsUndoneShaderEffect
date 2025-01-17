
import React from 'react';
import ShaderPlane from './components/ShaderPlane';
import './style.css';

export default function App() {
  return (
    <div style={{ width: '100vw', height: '100vh', overflow: 'hidden' }}>
      <ShaderPlane />
    </div>
  );
}
