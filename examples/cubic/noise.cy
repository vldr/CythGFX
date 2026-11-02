import "game.cy"

class PerlinNoise
  int[] hash

  void __init__(Random random)
    hash = []
    for int i; i < 256; i++
      hash.push(0)

    for int i; i < 512; i++
      hash.push(0)

    for int i; i < 256; i++
      hash[i] = i

    for int i; i < 256; i++
      int r1 = random.integerRange(0, 256 - i - 1) + i
      int r2 = hash[i]
      hash[i] = hash[r1]
      hash[r1] = r2
      hash[i + 256] = hash[i]

  float f(float x)
    return x * x * x * (x * (x * 6.0 - 15.0) + 10.0)

  float lerp(float t, float a, float b)
    return a + t * (b - a)

  float grad(int i, float x, float y, float z)
    i = i & 15
    float a = i < 8 ? x : y
    float b = i < 4 ? y : (i != 12 and i != 14 ? z : x)
    return ((i & 1) == 0 ? a : -a) + ((i & 2) == 0 ? b : -b)

  float compute(float x, float y)
    float vx = x
    float vy = y
    float vz = 0.0
    int ix = (int)vx & 255
    int iy = (int)vy & 255
    int iz = (int)vz & 255

    vx -= floorTo(vx)
    vy -= floorTo(vy)
    vz -= floorTo(vz)

    float xd = f(vx)
    float yd = f(vy)
    float zd = f(vz)

    int aaa = hash[hash[hash[ix] + iy] + iz]
    int aba = hash[hash[hash[ix] + iy + 1] + iz]
    int aab = hash[hash[hash[ix] + iy] + iz + 1]
    int abb = hash[hash[hash[ix] + iy + 1] + iz + 1]
    int baa = hash[hash[hash[ix + 1] + iy] + iz]
    int bba = hash[hash[hash[ix + 1] + iy + 1] + iz]
    int bab = hash[hash[hash[ix + 1] + iy] + iz + 1]
    int bbb = hash[hash[hash[ix + 1] + iy + 1] + iz + 1]

    float l1 = lerp(xd, grad(aaa, vx, vy, vz), grad(baa, vx - 1.0, vy, vz))
    float l2 = lerp(xd, grad(aba, vx, vy - 1.0, vz), grad(bba, vx - 1.0, vy - 1.0, vz))
    float l3 = lerp(xd, grad(aab, vx, vy, vz - 1.0), grad(bab, vx - 1.0, vy, vz - 1.0))
    float l4 = lerp(xd, grad(abb, vx, vy - 1.0, vz - 1.0), grad(bbb, vx - 1.0, vy - 1.0, vz - 1.0))
    return lerp(zd, lerp(yd, l1, l2), lerp(yd, l3, l4))

class OctaveNoise
  int octaveCount
  PerlinNoise[] noises

  void __init__(Random random, int octaveCount)
    noises = []
    this.octaveCount = octaveCount

    for int i; i < octaveCount; i++
      noises.push(PerlinNoise(random))

  float compute(float x, float y)
    float a = 0.0
    float b = 1.0

    for int i; i < octaveCount; i++
      a += noises[i].compute(x / b, y / b) * b
      b *= 2.0

    return a

class CombinedNoise
  OctaveNoise noise1
  OctaveNoise noise2

  void __init__(OctaveNoise noise1, OctaveNoise noise2)
    this.noise1 = noise1
    this.noise2 = noise2

  float compute(float x, float y)
    return noise1.compute(x + noise2.compute(x, y), y)
