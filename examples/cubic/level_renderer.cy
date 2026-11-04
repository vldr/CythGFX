import "game.cy"

int MAX_CHUNK_UPDATES = 4
int CHUNKS_X = LEVEL_WIDTH / CHUNK_SIZE
int CHUNKS_Y = LEVEL_HEIGHT / CHUNK_SIZE
int CHUNKS_Z = LEVEL_DEPTH / CHUNK_SIZE
int CHUNK_COUNT = CHUNKS_X * CHUNKS_Y * CHUNKS_Z

class LevelRenderer
  Frustum frustum
  Skybox skybox

  Chunk[] chunks
  bool[] queued

  int chunkUpdates

  char[] waterTextureData
  float[] waterTextureRed
  float[] waterTextureGreen
  float[] waterTextureBlue
  float[] waterTextureAlpha

  char[] lavaTextureData
  float[] lavaTextureRed
  float[] lavaTextureGreen
  float[] lavaTextureBlue
  float[] lavaTextureAlpha

  void __init__()
    frustum = Frustum()
    skybox = Skybox()
    chunkUpdates = 0

    chunks.reserve(CHUNK_COUNT)
    queued.reserve(CHUNK_COUNT)

    for int x; x < CHUNKS_X; x++
      for int y; y < CHUNKS_Y; y++
        for int z; z < CHUNKS_Z; z++
          int index = chunkIndex(x, y, z)
          chunks[index] = Chunk(x * CHUNK_SIZE, y * CHUNK_SIZE, z * CHUNK_SIZE)
          queued[index] = false

    waterTextureData.reserve(1024)
    waterTextureRed.reserve(256)
    waterTextureGreen.reserve(256)
    waterTextureBlue.reserve(256)
    waterTextureAlpha.reserve(256)

    lavaTextureData.reserve(1024)
    lavaTextureRed.reserve(256)
    lavaTextureGreen.reserve(256)
    lavaTextureBlue.reserve(256)
    lavaTextureAlpha.reserve(256)

  void init()
    skybox.init()

  int chunkIndex(int x, int y, int z)
    return (z * CHUNKS_Y + y) * CHUNKS_X + x

  bool validChunk(int x, int y, int z)
    return x >= 0 and y >= 0 and z >= 0 and x < CHUNKS_X and y < CHUNKS_Y and z < CHUNKS_Z

  Chunk getChunk(int x, int y, int z)
    if not validChunk(x, y, z)
      return null

    return chunks[chunkIndex(x, y, z)]

  void update(Matrix projection, Matrix view)
    frustum.update(projection, view)

  void queueChunk(int x, int y, int z)
    if not validChunk(x, y, z)
      return

    int index = chunkIndex(x, y, z)
    if not queued[index]
      queued[index] = true
      chunks[index].isLoaded = false

  void loadAllChunks()
    for int i; i < chunks.length; i++
      queued[i] = true
      chunks[i].isLoaded = false

  void loadChunks(int x, int y, int z)
    int[] dx = [0, 1, -1, 0, 0, 0, 0]
    int[] dy = [0, 0, 0, 1, -1, 0, 0]
    int[] dz = [0, 0, 0, 0, 0, 1, -1]

    for int i; i < 7; i++
      int blockX = x + dx[i]
      int blockY = y + dy[i]
      int blockZ = z + dz[i]

      if blockX >= 0 and blockY >= 0 and blockZ >= 0
        int chunkX = blockX / CHUNK_SIZE
        int chunkY = blockY / CHUNK_SIZE
        int chunkZ = blockZ / CHUNK_SIZE

        if validChunk(chunkX, chunkY, chunkZ)
          int index = chunkIndex(chunkX, chunkY, chunkZ)

          if chunks[index].isLoaded
            queueChunk(chunkX, chunkY, chunkZ)

  int nearestQueuedChunk()
    int selected = -1
    float selectedDistance = 0.0

    for int i; i < chunks.length; i++
      if queued[i]
        float distance = chunks[i].distanceToPlayer()

        if selected == -1 or distance < selectedDistance
          selected = i
          selectedDistance = distance

    return selected

  void updateQueuedChunks()
    int updates = 0

    while updates < MAX_CHUNK_UPDATES
      int index = nearestQueuedChunk()
      if index == -1
        break

      queued[index] = false
      chunks[index].update()
      updates++

    chunkUpdates += updates

  void render()
    updateQueuedChunks()
    setTexture(game.atlasTexture)

    for Chunk chunk in chunks
      chunk.isVisible = frustum.contains(chunk)

      if chunk.isVisible
        chunk.render()

    skybox.renderBedrock()
    skybox.renderSky()
    skybox.renderClouds()

  void renderPost()
    setTexture(game.atlasTexture)
    setColorMask(false, false, false, false)

    for Chunk chunk in chunks
      if chunk.isVisible
        chunk.renderWater()

    skybox.renderWater()

    setColorMask(true, true, true, true)
    setTexture(game.atlasTexture)

    for Chunk chunk in chunks
      if chunk.isVisible
        chunk.renderWater()

    skybox.renderWater()

  void tick()
    setTexture(game.atlasTexture)

    updateLavaTexture()
    updateWaterTexture()

  void updateWaterTexture()
    for int x; x < 16; x++
      for int y; y < 16; y++
        float value = 0.0

        for int i = x - 1; i <= x + 1; i++
          int a = i & 15
          int b = y & 15
          value += waterTextureRed[a + (b << 4)]

        int index = x + (y << 4)
        waterTextureBlue[index] = value / 3.3 + waterTextureGreen[index] * 0.8

    for int x; x < 16; x++
      for int y; y < 16; y++
        int index = x + (y << 4)
        waterTextureGreen[index] += waterTextureAlpha[index] * 0.05

        if waterTextureGreen[index] < 0.0
          waterTextureGreen[index] = 0.0

        waterTextureAlpha[index] -= 0.1

        if game.random.uniform() < 0.05
          waterTextureAlpha[index] = 0.5

    for int i; i < 256; i++
      float previousBlue = waterTextureBlue[i]
      waterTextureBlue[i] = waterTextureRed[i]
      waterTextureRed[i] = previousBlue

      float value = clamp(waterTextureRed[i], 0.0, 1.0)
      int red = (int)(32.0 + value * value * 32.0)
      int green = (int)(50.0 + value * value * 64.0)
      int alpha = (int)(180.0 + value * value * 45.0)

      waterTextureData[i << 2] = (char)red
      waterTextureData[(i << 2) + 1] = (char)green
      waterTextureData[(i << 2) + 2] = (char)255
      waterTextureData[(i << 2) + 3] = (char)alpha

    int texture = blockDefinitions[BLOCK_WATER].topTexture
    updateTextureRegion(
      game.atlasTexture,
      texture % 16 << 4,
      texture / 16 << 4,
      16,
      16,
      waterTextureData
    )

    skybox.updateWater(waterTextureData)

  void updateLavaTexture()
    for int x; x < 16; x++
      for int y; y < 16; y++
        int sy = (int)(sin((float)y * PI / 8.0) * 1.2)
        int sx = (int)(sin((float)x * PI / 8.0) * 1.2)
        float value = 0.0

        for int i = x - 1; i <= x + 1; i++
          for int j = y - 1; j <= y + 1; j++
            int a = i + sy & 15
            int b = j + sx & 15
            value += lavaTextureRed[a + (b << 4)]

        int index = x + (y << 4)
        int index00 = (x & 15) + ((y & 15) << 4)
        int index10 = (x + 1 & 15) + ((y & 15) << 4)
        int index11 = (x + 1 & 15) + ((y + 1 & 15) << 4)
        int index01 = (x & 15) + ((y + 1 & 15) << 4)

        float neighboringBlue = lavaTextureBlue[index00]
        neighboringBlue += lavaTextureBlue[index10]
        neighboringBlue += lavaTextureBlue[index11]
        neighboringBlue += lavaTextureBlue[index01]
        lavaTextureGreen[index] = value / 10.0 + neighboringBlue / 4.0 * 0.8

        lavaTextureBlue[index] += lavaTextureAlpha[index] * 0.01

        if lavaTextureBlue[index] < 0.0
          lavaTextureBlue[index] = 0.0

        lavaTextureAlpha[index] -= 0.06

        if game.random.uniform() < 0.005
          lavaTextureAlpha[index] = 1.5

    for int i; i < 256; i++
      float previousRed = lavaTextureRed[i]
      lavaTextureRed[i] = lavaTextureGreen[i]
      lavaTextureGreen[i] = previousRed

      float value = clamp(lavaTextureRed[i] * 2.0, 0.0, 1.0)
      int red = (int)(value * 100.0 + 155.0)
      int green = (int)(value * value * 255.0)
      int blue = (int)(value * value * value * value * 128.0)

      lavaTextureData[i << 2] = (char)red
      lavaTextureData[(i << 2) + 1] = (char)green
      lavaTextureData[(i << 2) + 2] = (char)blue
      lavaTextureData[(i << 2) + 3] = (char)255

    int texture = blockDefinitions[BLOCK_LAVA].topTexture
    updateTextureRegion(game.atlasTexture, texture % 16 << 4, texture / 16 << 4, 16, 16, lavaTextureData)
