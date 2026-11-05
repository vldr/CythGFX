import "game.cy"

int CHUNK_SIZE = 16

int FACE_TOP = 0
int FACE_BOTTOM = 1
int FACE_FRONT = 2
int FACE_BACK = 3
int FACE_LEFT = 4
int FACE_RIGHT = 5

float[] verticesData
verticesData.reserve(1024)

float[] waterVerticesData
waterVerticesData.reserve(1024)

class Chunk
  Int3 position

  bool isVisible
  bool isLoaded

  VertexList vertices
  VertexList waterVertices

  void __init__( int x, int y, int z)
    vertices = VertexList()
    waterVertices = VertexList()
    position = Int3(x, y, z)
    isVisible = false
    isLoaded = false

    vertices.init(verticesData)
    waterVertices.init(waterVerticesData)

  bool isLiquid(int blockType)
    return blockDefinitions[blockType].collide == COLLIDE_LIQUID

  bool shouldRenderFace(int faceType, int x, int y, int z)
    int blockType = game.level.getRenderTile(x, y, z)
    Definition blockDefinition = blockDefinitions[blockType]

    int adjacentType
    if faceType == FACE_RIGHT
      adjacentType = game.level.getRenderTile(x + 1, y, z)
    else if faceType == FACE_LEFT
      adjacentType = game.level.getRenderTile(x - 1, y, z)
    else if faceType == FACE_TOP
      adjacentType = game.level.getRenderTile(x, y + 1, z)
    else if faceType == FACE_BOTTOM
      adjacentType = game.level.getRenderTile(x, y - 1, z)
    else if faceType == FACE_FRONT
      adjacentType = game.level.getRenderTile(x, y, z + 1)
    else
      adjacentType = game.level.getRenderTile(x, y, z - 1)

    Definition adjacent = blockDefinitions[adjacentType]

    if blockDefinition.draw == DRAW_OPAQUE
      if adjacent.draw == DRAW_OPAQUE
        return false
      else if adjacent.draw == DRAW_OPAQUE_SMALL
        return faceType != FACE_TOP
      else if adjacent.draw == DRAW_TRANSPARENT or adjacent.draw == DRAW_TRANSPARENT_THICK or adjacent.draw == DRAW_TRANSLUCENT or adjacent.draw == DRAW_GAS or adjacent.draw == DRAW_SPRITE
        return true

    else if blockDefinition.draw == DRAW_OPAQUE_SMALL
      if adjacent.draw == DRAW_OPAQUE
        return faceType == FACE_TOP
      else if adjacent.draw == DRAW_OPAQUE_SMALL
        return faceType == FACE_TOP or faceType == FACE_BOTTOM
      else if adjacent.draw == DRAW_TRANSPARENT or adjacent.draw == DRAW_TRANSPARENT_THICK or adjacent.draw == DRAW_TRANSLUCENT or adjacent.draw == DRAW_GAS or adjacent.draw == DRAW_SPRITE
        return true

    else if blockDefinition.draw == DRAW_TRANSPARENT_THICK
      return adjacent.draw != DRAW_OPAQUE

    else if blockDefinition.draw == DRAW_TRANSLUCENT or blockDefinition.draw == DRAW_TRANSPARENT
      if adjacent.draw == blockDefinition.draw and adjacentType == blockType
        return false

      else if adjacent.draw == DRAW_OPAQUE
        if faceType == FACE_TOP and blockDefinition.collide == COLLIDE_LIQUID
          int[] offsetsX = [0, 0, -1, 1, 1, 1, -1, -1]
          int[] offsetsZ = [1, -1, 0, 0, 1, -1, 1, -1]

          for int i; i < 8; i++
            int px = x + offsetsX[i]
            int pz = z + offsetsZ[i]

            if not game.level.isInBounds(px, y, pz)
              continue

            int topType = game.level.getRenderTile(px, y + 1, pz)
            int bottomType = game.level.getRenderTile(px, y, pz)

            Definition top = blockDefinitions[topType]
            Definition bottom = blockDefinitions[bottomType]

            if bottomType != topType and bottom.draw != DRAW_OPAQUE and top.draw != DRAW_OPAQUE and top.draw != DRAW_OPAQUE_SMALL
              return true

        return false

      else
        return true

    return false

  float faceBrightness(int faceType, int x, int y, int z, int blockType)
    if game.level.isLavaTile(blockType)
      return game.level.getTileBrightness(x, y, z)

    if faceType == FACE_TOP
      return game.level.getTileBrightness(x, y + 1, z)
    if faceType == FACE_BOTTOM
      return game.level.getTileBrightness(x, y - 1, z)
    if faceType == FACE_FRONT
      return game.level.getTileBrightness(x, y, z + 1)
    if faceType == FACE_BACK
      return game.level.getTileBrightness(x, y, z - 1)
    if faceType == FACE_RIGHT
      return game.level.getTileBrightness(x + 1, y, z)

    return game.level.getTileBrightness(x - 1, y, z)

  bool mirrorFace(int faceType, int x, int y, int z, Definition definition)
    if definition.collide != COLLIDE_LIQUID
      return false

    if faceType == FACE_TOP
      return game.level.isInBounds(x, y + 1, z)
    if faceType == FACE_BOTTOM
      return game.level.isInBounds(x, y - 1, z)
    if faceType == FACE_FRONT
      return game.level.isInBounds(x, y, z + 1)
    if faceType == FACE_BACK
      return game.level.isInBounds(x, y, z - 1)
    if faceType == FACE_RIGHT
      return game.level.isInBounds(x + 1, y, z)

    return game.level.isInBounds(x - 1, y, z)

  float faceShift(int faceType, int x, int y, int z, int blockType, Definition definition)
    if definition.collide != COLLIDE_LIQUID
      return 0.0

    if faceType == FACE_FRONT and blockType == game.level.getRenderTile(x, y - 1, z + 1)
      return -0.1
    if faceType == FACE_BACK and blockType == game.level.getRenderTile(x, y - 1, z - 1)
      return -0.1
    if faceType == FACE_RIGHT and blockType == game.level.getRenderTile(x + 1, y - 1, z)
      return -0.1
    if faceType == FACE_LEFT and blockType == game.level.getRenderTile(x - 1, y - 1, z)
      return -0.1

    return 0.0

  void emitTop(VertexList list, int x, int y, int z, Definition definition, float height, float brightness, bool mirror)
    float u = 0.0625 * (float)(definition.topTexture % 16)
    float v = 0.0625 * (float)(definition.topTexture / 16)
    float u2 = u + 0.0625
    float v2 = v + 0.0625
    float fy = (float)y + height

    list.push((float)x, fy, (float)z, u, v, brightness)
    list.push((float)x, fy, (float)z + 1.0, u, v2, brightness)
    list.push((float)x + 1.0, fy, (float)z + 1.0, u2, v2, brightness)

    list.push((float)x, fy, (float)z, u, v, brightness)
    list.push((float)x + 1.0, fy, (float)z + 1.0, u2, v2, brightness)
    list.push((float)x + 1.0, fy, (float)z, u2, v, brightness)

    if mirror
      list.push((float)x, fy, (float)z + 1.0, u, v, brightness)
      list.push((float)x, fy, (float)z, u, v2, brightness)
      list.push((float)x + 1.0, fy, (float)z, u2, v2, brightness)

      list.push((float)x, fy, (float)z + 1.0, u, v, brightness)
      list.push((float)x + 1.0, fy, (float)z, u2, v2, brightness)
      list.push((float)x + 1.0, fy, (float)z + 1.0, u2, v, brightness)

  void emitBottom(VertexList list, int x, int y, int z, Definition definition, float brightness, bool mirror)
    float u = 0.0625 * (float)(definition.bottomTexture % 16)
    float v = 0.0625 * (float)(definition.bottomTexture / 16)
    float u2 = u + 0.0625
    float v2 = v + 0.0625
    float shade = brightness * 0.5

    list.push((float)x, (float)y, (float)z + 1.0, u, v, shade)
    list.push((float)x, (float)y, (float)z, u, v2, shade)
    list.push((float)x + 1.0, (float)y, (float)z, u2, v2, shade)

    list.push((float)x, (float)y, (float)z + 1.0, u, v, shade)
    list.push((float)x + 1.0, (float)y, (float)z, u2, v2, shade)
    list.push((float)x + 1.0, (float)y, (float)z + 1.0, u2, v, shade)

    if mirror
      list.push((float)x, (float)y, (float)z, u, v, brightness)
      list.push((float)x, (float)y, (float)z + 1.0, u, v2, brightness)
      list.push((float)x + 1.0, (float)y, (float)z + 1.0, u2, v2, brightness)

      list.push((float)x, (float)y, (float)z, u, v, brightness)
      list.push((float)x + 1.0, (float)y, (float)z + 1.0, u2, v2, brightness)
      list.push((float)x + 1.0, (float)y, (float)z, u2, v, brightness)

  void emitFrontBack(VertexList list, int faceType, int x, int y, int z, Definition definition, float height, float shift, float brightness, bool mirror)
    float u = 0.0625 * (float)(definition.sideTexture % 16)
    float v = 0.0625 * (float)(definition.sideTexture / 16)
    float u2 = u + 0.0625
    float v2 = v + height * 0.0625
    float shade = brightness * 0.8
    float low = (float)y + shift
    float high = (float)y + height

    if faceType == FACE_FRONT
      float pz = (float)z + 1.0

      list.push((float)x, high, pz, u, v, shade)
      list.push((float)x, low, pz, u, v2, shade)
      list.push((float)x + 1.0, low, pz, u2, v2, shade)

      list.push((float)x, high, pz, u, v, shade)
      list.push((float)x + 1.0, low, pz, u2, v2, shade)
      list.push((float)x + 1.0, high, pz, u2, v, shade)

      if mirror
        list.push((float)x + 1.0, high, pz, u, v, shade)
        list.push((float)x + 1.0, low, pz, u, v2, shade)
        list.push((float)x, low, pz, u2, v2, shade)

        list.push((float)x + 1.0, high, pz, u, v, shade)
        list.push((float)x, low, pz, u2, v2, shade)
        list.push((float)x, high, pz, u2, v, shade)
    else
      float pz = (float)z

      list.push((float)x + 1.0, high, pz, u, v, shade)
      list.push((float)x + 1.0, low, pz, u, v2, shade)
      list.push((float)x, low, pz, u2, v2, shade)

      list.push((float)x + 1.0, high, pz, u, v, shade)
      list.push((float)x, low, pz, u2, v2, shade)
      list.push((float)x, high, pz, u2, v, shade)

      if mirror
        list.push((float)x, high, pz, u, v, shade)
        list.push((float)x, low, pz, u, v2, shade)
        list.push((float)x + 1.0, low, pz, u2, v2, shade)

        list.push((float)x, high, pz, u, v, shade)
        list.push((float)x + 1.0, low, pz, u2, v2, shade)
        list.push((float)x + 1.0, high, pz, u2, v, shade)

  void emitLeftRight(VertexList list, int faceType, int x, int y, int z, Definition definition, float height, float shift, float brightness, bool mirror)
    float u = 0.0625 * (float)(definition.sideTexture % 16)
    float v = 0.0625 * (float)(definition.sideTexture / 16)
    float u2 = u + 0.0625
    float v2 = v + height * 0.0625
    float shade = brightness * 0.6
    float low = (float)y + shift
    float high = (float)y + height

    if faceType == FACE_RIGHT
      float px = (float)x + 1.0

      list.push(px, high, (float)z + 1.0, u, v, shade)
      list.push(px, low, (float)z + 1.0, u, v2, shade)
      list.push(px, low, (float)z, u2, v2, shade)

      list.push(px, high, (float)z + 1.0, u, v, shade)
      list.push(px, low, (float)z, u2, v2, shade)
      list.push(px, high, (float)z, u2, v, shade)

      if mirror
        list.push(px, high, (float)z, u, v, shade)
        list.push(px, low, (float)z, u, v2, shade)
        list.push(px, low, (float)z + 1.0, u2, v2, shade)

        list.push(px, high, (float)z, u, v, shade)
        list.push(px, low, (float)z + 1.0, u2, v2, shade)
        list.push(px, high, (float)z + 1.0, u2, v, shade)
    else
      float px = (float)x

      list.push(px, high, (float)z, u, v, shade)
      list.push(px, low, (float)z, u, v2, shade)
      list.push(px, low, (float)z + 1.0, u2, v2, shade)

      list.push(px, high, (float)z, u, v, shade)
      list.push(px, low, (float)z + 1.0, u2, v2, shade)
      list.push(px, high, (float)z + 1.0, u2, v, shade)

      if mirror
        list.push(px, high, (float)z + 1.0, u, v, shade)
        list.push(px, low, (float)z + 1.0, u, v2, shade)
        list.push(px, low, (float)z, u2, v2, shade)

        list.push(px, high, (float)z + 1.0, u, v, shade)
        list.push(px, low, (float)z, u2, v2, shade)
        list.push(px, high, (float)z, u2, v, shade)

  void emitSprite(int x, int y, int z, Definition definition)
    float u = 0.0625 * (float)(definition.sideTexture % 16)
    float v = 0.0625 * (float)(definition.sideTexture / 16) + 0.0625 - 0.0625 * definition.height
    float u2 = u + 0.0625
    float v2 = v + 0.0625

    float x0 = (float)x
    float x1 = x0 + 1.0
    float y0 = (float)y
    float y1 = y0 + 1.0
    float z0 = (float)z
    float z1 = z0 + 1.0

    vertices.push(x0, y1, z0, u, v, 1.0)
    vertices.push(x0, y0, z0, u, v2, 1.0)
    vertices.push(x1, y0, z1, u2, v2, 1.0)
    vertices.push(x0, y1, z0, u, v, 1.0)
    vertices.push(x1, y0, z1, u2, v2, 1.0)
    vertices.push(x1, y1, z1, u2, v, 1.0)

    vertices.push(x0, y1, z1, u, v, 1.0)
    vertices.push(x0, y0, z1, u, v2, 1.0)
    vertices.push(x1, y0, z0, u2, v2, 1.0)
    vertices.push(x0, y1, z1, u, v, 1.0)
    vertices.push(x1, y0, z0, u2, v2, 1.0)
    vertices.push(x1, y1, z0, u2, v, 1.0)

    vertices.push(x1, y1, z1, u, v, 1.0)
    vertices.push(x1, y0, z1, u, v2, 1.0)
    vertices.push(x0, y0, z0, u2, v2, 1.0)
    vertices.push(x1, y1, z1, u, v, 1.0)
    vertices.push(x0, y0, z0, u2, v2, 1.0)
    vertices.push(x0, y1, z0, u2, v, 1.0)

    vertices.push(x1, y1, z0, u, v, 1.0)
    vertices.push(x1, y0, z0, u, v2, 1.0)
    vertices.push(x0, y0, z1, u2, v2, 1.0)
    vertices.push(x1, y1, z0, u, v, 1.0)
    vertices.push(x0, y0, z1, u2, v2, 1.0)
    vertices.push(x0, y1, z1, u2, v, 1.0)

  void emitFace(int faceType, int x, int y, int z, int blockType, Definition definition)
    float height = definition.height
    if definition.collide == COLLIDE_LIQUID and shouldRenderFace(FACE_TOP, x, y, z) 
      height = 0.9

    float brightness = faceBrightness(faceType, x, y, z, blockType)
    float shift = faceShift(faceType, x, y, z, blockType, definition)
    bool mirror = mirrorFace(faceType, x, y, z, definition)
    VertexList list = game.level.isWaterTile(blockType) ? waterVertices : vertices

    if faceType == FACE_TOP
      emitTop(list, x, y, z, definition, height, brightness, mirror)
    else if faceType == FACE_BOTTOM
      emitBottom(list, x, y, z, definition, brightness, mirror)
    else if faceType == FACE_FRONT or faceType == FACE_BACK
      emitFrontBack(list, faceType, x, y, z, definition, height, shift, brightness, mirror)
    else
      emitLeftRight(list, faceType, x, y, z, definition, height, shift, brightness, mirror)

  void update()
    vertices.reset()
    waterVertices.reset()

    for int x = position.x; x < position.x + CHUNK_SIZE; x++
      for int y = position.y; y < position.y + CHUNK_SIZE; y++
        for int z = position.z; z < position.z + CHUNK_SIZE; z++
          int blockType = game.level.getRenderTile(x, y, z)
          if blockType != BLOCK_AIR
            Definition definition = blockDefinitions[blockType]

            if definition.draw == DRAW_SPRITE
              emitSprite(x, y, z, definition)
            else
              for int faceType; faceType < 6; faceType++
                if shouldRenderFace(faceType, x, y, z)
                  emitFace(faceType, x, y, z, blockType, definition)

    vertices.update()
    waterVertices.update()
    isLoaded = true

  void render()
    vertices.render()

  void renderWater()
    waterVertices.render()

  float distanceToPlayer()
    float distanceX = game.localPlayer.entity.position.x - ((float)position.x + (float)CHUNK_SIZE / 2.0)
    float distanceY = game.localPlayer.entity.position.y - ((float)position.y + (float)CHUNK_SIZE / 2.0)
    float distanceZ = game.localPlayer.entity.position.z - ((float)position.z + (float)CHUNK_SIZE / 2.0)

    return distanceX * distanceX + distanceY * distanceY + distanceZ * distanceZ
