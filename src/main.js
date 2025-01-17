updateTrailTexture() {
    const currentRenderTarget = this.trailRenderTarget.clone();

    // Update current texture with main scene
    this.renderer.setRenderTarget(currentRenderTarget);
    this.renderer.render(this.scene, this.camera);

    // Update trail material uniforms
    this.trailMaterial.uniforms.uCurrentTexture.value = currentRenderTarget.texture;
    this.trailMaterial.uniforms.uTrailTexture.value = this.trailRenderTarget.texture;

    // Render trail effect
    this.renderer.setRenderTarget(this.trailRenderTarget);
    this.renderer.render(this.trailScene, this.trailCamera);
    this.renderer.setRenderTarget(null);

    currentRenderTarget.dispose();
  }