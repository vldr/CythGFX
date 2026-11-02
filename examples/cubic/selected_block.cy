import "game.cy"

int SELECTED_BLOCK_VERTEX_COUNT = 24

class SelectedBlock
  TextureManager textureManager

  int vao
  int buffer
  int texture
  int cachedIndex
  float[] vertices

  void __init__()
    textureManager = TextureManager()

    vao = 0
    buffer = 0
    texture = 0
    cachedIndex = -1
    vertices.reserve(SELECTED_BLOCK_VERTEX_COUNT * 3)

  void init()
    texture = textureManager.loadColor(0.0, 0.0, 0.0)

    vao = createVertexArray()
    bindVertexArray(vao)

    buffer = createArrayBuffer()
    bindArrayBuffer(buffer)

    setArrayBufferData(buffer, vertices, SELECTED_BLOCK_VERTEX_COUNT * 3)
    setVertexAttribute(game.positionAttribute, 3, 12, 0)
    setVertexAttribute(game.uvAttribute, 0.0, 1.0)
    setVertexAttribute(game.shadeAttribute, 0.0)

  void setVertex(int index, float x, float y, float z)
    int offset = index * 3
    vertices[offset] = x
    vertices[offset + 1] = y
    vertices[offset + 2] = z

  void rebuild(AABB box)
    setVertex(0, box.x0, box.y0, box.z0)
    setVertex(1, box.x0, box.y0, box.z1)
    setVertex(2, box.x1, box.y0, box.z0)
    setVertex(3, box.x1, box.y0, box.z1)

    setVertex(4, box.x0, box.y1, box.z0)
    setVertex(5, box.x0, box.y1, box.z1)
    setVertex(6, box.x1, box.y1, box.z0)
    setVertex(7, box.x1, box.y1, box.z1)

    setVertex(8, box.x0, box.y0, box.z0)
    setVertex(9, box.x1, box.y0, box.z0)
    setVertex(10, box.x0, box.y0, box.z1)
    setVertex(11, box.x1, box.y0, box.z1)

    setVertex(12, box.x0, box.y1, box.z0)
    setVertex(13, box.x1, box.y1, box.z0)
    setVertex(14, box.x0, box.y1, box.z1)
    setVertex(15, box.x1, box.y1, box.z1)

    setVertex(16, box.x0, box.y0, box.z0)
    setVertex(17, box.x0, box.y1, box.z0)
    setVertex(18, box.x1, box.y0, box.z0)
    setVertex(19, box.x1, box.y1, box.z0)

    setVertex(20, box.x1, box.y0, box.z1)
    setVertex(21, box.x1, box.y1, box.z1)
    setVertex(22, box.x0, box.y0, box.z1)
    setVertex(23, box.x0, box.y1, box.z1)

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

    if cachedIndex != game.localPlayer.selected.index
      AABB box = blockDefinitions[blockType].boundingBox.move((float)game.localPlayer.selected.x, (float)game.localPlayer.selected.y, (float)game.localPlayer.selected.z)
      box = box.grow(0.002, 0.002, 0.002)
      rebuild(box)

      cachedIndex = game.localPlayer.selected.index
      game.localPlayer.selectedIndex = cachedIndex

    drawVertexArrayLines(SELECTED_BLOCK_VERTEX_COUNT)
