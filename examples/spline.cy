import "common/math.cy"

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
