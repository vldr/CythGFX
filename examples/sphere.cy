int SPHERE_SIZE = 200
int M_AMBIENT = 0 
int M_DIFFUSE = 1 
int M_SPECULAR = 2  
float PI = 3.14
float TWO_PI = PI * 2
float PHONG_SPECULAR = 30
float PERSPECTIVE = 0.002 

Vector3 LIGHT = Vector3(200, 200, 350)
Vector3 EYE = Vector3(0, 0, 600)

Vector3 OUTLINE_COLOR = Vector3(1.0, 0.2, 0.5)
Vector3 FILL_COLOR = Vector3(1.0, 1.0, 1.0) 
Vector3 MATERIAL = Vector3(0.1, 0.8, 0.8)

int KEY_LIGHTING = KEY_L 
int KEY_NORMALS = KEY_N 
int KEY_OUTLINE = KEY_O
int KEY_ROTATE = KEY_R 
int KEY_SHADING = KEY_S

int LIGHTING_FLAT
int LIGHTING_PHONG_FACE = 1
int LIGHTING_PHONG_VERTEX = 2

int SHADING_NONE = 0
int SHADING_BARYCENTRIC = 1
int SHADING_FLAT = 2
int SHADING_GOURAUD = 3
int SHADING_PHONG = 4

int lighting = LIGHTING_PHONG_VERTEX
int shading = SHADING_PHONG

bool doOutline = false
bool rotate = true
bool normals = false

int lastTime
int lastFps
int fps

float theta = 0.0
float delta = 0.01

char r 
char g
char b 

Triangle[] sphereList = makeSphere(SPHERE_SIZE, 10)
Triangle[] rotatedList
rotatedList.reserve(sphereList.length)

size("Sphere", 640, 640)
fill(0, 0, 0)

Image img = Image(640, 640)

void draw(int time)
  if rotate
    theta += delta
    while theta > PI*2
      theta -= PI*2

  fill(0, 0, 0)
  img.clear()

  keyPressed()
  rotateSphere(sphereList, rotatedList, theta)
  drawSphere(rotatedList, lighting, shading)

  img.draw()
  drawSettings()

  fps += 1

  if time - lastTime >= 1000
    lastFps = fps
    lastTime = time
    fps = 0

void drawSettings()
  string[] shaders = [
    "SHADING_NONE",
    "SHADING_BARYCENTRIC",
    "SHADING_FLAT",
    "SHADING_GOURAUD",
    "SHADING_PHONG"
  ]

  string[] lights = [
    "LIGHTING_FLAT",
    "LIGHTING_PHONG_FACE",
    "LIGHTING_PHONG_VERTEX"
  ]

  string msg = (
    "Shading: " + shaders[shading] + "\n" +
    "Lighting: " + lights[lighting] + "\n" +
    "Outline: " + doOutline + "\n" + 
    "FPS: " + lastFps
  )

  fill(255, 255, 255)
  text(msg, 5, 5, 18)

void keyPressed()
  bool keyPressed

  if isKeyPressed(KEY_SHADING)
    shading = (shading + 1) % 5
    keyPressed = true

  if isKeyPressed(KEY_LIGHTING)
    lighting = (lighting + 1) % 3
    keyPressed = true
  
  if isKeyPressed(KEY_OUTLINE)
    doOutline = !doOutline
    keyPressed = true

  if isKeyPressed(KEY_ROTATE)
    rotate = !rotate
    keyPressed = true

  if isKeyPressed(KEY_NORMALS)
    normals = !normals
    keyPressed = true

void color(float _r, float _g, float _b)
  r = (char)min((int)(_r * 255), 255)
  g = (char)min((int)(_g * 255), 255)
  b = (char)min((int)(_b * 255), 255)

void vertex(int x, int y)
  x += 320
  y *= -1
  y += 320

  int index = (y * 640 + x) * 3
  img.data[index] = r
  img.data[index + 1] = g
  img.data[index + 2] = b

  index = ((y + 1) * 640 + (x + 1)) * 3
  img.data[index] = r
  img.data[index + 1] = g
  img.data[index + 2] = b

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

  Vector3 normalize()
    float norm = (x * x + y * y + z * z).sqrt()
    return Vector3(x / norm, y / norm, z / norm)

  float dot(Vector3 q)
    return x * q.x + y * q.y + z * q.z

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

  Vector3 cross(Vector3 vect_B)
    return Vector3(
      y * vect_B.z - z * vect_B.y, 
      z * vect_B.x - x * vect_B.z,
      x * vect_B.y - y * vect_B.x
    )

  Vector3 clone()
    return Vector3(x,y,z)

