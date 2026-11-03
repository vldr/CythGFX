float PI = 3.14159265358979323846
float FLT_MAX = 340282346638528859811704183484516925824.0

class Vector2
  float x
  float y

  void __init__()
  void __init__(float x, float y)
    this.x = x
    this.y = y

class Vector3
  float x
  float y
  float z

  void __init__()
  void __init__(float x, float y, float z)
    this.x = x
    this.y = y
    this.z = z

  Vector3 __add__(Vector3 other)
    return Vector3(x + other.x, y + other.y, z + other.z)

  Vector3 __sub__(Vector3 other)
    return Vector3(x - other.x, y - other.y, z - other.z)

  Vector3 __mul__(float factor)
    return Vector3(x * factor, y * factor, z * factor)

  bool __eq__(Vector3 other)
    return x == other.x and y == other.y and z == other.z

  float dot(Vector3 other)
    return x * other.x + y * other.y + z * other.z

  Vector3 cross(Vector3 other)
    return Vector3(
      y * other.z - z * other.y,
      z * other.x - x * other.z,
      x * other.y - y * other.x
    )

  float length()
    return (x * x + y * y + z * z).sqrt()

  Vector3 normalize()
    float norm = length()
    return Vector3(x / norm, y / norm, z / norm)

  Vector3 clone()
    return Vector3(x, y, z)

  float distance(Vector3 other)
    float dx = x - other.x
    float dy = y - other.y
    float dz = z - other.z
  
    return (dx * dx + dy * dy + dz * dz).sqrt()

  Vector3 mix(Vector3 end, float s)
    return Vector3(
      x + (end.x - x) * s,
      y + (end.y - y) * s,
      z + (end.z - z) * s
    )

class Int3
  int x
  int y
  int z

  void __init__()
  void __init__(int x, int y, int z)
    this.x = x
    this.y = y
    this.z = z

  bool __eq__(Int3 other)
    return x == other.x and y == other.y and z == other.z

class Queue<T>
  T[] items
  int head

  void __init__()
    items = []
    head = 0

  void push(T item)
    items.push(item)

  int size()
    return items.length - head

  bool empty()
    return size() == 0

  T front()
    return items[head]

  void pop()
    head++

    if head > 1024 and head * 2 >= items.length
      T[] remaining

      for int i = head; i < items.length; i++
        remaining.push(items[i])

      items = remaining
      head = 0

  void clear()
    items = []
    head = 0

float radians(float degrees)
  return degrees * PI / 180.0

float degrees(float radians)
  return radians * 180.0 / PI

float floorTo(float x)
  int i = (int)x
  if (float)i > x
    return (float)(i - 1)
  return (float)i

float clamp(float value, float min, float max)
  if value < min
    return min
  if value > max
    return max
  return value

float max(float a, float b)
  if a > b
    return a
  return b

float min(float a, float b)
  if a < b
    return a
  return b

int max(int a, int b)
  if a > b
    return a
  return b

int min(int a, int b)
  if a < b
    return a
  return b

int abs(int a)
  if a < 0
    return -a
  return a

class Matrix
  float[] data

  void __init__()
    data = [
      1.0, 0.0, 0.0, 0.0,
      0.0, 1.0, 0.0, 0.0,
      0.0, 0.0, 1.0, 0.0,
      0.0, 0.0, 0.0, 1.0
    ]

  void __init__(float[] values)
    data = values

  float __get__(int index)
    return data[index]

  void __set__(int index, float value)
    data[index] = value

  Matrix clone()
    float[] values

    for int i; i < 16; i++
      values.push(data[i])

    return Matrix(values)

  void set(Matrix source)
    for int i; i < 16; i++
      data[i] = source.data[i]

  Matrix multiply(Matrix other)
    float[] result

    for int column; column < 4; column++
      for int row; row < 4; row++
        float sum = 0.0

        for int k; k < 4; k++
          sum += data[row + k * 4] * other.data[column * 4 + k]

        result.push(sum)

    return Matrix(result)

  Matrix translate(Vector3 value)
    Matrix translation = Matrix()
    translation.data[12] = value.x
    translation.data[13] = value.y
    translation.data[14] = value.z

    return multiply(translation)

  Matrix scale(Vector3 value)
    Matrix scaling = Matrix()
    scaling.data[0] = value.x
    scaling.data[5] = value.y
    scaling.data[10] = value.z
    return multiply(scaling)

  Matrix rotate(float angle, Vector3 axis)
    float c = cos(angle)
    float c1 = 1.0 - c
    float s = sin(angle)

    float x = axis.x
    float y = axis.y
    float z = axis.z
    float xx = x * x
    float yy = y * y
    float zz = z * z
    float xy = x * y
    float yz = y * z
    float zx = z * x
    float sx = s * x
    float sy = s * y
    float sz = s * z

    float[] values = [
      c1 * xx + c,  c1 * xy + sz, c1 * zx - sy, 0.0,
      c1 * xy - sz, c1 * yy + c,  c1 * yz + sx, 0.0,
      c1 * zx + sy, c1 * yz - sx, c1 * zz + c,  0.0,
      0.0,           0.0,          0.0,           1.0
    ]

    return multiply(Matrix(values))

Matrix matrixIdentity()
  return Matrix()

Matrix matrixPerspective(
  float fovyRadians,
  float aspect,
  float zNear,
  float zFar
)
  float tanHalfFovy = tan(fovyRadians * 0.5)

  float[] result
  result.reserve(16)

  result[0] = 1.0 / (aspect * tanHalfFovy)
  result[5] = 1.0 / tanHalfFovy
  result[10] = -(zFar + zNear) / (zFar - zNear)
  result[11] = -1.0
  result[14] = -(2.0 * zFar * zNear) / (zFar - zNear)

  return Matrix(result)

Matrix matrixOrtho(
  float left,
  float right,
  float bottom,
  float top,
  float zNear,
  float zFar
)
  float[] result
  result.reserve(16)

  result[0] = 2.0 / (right - left)
  result[5] = 2.0 / (top - bottom)
  result[10] = -2.0 / (zFar - zNear)
  result[15] = 1.0
  result[12] = -(right + left) / (right - left)
  result[13] = -(top + bottom) / (top - bottom)
  result[14] = -(zFar + zNear) / (zFar - zNear)

  return Matrix(result)

Matrix matrixLookAt(Vector3 eye, Vector3 center, Vector3 up)
  Vector3 forward = (center - eye).normalize()
  Vector3 side = (forward.cross(up)).normalize()
  Vector3 cameraUp = side.cross(forward)

  float[] result = [
    side.x, cameraUp.x, -forward.x, 0.0,
    side.y, cameraUp.y, -forward.y, 0.0,
    side.z, cameraUp.z, -forward.z, 0.0,
    -(side.dot(eye)),
    -(cameraUp.dot(eye)),
    forward.dot(eye),
    1.0
  ]

  return Matrix(result)

