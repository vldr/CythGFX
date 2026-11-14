import "game.cy"

int GENERATOR_INIT = 0
int GENERATOR_HEIGHT_MAP = 1
int GENERATOR_DIRT_STONE_LAVA = 2
int GENERATOR_WATER = 3
int GENERATOR_CAVES = 4
int GENERATOR_ORE = 5
int GENERATOR_GRASS_SAND_GRAVEL = 6
int GENERATOR_FLOWERS = 7
int GENERATOR_MUSHROOMS = 8
int GENERATOR_TREES = 9
int GENERATOR_DESTROY = 10
int GENERATOR_FINISHED = 11

class LevelGenerator
  CombinedNoise noise1 = CombinedNoise(OctaveNoise(8), OctaveNoise(8))
  CombinedNoise noise2 = CombinedNoise(OctaveNoise(8), OctaveNoise(8))
  OctaveNoise noise3 = OctaveNoise(6)
  int[] heights
  int state

  void __init__()
    heights.reserve(LEVEL_WIDTH * LEVEL_DEPTH)

    init()

  void init()
    state = GENERATOR_INIT

  bool finished()
    return state == GENERATOR_FINISHED

  void update()
    if state == GENERATOR_INIT
      state = GENERATOR_HEIGHT_MAP
    else if state == GENERATOR_HEIGHT_MAP
      generateHeightMap()
      state = GENERATOR_DIRT_STONE_LAVA
    else if state == GENERATOR_DIRT_STONE_LAVA
      generateDirtStoneLava()
      state = GENERATOR_WATER
    else if state == GENERATOR_WATER
      generateWater()
      state = GENERATOR_CAVES
    else if state == GENERATOR_CAVES
      generateCaves()
      state = GENERATOR_ORE
    else if state == GENERATOR_ORE
      generateOre(BLOCK_COAL_ORE, 90)
      generateOre(BLOCK_IRON_ORE, 70)
      generateOre(BLOCK_GOLD_ORE, 50)
      state = GENERATOR_GRASS_SAND_GRAVEL
    else if state == GENERATOR_GRASS_SAND_GRAVEL
      generateGrassSandGravel()
      state = GENERATOR_FLOWERS
    else if state == GENERATOR_FLOWERS
      generateFlowers()
      state = GENERATOR_MUSHROOMS
    else if state == GENERATOR_MUSHROOMS
      generateMushrooms()
      state = GENERATOR_TREES
    else if state == GENERATOR_TREES
      generateTrees()
      state = GENERATOR_DESTROY
    else if state == GENERATOR_DESTROY
      game.level.calculateLightDepths(0, 0, LEVEL_WIDTH, LEVEL_DEPTH)
      game.level.calculateSpawnPosition()
      game.level.reset()

      game.levelRenderer.loadAllChunks()

      state = GENERATOR_FINISHED

  void generateHeightMap()
    for int z; z < LEVEL_DEPTH; z++
      for int x; x < LEVEL_WIDTH; x++
        float noise1Value = noise1.compute((float)x * 1.3, (float)z * 1.3) / 6.0 - 4.0
        float noise2Value = noise2.compute((float)x * 1.3, (float)z * 1.3) / 5.0 + 6.0

        if noise3.compute((float)x, (float)z) / 8.0 > 0.0
          noise2Value = noise1Value

        float maxValue = noise1Value
        if noise2Value > maxValue
          maxValue = noise2Value
        maxValue /= 2.0
        heights[x + z * LEVEL_WIDTH] = (int)maxValue

    for int z; z < LEVEL_DEPTH; z++
      for int x; x < LEVEL_WIDTH; x++
        float noise1Value = noise1.compute((float)x * 2.0, (float)z * 2.0) / 8.0
        int noise2Value = noise2.compute((float)x * 2.0, (float)z * 2.0) > 0.0 ? 1 : 0

        if noise1Value > 2.0
          int height = heights[x + z * LEVEL_WIDTH]
          heights[x + z * LEVEL_WIDTH] = ((height - noise2Value) / 2 << 1) + noise2Value

  void generateDirtStoneLava()
    for int z; z < LEVEL_DEPTH; z++
      for int x; x < LEVEL_WIDTH; x++
        int noise3Value = (int)(noise3.compute((float)x, (float)z) / 24.0) - 4
        int heightValue = heights[x + z * LEVEL_WIDTH] + game.level.waterLevel
        int combinedValue = heightValue + noise3Value

        heights[x + z * LEVEL_WIDTH] = heightValue > combinedValue ? heightValue : combinedValue

        if heights[x + z * LEVEL_WIDTH] > LEVEL_HEIGHT - 2
          heights[x + z * LEVEL_WIDTH] = LEVEL_HEIGHT - 2
        if heights[x + z * LEVEL_WIDTH] < 1
          heights[x + z * LEVEL_WIDTH] = 1

        for int height; height < LEVEL_HEIGHT; height++
          int tile = BLOCK_AIR
          if height <= heightValue
            tile = BLOCK_DIRT
          if height <= combinedValue
            tile = BLOCK_STONE
          if height == 0
            tile = BLOCK_LAVA

          game.level.setTile(x, height, z, tile, false)

  void generateWater()
    for int z; z < LEVEL_DEPTH; z++
      for int x; x < LEVEL_WIDTH; x++
        int heightValue = heights[x + z * LEVEL_WIDTH]

        for int height = heightValue; height < game.level.waterLevel; height++
          if game.level.getTile(x, height, z) == BLOCK_AIR
            game.level.setTile(x, height, z, BLOCK_WATER, false)

  void generateCaves()
    int size = LEVEL_WIDTH * LEVEL_DEPTH * LEVEL_HEIGHT / 256 / 64 << 1

    for int i; i < size; i++
      int numberOfSteps = (int)((game.random.uniform() + game.random.uniform()) * 200.0)

      float startX = game.random.uniform() * (float)LEVEL_WIDTH
      float startY = game.random.uniform() * (float)LEVEL_HEIGHT
      float startZ = game.random.uniform() * (float)LEVEL_DEPTH

      float angleX = game.random.uniform() * 2.0 * PI
      float angleY = game.random.uniform() * 2.0 * PI
      float angleYOffset = 0.0
      float randomFactor = game.random.uniform() * game.random.uniform()

      for int j; j < numberOfSteps; j++
        startX += sin(angleX) * cos(angleY)
        startY += sin(angleY)
        startZ += cos(angleX) * cos(angleY)

        angleX = (angleX + angleX * 0.2) * 0.9
        angleY = (angleY + angleYOffset * 0.5) * 0.5
        angleYOffset = angleYOffset * 0.75 + game.random.uniform() - game.random.uniform()

        if game.random.uniform() >= 0.25
          float currentX = startX + (game.random.uniform() * 4.0 - 2.0) * 0.2
          float currentY = startY + (game.random.uniform() * 4.0 - 2.0) * 0.2
          float currentZ = startZ + (game.random.uniform() * 4.0 - 2.0) * 0.2

          float radius = ((float)LEVEL_HEIGHT - currentY) / (float)LEVEL_HEIGHT * 2.0
          radius = 1.2 + (radius * 3.5 + 1.0) * randomFactor
          radius *= sin((float)j * PI / (float)numberOfSteps)

          for int blockX = (int)(currentX - radius); blockX <= (int)(currentX + radius); blockX++
            for int blockY = (int)(currentY - radius); blockY <= (int)(currentY + radius); blockY++
              for int blockZ = (int)(currentZ - radius); blockZ <= (int)(currentZ + radius); blockZ++
                float distanceX = (float)blockX - currentX
                float distanceY = (float)blockY - currentY
                float distanceZ = (float)blockZ - currentZ

                bool inside = distanceX * distanceX + 2.0 * distanceY * distanceY + distanceZ * distanceZ < radius * radius
                bool bounded = blockX >= 1 and blockY >= 1 and blockZ >= 1 and blockX < LEVEL_WIDTH - 1 and blockY < LEVEL_HEIGHT - 1 and blockZ < LEVEL_DEPTH - 1

                if inside and bounded
                  bool dry = game.level.getTile(blockX, blockY + 1, blockZ) != BLOCK_WATER
                  dry = dry and game.level.getTile(blockX, blockY - 1, blockZ) != BLOCK_WATER
                  dry = dry and game.level.getTile(blockX + 1, blockY, blockZ) != BLOCK_WATER
                  dry = dry and game.level.getTile(blockX - 1, blockY, blockZ) != BLOCK_WATER
                  dry = dry and game.level.getTile(blockX, blockY, blockZ + 1) != BLOCK_WATER
                  dry = dry and game.level.getTile(blockX, blockY, blockZ - 1) != BLOCK_WATER

                  if dry and game.level.getTile(blockX, blockY, blockZ) == BLOCK_STONE
                    game.level.setTile(blockX, blockY, blockZ, BLOCK_AIR, false)

  void generateOre(int blockType, int amount)
    int size = LEVEL_WIDTH * LEVEL_DEPTH * LEVEL_HEIGHT / 256 / 64 * amount / 100

    for int i; i < size; i++
      int numberOfSteps = (int)((game.random.uniform() + game.random.uniform()) * 75.0 * (float)amount / 100.0)

      float startX = game.random.uniform() * (float)LEVEL_WIDTH
      float startY = game.random.uniform() * (float)LEVEL_HEIGHT
      float startZ = game.random.uniform() * (float)LEVEL_DEPTH

      float angleX = game.random.uniform() * 2.0 * PI
      float angleY = game.random.uniform() * 2.0 * PI
      float angleXOffset = 0.0
      float angleYOffset = 0.0

      for int j; j < numberOfSteps; j++
        startX += sin(angleX) * cos(angleY)
        startY += sin(angleY)
        startZ += cos(angleX) * cos(angleY)

        angleX += angleXOffset * 0.2
        angleXOffset = angleXOffset * 0.9 + game.random.uniform() - game.random.uniform()
        angleY = (angleY + angleYOffset * 0.5) * 0.5
        angleYOffset = angleYOffset * 0.9 + game.random.uniform() - game.random.uniform()

        float radius = sin((float)j * PI / (float)numberOfSteps) * (float)amount / 100.0 + 1.0

        for int blockX = (int)(startX - radius); blockX <= (int)(startX + radius); blockX++
          for int blockY = (int)(startY - radius); blockY <= (int)(startY + radius); blockY++
            for int blockZ = (int)(startZ - radius); blockZ <= (int)(startZ + radius); blockZ++
              float distanceX = (float)blockX - startX
              float distanceY = (float)blockY - startY
              float distanceZ = (float)blockZ - startZ

              bool inside = distanceX * distanceX + 2.0 * distanceY * distanceY + distanceZ * distanceZ < radius * radius
              bool bounded = blockX >= 1 and blockY >= 1 and blockZ >= 1 and blockX < LEVEL_WIDTH - 1 and blockY < LEVEL_HEIGHT - 1 and blockZ < LEVEL_DEPTH - 1

              if inside and bounded and game.level.getTile(blockX, blockY, blockZ) == BLOCK_STONE
                game.level.setTile(blockX, blockY, blockZ, blockType, false)

  void generateGrassSandGravel()
    for int z; z < LEVEL_DEPTH; z++
      for int x; x < LEVEL_WIDTH; x++
        int height = heights[x + z * LEVEL_WIDTH]
        bool isNoise1 = noise1.compute((float)x, (float)z) > 8.0
        bool isNoise2 = noise2.compute((float)x, (float)z) > 12.0
        int blockAbove = game.level.getTile(x, height + 1, z)

        if blockAbove == BLOCK_WATER and height <= LEVEL_HEIGHT / 2 - 1 and isNoise2
          game.level.setTile(x, height, z, BLOCK_GRAVEL, false)

        if blockAbove == BLOCK_AIR
          if height <= LEVEL_HEIGHT / 2 - 1 and isNoise1
            game.level.setTile(x, height, z, BLOCK_SAND, false)
          else
            game.level.setTile(x, height, z, BLOCK_GRASS, false)

  void generateFlowers()
    int size = LEVEL_WIDTH * LEVEL_DEPTH / 3000

    for int i; i < size; i++
      int xCoord = game.random.integerRange(0, LEVEL_WIDTH - 1)
      int zCoord = game.random.integerRange(0, LEVEL_DEPTH - 1)
      int flowerType = game.random.integerRange(0, 1)

      for int j; j < 10; j++
        int currentX = xCoord
        int currentZ = zCoord

        for int directionChange; directionChange < 5; directionChange++
          currentX += game.random.integerRange(0, 5) - game.random.integerRange(0, 5)
          currentZ += game.random.integerRange(0, 5) - game.random.integerRange(0, 5)

          bool accepted = flowerType < 2 or game.random.integerRange(0, 3) == 0
          bool bounded = currentX >= 0 and currentZ >= 0 and currentX < LEVEL_WIDTH and currentZ < LEVEL_DEPTH

          if accepted and bounded
            int yCoord = heights[currentX + currentZ * LEVEL_WIDTH]
            if game.level.getTile(currentX, yCoord, currentZ) == BLOCK_GRASS
              if flowerType == 0
                game.level.setTile(currentX, yCoord + 1, currentZ, BLOCK_DANDELION, false)
              else
                game.level.setTile(currentX, yCoord + 1, currentZ, BLOCK_ROSE, false)

  void generateMushrooms()
    int size = LEVEL_WIDTH * LEVEL_DEPTH * LEVEL_HEIGHT / 2000

    for int i; i < size; i++
      int mushroomType = game.random.integerRange(0, 1)
      int blockX = game.random.integerRange(0, LEVEL_WIDTH - 1)
      int blockY = game.random.integerRange(0, LEVEL_HEIGHT - 1)
      int blockZ = game.random.integerRange(0, LEVEL_DEPTH - 1)

      for int j; j < 20; j++
        int currentX = blockX
        int currentY = blockY
        int currentZ = blockZ

        for int directionChange; directionChange < 5; directionChange++
          currentX += game.random.integerRange(0, 5) - game.random.integerRange(0, 5)
          currentY += game.random.integerRange(0, 1) - game.random.integerRange(0, 1)
          currentZ += game.random.integerRange(0, 5) - game.random.integerRange(0, 5)

          bool accepted = mushroomType < 2 or game.random.integerRange(0, 3) == 0
          bool bounded = currentX >= 0 and currentZ >= 0 and currentY >= 1
          bounded = bounded and currentX < LEVEL_WIDTH and currentZ < LEVEL_DEPTH
          bounded = bounded and currentY < heights[currentX + currentZ * LEVEL_WIDTH] - 1

          if accepted and bounded and game.level.getTile(currentX, blockY, currentZ) == BLOCK_AIR
            if game.level.getTile(currentX, blockY - 1, currentZ) == BLOCK_STONE
              int type = mushroomType == 0 ? BLOCK_BROWN_SHROOM : BLOCK_RED_SHROOM
              game.level.setTile(currentX, blockY, currentZ, type, false)

  void generateTrees()
    for int z = 4; z < LEVEL_DEPTH - 4; z += 5
      for int x = 4; x < LEVEL_WIDTH - 4; x += 5
        int treeHeight = heights[x + z * LEVEL_WIDTH]

        if game.random.integerRange(0, 4) == 0
          int treeTrunkSize = game.random.integerRange(0, 2) + 5

          if game.level.getTile(x, treeHeight, z) == BLOCK_GRASS and treeHeight < LEVEL_DEPTH - treeTrunkSize - 1
            game.level.setTile(x, treeHeight, z, BLOCK_DIRT, false)

            for int leavesY = treeHeight - 3 + treeTrunkSize; leavesY <= treeHeight + treeTrunkSize; leavesY++
              int distanceFromTop = leavesY - (treeHeight + treeTrunkSize)
              int leavesWidth = 1 - distanceFromTop / 2

              for int leavesX = x - leavesWidth; leavesX <= x + leavesWidth; leavesX++
                int xDistance = leavesX - x

                for int leavesZ = z - leavesWidth; leavesZ <= z + leavesWidth; leavesZ++
                  int zDistance = leavesZ - z
                  int absoluteXDistance = xDistance < 0 ? -xDistance : xDistance
                  int absoluteZDistance = zDistance < 0 ? -zDistance : zDistance
                  bool edge = absoluteXDistance == leavesWidth and absoluteZDistance == leavesWidth
                  bool place = not edge

                  if edge
                    place = game.random.integerRange(0, 1) != 0 and distanceFromTop != 0

                  if place
                    game.level.setTile(leavesX, leavesY, leavesZ, BLOCK_LEAVES, false)

            for int trunkY; trunkY < treeTrunkSize; trunkY++
              game.level.setTile(x, treeHeight + trunkY, z, BLOCK_LOG, false)