float max(float a, float b)
  return a > b ? a : b

int min(int a, int b)
  return a < b ? a : b

float min(float a, float b)
  return a < b ? a : b

float max(float a, float b, float c)
  return a > b ? (a > c ? a : c) : (b > c ? b : c)

float min(float a, float b, float c)
  return a < b ? (a < c ? a : c) : (b < c ? b : c)

class Triangle
  void __init__(Vector3 V1, Vector3 V2, Vector3 V3)
    v1 = V1.clone()
    v2 = V2.clone()
    v3 = V3.clone()

  Vector3 v1
  Vector3 v2
  Vector3 v3

  Vector2 pv1
  Vector2 pv2
  Vector2 pv3

  Vector3 e1
  Vector3 e2
  Vector3 e3
  
  Vector3 centerPoint
  Vector3 normal
  
  Vector3 c

  Vector3 phong
    
  Vector3 phongV1
  Vector3 phongV2
  Vector3 phongV3

Triangle[] makeSphere(int radius, int divisions)
    Vector3[][] sphereVerticies
    sphereVerticies.reserve(divisions + 1, divisions + 1)
    
    for int i = 0; i <= divisions; i += 1
      for int j = 0; j <= divisions; j += 1
        float v = (PI / divisions) * i
        float u = (TWO_PI / divisions) * j
        
        float x = radius * sin(v) * sin(u)
        float y = radius * cos(v)
        float z = radius * sin(v) * cos(u)
        
        sphereVerticies[i][j] = Vector3(x, y, z)
     
    Triangle[] triangles
    triangles.reserve((divisions * divisions) + (divisions * divisions))
    int count = 0
   
    for int verticalOffset = 0; verticalOffset < divisions; verticalOffset += 1
      for int horizontalOffset = 0; horizontalOffset < divisions; horizontalOffset += 1
        Vector3 v1 = sphereVerticies[verticalOffset][horizontalOffset]
        Vector3 v2 = sphereVerticies[verticalOffset][(horizontalOffset + 1)]
        Vector3 v3 = sphereVerticies[(verticalOffset + 1)][(horizontalOffset + 1)]
        Vector3 v4 = sphereVerticies[(verticalOffset + 1)][horizontalOffset]
    
        triangles[count] = Triangle(v1, v4, v3)
        count += 1

        triangles[count] = Triangle(v1, v3, v2)
        count += 1

    return triangles

Triangle setupTriangle(Triangle t)
  t.e1 = t.v2 - t.v1
  t.e2 = t.v3 - t.v2
  t.e3 = t.v1 - t.v3
  
  t.centerPoint = Vector3( 
    (t.v1.x + t.v2.x + t.v3.x) / 3, 
    (t.v1.y + t.v2.y + t.v3.y) / 3,
    (t.v1.z + t.v2.z + t.v3.z) / 3
  )
  
  Vector3 V1toCenterPointEdge = t.centerPoint - t.v1
  t.normal = t.e1.cross(V1toCenterPointEdge).normalize()
  
  t.c = FILL_COLOR
    
  return t

Vector2 project(Vector3 v)
  float adjZ = v.z - EYE.z  
  if adjZ > 0
    return Vector2()

  adjZ *=- 1 
  float px = v.x / (adjZ * PERSPECTIVE)
  float py = v.y / (adjZ * PERSPECTIVE)

  return Vector2(px, py)

void rotateVertex(Vector3 v, float theta)
  float rx = v.x * cos(theta) - v.z * sin(theta)
  float rz = v.x * sin(theta) + v.z * cos(theta)

  v.x = rx 
  v.z = rz

void drawSphere(Triangle[] sphere, int lighting, int shading)
  for Triangle t in sphere
    if not t
      continue

    t.pv1 = project(t.v1) 
    t.pv2 = project(t.v2)
    t.pv3 = project(t.v3)
    
    draw2DTriangle(t, lighting, shading)

