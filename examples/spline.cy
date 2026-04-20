Vector4[] controlPoints = [
  Vector4(-0.367188, 0.484375, 0.000000, 1.000000),
  Vector4(-0.335938, 0.878906, 0.000000, 1.000000),
  Vector4(0.191406, 0.890625, 0.000000, 1.000000),

  Vector4(0.253906, 0.496094, 0.000000, 1.000000),
  Vector4(0.765625, 0.484375, 0.000000, 1.000000),
  Vector4(0.800781, -0.117188, 0.000000, 1.000000),

  Vector4(0.328125, -0.191406, 0.000000, 1.000000),
  Vector4(0.296875, -0.800781, 0.000000, 1.000000),
  Vector4(-0.292969, -0.808594, 0.000000, 1.000000),

  Vector4(-0.343750, -0.218750, 0.000000, 1.000000),
  Vector4(-0.832031, -0.164062, 0.000000, 1.000000),
  Vector4(-0.851562, 0.398438, 0.000000, 1.000000)
]

Vector4 selectedControlPoint

int WIDTH = 500
int HEIGHT = 500
int SPLINE_SUBDIVISIONS = 100
float SQUARE_SIZE = 0.01625

int BEZIER = 0
int CATMULL_ROM = 1
int BSPLINE = 2

int splineType = BEZIER
bool first = true

size("Spline", WIDTH, HEIGHT)

void draw(int time)
  fill(0, 0, 0)
  clear()

  input()
  drawControlPoints()
  drawSpline()

void input()
  if isKeyPressed(KEY_SPACE)
    keyPressed()

  int x = getMouseX()                                  
  int y = getMouseY()

  if isMouseButtonDown(MOUSE_BUTTON_LEFT)
    if first
      mousePressed(x, y)
      first = false
    else
      mouseDragged(x, y)
  else
    if not first
      mouseReleased(x, y)

    first = true 

void mousePressed(int x, int y)
  Vector2 cursor = translateCoords(x, y)
  for Vector4 controlPoint in controlPoints
    if (
      controlPoint.x <= cursor.x and 
      controlPoint.x + SQUARE_SIZE * 2 >= cursor.x and
      controlPoint.y <= cursor.y and 
      controlPoint.y + SQUARE_SIZE * 2 >= cursor.y
    )
      selectedControlPoint = controlPoint

void mouseDragged(int x, int y)
  if selectedControlPoint
    Vector2 cursor = translateCoords(x, y)
    
    selectedControlPoint.x = cursor.x
    selectedControlPoint.y = cursor.y

void mouseReleased(int x, int y)
  selectedControlPoint = null

void keyPressed()
  splineType = (splineType + 1) % 3

void drawSpline()
  stroke(255, 255, 255)

  for int index = 0; index < controlPoints.length; index += splineType == BEZIER ? 3 : 1
    Vector4 previousPosition

    Mat4 P = Mat4(
      controlPoints[index],
      controlPoints[(index + 1) % controlPoints.length],
      controlPoints[(index + 2) % controlPoints.length],
      controlPoints[(index + 3) % controlPoints.length]
    )

    for int x = 0; x <= SPLINE_SUBDIVISIONS; x += 1
      float t = (float)x / SPLINE_SUBDIVISIONS

      Vector4 T = Vector4(t * t * t, t * t, t, 1.0)
      Vector4 position

      if splineType == BEZIER
        Mat4 M = Mat4(
          -1, 3, -3, 1,
          3, -6, 3, 0,
          -3, 3, 0, 0,
          1, 0, 0, 0
        )

        position = P * M * T
      else if splineType == CATMULL_ROM
        Mat4 M = Mat4(
          -1, 3, -3, 1,
          2, -5, 4, -1,
          -1, 0, 1, 0,
          0, 2, 0, 0
        )

        position = P * (M * 0.5) * T
      else if splineType == BSPLINE
        Mat4 M = Mat4(
          -1, 3, -3, 1,
          3, -6, 3, 0,
          -3, 0, 3, 0,
          1, 4, 1, 0
        )

        position = P * (M * (1.0 / 6.0)) * T

      if previousPosition
        int x0 = (int)(previousPosition.x * (WIDTH / 2) + WIDTH / 2)
        int y0 = (int)(previousPosition.y * (HEIGHT / 2) + HEIGHT / 2)
        int x1 = (int)(position.x * (WIDTH / 2) + WIDTH / 2)
        int y1 = (int)(position.y * (HEIGHT / 2) + HEIGHT / 2)

        line(x0, y0, x1, y1)

      previousPosition = position

void drawControlPoints()
  fill(255, 255, 255)

  for Vector4 controlPoint in controlPoints
    int x = (int)(controlPoint.x * (WIDTH / 2) + WIDTH / 2)
    int y = (int)(controlPoint.y * (HEIGHT / 2) + HEIGHT / 2)
  
    rect(x, y, (int)(SQUARE_SIZE * WIDTH), (int)(SQUARE_SIZE * HEIGHT))

Vector2 translateCoords(int x, int y)
  float width_midpoint = (WIDTH / 2.0)
  float height_midpoint = (HEIGHT / 2.0)
  float horizontal_delta = -(width_midpoint - x) / width_midpoint
  float vertical_delta = -(height_midpoint - y) / height_midpoint

  return Vector2(horizontal_delta, vertical_delta)

class Vector2
  float x
  float y

  void __init__()
  void __init__(float x, float y)
    this.x = x
    this.y = y

  bool __eq__(Vector2 v2)
    return x == v2.x and y == v2.y

  Vector2 __sub__(Vector2 v2)
    return Vector2(
      x - v2.x, 
      y - v2.y
    )
  
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

  float dot(Vector3 q)
    return x * q.x + y * q.y + z * q.z

  Vector3 cross(Vector3 vect_B)
    return Vector3(
      y * vect_B.z - z * vect_B.y, 
      z * vect_B.x - x * vect_B.z,
      x * vect_B.y - y * vect_B.x
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

  void __init__(Vector3 v, float w)
    this.x = v.x
    this.y = v.y
    this.z = v.z
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

  Vector3 xyz()
    return Vector3(x, y, z)

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
      m00*b.m00 + m10*b.m01 + m20*b.m02 + m30*b.m03,
      m01*b.m00 + m11*b.m01 + m21*b.m02 + m31*b.m03,
      m02*b.m00 + m12*b.m01 + m22*b.m02 + m32*b.m03,
      m03*b.m00 + m13*b.m01 + m23*b.m02 + m33*b.m03,

      m00*b.m10 + m10*b.m11 + m20*b.m12 + m30*b.m13,
      m01*b.m10 + m11*b.m11 + m21*b.m12 + m31*b.m13,
      m02*b.m10 + m12*b.m11 + m22*b.m12 + m32*b.m13,
      m03*b.m10 + m13*b.m11 + m23*b.m12 + m33*b.m13,

      m00*b.m20 + m10*b.m21 + m20*b.m22 + m30*b.m23,
      m01*b.m20 + m11*b.m21 + m21*b.m22 + m31*b.m23,
      m02*b.m20 + m12*b.m21 + m22*b.m22 + m32*b.m23,
      m03*b.m20 + m13*b.m21 + m23*b.m22 + m33*b.m23,

      m00*b.m30 + m10*b.m31 + m20*b.m32 + m30*b.m33,
      m01*b.m30 + m11*b.m31 + m21*b.m32 + m31*b.m33,
      m02*b.m30 + m12*b.m31 + m22*b.m32 + m32*b.m33,
      m03*b.m30 + m13*b.m31 + m23*b.m32 + m33*b.m33
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