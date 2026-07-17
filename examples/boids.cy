# Ported from https://github.com/contextfreecode/life

int WIDTH = 800
int HEIGHT = 600
float SIZE_X = (float)WIDTH
float SIZE_Y = (float)HEIGHT
float SIZE_MAX = max(SIZE_X, SIZE_Y)

Boid[] boids
float reach
float speed
float fps

size("Boids", WIDTH, HEIGHT)

reach = 0.05 * SIZE_MAX
speed = 0.1 * SIZE_MAX
fps = 0.0

void draw(int time)
  update()
  render()

void addBoid()
  Vector2 pos = Vector2(
    (float)getRandomValue(0, WIDTH - 1),
    (float)getRandomValue(0, HEIGHT - 1)
  )

  Vector2 vel = Vector2(
    (float)getRandomValue(0, 1000) / 1000.0 - 0.5,
    (float)getRandomValue(0, 1000) / 1000.0 - 0.5
  ).normalize()

  boids.push(Boid(pos, vel))

Vector2 getDelta(Vector2 toward, Vector2 from)
  float halfX = SIZE_X * 0.5
  float halfY = SIZE_Y * 0.5
  Vector2 delta = toward - from

  if delta.x < -halfX
    delta.x += SIZE_X
  else if delta.x > halfX
    delta.x -= SIZE_X

  if delta.y < -halfY
    delta.y += SIZE_Y
  else if delta.y > halfY
    delta.y -= SIZE_Y

  return delta

Vector2 wrap(Vector2 pos)
  while pos.x < 0
    pos.x += SIZE_X
  while pos.x >= SIZE_X
    pos.x -= SIZE_X
  while pos.y < 0
    pos.y += SIZE_Y
  while pos.y >= SIZE_Y
    pos.y -= SIZE_Y

  return pos

void updateBoidVel(Boid boid)
  Vector2 meanDelta = Vector2()
  Vector2 meanTrend = Vector2()
  Vector2 meanSpread = Vector2()
  float weight = 0
  float spreadWeight = 0

  for Boid other in boids
    Vector2 delta = getDelta(other.pos, boid.pos)
    float distance = delta.length()

    if distance < reach
      float w = 1.0 - distance / reach
      float wdt = pow(w, 5)

      meanDelta += delta * wdt
      meanTrend += other.vel * wdt
      weight += wdt

      float ws = pow(w, 10)
      meanSpread -= delta * ws
      spreadWeight += ws

  if weight != 0
    Vector2 vel = boid.vel * 1.0
    vel += meanDelta * (0.01 / weight)
    vel += meanTrend * (0.03 / weight)
    vel += meanSpread * (0.02 / spreadWeight)
    boid.vel = vel.normalize()

void update()
  float dt = getFrameTime()

  for Boid boid in boids
    updateBoidVel(boid)
    boid.pos.x = wrap(boid.pos + boid.vel * speed * dt).x
    boid.pos.y = wrap(boid.pos + boid.vel * speed * dt).y

  fps = 0.9 * fps + 0.1 / max(dt, 0.001)

  if fps > 40
    addBoid()

void render()
  fill(43, 43, 56)
  clear()

  fill(232, 232, 232)
  for Boid boid in boids
    int x = (int)boid.pos.x - 1
    int y = (int)boid.pos.y - 1
    rect(x, y, 3, 3)

  fill(232, 232, 232)
  text("FPS: " + (int)fps, 10, 10, 40)
  text("Boids: " + boids.length, 10, 50, 40)

  float score = (float)(boids.length * boids.length) / 1000.0
  text("Score: " + score, 10, 90, 40)

class Boid
  Vector2 pos
  Vector2 vel

  void __init__(Vector2 pos, Vector2 vel)
    this.pos = pos
    this.vel = vel

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

float max(float a, float b)
  if a > b
    return a
  return b