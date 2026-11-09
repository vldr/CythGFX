import "game.cy"

int SELECTED_BLOCK_VERTEX_COUNT = 24

class SelectedBlock
  int vao
  int buffer
  int texture

  void init()
    texture = game.textureManager.loadColor(0.0, 0.0, 0.0)

    vao = createVertexArray()
    bindVertexArray(vao)

    buffer = createArrayBuffer()
    bindArrayBuffer(buffer)

    setVertexAttribute(game.positionAttribute, 3, 12, 0)
    setVertexAttribute(game.uvAttribute, 0.0, 1.0)
    setVertexAttribute(game.shadeAttribute, 0.0)

    float[] vertices
    vertices.reserve(SELECTED_BLOCK_VERTEX_COUNT * 3)

    setArrayBufferData(buffer, vertices, SELECTED_BLOCK_VERTEX_COUNT * 3)

  void rebuild(AABB aabb)
    float[] vertices = [
      aabb.x0, aabb.y0, aabb.z0,
      aabb.x0, aabb.y0, aabb.z1,
      aabb.x1, aabb.y0, aabb.z0,
      aabb.x1, aabb.y0, aabb.z1,
      aabb.x0, aabb.y1, aabb.z0,
      aabb.x0, aabb.y1, aabb.z1,
      aabb.x1, aabb.y1, aabb.z0,
      aabb.x1, aabb.y1, aabb.z1,
      aabb.x0, aabb.y0, aabb.z0,
      aabb.x1, aabb.y0, aabb.z0,
      aabb.x0, aabb.y0, aabb.z1,
      aabb.x1, aabb.y0, aabb.z1,
      aabb.x0, aabb.y1, aabb.z0,
      aabb.x1, aabb.y1, aabb.z0,
      aabb.x0, aabb.y1, aabb.z1,
      aabb.x1, aabb.y1, aabb.z1,
      aabb.x0, aabb.y0, aabb.z0,
      aabb.x0, aabb.y1, aabb.z0,
      aabb.x1, aabb.y0, aabb.z0,
      aabb.x1, aabb.y1, aabb.z0,
      aabb.x1, aabb.y0, aabb.z1,
      aabb.x1, aabb.y1, aabb.z1,
      aabb.x0, aabb.y0, aabb.z1,
      aabb.x0, aabb.y1, aabb.z1,
    ]

    bindArrayBuffer(buffer)
    updateArrayBufferData(
      buffer,
      vertices,
      SELECTED_BLOCK_VERTEX_COUNT * 3
    )

  void renderPost()
    if not game.localPlayer.selected.isValid
      return

    int blockType = game.level.getTile(game.localPlayer.selected.x, game.localPlayer.selected.y, game.localPlayer.selected.z)
    if blockType == BLOCK_AIR
      return

    setTexture(texture)
    bindVertexArray(vao)

    if game.localPlayer.selectedIndex != game.localPlayer.selected.index
      AABB aabb = blockDefinitions[blockType].boundingBox
      aabb = aabb.move((float)game.localPlayer.selected.x, (float)game.localPlayer.selected.y, (float)game.localPlayer.selected.z)
      aabb = aabb.grow(0.002, 0.002, 0.002)

      rebuild(aabb)

      game.localPlayer.selectedIndex = game.localPlayer.selected.index

    drawVertexArrayLines(SELECTED_BLOCK_VERTEX_COUNT)
