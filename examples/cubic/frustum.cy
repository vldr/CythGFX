import "game.cy"

class Frustum
  float[] planes
  float[] clip

  void __init__()
    planes.reserve(6 * 4)
    clip.reserve(16)

  int planeIndex(int plane, int component)
    return plane * 4 + component

  void normalizePlane(int plane)
    int base = plane * 4
    float x = planes[base]
    float y = planes[base + 1]
    float z = planes[base + 2]
    float length = (x * x + y * y + z * z).sqrt()

    if length != 0.0
      planes[base] /= length
      planes[base + 1] /= length
      planes[base + 2] /= length
      planes[base + 3] /= length

  void setPlane(int plane, float a, float b, float c, float d)
    int base = plane * 4
    planes[base] = a
    planes[base + 1] = b
    planes[base + 2] = c
    planes[base + 3] = d
    normalizePlane(plane)

  void update(Matrix projection, Matrix view)
    clip[0] = view[0] * projection[0] + view[1] * projection[4] + view[2] * projection[8] + view[3] * projection[12]
    clip[1] = view[0] * projection[1] + view[1] * projection[5] + view[2] * projection[9] + view[3] * projection[13]
    clip[2] = view[0] * projection[2] + view[1] * projection[6] + view[2] * projection[10] + view[3] * projection[14]
    clip[3] = view[0] * projection[3] + view[1] * projection[7] + view[2] * projection[11] + view[3] * projection[15]

    clip[4] = view[4] * projection[0] + view[5] * projection[4] + view[6] * projection[8] + view[7] * projection[12]
    clip[5] = view[4] * projection[1] + view[5] * projection[5] + view[6] * projection[9] + view[7] * projection[13]
    clip[6] = view[4] * projection[2] + view[5] * projection[6] + view[6] * projection[10] + view[7] * projection[14]
    clip[7] = view[4] * projection[3] + view[5] * projection[7] + view[6] * projection[11] + view[7] * projection[15]

    clip[8] = view[8] * projection[0] + view[9] * projection[4] + view[10] * projection[8] + view[11] * projection[12]
    clip[9] = view[8] * projection[1] + view[9] * projection[5] + view[10] * projection[9] + view[11] * projection[13]
    clip[10] = view[8] * projection[2] + view[9] * projection[6] + view[10] * projection[10] + view[11] * projection[14]
    clip[11] = view[8] * projection[3] + view[9] * projection[7] + view[10] * projection[11] + view[11] * projection[15]

    clip[12] = view[12] * projection[0] + view[13] * projection[4] + view[14] * projection[8] + view[15] * projection[12]
    clip[13] = view[12] * projection[1] + view[13] * projection[5] + view[14] * projection[9] + view[15] * projection[13]
    clip[14] = view[12] * projection[2] + view[13] * projection[6] + view[14] * projection[10] + view[15] * projection[14]
    clip[15] = view[12] * projection[3] + view[13] * projection[7] + view[14] * projection[11] + view[15] * projection[15]

    setPlane(0, clip[3] - clip[0], clip[7] - clip[4], clip[11] - clip[8], clip[15] - clip[12])
    setPlane(1, clip[3] + clip[0], clip[7] + clip[4], clip[11] + clip[8], clip[15] + clip[12])
    setPlane(2, clip[3] - clip[1], clip[7] - clip[5], clip[11] - clip[9], clip[15] - clip[13])
    setPlane(3, clip[3] + clip[1], clip[7] + clip[5], clip[11] + clip[9], clip[15] + clip[13])
    setPlane(4, clip[3] - clip[2], clip[7] - clip[6], clip[11] - clip[10], clip[15] - clip[14])
    setPlane(5, clip[3] + clip[2], clip[7] + clip[6], clip[11] + clip[10], clip[15] + clip[14])

  bool pointOutside(int plane, float x, float y, float z)
    int base = plane * 4
    float distance = planes[base] * x
    distance += planes[base + 1] * y
    distance += planes[base + 2] * z
    distance += planes[base + 3]
    return distance <= 0.0

  bool contains(Chunk chunk)
    float startX = (float)chunk.position.x
    float startY = (float)chunk.position.y
    float startZ = (float)chunk.position.z
    float endX = (float)(chunk.position.x + CHUNK_SIZE)
    float endY = (float)(chunk.position.y + CHUNK_SIZE)
    float endZ = (float)(chunk.position.z + CHUNK_SIZE)

    for int plane; plane < 6; plane++
      bool outside = pointOutside(plane, startX, startY, startZ)
      outside = outside and pointOutside(plane, endX, startY, startZ)
      outside = outside and pointOutside(plane, startX, endY, startZ)
      outside = outside and pointOutside(plane, endX, endY, startZ)
      outside = outside and pointOutside(plane, startX, startY, endZ)
      outside = outside and pointOutside(plane, endX, startY, endZ)
      outside = outside and pointOutside(plane, startX, endY, endZ)
      outside = outside and pointOutside(plane, endX, endY, endZ)

      if outside
        return false

    return true
