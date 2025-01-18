
import React from 'react';
import ShaderBackground from './ShaderBackground';

const App = () => {
  return (
    <div>
      <ShaderBackground />
      <div className="relative z-10">
        {/* Your content goes here */}
        <h1 className="p-5 text-white">Your Content</h1>
      </div>
    </div>
  );
};

export default App;
