import "game.cy"

class Allocator
  float[] data
  int size

  void __init__()
    data = []
    size = 0

  void __init__(int size)
    this.data = []
    this.size = size
    this.data.reserve(size * 6)

class VertexList
  Allocator allocator
  int vao
  int buffer
  int bufferLength
  int length
  int index

  void __init__()
    allocator = Allocator()
    vao = 0
    buffer = 0
    bufferLength = 0
    length = 0
    index = 0

  void init(Allocator allocator_)
    if not allocator_
      allocator = Allocator()
    else
      allocator.data = allocator_.data
      allocator.size = allocator_.size

    initializeGraphics()

  void init(int size)
    allocator.data = []
    allocator.size = size
    allocator.data.reserve(size * 6)
    initializeGraphics()

  void init()
    allocator.data = []
    allocator.size = 4
    allocator.data.reserve(24)
    initializeGraphics()

  void initializeGraphics()
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
    if index == allocator.size
      if allocator.size == 0
        allocator.size++
      allocator.size *= 2

      float[] old = allocator.data
      int copyLength = old.length
      allocator.data = []
      allocator.data.reserve(allocator.size * 6)
      for int i; i < copyLength; i++
        allocator.data[i] = old[i]

  void push(float x, float y, float z, float u, float v, float s)
    grow()

    int base = index * 6
    allocator.data[base] = x
    allocator.data[base + 1] = y
    allocator.data[base + 2] = z
    allocator.data[base + 3] = u
    allocator.data[base + 4] = v
    allocator.data[base + 5] = s
    index++

  void reset()
    index = 0

  void update()
    length = index

    if length > 0
      bindVertexArray(vao)
      bindArrayBuffer(buffer)

      if length > bufferLength
        setArrayBufferData(buffer, allocator.data, length * 6)
        bufferLength = length
      else
        updateArrayBufferData(buffer, allocator.data, length * 6)

      index = 0

  void render()
    if length > 0
      bindVertexArray(vao)
      drawVertexArray(0, length)
