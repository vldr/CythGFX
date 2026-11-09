import "game.cy"

class Entity
  Vector3 position = Vector3()
  Vector3 oldPosition = Vector3()
  Vector2 rotation = Vector2()
  Vector2 oldRotation = Vector2()
  Vector3 velocity = Vector3()
  AABB aabb = AABB()

  float oldWalkDistance
  float walkDistance

  bool noPhysics
  bool onGround
  bool collision
  bool horizontalCollision
  bool slide = true

  float aabbWidth = 0.6
  float aabbHeight = 1.8
  float heightOffset
  float fallDistance
  float slideOffset
  float footSize

  void setSize(float w, float h)
    aabbWidth = w
    aabbHeight = h

  void setPosition(float x, float y, float z)
    oldPosition.x = x
    oldPosition.y = y
    oldPosition.z = z

    position.x = x
    position.y = y
    position.z = z

    velocity.x = 0.0
    velocity.y = 0.0
    velocity.z = 0.0

    float w = aabbWidth / 2.0
    float h = aabbHeight / 2.0
    aabb.x0 = x - w
    aabb.y0 = y - h
    aabb.z0 = z - w
    aabb.x1 = x + w
    aabb.y1 = y + h
    aabb.z1 = z + w

  void tick()
    oldWalkDistance = walkDistance

    oldPosition.x = position.x
    oldPosition.y = position.y
    oldPosition.z = position.z

    oldRotation.y = rotation.y
    oldRotation.x = rotation.x

  void turn(float rx, float ry)
    float ory = rotation.y
    float orx = rotation.x

    float sum = rotation.x + rx
    rotation.x = sum - 360.0 * floor(sum / 360.0)

    float turned = rotation.y - ry
    if turned < -89.9
      turned = -89.9
    if turned > 89.9
      turned = 89.9
    rotation.y = turned

    oldRotation.y = oldRotation.y + rotation.y - ory
    oldRotation.x = oldRotation.x + rotation.x - orx

  bool isFree(float ax, float ay, float az)
    AABB moved = aabb.move(ax, ay, az)
    if game.level.getTileAABBCount(moved) > 0
      return false
    return not game.level.containsAnyLiquid(moved)

  bool isInWater()
    bool inStillWater = game.level.containsLiquid(aabb.grow(0.0, -0.4, 0.0), BLOCK_STILL_WATER)
    bool inWater = game.level.containsLiquid(aabb.grow(0.0, -0.4, 0.0), BLOCK_WATER)
    return inWater or inStillWater

  bool isInLava()
    bool inStillLava = game.level.containsLiquid(aabb.grow(0.0, -0.4, 0.0), BLOCK_STILL_LAVA)
    bool inLava = game.level.containsLiquid(aabb.grow(0.0, -0.4, 0.0), BLOCK_LAVA)
    return inLava or inStillLava

  void moveRelative(float x, float z, float speed)
    float length = (x * x + z * z).sqrt()

    if length >= 0.01
      if length < 1.0
        length = 1.0

      length = speed / length
      x = x * length
      z = z * length

      float s = sin(radians(rotation.x))
      float c = cos(radians(rotation.x))

      velocity.x = velocity.x + x * c - z * s
      velocity.z = velocity.z + z * c + x * s

  void move(float ax, float ay, float az)
    if noPhysics
      aabb = aabb.move(ax, ay, az)
      position.x = (aabb.x0 + aabb.x1) / 2.0
      position.z = (aabb.z0 + aabb.z1) / 2.0
      position.y = aabb.y0 + heightOffset - slideOffset
    else
      AABB oldAABB = aabb
      float x = position.x
      float z = position.z
      float ox = ax
      float oy = ay
      float oz = az

      AABB[] cubes = game.level.getTileAABB(aabb.expand(ax, ay, az))

      for int i; i < cubes.length; i++
        ay = cubes[i].clipY(aabb, ay)

      aabb = aabb.move(0.0, ay, 0.0)
      if not slide and oy != ay
        ax = 0.0
        ay = 0.0
        az = 0.0

      for int i; i < cubes.length; i++
        ax = cubes[i].clipX(aabb, ax)

      aabb = aabb.move(ax, 0.0, 0.0)
      if not slide and ox != ax
        ax = 0.0
        ay = 0.0
        az = 0.0

      for int i; i < cubes.length; i++
        az = cubes[i].clipZ(aabb, az)

      aabb = aabb.move(0.0, 0.0, az)
      if not slide and oz != az
        ax = 0.0
        ay = 0.0
        az = 0.0

      if (onGround or (oy != ay and oy < 0.0)) and (ox != ax or oz != az) and footSize > 0.0 and slideOffset < 0.05
        float bx = ax
        float by = ay
        float bz = az
        ax = ox
        ay = footSize
        az = oz

        AABB tempAABB = aabb
        aabb = oldAABB

        cubes = game.level.getTileAABB(aabb.expand(ox, ay, oz))

        for int i; i < cubes.length; i++
          ay = cubes[i].clipY(aabb, ay)

        aabb = aabb.move(0.0, ay, 0.0)
        if not slide and oy != ay
          ax = 0.0
          ay = 0.0
          az = 0.0

        for int i; i < cubes.length; i++
          ax = cubes[i].clipX(aabb, ax)

        aabb = aabb.move(ax, 0.0, 0.0)
        if not slide and ox != ax
          ax = 0.0
          ay = 0.0
          az = 0.0

        for int i; i < cubes.length; i++
          az = cubes[i].clipZ(aabb, az)

        aabb = aabb.move(0.0, 0.0, az)
        if not slide and oz != az
          ax = 0.0
          ay = 0.0
          az = 0.0

        if bx * bx + bz * bz >= ax * ax + az * az
          ax = bx
          ay = by
          az = bz
          aabb = tempAABB
        else
          slideOffset = slideOffset + 0.5

      onGround = oy != ay and oy < 0.0
      horizontalCollision = ox != ax or oz != az
      collision = horizontalCollision or oy != ay

      if onGround
        if fallDistance > 0.0
          fallDistance = 0.0
      else if ay < 0.0
        fallDistance = fallDistance - ay

      if ox != ax
        velocity.x = 0.0
      if oy != ay
        velocity.y = 0.0
      if oz != az
        velocity.z = 0.0

      position.x = (aabb.x0 + aabb.x1) / 2.0
      position.z = (aabb.z0 + aabb.z1) / 2.0
      position.y = aabb.y0 + heightOffset - slideOffset

      walkDistance = walkDistance + ((position.x - x) * (position.x - x) + (position.z - z) * (position.z - z)).sqrt() * 0.6
      slideOffset = slideOffset * 0.4
