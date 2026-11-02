import "game.cy"

class HeldBlock
  VertexList vertices

  float height
  float lastHeight

  int swingOffset
  bool isSwinging

  void __init__()
    vertices = VertexList()

    height = 1.0
    lastHeight = 1.0
    swingOffset = 0
    isSwinging = false

    vertices.init(36)
    update()

  void emitSprite(Definition definition)
    float u = 0.0625 * (float)(definition.sideTexture % 16)
    float v = 0.0625 * (float)(definition.sideTexture / 16)
    v += 0.0625 - 0.0625 * definition.height

    float u2 = u + 0.0625
    float v2 = v + 0.0625

    vertices.push(0.0, 1.5, 0.0, u, v, 1.0)
    vertices.push(0.0, 0.5, 0.0, u, v2, 1.0)
    vertices.push(1.0, 0.5, 1.0, u2, v2, 1.0)
    vertices.push(0.0, 1.5, 0.0, u, v, 1.0)
    vertices.push(1.0, 0.5, 1.0, u2, v2, 1.0)
    vertices.push(1.0, 1.5, 1.0, u2, v, 1.0)

    vertices.push(0.0, 1.5, 1.0, u, v, 1.0)
    vertices.push(0.0, 0.5, 1.0, u, v2, 1.0)
    vertices.push(1.0, 0.5, 0.0, u2, v2, 1.0)
    vertices.push(0.0, 1.5, 1.0, u, v, 1.0)
    vertices.push(1.0, 0.5, 0.0, u2, v2, 1.0)
    vertices.push(1.0, 1.5, 0.0, u2, v, 1.0)

    vertices.push(1.0, 1.5, 1.0, u, v, 1.0)
    vertices.push(1.0, 0.5, 1.0, u, v2, 1.0)
    vertices.push(0.0, 0.5, 0.0, u2, v2, 1.0)
    vertices.push(1.0, 1.5, 1.0, u, v, 1.0)
    vertices.push(0.0, 0.5, 0.0, u2, v2, 1.0)
    vertices.push(0.0, 1.5, 0.0, u2, v, 1.0)

    vertices.push(1.0, 1.5, 0.0, u, v, 1.0)
    vertices.push(1.0, 0.5, 0.0, u, v2, 1.0)
    vertices.push(0.0, 0.5, 1.0, u2, v2, 1.0)
    vertices.push(1.0, 1.5, 0.0, u, v, 1.0)
    vertices.push(0.0, 0.5, 1.0, u2, v2, 1.0)
    vertices.push(0.0, 1.5, 1.0, u2, v, 1.0)

  void emitCube(Definition definition)
    float uTop = 0.0625 * (float)(definition.topTexture % 16)
    float vTop = 0.0625 * (float)(definition.topTexture / 16)
    float uTop2 = uTop + 0.0625
    float vTop2 = vTop + 0.0625

    float uBottom = 0.0625 * (float)(definition.bottomTexture % 16)
    float vBottom = 0.0625 * (float)(definition.bottomTexture / 16)
    float uBottom2 = uBottom + 0.0625
    float vBottom2 = vBottom + 0.0625

    float u = 0.0625 * (float)(definition.sideTexture % 16)
    float v = 0.0625 * (float)(definition.sideTexture / 16)
    v += 0.0625 - 0.0625 * definition.height

    float u2 = u + 0.0625
    float v2 = 0.0625 + 0.0625 * (float)(definition.sideTexture / 16)
    float h = definition.height

    vertices.push(0.0, h, 0.0, uTop, vTop, 1.0)
    vertices.push(0.0, h, 1.0, uTop, vTop2, 1.0)
    vertices.push(1.0, h, 1.0, uTop2, vTop2, 1.0)
    vertices.push(0.0, h, 0.0, uTop, vTop, 1.0)
    vertices.push(1.0, h, 1.0, uTop2, vTop2, 1.0)
    vertices.push(1.0, h, 0.0, uTop2, vTop, 1.0)

    vertices.push(0.0, 0.0, 1.0, uBottom, vBottom, 0.5)
    vertices.push(0.0, 0.0, 0.0, uBottom, vBottom2, 0.5)
    vertices.push(1.0, 0.0, 0.0, uBottom2, vBottom2, 0.5)
    vertices.push(0.0, 0.0, 1.0, uBottom, vBottom, 0.5)
    vertices.push(1.0, 0.0, 0.0, uBottom2, vBottom2, 0.5)
    vertices.push(1.0, 0.0, 1.0, uBottom2, vBottom, 0.5)

    vertices.push(0.0, h, 1.0, u, v, 0.8)
    vertices.push(0.0, 0.0, 1.0, u, v2, 0.8)
    vertices.push(1.0, 0.0, 1.0, u2, v2, 0.8)
    vertices.push(0.0, h, 1.0, u, v, 0.8)
    vertices.push(1.0, 0.0, 1.0, u2, v2, 0.8)
    vertices.push(1.0, h, 1.0, u2, v, 0.8)

    vertices.push(1.0, h, 0.0, u, v, 0.8)
    vertices.push(1.0, 0.0, 0.0, u, v2, 0.8)
    vertices.push(0.0, 0.0, 0.0, u2, v2, 0.8)
    vertices.push(1.0, h, 0.0, u, v, 0.8)
    vertices.push(0.0, 0.0, 0.0, u2, v2, 0.8)
    vertices.push(0.0, h, 0.0, u2, v, 0.8)

    vertices.push(1.0, h, 1.0, u, v, 0.6)
    vertices.push(1.0, 0.0, 1.0, u, v2, 0.6)
    vertices.push(1.0, 0.0, 0.0, u2, v2, 0.6)
    vertices.push(1.0, h, 1.0, u, v, 0.6)
    vertices.push(1.0, 0.0, 0.0, u2, v2, 0.6)
    vertices.push(1.0, h, 0.0, u2, v, 0.6)

    vertices.push(0.0, h, 0.0, u, v, 0.6)
    vertices.push(0.0, 0.0, 0.0, u, v2, 0.6)
    vertices.push(0.0, 0.0, 1.0, u2, v2, 0.6)
    vertices.push(0.0, h, 0.0, u, v, 0.6)
    vertices.push(0.0, 0.0, 1.0, u2, v2, 0.6)
    vertices.push(0.0, h, 1.0, u2, v, 0.6)

  void update()
    int blockType = game.localPlayer.heldBlockType()
    Definition definition = blockDefinitions[blockType]

    if definition.draw == DRAW_SPRITE
      emitSprite(definition)
    else
      emitCube(definition)

    vertices.update()
    reset()

  void swing()
    swingOffset = 0
    isSwinging = true

  void reset()
    height = 0.0

  void tick()
    lastHeight = height

    float deltaHeight = 1.0 - height
    deltaHeight = clampf(deltaHeight, -0.4, 0.4)
    height += deltaHeight

    if isSwinging
      swingOffset++

      if swingOffset == 7
        swingOffset = 0
        isSwinging = false

  void render()
    float renderHeight = lastHeight + (height - lastHeight) * game.timer.delta
    float walk = game.localPlayer.entity.walkDistance
    walk += (game.localPlayer.entity.walkDistance - game.localPlayer.entity.oldWalkDistance) * game.timer.delta

    float bob = game.localPlayer.oldBobbing
    bob += (game.localPlayer.bobbing - game.localPlayer.oldBobbing) * game.timer.delta

    float tilt = game.localPlayer.oldTilt
    tilt += (game.localPlayer.tilt - game.localPlayer.oldTilt) * game.timer.delta

    Matrix matrix = Matrix()
    matrix = matrix.translate(Vector3(0.45, -0.55 - 0.25 * (1.0 - renderHeight), -0.8))
    matrix = matrix.translate(Vector3(sin(walk * PI) * bob * 0.5, -abs(cos(walk * PI) * bob), 0.0))
    matrix = matrix.translate(Vector3(0.0, radians(tilt), 0.0))

    if isSwinging
      float swingDelta = ((float)swingOffset + game.timer.delta) / 7.0
      float swingRoot = swingDelta.sqrt()

      matrix = matrix.translate(Vector3(-sin(swingRoot * PI) * 0.4, sin(swingRoot * PI * 2.0) * 0.2, -sin(swingDelta * PI) * 0.2))

    matrix = matrix.scale(Vector3(0.3, 0.3, 0.3))
    matrix = matrix.rotate(radians(-40.0), Vector3(0.0, 1.0, 0.0))
    matrix = matrix.rotate(radians(sin(walk * PI) * bob * 3.0), Vector3(0.0, 0.0, 1.0))
    matrix = matrix.rotate(radians(abs(cos(walk * PI + 0.2) * bob) * 5.0), Vector3(1.0, 0.0, 0.0))

    if isSwinging
      float swingDelta = ((float)swingOffset + game.timer.delta) / 7.0
      float swingRoot = swingDelta.sqrt()

      matrix = matrix.rotate(radians(sin(swingRoot * PI) * 80.0), Vector3(0.0, 1.0, 0.0))
      matrix = matrix.rotate(radians(-sin(swingDelta * swingDelta * PI)), Vector3(1.0, 0.0, 0.0))

    setUniform(game.modelMatrixUniform, matrix.data)
    setTexture(game.atlasTexture)

    vertices.render()

    setUniform(game.modelMatrixUniform, Matrix().data)
