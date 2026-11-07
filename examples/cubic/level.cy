import "game.cy"

int LEVEL_WIDTH = 128
int LEVEL_HEIGHT = 64
int LEVEL_DEPTH = 128

class Level
  char[] blocks
  int[] lightDepths

  int groundLevel
  int waterLevel

  Vector3 spawn
  Queue<Int3> updates

  void __init__()
    blocks = []
    lightDepths = []
    spawn = Vector3()
    updates = Queue<Int3>()

    waterLevel = LEVEL_HEIGHT / 2
    groundLevel = waterLevel - 2

    spawn.x = (float)LEVEL_WIDTH - 1.0
    spawn.x = (float)LEVEL_HEIGHT - 1.0
    spawn.x = (float)LEVEL_DEPTH - 1.0

    blocks.reserve(LEVEL_WIDTH * LEVEL_HEIGHT * LEVEL_DEPTH)
    lightDepths.reserve(LEVEL_WIDTH * LEVEL_DEPTH)

    for int i; i < LEVEL_WIDTH * LEVEL_DEPTH; i++
      lightDepths[i] = LEVEL_HEIGHT - 1

  void reset()
    updates.clear()

  void tick()
    if game.timer.ticks % 7 == 0
      int size = updates.size()

      for int i; i < size; i++
        Int3 update = updates.front()

        updateTile(update.x, update.y, update.z)
        updates.pop()

  bool canFlood(int x, int y, int z, int blockType)
    for int i = x - 2; i <= x + 2; i++
      for int j = y - 2; j <= y + 2; j++
        for int k = z - 2; k <= z + 2; k++
          if getTile(i, j, k) == BLOCK_SPONGE and isWaterTile(blockType)
            return false

    return blockDefinitions[getTile(x, y, z)].collide == COLLIDE_NONE

  bool isTileLit(int x, int y, int z)
    if x < 0 or y < 0 or z < 0 or x >= LEVEL_WIDTH or y >= LEVEL_HEIGHT or z >= LEVEL_DEPTH
      return true
    return y >= lightDepths[x + z * LEVEL_WIDTH]

  float getTileBrightness(int x, int y, int z)
    if isLavaTile(x, y, z) or isTileLit(x, y, z)
      return 1.0

    return 0.6

  int getTileAABBCount(AABB box)
    int tiles = 0

    int x0 = (int)box.x0
    int y0 = (int)box.y0
    int z0 = (int)box.z0
    int x1 = (int)(box.x1 + 1.0)
    int y1 = (int)(box.y1 + 1.0)
    int z1 = (int)(box.z1 + 1.0)

    if box.x0 < 0.0
      x0--
    if box.y0 < 0.0
      y0--
    if box.z0 < 0.0
      z0--

    for int i = x0; i < x1; i++
      for int j = y0; j < y1; j++
        for int k = z0; k < z1; k++
          if i >= 0 and j >= 0 and k >= 0 and i < LEVEL_WIDTH and j < LEVEL_HEIGHT and k < LEVEL_DEPTH
            Definition blockDefinition = blockDefinitions[getTile(i, j, k)]

            if blockDefinition.collide != COLLIDE_NONE and blockDefinition.collide != COLLIDE_LIQUID
              AABB aabb = AABB(
                (float)i,
                (float)j,
                (float)k,
                (float)i + 1.0,
                (float)j + blockDefinition.height,
                (float)k + 1.0
              )

              if box.intersectsInner(aabb)
                tiles++
          else if i < 0 or j < 0 or k < 0 or i >= LEVEL_WIDTH or k >= LEVEL_DEPTH
            if j < groundLevel
              Definition blockDefinition = blockDefinitions[BLOCK_BEDROCK]

              AABB aabb = AABB(
                (float)i,
                (float)j,
                (float)k,
                (float)i + 1.0,
                (float)j + blockDefinition.height,
                (float)k + 1.0
              )

              if box.intersectsInner(aabb)
                tiles++

    return tiles

  AABB[] getTileAABB(AABB box)
    AABB[] tiles

    int x0 = (int)box.x0
    int y0 = (int)box.y0
    int z0 = (int)box.z0
    int x1 = (int)(box.x1 + 1.0)
    int y1 = (int)(box.y1 + 1.0)
    int z1 = (int)(box.z1 + 1.0)

    if box.x0 < 0.0
      x0--
    if box.y0 < 0.0
      y0--
    if box.z0 < 0.0
      z0--

    for int i = x0; i < x1; i++
      for int j = y0; j < y1; j++
        for int k = z0; k < z1; k++
          if i >= 0 and j >= 0 and k >= 0 and i < LEVEL_WIDTH and j < LEVEL_HEIGHT and k < LEVEL_DEPTH
            Definition blockDefinition = blockDefinitions[getTile(i, j, k)]

            if blockDefinition.collide != COLLIDE_NONE and blockDefinition.collide != COLLIDE_LIQUID
              AABB aabb = AABB(
                (float)i,
                (float)j,
                (float)k,
                (float)i + 1.0,
                (float)j + blockDefinition.height,
                (float)k + 1.0
              )

              if box.intersectsInner(aabb)
                tiles.push(aabb)
          else if i < 0 or j < 0 or k < 0 or i >= LEVEL_WIDTH or k >= LEVEL_DEPTH
            if j < groundLevel
              Definition blockDefinition = blockDefinitions[BLOCK_BEDROCK]

              AABB aabb = AABB(
                (float)i,
                (float)j,
                (float)k,
                (float)i + 1.0,
                (float)j + blockDefinition.height,
                (float)k + 1.0
              )

              if box.intersectsInner(aabb)
                tiles.push(aabb)

    return tiles

  bool containsAnyLiquid(AABB box)
    int x0 = (int)box.x0
    int y0 = (int)box.y0
    int z0 = (int)box.z0
    int x1 = (int)(box.x1 + 1.0)
    int y1 = (int)(box.y1 + 1.0)
    int z1 = (int)(box.z1 + 1.0)

    if box.x0 < 0.0
      x0--
    if box.y0 < 0.0
      y0--
    if box.z0 < 0.0
      z0--

    for int i = x0; i < x1; i++
      for int j = y0; j < y1; j++
        for int k = z0; k < z1; k++
          Definition blockDefinition = blockDefinitions[getTile(i, j, k)]

          if i < 0 or j < 0 or k < 0 or i >= LEVEL_WIDTH or k >= LEVEL_DEPTH
            if j < waterLevel and j > groundLevel
              return true
          else if blockDefinition.collide == COLLIDE_LIQUID
            return true

    return false

  bool containsLiquid(AABB box, int blockType)
    int x0 = (int)box.x0
    int y0 = (int)box.y0
    int z0 = (int)box.z0
    int x1 = (int)(box.x1 + 1.0)
    int y1 = (int)(box.y1 + 1.0)
    int z1 = (int)(box.z1 + 1.0)

    if box.x0 < 0.0
      x0--
    if box.y0 < 0.0
      y0--
    if box.z0 < 0.0
      z0--

    for int i = x0; i < x1; i++
      for int j = y0; j < y1; j++
        for int k = z0; k < z1; k++
          if i < 0 or j < 0 or k < 0 or i >= LEVEL_WIDTH or k >= LEVEL_DEPTH
            if j < waterLevel and j > groundLevel and (blockType == BLOCK_STILL_WATER or blockType == BLOCK_WATER)
              return true
          else if getTile(i, j, k) == blockType
            return true

    return false

  void calculateSpawnPosition()
    Vector3 maxPosition = Vector3(-FLT_MAX, -FLT_MAX, -FLT_MAX)

    for int x; x < LEVEL_WIDTH; x++
      for int z; z < LEVEL_DEPTH; z++
        int y = lightDepths[x + z * LEVEL_WIDTH]

        if getTile(x, y + 1, z) == BLOCK_AIR and getTile(x, y + 2, z) == BLOCK_AIR
          if y > maxPosition.y
            maxPosition.x = (float)x
            maxPosition.y = (float)y
            maxPosition.z = (float)z

    Vector3 newSpawn = Vector3(maxPosition.x + 0.5, maxPosition.y + 2.0, maxPosition.z + 0.5)
    game.localPlayer.setPosition(newSpawn.x, newSpawn.y, newSpawn.z)
    game.level.spawn = game.localPlayer.entity.position.clone()

  void calculateLightDepths(int x, int z, int offsetX, int offsetZ)
    for int i = x; i < x + offsetX; i++
      for int j = z; j < z + offsetZ; j++
        int blocker = lightDepths[i + j * LEVEL_WIDTH]
        int k = LEVEL_HEIGHT - 1

        while not blockDefinitions[getTile(i, k, j)].blocksLight and k > 0
          k--

        lightDepths[i + j * LEVEL_WIDTH] = k

        if blocker != k
          int min = blocker < k ? blocker : k
          int max = blocker > k ? blocker : k

          game.levelRenderer.loadChunks(i, min, j)

  int getTile(int x, int y, int z)
    if isInBounds(x, y, z)
      return blocks[(z * LEVEL_HEIGHT + y) * LEVEL_WIDTH + x]
    return BLOCK_AIR

  int getRenderTile(int x, int y, int z)
    if x < 0 or y < 0 or z < 0 or x >= LEVEL_WIDTH or z >= LEVEL_DEPTH
      if y < waterLevel and y >= groundLevel
        return BLOCK_WATER

    if isInBounds(x, y, z)
      return blocks[(z * LEVEL_HEIGHT + y) * LEVEL_WIDTH + x]

    return BLOCK_AIR

  void updateTileDeferred(int x, int y, int z, bool deferred)
    if not isInBounds(x, y, z)
      return

    int blockType = getTile(x, y, z)

    if isMovingWaterTile(blockType) or isMovingLavaTile(blockType)
      if deferred
        updates.push(Int3(x, y, z))
      else
        if canFlood(x - 1, y, z, blockType)
          setTileWithNoNeighborChange(x - 1, y, z, blockType, false)
          updates.push(Int3(x - 1, y, z))
        else if (isLavaTile(x - 1, y, z) and isWaterTile(blockType)) or (isWaterTile(x - 1, y, z) and isLavaTile(blockType))
          setTileWithNoNeighborChange(x - 1, y, z, BLOCK_OBSIDIAN, false)

        if canFlood(x + 1, y, z, blockType)
          setTileWithNoNeighborChange(x + 1, y, z, blockType, false)
          updates.push(Int3(x + 1, y, z))
        else if (isLavaTile(x + 1, y, z) and isWaterTile(blockType)) or (isWaterTile(x + 1, y, z) and isLavaTile(blockType))
          setTileWithNoNeighborChange(x + 1, y, z, BLOCK_OBSIDIAN, false)

        if canFlood(x, y - 1, z, blockType)
          setTileWithNoNeighborChange(x, y - 1, z, blockType, false)
          updates.push(Int3(x, y - 1, z))
        else if (isLavaTile(x, y - 1, z) and isWaterTile(blockType)) or (isWaterTile(x, y - 1, z) and isLavaTile(blockType))
          setTileWithNoNeighborChange(x, y - 1, z, BLOCK_OBSIDIAN, false)

        if canFlood(x, y, z - 1, blockType)
          setTileWithNoNeighborChange(x, y, z - 1, blockType, false)
          updates.push(Int3(x, y, z - 1))
        else if (isLavaTile(x, y, z - 1) and isWaterTile(blockType)) or (isWaterTile(x, y, z - 1) and isLavaTile(blockType))
          setTileWithNoNeighborChange(x, y, z - 1, BLOCK_OBSIDIAN, false)

        if canFlood(x, y, z + 1, blockType)
          setTileWithNoNeighborChange(x, y, z + 1, blockType, false)
          updates.push(Int3(x, y, z + 1))
        else if (isLavaTile(x, y, z + 1) and isWaterTile(blockType)) or (isWaterTile(x, y, z + 1) and isLavaTile(blockType))
          setTileWithNoNeighborChange(x, y, z + 1, BLOCK_OBSIDIAN, false)
    else if blockType == BLOCK_SAND or blockType == BLOCK_GRAVEL
      int height = 1
      while blockDefinitions[getTile(x, y - height, z)].collide != COLLIDE_SOLID and isInBounds(x, y - height, z)
        height++

      if height > 1
        setTileWithNoNeighborChange(x, y - height + 1, z, blockType, false)
        setTileWithNeighborChange(x, y, z, BLOCK_AIR, false)

  void updateTile(int x, int y, int z)
    updateTileDeferred(x, y, z, false)

  bool setTileWithNeighborChange(int x, int y, int z, int blockType, bool mode)
    if setTileWithNoNeighborChange(x, y, z, blockType, mode)
      updateTileDeferred(x - 1, y, z, true)
      updateTileDeferred(x + 1, y, z, true)
      updateTileDeferred(x, y - 1, z, true)
      updateTileDeferred(x, y + 1, z, true)
      updateTileDeferred(x, y, z - 1, true)
      updateTileDeferred(x, y, z + 1, true)
      updateTileDeferred(x, y, z, true)

      return true

    return false

  void addedTile(int x, int y, int z, int blockType)
    if blockType == BLOCK_SPONGE
      for int i = x - 2; i <= x + 2; i++
        for int j = y - 2; j <= y + 2; j++
          for int k = z - 2; k <= z + 2; k++
            if isWaterTile(i, j, k)
              setTileWithNoNeighborChange(i, j, k, BLOCK_AIR, false)
              
    else if blockType == BLOCK_SLAB
      if getTile(x, y - 1, z) == BLOCK_SLAB
        setTileWithNoNeighborChange(x, y, z, BLOCK_AIR, false)
        setTileWithNoNeighborChange(x, y - 1, z, BLOCK_DOUBLE_SLAB, false)

  void removedTile(int x, int y, int z, int blockType)
    if blockType == BLOCK_SPONGE
      for int i = x - 3; i <= x + 3; i++
        for int j = y - 3; j <= y + 3; j++
          for int k = z - 3; k <= z + 3; k++
            updateTileDeferred(i, j, k, true)

  bool setTileWithNoNeighborChange(int x, int y, int z, int blockType, bool mode)
    if x < 0 or y < 0 or z < 0 or x >= LEVEL_WIDTH or y >= LEVEL_HEIGHT or z >= LEVEL_DEPTH
      return false

    int previousBlockType = getTile(x, y, z)
    if previousBlockType == blockType
      return false

    if x == 0 or z == 0 or x == LEVEL_WIDTH - 1 or z == LEVEL_DEPTH - 1
      if y >= groundLevel and y < waterLevel and blockType == BLOCK_AIR
        blockType = BLOCK_WATER

    setTile(x, y, z, blockType, mode)
    calculateLightDepths(x, z, 1, 1)

    game.levelRenderer.loadChunks(x, y, z)

    if previousBlockType != BLOCK_AIR
      removedTile(x, y, z, previousBlockType)

    if blockType != BLOCK_AIR
      addedTile(x, y, z, blockType)

    return true

  void setTile(int x, int y, int z, int blockType, bool mode)
    if isInBounds(x, y, z)
      blocks[(z * LEVEL_HEIGHT + y) * LEVEL_WIDTH + x] = (char)blockType

  bool isInBounds(int x, int y, int z)
    return x >= 0 and y >= 0 and z >= 0 and x < LEVEL_WIDTH and y < LEVEL_HEIGHT and z < LEVEL_DEPTH

  bool isAirTile(int x, int y, int z)
    int blockType = getTile(x, y, z)
    return blockType == BLOCK_AIR

  bool isAirTile(int blockType)
    return blockType == BLOCK_AIR

  bool isRenderWaterTile(float x, float y, float z)
    if x < 0.0 or y < 0.0 or z < 0.0 or x >= (float)LEVEL_WIDTH or z >= (float)LEVEL_DEPTH
      if y < (float)waterLevel and y > (float)groundLevel
        return true

    int blockType = getTile((int)x, (int)y, (int)z)
    return blockType == BLOCK_WATER or blockType == BLOCK_STILL_WATER

  bool isWaterTile(int x, int y, int z)
    int blockType = getTile(x, y, z)
    return blockType == BLOCK_WATER or blockType == BLOCK_STILL_WATER

  bool isWaterTile(int blockType)
    return blockType == BLOCK_WATER or blockType == BLOCK_STILL_WATER

  bool isMovingWaterTile(int x, int y, int z)
    int blockType = getTile(x, y, z)
    return blockType == BLOCK_WATER

  bool isMovingWaterTile(int blockType)
    return blockType == BLOCK_WATER

  bool isLavaTile(float x, float y, float z)
    int blockType = getTile((int)x, (int)y, (int)z)
    return blockType == BLOCK_LAVA or blockType == BLOCK_STILL_LAVA

  bool isMovingLavaTile(int x, int y, int z)
    int blockType = getTile(x, y, z)
    return blockType == BLOCK_LAVA

  bool isMovingLavaTile(int blockType)
    return blockType == BLOCK_LAVA

  bool isLavaTile(int x, int y, int z)
    int blockType = getTile(x, y, z)
    return blockType == BLOCK_LAVA or blockType == BLOCK_STILL_LAVA

  bool isLavaTile(int blockType)
    return blockType == BLOCK_LAVA or blockType == BLOCK_STILL_LAVA

  AABBPosition clip(Vector3 start, Vector3 end)
    return clip(
      start,
      end,
      Int3(0, 0, 0),
      false
    )

  AABBPosition clip(
    Vector3 start,
    Vector3 end,
    Int3 expected
  )
    return clip(start, end, expected, true)

  AABBPosition clip(
    Vector3 start,
    Vector3 end,
    Int3 expected,
    bool hasExpected
  )
    start = start.clone()
    end = end.clone()

    AABBPosition aabbPosition = AABBPosition()
    aabbPosition.isValid = false

    int ITERATIONS = 20

    int startBlockX = (int)start.x
    int startBlockY = (int)start.y
    int startBlockZ = (int)start.z
    int endBlockX = (int)end.x
    int endBlockY = (int)end.y
    int endBlockZ = (int)end.z

    int i = ITERATIONS
    bool exitLoop = false
    while not exitLoop
      if startBlockX == endBlockX and startBlockY == endBlockY and startBlockZ == endBlockZ
        break

      if i < ITERATIONS
        Vector3 nextIntersection = Vector3(999.0, 999.0, 999.0)
        Vector3 intersectionDistances = Vector3(999.0, 999.0, 999.0)
        Vector3 movementVector = end - start

        if endBlockX > startBlockX
          nextIntersection.x = (float)startBlockX + 1.0
        if endBlockX < startBlockX
          nextIntersection.x = (float)startBlockX
        if endBlockY > startBlockY
          nextIntersection.y = (float)startBlockY + 1.0
        if endBlockY < startBlockY
          nextIntersection.y = (float)startBlockY
        if endBlockZ > startBlockZ
          nextIntersection.z = (float)startBlockZ + 1.0
        if endBlockZ < startBlockZ
          nextIntersection.z = (float)startBlockZ

        if nextIntersection.x != 999.0
          intersectionDistances.x = (nextIntersection.x - start.x) / movementVector.x
        if nextIntersection.y != 999.0
          intersectionDistances.y = (nextIntersection.y - start.y) / movementVector.y
        if nextIntersection.z != 999.0
          intersectionDistances.z = (nextIntersection.z - start.z) / movementVector.z

        int axisOfLeastPenetration = 0
        if intersectionDistances.x < intersectionDistances.y and intersectionDistances.x < intersectionDistances.z
          axisOfLeastPenetration = endBlockX > startBlockX ? 4 : 5
          start.x = nextIntersection.x
          start.y = start.y + movementVector.y * intersectionDistances.x
          start.z = start.z + movementVector.z * intersectionDistances.x
        else if intersectionDistances.y < intersectionDistances.z
          axisOfLeastPenetration = endBlockY > startBlockY ? 0 : 1
          start.y = nextIntersection.y
          start.x = start.x + movementVector.x * intersectionDistances.y
          start.z = start.z + movementVector.z * intersectionDistances.y
        else
          axisOfLeastPenetration = endBlockZ > startBlockZ ? 2 : 3
          start.z = nextIntersection.z
          start.x = start.x + movementVector.x * intersectionDistances.z
          start.y = start.y + movementVector.y * intersectionDistances.z

        startBlockX = (int)start.x
        startBlockY = (int)start.y
        startBlockZ = (int)start.z

        if axisOfLeastPenetration == 5
          startBlockX--
        if axisOfLeastPenetration == 1
          startBlockY--
        if axisOfLeastPenetration == 3
          startBlockZ--

      int blockType = getTile(startBlockX, startBlockY, startBlockZ)
      Definition blockDefinition = blockDefinitions[blockType]
      AABB blockAABB = blockDefinition.boundingBox

      if hasExpected
        if blockType == BLOCK_AIR or blockDefinition.collide == COLLIDE_LIQUID
          for int x = -1; x != 2; x++
            for int z = -1; z != 2; z++
              Int3 neighbor = Int3(startBlockX + x, startBlockY, startBlockZ + z)

              if neighbor == expected
                aabbPosition.x = neighbor.x
                aabbPosition.y = neighbor.y
                aabbPosition.z = neighbor.z
                aabbPosition.index = (aabbPosition.z * LEVEL_HEIGHT + aabbPosition.y) * LEVEL_WIDTH + aabbPosition.x
                aabbPosition.vector = aabbPosition.vector + Vector3((float)neighbor.x, (float)neighbor.y, (float)neighbor.z)
                aabbPosition.destructible = false
                aabbPosition.isValid = true

                if x == 0
                  if z == 1
                    aabbPosition.face = 2
                  else
                    aabbPosition.face = 3
                else if z == 0
                  if x == 1
                    aabbPosition.face = 4
                  else
                    aabbPosition.face = 5
                else
                  aabbPosition.isValid = false

                return aabbPosition
      else
        if blockType != BLOCK_AIR and blockDefinition.collide != COLLIDE_LIQUID
          Vector3 origin = Vector3((float)startBlockX, (float)startBlockY, (float)startBlockZ)

          aabbPosition = blockAABB.clip(start - origin, end - origin)
          if aabbPosition.isValid
            aabbPosition.x = (int)origin.x
            aabbPosition.y = (int)origin.y
            aabbPosition.z = (int)origin.z
            aabbPosition.index = (aabbPosition.z * LEVEL_HEIGHT + aabbPosition.y) * LEVEL_WIDTH + aabbPosition.x
            aabbPosition.vector = aabbPosition.vector + origin
            aabbPosition.destructible = true

            return aabbPosition

      if i >= 0
        i--
      else
        exitLoop = true

    return aabbPosition
