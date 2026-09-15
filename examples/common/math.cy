float clamp(float val, float min, float max)
  if val < min
    return min
  
  if val > max
    return max

  return val

int max(int a, int b)
  if a > b
    return a
  return b

float max(float a, float b)
  if a > b
    return a
  return b

int min(int a, int b)
  if a < b
    return a
  return b

float min(float a, float b)
  if a < b
    return a
  return b

float max(float a, float b, float c)
  return a > b ? (a > c ? a : c) : (b > c ? b : c)

float min(float a, float b, float c)
  return a < b ? (a < c ? a : c) : (b < c ? b : c)

class Vector2
  float x
  float y

  void __init__()
  void __init__(float x, float y)
    this.x = x
    this.y = y

  Vector2 __add__(Vector2 other)
    return Vector2(x + other.x, y + other.y)

  Vector2 __sub__(Vector2 other)
    return Vector2(x - other.x, y - other.y)

  Vector2 __mul__(float factor)
    return Vector2(x * factor, y * factor)

  float length()
    return (x * x + y * y).sqrt()

  Vector2 normalize()
    float len = length()
    if len != 0
      return Vector2(x / len, y / len)
    return Vector2(0, 0)

  float cross(Vector2 q)
    return x * q.y - y * q.x

class Vector3
  float x
  float y
  float z

  void __init__()
  void __init__(float n)
    this.x = n
    this.y = n
    this.z = n

  void __init__(float x, float y, float z)
    this.x = x
    this.y = y
    this.z = z

  Vector3 __mul__(float factor)
    return Vector3(x * factor, y * factor, z * factor)

  Vector3 __add__(Vector3 v2)
    return Vector3(
      x + v2.x,
      y + v2.y,
      z + v2.z
    )

  Vector3 __sub__(Vector3 v2)
    return Vector3(
      x - v2.x, 
      y - v2.y, 
      z - v2.z 
    )

  bool __eq__(Vector3 v2)
    return x == v2.x and y == v2.y and z == v2.z

  Vector3 normalize()
    float norm = (x * x + y * y + z * z).sqrt()
    return Vector3(x / norm, y / norm, z / norm)
  
  Vector3 scale(float s)
    return Vector3(x * s, y * s, z * s)

  float dot(Vector3 other)
    return x * other.x + y * other.y + z * other.z

  Vector3 cross(Vector3 other)
    return Vector3(
      y * other.z - z * other.y, 
      z * other.x - x * other.z,
      x * other.y - y * other.x
    )

  Vector3 clone()
    return Vector3(x,y,z)

class Vector4
  float x
  float y
  float z
  float w

  void __init__()
  void __init__(float n)
    this.x = n
    this.y = n
    this.z = n
    this.w = n

  void __init__(float x, float y, float z, float w)
    this.x = x
    this.y = y
    this.z = z
    this.w = w

  Vector4 __add__(Vector4 v2)
    return Vector4(
      x + v2.x,
      y + v2.y,
      z + v2.z,
      w + v2.w
    )

  Vector4 __sub__(Vector4 v2)
    return Vector4(
      x - v2.x,
      y - v2.y,
      z - v2.z,
      w - v2.w
    )

  Vector4 __mul__(float factor)
    return Vector4(x * factor, y * factor, z * factor, w * factor)

  bool __eq__(Vector4 v2)
    return x == v2.x and y == v2.y and z == v2.z and w == v2.w

  float dot(Vector4 q)
    return x * q.x + y * q.y + z * q.z + w * q.w

  float length()
    return (x * x + y * y + z * z + w * w).sqrt()

  Vector4 normalize()
    float len = length()
    return Vector4(x / len, y / len, z / len, w / len)

  Vector4 clone()
    return Vector4(x, y, z, w)

