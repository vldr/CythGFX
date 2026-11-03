import "game.cy"

int PARTICLES_PER_AXIS = 4
int PARTICLES_PER_GROUP = 64
int VERTICES_PER_PARTICLE = 6

class Particle
  Entity entity

  int age
  int maxAge
  float size

  float u0
  float v0
  float u1
  float v1
  float brightness

  void __init__(
    float x,
    float y,
    float z,
    float xd,
    float yd,
    float zd,
    int blockType
  )
    entity = Entity()
    entity.init()
    entity.setSize(0.2, 0.2)
    entity.setPosition(x, y, z)
    entity.heightOffset = entity.aabbHeight / 2.0

    entity.velocity.x = xd + (game.random.uniform() * 2.0 - 1.0) * 0.4
    entity.velocity.y = yd + (game.random.uniform() * 2.0 - 1.0) * 0.4
    entity.velocity.z = zd + (game.random.uniform() * 2.0 - 1.0) * 0.4

    size = 0.1 * (game.random.uniform() * 0.5 + 0.5)
    maxAge = (int)(4.0 / (game.random.uniform() * 0.9 + 0.1))
    age = 0

    float velocityLength = entity.velocity.length()
    if velocityLength > 0.0
      float speed = (game.random.uniform() + game.random.uniform() + 1.0) * 0.15 * 0.4 / velocityLength
      entity.velocity.x *= speed
      entity.velocity.y *= speed
      entity.velocity.z *= speed

    entity.velocity.y += 0.1

    int texture = blockDefinitions[blockType].sideTexture
    float u = game.random.uniform() * 3.0
    float v = game.random.uniform() * 3.0

    u0 = ((float)(texture % 16) + u / 4.0) / 16.0
    v0 = ((float)(texture / 16) + v / 4.0) / 16.0
    u1 = u0 + 0.015609375
    v1 = v0 + 0.015609375

    brightness = game.level.getTileBrightness((int)x, (int)y, (int)z)

  bool expired()
    return age >= maxAge

  void tick()
    if expired()
      return

    entity.tick()

    age++
    entity.velocity.y -= 0.04

    entity.move(
      entity.velocity.x,
      entity.velocity.y,
      entity.velocity.z
    )

    entity.velocity.x *= 0.98
    entity.velocity.y *= 0.98
    entity.velocity.z *= 0.98

    if entity.onGround
      entity.velocity.x *= 0.7
      entity.velocity.z *= 0.7

  void update(VertexList vertexList)
    if expired()
      return

    Vector3 renderPosition = entity.oldPosition.mix(
      entity.position,
      game.timer.delta
    )

    float rotationX = radians(game.localPlayer.entity.rotation.x)
    float rotationY = radians(game.localPlayer.entity.rotation.y)

    float x = -cos(rotationX)
    float z = -sin(rotationX)
    float y = cos(rotationY)

    float rotX = -z * sin(rotationY)
    float rotZ = x * sin(rotationY)

    vertexList.push(
      renderPosition.x - x * size + rotX * size,
      renderPosition.y + y * size,
      renderPosition.z - z * size + rotZ * size,
      u0,
      v0,
      brightness
    )

    vertexList.push(
      renderPosition.x - x * size - rotX * size,
      renderPosition.y - y * size,
      renderPosition.z - z * size - rotZ * size,
      u0,
      v1,
      brightness
    )

    vertexList.push(
      renderPosition.x + x * size - rotX * size,
      renderPosition.y - y * size,
      renderPosition.z + z * size - rotZ * size,
      u1,
      v1,
      brightness
    )

    vertexList.push(
      renderPosition.x - x * size + rotX * size,
      renderPosition.y + y * size,
      renderPosition.z - z * size + rotZ * size,
      u0,
      v0,
      brightness
    )

    vertexList.push(
      renderPosition.x + x * size - rotX * size,
      renderPosition.y - y * size,
      renderPosition.z + z * size - rotZ * size,
      u1,
      v1,
      brightness
    )

    vertexList.push(
      renderPosition.x + x * size + rotX * size,
      renderPosition.y + y * size,
      renderPosition.z + z * size + rotZ * size,
      u1,
      v0,
      brightness
    )

class ParticleGroup
  VertexList vertexList
  Particle[] particles
  bool active

  void __init__()
    active = false
    particles = []

  void initialize(
    float x,
    float y,
    float z,
    int blockType
  )
    particles = []
    particles.reserve(PARTICLES_PER_GROUP)

    vertexList = VertexList()
    vertexList.init(
      PARTICLES_PER_GROUP *
      VERTICES_PER_PARTICLE
    )

    for int i; i < PARTICLES_PER_AXIS; i++
      for int j; j < PARTICLES_PER_AXIS; j++
        for int k; k < PARTICLES_PER_AXIS; k++
          float xd = x + ((float)i + 0.5) / 4.0
          float yd = y + ((float)j + 0.5) / 4.0
          float zd = z + ((float)k + 0.5) / 4.0

          int index = (
            i * PARTICLES_PER_AXIS + j
          ) * PARTICLES_PER_AXIS + k

          particles[index] = Particle(
            xd,
            yd,
            zd,
            xd - x - 0.5,
            yd - y - 0.5,
            zd - z - 0.5,
            blockType
          )

    active = true

  void tick()
    if not active
      return

    int expiredCount = 0

    for Particle particle in particles
      if particle.expired()
        expiredCount++
      else
        particle.tick()

    if expiredCount == PARTICLES_PER_GROUP
      active = false

  void render()
    if not active
      return

    for Particle particle in particles
      particle.update(vertexList)

    vertexList.update()
    vertexList.render()

class ParticleManager
  ParticleGroup[] groups

  void __init__()
    groups = []

  void tick()
    for ParticleGroup group in groups
      group.tick()

  void render()
    setTexture(game.atlasTexture)

    for ParticleGroup group in groups
      group.render()

  int reusableGroup()
    for ParticleGroup group in groups
      if not group.active
        return it

    return -1

  void spawn(
    float x,
    float y,
    float z,
    int blockType
  )
    int index = reusableGroup()
    if index == -1
      groups.push(ParticleGroup())
      index = groups.length - 1

    groups[index].initialize(x, y, z, blockType)

  int activeGroupCount()
    int count = 0

    for ParticleGroup group in groups
      if group.active
        count++

    return count
