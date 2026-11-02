class TextureManager
  int load(string name)
    return createTexture(name)

  int load(string name, int x, int y, int width, int height)
    return createTextureRegion(name, x, y, width, height)

  int loadColor(float r, float g, float b)
    return createColorTexture(r, g, b)
