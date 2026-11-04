import "game.cy"

Vector3 MAX_VECTOR = Vector3(FLT_MAX, FLT_MAX, FLT_MAX)

class AABBPosition
  int x
  int y
  int z
  int index
  int face
  bool isValid
  bool destructible
  Vector3 vector

  void __init__()
    isValid = false
    destructible = false
    face = 0
    index = 0
    x = 0
    y = 0
    z = 0
    vector = Vector3()

class AABB
  float x0
  float y0
  float z0
  float x1
  float y1
  float z1

  void __init__()
  void __init__(float x0, float y0, float z0, float x1, float y1, float z1)
    this.x0 = x0
    this.y0 = y0
    this.z0 = z0
    this.x1 = x1
    this.y1 = y1
    this.z1 = z1

  AABB expand(float x, float y, float z)
    return AABB(
      x0 + (x < 0.0 ? x : 0.0),
      y0 + (y < 0.0 ? y : 0.0),
      z0 + (z < 0.0 ? z : 0.0),
      x1 + (x > 0.0 ? x : 0.0),
      y1 + (y > 0.0 ? y : 0.0),
      z1 + (z > 0.0 ? z : 0.0)
    )

  AABB expand(int x, int y, int z)
    return expand((float)x, (float)y, (float)z)

  AABB grow(float x, float y, float z)
    return AABB(
      x0 - x,
      y0 - y,
      z0 - z,
      x1 + x,
      y1 + y,
      z1 + z
    )

  AABB grow(int x, int y, int z)
    return grow((float)x, (float)y, (float)z)

  AABB move(float x, float y, float z)
    return AABB(
      x0 + x,
      y0 + y,
      z0 + z,
      x1 + x,
      y1 + y,
      z1 + z
    )

  AABB move(int x, int y, int z)
    return move((float)x, (float)y, (float)z)

  float clipX(AABB aabb, float velocityX)
    if aabb.y1 <= y0 or aabb.y0 >= y1 or aabb.z1 <= z0 or aabb.z0 >= z1
      return velocityX

    float max = x0 - aabb.x1 - 0.0000001
    if velocityX > 0.0 and aabb.x1 <= x0 and max < velocityX
      velocityX = max

    max = x1 - aabb.x0 + 0.0000001
    if velocityX < 0.0 and aabb.x0 >= x1 and max > velocityX
      velocityX = max

    return velocityX

  float clipY(AABB aabb, float velocityY)
    if aabb.x1 <= x0 or aabb.x0 >= x1 or aabb.z1 <= z0 or aabb.z0 >= z1
      return velocityY

    float max = y0 - aabb.y1 - 0.0000001
    if velocityY > 0.0 and aabb.y1 <= y0 and max < velocityY
      velocityY = max

    max = y1 - aabb.y0 + 0.0000001
    if velocityY < 0.0 and aabb.y0 >= y1 and max > velocityY
      velocityY = max

    return velocityY

  float clipZ(AABB aabb, float velocityZ)
    if aabb.x1 <= x0 or aabb.x0 >= x1 or aabb.y1 <= y0 or aabb.y0 >= y1
      return velocityZ

    float max = z0 - aabb.z1 - 0.0000001
    if velocityZ > 0.0 and aabb.z1 <= z0 and max < velocityZ
      velocityZ = max

    max = z1 - aabb.z0 + 0.0000001
    if velocityZ < 0.0 and aabb.z0 >= z1 and max > velocityZ
      velocityZ = max

    return velocityZ

  bool intersects(AABB aabb)
    if aabb.x1 > x0 and aabb.x0 < x1
      if aabb.y1 > y0 and aabb.y0 < y1
        return aabb.z1 > z0 and aabb.z0 < z1
      return false
    return false

  bool intersectsInner(AABB aabb)
    if aabb.x1 >= x0 and aabb.x0 <= x1
      if aabb.y1 >= y0 and aabb.y0 <= y1
        return aabb.z1 >= z0 and aabb.z0 <= z1
      return false
    return false

  bool intersectsX(Vector3 v)
    return v.y >= y0 and v.y <= y1 and v.z >= z0 and v.z <= z1

  bool intersectsY(Vector3 v)
    return v.x >= x0 and v.x <= x1 and v.z >= z0 and v.z <= z1

  bool intersectsZ(Vector3 v)
    return v.x >= x0 and v.x <= x1 and v.y >= y0 and v.y <= y1

  Vector3 intersectionX(Vector3 start, Vector3 end, float s)
    float dx = end.x - start.x
    float da = dx

    s = (s - start.x) / da

    float absDa = da
    if absDa < 0.0
      absDa = -absDa

    if absDa < 0.0000001 or s < 0.0 or s > 1.0
      return MAX_VECTOR

    return start.mix(end, s)

  Vector3 intersectionY(Vector3 start, Vector3 end, float s)
    float dy = end.y - start.y
    float da = dy

    s = (s - start.y) / da

    float absDa = da
    if absDa < 0.0
      absDa = -absDa

    if absDa < 0.0000001 or s < 0.0 or s > 1.0
      return MAX_VECTOR

    return start.mix(end, s)

  Vector3 intersectionZ(Vector3 start, Vector3 end, float s)
    float dz = end.z - start.z
    float da = dz

    s = (s - start.z) / da

    float absDa = da
    if absDa < 0.0
      absDa = -absDa

    if absDa < 0.0000001 or s < 0.0 or s > 1.0
      return MAX_VECTOR

    return start.mix(end, s)

  AABBPosition clip(Vector3 start, Vector3 end)
    Vector3 minX = intersectionX(start, end, x0)
    Vector3 maxX = intersectionX(start, end, x1)
    Vector3 minY = intersectionY(start, end, y0)
    Vector3 maxY = intersectionY(start, end, y1)
    Vector3 minZ = intersectionZ(start, end, z0)
    Vector3 maxZ = intersectionZ(start, end, z1)

    if not intersectsX(minX)
      minX = MAX_VECTOR
    if not intersectsX(maxX)
      maxX = MAX_VECTOR
    if not intersectsY(minY)
      minY = MAX_VECTOR
    if not intersectsY(maxY)
      maxY = MAX_VECTOR
    if not intersectsZ(minZ)
      minZ = MAX_VECTOR
    if not intersectsZ(maxZ)
      maxZ = MAX_VECTOR

    Vector3 intersection = MAX_VECTOR

    if minX != MAX_VECTOR
      intersection = minX

    if maxX != MAX_VECTOR and (intersection == MAX_VECTOR or start.distance(maxX) < start.distance(intersection))
      intersection = maxX

    if minY != MAX_VECTOR and (intersection == MAX_VECTOR or start.distance(minY) < start.distance(intersection))
      intersection = minY

    if maxY != MAX_VECTOR and (intersection == MAX_VECTOR or start.distance(maxY) < start.distance(intersection))
      intersection = maxY

    if minZ != MAX_VECTOR and (intersection == MAX_VECTOR or start.distance(minZ) < start.distance(intersection))
      intersection = minZ

    if maxZ != MAX_VECTOR and (intersection == MAX_VECTOR or start.distance(maxZ) < start.distance(intersection))
      intersection = maxZ

    if intersection == MAX_VECTOR
      AABBPosition aabbPosition = AABBPosition()
      aabbPosition.isValid = false

      return aabbPosition

    int face = -1
    if intersection.x == minX.x and intersection.y == minX.y and intersection.z == minX.z
      face = 4
    if intersection.x == maxX.x and intersection.y == maxX.y and intersection.z == maxX.z
      face = 5
    if intersection.x == minY.x and intersection.y == minY.y and intersection.z == minY.z
      face = 0
    if intersection.x == maxY.x and intersection.y == maxY.y and intersection.z == maxY.z
      face = 1
    if intersection.x == minZ.x and intersection.y == minZ.y and intersection.z == minZ.z
      face = 2
    if intersection.x == maxZ.x and intersection.y == maxZ.y and intersection.z == maxZ.z
      face = 3

    AABBPosition aabbPositionOut = AABBPosition()
    aabbPositionOut.isValid = true
    aabbPositionOut.face = face
    aabbPositionOut.vector = intersection

    return aabbPositionOut
