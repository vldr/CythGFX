import "game.cy"

class Skybox
  VertexList bedrockVertices
  int bedrockTexture

  VertexList waterVertices
  int waterTexture

  VertexList cloudsVertices
  int cloudsTexture

  VertexList skyVertices
  int skyTexture

  void __init__()
    bedrockVertices = VertexList()
    waterVertices = VertexList()
    cloudsVertices = VertexList()
    skyVertices = VertexList()

    bedrockTexture = 0
    waterTexture = 0
    cloudsTexture = 0
    skyTexture = 0

  void init()
    initBedrock()
    initWater()
    initClouds()
    initSky()

  void initBedrock()
    int texture = blockDefinitions[BLOCK_BEDROCK].sideTexture
    int width = 16
    int height = 16
    int textureX = (texture % width) * width
    int textureY = (texture / height) * height

    bedrockTexture = game.textureManager.load(
      terrainResourceTexture,
      textureX,
      textureY,
      width,
      height
    )

    bedrockVertices.init()

    float ground = (float)game.level.groundLevel
    int a = min(128, min(LEVEL_WIDTH, LEVEL_DEPTH))
    int b = 1024 / a

    for int i = -a * b; i < LEVEL_WIDTH + a * b; i += a
      for int j = -a * b; j < LEVEL_DEPTH + a * b; j += a
        float g = ground

        if i >= 0 and j >= 0 and i < LEVEL_WIDTH and j < LEVEL_DEPTH
          g = 0.0

        bedrockVertices.push((float)i, g, (float)j, 0.0, 0.0, 0.5)
        bedrockVertices.push((float)i, g, (float)(j + a), 0.0, (float)a, 0.5)
        bedrockVertices.push((float)(i + a), g, (float)(j + a), (float)a, (float)a, 0.5)

        bedrockVertices.push((float)i, g, (float)j, 0.0, 0.0, 0.5)
        bedrockVertices.push((float)(i + a), g, (float)(j + a), (float)a, (float)a, 0.5)
        bedrockVertices.push((float)(i + a), g, (float)j, (float)a, 0.0, 0.5)

    for int i; i < LEVEL_WIDTH; i += a
      bedrockVertices.push((float)i, ground, 0.0, 0.0, ground, 0.8)
      bedrockVertices.push((float)i, 0.0, 0.0, 0.0, 0.0, 0.8)
      bedrockVertices.push((float)(i + a), 0.0, 0.0, (float)a, 0.0, 0.8)

      bedrockVertices.push((float)i, ground, 0.0, 0.0, ground, 0.8)
      bedrockVertices.push((float)(i + a), 0.0, 0.0, (float)a, 0.0, 0.8)
      bedrockVertices.push((float)(i + a), ground, 0.0, (float)a, ground, 0.8)

      bedrockVertices.push((float)(i + a), ground, (float)LEVEL_DEPTH, (float)a, ground, 0.8)
      bedrockVertices.push((float)(i + a), 0.0, (float)LEVEL_DEPTH, (float)a, 0.0, 0.8)
      bedrockVertices.push((float)i, 0.0, (float)LEVEL_DEPTH, 0.0, 0.0, 0.8)

      bedrockVertices.push((float)(i + a), ground, (float)LEVEL_DEPTH, (float)a, ground, 0.8)
      bedrockVertices.push((float)i, 0.0, (float)LEVEL_DEPTH, 0.0, 0.0, 0.8)
      bedrockVertices.push((float)i, ground, (float)LEVEL_DEPTH, 0.0, ground, 0.8)

    for int i; i < LEVEL_DEPTH; i += a
      bedrockVertices.push(0.0, ground, (float)(i + a), (float)a, 0.0, 0.6)
      bedrockVertices.push(0.0, 0.0, (float)(i + a), (float)a, ground, 0.6)
      bedrockVertices.push(0.0, 0.0, (float)i, 0.0, ground, 0.6)

      bedrockVertices.push(0.0, ground, (float)(i + a), (float)a, 0.0, 0.6)
      bedrockVertices.push(0.0, 0.0, (float)i, 0.0, ground, 0.6)
      bedrockVertices.push(0.0, ground, (float)i, 0.0, 0.0, 0.6)

      bedrockVertices.push((float)LEVEL_WIDTH, ground, (float)i, 0.0, 0.0, 0.6)
      bedrockVertices.push((float)LEVEL_WIDTH, 0.0, (float)i, 0.0, ground, 0.6)
      bedrockVertices.push((float)LEVEL_WIDTH, 0.0, (float)(i + a), (float)a, ground, 0.6)

      bedrockVertices.push((float)LEVEL_WIDTH, ground, (float)i, 0.0, 0.0, 0.6)
      bedrockVertices.push((float)LEVEL_WIDTH, 0.0, (float)(i + a), (float)a, ground, 0.6)
      bedrockVertices.push((float)LEVEL_WIDTH, ground, (float)(i + a), (float)a, 0.0, 0.6)

    bedrockVertices.update()

  void initWater()
    int texture = blockDefinitions[BLOCK_WATER].sideTexture
    int width = 16
    int height = 16
    int textureX = (texture % width) * width
    int textureY = (texture / height) * height

    waterTexture = game.textureManager.load(
      terrainResourceTexture,
      textureX,
      textureY,
      width,
      height
    )

    waterVertices.init()

    float water = (float)game.level.waterLevel
    int a = min(128, min(LEVEL_WIDTH, LEVEL_DEPTH))
    int b = 1024 / a

    for int i = -a * b; i < LEVEL_WIDTH + a * b; i += a
      for int j = -a * b; j < LEVEL_DEPTH + a * b; j += a
        float w = water - 0.1

        if i < 0 or j < 0 or i >= LEVEL_WIDTH or j >= LEVEL_DEPTH
          waterVertices.push((float)i, w, (float)j, 0.0, 0.0, 1.0)
          waterVertices.push((float)i, w, (float)(j + a), 0.0, (float)a, 1.0)
          waterVertices.push((float)(i + a), w, (float)(j + a), (float)a, (float)a, 1.0)

          waterVertices.push((float)i, w, (float)j, 0.0, 0.0, 1.0)
          waterVertices.push((float)(i + a), w, (float)(j + a), (float)a, (float)a, 1.0)
          waterVertices.push((float)(i + a), w, (float)j, (float)a, 0.0, 1.0)

          waterVertices.push((float)i, w, (float)(j + a), 0.0, (float)a, 1.0)
          waterVertices.push((float)i, w, (float)j, 0.0, 0.0, 1.0)
          waterVertices.push((float)(i + a), w, (float)j, (float)a, 0.0, 1.0)

          waterVertices.push((float)i, w, (float)(j + a), 0.0, (float)a, 1.0)
          waterVertices.push((float)(i + a), w, (float)j, (float)a, 0.0, 1.0)
          waterVertices.push((float)(i + a), w, (float)(j + a), (float)a, (float)a, 1.0)

    waterVertices.update()

  void initClouds()
    cloudsTexture = game.textureManager.load(cloudsResourceTexture)
    cloudsVertices.init()

    float y = (float)LEVEL_HEIGHT + 2.0
    float textureOffset = 0.0

    for int x = -1024; x < LEVEL_WIDTH + 1024; x += 512
      for int z = -1024; z < LEVEL_DEPTH + 1024; z += 512
        float u0 = ((float)x + textureOffset) / 2048.0
        float u1 = ((float)(x + 512) + textureOffset) / 2048.0
        float v0 = (float)z / 2048.0
        float v1 = (float)(z + 512) / 2048.0

        cloudsVertices.push((float)x, y, (float)z, u0, v0, 1.0)
        cloudsVertices.push((float)x, y, (float)(z + 512), u0, v1, 1.0)
        cloudsVertices.push((float)(x + 512), y, (float)(z + 512), u1, v1, 1.0)

        cloudsVertices.push((float)x, y, (float)z, u0, v0, 1.0)
        cloudsVertices.push((float)(x + 512), y, (float)(z + 512), u1, v1, 1.0)
        cloudsVertices.push((float)(x + 512), y, (float)z, u1, v0, 1.0)

        cloudsVertices.push((float)x, y, (float)(z + 512), u0, v1, 1.0)
        cloudsVertices.push((float)x, y, (float)z, u0, v0, 1.0)
        cloudsVertices.push((float)(x + 512), y, (float)z, u1, v0, 1.0)

        cloudsVertices.push((float)x, y, (float)(z + 512), u0, v1, 1.0)
        cloudsVertices.push((float)(x + 512), y, (float)z, u1, v0, 1.0)
        cloudsVertices.push((float)(x + 512), y, (float)(z + 512), u1, v1, 1.0)

    cloudsVertices.update()

  void initSky()
    skyTexture = game.textureManager.loadColor(0.6, 0.8, 1.0)
    skyVertices.init()

    float y = (float)LEVEL_HEIGHT + 10.0

    for int x = -1024; x < LEVEL_WIDTH + 1024; x += 512
      for int z = -1024; z < LEVEL_DEPTH + 1024; z += 512
        float u0 = (float)x / 2048.0
        float u1 = (float)(x + 512) / 2048.0
        float v0 = (float)z / 2048.0
        float v1 = (float)(z + 512) / 2048.0

        skyVertices.push((float)x, y, (float)(z + 512), u0, v1, 1.0)
        skyVertices.push((float)x, y, (float)z, u0, v0, 1.0)
        skyVertices.push((float)(x + 512), y, (float)z, u1, v0, 1.0)

        skyVertices.push((float)x, y, (float)(z + 512), u0, v1, 1.0)
        skyVertices.push((float)(x + 512), y, (float)z, u1, v0, 1.0)
        skyVertices.push((float)(x + 512), y, (float)(z + 512), u1, v1, 1.0)

    skyVertices.update()

  void updateWater(char[] waterTextureData)
    updateTextureRegion(
      waterTexture,
      0,
      0,
      16,
      16,
      waterTextureData
    )

  void renderBedrock()
    setTexture(bedrockTexture)
    bedrockVertices.render()

  void renderWater()
    setTexture(waterTexture)
    waterVertices.render()

  void renderClouds()
    setTexture(cloudsTexture)
    setUniform(game.fragmentOffsetUniform, (0.03 * (game.timer.ticks + game.timer.delta)) / 2048.0, 0.0)

    cloudsVertices.render()

    setUniform(game.fragmentOffsetUniform, 0.0, 0.0)

  void renderSky()
    setTexture(skyTexture)
    skyVertices.render()
