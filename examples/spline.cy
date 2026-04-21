Vector4[] controlPoints = [
  Vector4(-0.403188, 0.460375, 0, 1),
  Vector4(-0.351938, 0.914906, 0, 1),
  Vector4(0.335406, 0.926624, 0, 1),

  Vector4(0.353906, 0.480094, 0, 1),
  Vector4(0.889625, 0.440375, 0, 1),
  Vector4(0.912781, -0.297188, 0, 1),

  Vector4(0.332125, -0.355406, 0, 1),
  Vector4(0.328875, -0.840781, 0, 1),
  Vector4(-0.400969, -0.836594, 0, 1),

  Vector4(-0.41175, -0.34675, 0, 1),
  Vector4(-0.888031, -0.332062, 0, 1),
  Vector4(-0.919562, 0.470438, 0, 1),
]

Vector4 selectedControlPoint
Vector2 dragOffset

int WIDTH = 500
int HEIGHT = 500
int SPLINE_SUBDIVISIONS = 100
float PI = 3.14159265359
float SQUARE_SIZE = 0.01625

int SPLINE_BEZIER = 0
int SPLINE_CATMULL_ROM = 1
int SPLINE_BSPLINE = 2
int splineType = SPLINE_BEZIER

float TRIANGLE_HEIGHT = 4
float TRIANGLE_BASE = TRIANGLE_HEIGHT * 2
float triangleT
int triangleIndex

bool first = true

size("Spline", WIDTH, HEIGHT)

void draw(int time)
  fill(0, 0, 0)
  clear()

  input()
  drawControlPoints()
  drawSpline()
  drawTriangle()

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
  Vector2 cursor = mouseToScreen(x, y)
  for Vector4 controlPoint in controlPoints
    if (
      controlPoint.x <= cursor.x and 
      controlPoint.x + SQUARE_SIZE * 2 >= cursor.x and
      controlPoint.y <= cursor.y and 
      controlPoint.y + SQUARE_SIZE * 2 >= cursor.y
    )
      selectedControlPoint = controlPoint
      dragOffset = Vector2(
        cursor.x - controlPoint.x,
        cursor.y - controlPoint.y
      )

void mouseDragged(int x, int y)
  if selectedControlPoint
    Vector2 cursor = mouseToScreen(x, y)
    
    selectedControlPoint.x = cursor.x - dragOffset.x
    selectedControlPoint.y = cursor.y - dragOffset.y

void mouseReleased(int x, int y)
  selectedControlPoint = null

void keyPressed()
  splineType = (splineType + 1) % 3
  triangleIndex = 0
  triangleT = 0

void drawSpline()
  stroke(255, 255, 255)

  for int index = 0; index < controlPoints.length; index += splineType == SPLINE_BEZIER ? 3 : 1
    Vector4 previousPosition

    for int x = 0; x <= SPLINE_SUBDIVISIONS; x += 1
      float t = (float)x / SPLINE_SUBDIVISIONS
      Vector4 position = spline(index, t, false)

      if previousPosition
        int x0 = (int)(previousPosition.x * (WIDTH / 2) + WIDTH / 2)
        int y0 = (int)(previousPosition.y * (HEIGHT / 2) + HEIGHT / 2)
        int x1 = (int)(position.x * (WIDTH / 2) + WIDTH / 2)
        int y1 = (int)(position.y * (HEIGHT / 2) + HEIGHT / 2)

        line(x0, y0, x1, y1)

      previousPosition = position

void drawTriangle()
  triangleT += 0.75 * getFrameTime()
  
  if triangleT > 1
    triangleT = 0
    triangleIndex = (triangleIndex + (splineType == SPLINE_BEZIER ? 3 : 1)) % controlPoints.length

  Vector4 position = spline(triangleIndex, triangleT, false)
  Vector4 direction = spline(triangleIndex, triangleT, true)

  int x = (int)(position.x * (WIDTH / 2) + WIDTH / 2)
  int y = (int)(position.y * (HEIGHT / 2) + HEIGHT / 2)

  float angle = atan2(direction.y, direction.x) + PI / 2
  float cosA = cos(angle)
  float sinA = sin(angle)
  float halfBase = TRIANGLE_BASE

  float px0 = 0
  float py0 = -TRIANGLE_HEIGHT

  float px1 = -halfBase
  float py1 = halfBase

  float px2 = halfBase
  float py2 = halfBase

  float x0 = x + (px0 * cosA - py0 * sinA)
  float y0 = y + (px0 * sinA + py0 * cosA)

  float x1 = x + (px1 * cosA - py1 * sinA)
  float y1 = y + (px1 * sinA + py1 * cosA)

  float x2 = x + (px2 * cosA - py2 * sinA)
  float y2 = y + (px2 * sinA + py2 * cosA)

  fill(255, 0, 0)
  triangle((int)x0, (int)y0, (int)x1, (int)y1, (int)x2, (int)y2)

void drawControlPoints()
  fill(255, 255, 255)

  for Vector4 controlPoint in controlPoints
    int x = (int)(controlPoint.x * (WIDTH / 2) + WIDTH / 2)
    int y = (int)(controlPoint.y * (HEIGHT / 2) + HEIGHT / 2)
  
    rect(x, y, (int)(SQUARE_SIZE * WIDTH), (int)(SQUARE_SIZE * HEIGHT))

Vector2 mouseToScreen(int x, int y)
  float widthMidpoint = (WIDTH / 2.0)
  float heightMidpoint = (HEIGHT / 2.0)
  float horizontalDelta = -(widthMidpoint - x) / widthMidpoint
  float verticalDelta = -(heightMidpoint - y) / heightMidpoint

  return Vector2(horizontalDelta, verticalDelta)

Vector4 spline(int index, float t, bool direction)
  Mat4 P = Mat4(
    controlPoints[index],
    controlPoints[(index + 1) % controlPoints.length],
    controlPoints[(index + 2) % controlPoints.length],
    controlPoints[(index + 3) % controlPoints.length]
  )

  Vector4 T = (direction ? Vector4(3 * t * t , 2 * t, 1.0, 0.0) :
                           Vector4(t * t * t, t * t, t, 1.0))

  if splineType == SPLINE_BEZIER
    Mat4 M = Mat4(
      -1, 3, -3, 1,
      3, -6, 3, 0,
      -3, 3, 0, 0,
      1, 0, 0, 0
    )

    return P * M * T
  else if splineType == SPLINE_CATMULL_ROM
    Mat4 M = Mat4(
      -1, 3, -3, 1,
      2, -5, 4, -1,
      -1, 0, 1, 0,
      0, 2, 0, 0
    )

    return P * (M * 0.5) * T
  else
    Mat4 M = Mat4(
      -1, 3, -3, 1,
      3, -6, 3, 0,
      -3, 0, 3, 0,
      1, 4, 1, 0
    )

    return P * (M * (1.0 / 6.0)) * T

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
