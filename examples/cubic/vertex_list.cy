import "game.cy"

class VertexList
  float[] data
  int vao
  int buffer
  int bufferLength
  int length
  int index

  void __init__()
    vao = 0
    buffer = 0
    bufferLength = 0
    length = 0
    index = 0

  void init()
    init(24)

  void init(int size)
    float[] data
    data.reserve(size)

    init(data)

  void init(float[] vertices)
    data = vertices
    index = 0
    length = 0
    bufferLength = 0

    vao = createVertexArray()
    bindVertexArray(vao)

    buffer = createArrayBuffer()
    bindArrayBuffer(buffer)

    setVertexAttribute(game.positionAttribute, 3, 24, 0)
    setVertexAttribute(game.uvAttribute, 2, 24, 12)
    setVertexAttribute(game.shadeAttribute, 1, 24, 20)

  void grow()
    int required = (index + 1) * 6
    if required > data.length
      int growth = data.length
      if growth <= 0
        growth = 24

      for int i = 0; i < growth; i++
        data.push(0)

  void push(float x, float y, float z, float u, float v, float s)
    grow()

    int base = index * 6
    data[base] = x
    data[base + 1] = y
    data[base + 2] = z
    data[base + 3] = u
    data[base + 4] = v
    data[base + 5] = s

    index++

  void reset()
    index = 0 

  void update()
    length = index

    if length > 0
      bindVertexArray(vao)
      bindArrayBuffer(buffer)

      if length > bufferLength
        setArrayBufferData(buffer, data, length * 6)
        bufferLength = length
      else
        updateArrayBufferData(buffer, data, length * 6)

      reset()

  void render()
    if length > 0
      bindVertexArray(vao)
      drawVertexArray(0, length)