void draw2DTriangle(Triangle t, int lighting, int shading)
    Vector2 pe1 = t.pv2 - t.pv1
    Vector2 pe2 = t.pv3 - t.pv2

    float cross2d = pe1.cross(pe2)
    
    if (cross2d < 0)
      return
    
    if (cross2d / 2 < 1)
      return

    if lighting == LIGHTING_PHONG_FACE
      t.phong = phong(t.centerPoint, t.normal, EYE, LIGHT, MATERIAL, FILL_COLOR, PHONG_SPECULAR)
      t.c = Vector3(t.phong.x, t.phong.y, t.phong.z)

    else if lighting == LIGHTING_PHONG_VERTEX
      Vector3 origin = Vector3(0, 0, 0)
      Vector3 normalV1 = (t.v1 - origin).normalize()
      Vector3 normalV2 = (t.v2 - origin).normalize()
      Vector3 normalV3 = (t.v3 - origin).normalize()
      
      t.phongV1 = phong(t.v1, normalV1, EYE, LIGHT, MATERIAL, FILL_COLOR, PHONG_SPECULAR)
      t.phongV2 = phong(t.v2, normalV2, EYE, LIGHT, MATERIAL, FILL_COLOR, PHONG_SPECULAR)
      t.phongV3 = phong(t.v3, normalV3, EYE, LIGHT, MATERIAL, FILL_COLOR, PHONG_SPECULAR)
 
      Vector3 avgPhong = Vector3(
          (t.phongV1.x + t.phongV2.x + t.phongV3.x) / 3, 
          (t.phongV1.y + t.phongV2.y + t.phongV3.y) / 3, 
          (t.phongV1.z + t.phongV2.z + t.phongV3.z) / 3  
      )
      
      t.c = Vector3(avgPhong.x, avgPhong.y, avgPhong.z)
    else 
      t.c = FILL_COLOR
    
    fillTriangle(t, shading)
    
    if doOutline
      color(OUTLINE_COLOR.x, OUTLINE_COLOR.y, OUTLINE_COLOR.z)
      bresLine((int)t.pv1.x, (int)t.pv1.y, (int)t.pv2.x, (int)t.pv2.y)
      bresLine((int)t.pv2.x, (int)t.pv2.y, (int)t.pv3.x, (int)t.pv3.y)
      bresLine((int)t.pv3.x, (int)t.pv3.y, (int)t.pv1.x, (int)t.pv1.y)
    
    if normals
      Vector3 origin = Vector3(0, 0, 0)
      Vector3 normalV1 = (t.v1 - origin).normalize()
      Vector3 normalV2 = (t.v2 - origin).normalize()
      Vector3 normalV3 = (t.v3 - origin).normalize()
      
      color(255, 255, 0)
      drawNormal(t.v1, normalV1)
      drawNormal(t.v2, normalV2)
      drawNormal(t.v3, normalV3)
      
      color(0, 255, 255)
      drawNormal(t.centerPoint, t.normal)

void drawNormal(Vector3 p, Vector3 n)
  Vector3 offsetNormal = n * 20.0
  Vector3 endPoint = p + offsetNormal
  
  Vector2 projectedCenterPoint = project(p)
  Vector2 projectedEndPoint = project(endPoint)
  
  if projectedCenterPoint and projectedEndPoint
    bresLine(
      (int)projectedCenterPoint.x, 
      (int)projectedCenterPoint.y, 
      (int)projectedEndPoint.x, 
      (int)projectedEndPoint.y
    )