class Mat4
  float m00
  float m01
  float m02
  float m03
  float m10
  float m11
  float m12
  float m13
  float m20
  float m21
  float m22
  float m23
  float m30
  float m31
  float m32
  float m33

  void __init__()
    m00 = 1.0
    m01 = 0.0
    m02 = 0.0
    m03 = 0.0
    m10 = 0.0
    m11 = 1.0
    m12 = 0.0
    m13 = 0.0
    m20 = 0.0
    m21 = 0.0
    m22 = 1.0
    m23 = 0.0
    m30 = 0.0
    m31 = 0.0
    m32 = 0.0
    m33 = 1.0

  void __init__(
    float m00, float m01, float m02, float m03,
    float m10, float m11, float m12, float m13,
    float m20, float m21, float m22, float m23,
    float m30, float m31, float m32, float m33
  )
    this.m00 = m00
    this.m01 = m01
    this.m02 = m02
    this.m03 = m03
    this.m10 = m10
    this.m11 = m11
    this.m12 = m12
    this.m13 = m13
    this.m20 = m20
    this.m21 = m21
    this.m22 = m22
    this.m23 = m23
    this.m30 = m30
    this.m31 = m31
    this.m32 = m32
    this.m33 = m33

  void __init__(Vector4 c0, Vector4 c1, Vector4 c2, Vector4 c3)
    this.m00 = c0.x
    this.m01 = c0.y
    this.m02 = c0.z
    this.m03 = c0.w
    this.m10 = c1.x
    this.m11 = c1.y
    this.m12 = c1.z
    this.m13 = c1.w
    this.m20 = c2.x
    this.m21 = c2.y
    this.m22 = c2.z
    this.m23 = c2.w
    this.m30 = c3.x
    this.m31 = c3.y
    this.m32 = c3.z
    this.m33 = c3.w

  bool __eq__(Mat4 b)
    return (m00 == b.m00 and m01 == b.m01 and m02 == b.m02 and m03 == b.m03
       and m10 == b.m10 and m11 == b.m11 and m12 == b.m12 and m13 == b.m13
       and m20 == b.m20 and m21 == b.m21 and m22 == b.m22 and m23 == b.m23
       and m30 == b.m30 and m31 == b.m31 and m32 == b.m32 and m33 == b.m33)

  Vector4 __mul__(Vector4 v)
    return Vector4(
      m00 * v.x + m10 * v.y + m20 * v.z + m30 * v.w,
      m01 * v.x + m11 * v.y + m21 * v.z + m31 * v.w,
      m02 * v.x + m12 * v.y + m22 * v.z + m32 * v.w,
      m03 * v.x + m13 * v.y + m23 * v.z + m33 * v.w
    )
  
  Mat4 __mul__(Mat4 b)
    return Mat4(
      m00 * b.m00 + m10 * b.m01 + m20 * b.m02 + m30 * b.m03,
      m01 * b.m00 + m11 * b.m01 + m21 * b.m02 + m31 * b.m03,
      m02 * b.m00 + m12 * b.m01 + m22 * b.m02 + m32 * b.m03,
      m03 * b.m00 + m13 * b.m01 + m23 * b.m02 + m33 * b.m03,

      m00 * b.m10 + m10 * b.m11 + m20 * b.m12 + m30 * b.m13,
      m01 * b.m10 + m11 * b.m11 + m21 * b.m12 + m31 * b.m13,
      m02 * b.m10 + m12 * b.m11 + m22 * b.m12 + m32 * b.m13,
      m03 * b.m10 + m13 * b.m11 + m23 * b.m12 + m33 * b.m13,

      m00 * b.m20 + m10 * b.m21 + m20 * b.m22 + m30 * b.m23,
      m01 * b.m20 + m11 * b.m21 + m21 * b.m22 + m31 * b.m23,
      m02 * b.m20 + m12 * b.m21 + m22 * b.m22 + m32 * b.m23,
      m03 * b.m20 + m13 * b.m21 + m23 * b.m22 + m33 * b.m23,

      m00 * b.m30 + m10 * b.m31 + m20 * b.m32 + m30 * b.m33,
      m01 * b.m30 + m11 * b.m31 + m21 * b.m32 + m31 * b.m33,
      m02 * b.m30 + m12 * b.m31 + m22 * b.m32 + m32 * b.m33,
      m03 * b.m30 + m13 * b.m31 + m23 * b.m32 + m33 * b.m33
    )

  Mat4 __mul__(float factor)
    return Mat4(
      m00 * factor, m01 * factor, m02 * factor, m03 * factor,
      m10 * factor, m11 * factor, m12 * factor, m13 * factor,
      m20 * factor, m21 * factor, m22 * factor, m23 * factor,
      m30 * factor, m31 * factor, m32 * factor, m33 * factor
    )

  Mat4 transpose()
    return Mat4(
      m00, m10, m20, m30,
      m01, m11, m21, m31,
      m02, m12, m22, m32,
      m03, m13, m23, m33
    )

  Mat4 clone()
    return Mat4(
      m00, m01, m02, m03,
      m10, m11, m12, m13,
      m20, m21, m22, m23,
      m30, m31, m32, m33
    )