void fillTriangle(Triangle t, int shading)
  if (shading == SHADING_NONE)
    return

  float Xmin = min(t.pv1.x, t.pv2.x, t.pv3.x)
  float Xmax = max(t.pv1.x, t.pv2.x, t.pv3.x)
  
  float Ymin = min(t.pv1.y, t.pv2.y, t.pv3.y)
  float Ymax = max(t.pv1.y, t.pv2.y, t.pv3.y)
    
  for int y = (int)Ymin; y <= (int)Ymax; y += 1
      for int x = (int)Xmin; x <= (int)Xmax; x += 1
        Vector2 P = Vector2((float)x, (float)y)
        Vector2 E1 = t.pv2 - t.pv1
        Vector2 E2 = t.pv3 - t.pv2
        Vector2 E3 = t.pv1 - t.pv3
        
        Vector2 A1 = P - t.pv1
        Vector2 A2 = P - t.pv2
        Vector2 A3 = P - t.pv3

        float first = E1.cross(A1)
        float second = E2.cross(A2)
        float third = E3.cross(A3)
        
        if (first > 0 and second > 0 and third > 0) or (first < 0 and second < 0 and third < 0)
          if shading == SHADING_BARYCENTRIC
            float triangleArea = E1.cross(E2) / 2
            float w = (first / 2) / triangleArea
            float u = (second / 2) / triangleArea
            float v = (third / 2) / triangleArea

            t.c = Vector3(u,v,w)
          else if shading == SHADING_GOURAUD
            float triangleArea = E1.cross(E2) / 2
            float w = (first / 2) / triangleArea
            float u = (second / 2) / triangleArea
            float v = (third / 2) / triangleArea
            
            if lighting == LIGHTING_PHONG_VERTEX
              t.c = (t.phongV1 * u) + (t.phongV2 * v) + (t.phongV3 * w)
            else
              t.c = (t.c * u) + (t.c * v) + (t.c * w)
          else if shading == SHADING_PHONG
            float triangleArea = E1.cross(E2) / 2
            float w = (first / 2) / triangleArea
            float u = (second / 2) / triangleArea
            float v = (third / 2) / triangleArea
            
            Vector3 uV1 = t.v1 * u
            Vector3 vV2 = t.v2 * v
            Vector3 wV3 = t.v3 * w
            
            Vector3 P3 = uV1 + vV2 + wV3
            
            Vector3 origin = Vector3()
            Vector3 normal = (P3 - origin).normalize()
          
            t.c = phong(P3, normal, EYE, LIGHT, MATERIAL, FILL_COLOR, PHONG_SPECULAR)

          color(t.c.x, t.c.y, t.c.z)
          vertex(x, y)

Vector3 phong(Vector3 p, Vector3 N, Vector3 eye, Vector3 light, Vector3 material, Vector3 fillColor, float s)
  Vector3 L = (light - p).normalize()
  Vector3 V = (eye - p).normalize()

  Vector3 R = N * (2 * max(N.dot(L), 0)) -  L
  
  float ma = material.x
  float md = material.y
  float ms = material.z
  
  Vector3 Ambient = fillColor * ma
  Vector3 Diffuse = fillColor * max(L.dot(N), 0) * md
  
  float Sprime = (float)pow(max(R.dot(V), 0), s)
  Vector3 Specular = Vector3(Sprime)
  Specular = Specular * ms

  Vector3 shading = Ambient + Diffuse + Specular
  return shading

void bresLine(int fromX, int fromY, int toX, int toY)
  float error = 0.5
  
  float deltaX = (float)(toX - fromX)
  float deltaY = (float)(toY - fromY)
  
  int X = fromX
  int Y = fromY
  
  int stepX = 1
  int stepY = 1
  
  if deltaX < 0
    deltaX *= -1
    stepX *= -1
  
  if deltaY < 0
    deltaY *= -1
    stepY *= -1
  
  if abs(deltaX) > abs(deltaY)
    float slope = abs(deltaY / deltaX)
  
    while toX - X != 0
        vertex(X, Y)
        
        X += stepX
        error += slope
        
        if (error >= 0.5)
          Y += stepY
          error -= 1
        
  else
    float slope = abs(deltaX / deltaY)
    
    while toY - Y != 0
        vertex(X, Y)

        Y += stepY
        
        error += slope
        
        if error >= 0.5
          X += stepX
          error -= 1

void rotateSphere(Triangle[] original, Triangle[] rotated, float theta)
  for int i = 0; i < original.length; i += 1
    if not rotated[i]
      rotated[i] = setupTriangle(Triangle(original[i].v1, original[i].v2, original[i].v3))
    else
      rotated[i].v1 = original[i].v1.clone()
      rotated[i].v2 = original[i].v2.clone()
      rotated[i].v3 = original[i].v3.clone()

      rotateVertex(rotated[i].v1, theta)
      rotateVertex(rotated[i].v2, theta)
      rotateVertex(rotated[i].v3, theta)
      setupTriangle(rotated[i])