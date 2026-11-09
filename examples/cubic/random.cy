void limbs8FromInt(int[] limbs, int value)
  limbs[0] = value & 0xFF
  limbs[1] = value >> 8 & 0xFF
  limbs[2] = value >> 16 & 0xFF
  limbs[3] = value >> 24 & 0xFF
  limbs[4] = 0
  limbs[5] = 0
  limbs[6] = 0
  limbs[7] = 0

void limbs8Copy(int[] dest, int[] src)
  for int i; i < 8; i++
    dest[i] = src[i]

void limbs8Zero(int[] limbs)
  for int i; i < 8; i++
    limbs[i] = 0

void limbs8Xor(int[] a, int[] b)
  for int i; i < 8; i++
    a[i] = a[i] ^ b[i]

void limbs8Shr1(int[] limbs)
  int carry = 0
  for int i; i < 8; i++
    int bit = limbs[7 - i] & 1
    limbs[7 - i] = limbs[7 - i] >> 1 | carry << 7
    carry = bit

void limbs8Shl1(int[] limbs)
  int carry = 0
  for int i; i < 8; i++
    int bit = limbs[i] >> 7 & 1
    limbs[i] = limbs[i] << 1 & 0xFF | carry
    carry = bit

void limbs8Shr(int[] limbs, int n)
  for int i; i < n; i++
    limbs8Shr1(limbs)

void limbs8Shl(int[] limbs, int n)
  for int i; i < n; i++
    limbs8Shl1(limbs)

void limbs8Mul(int[] out, int[] a, int[] b)
  int[] temp
  for int i; i < 16; i++
    temp.push(0)

  for int i; i < 8; i++
    for int j; j < 8; j++
      temp[i + j] += a[i] * b[j]

  for int i; i < 15; i++
    temp[i + 1] += temp[i] >> 8
    temp[i] = temp[i] & 0xFF

  for int i; i < 8; i++
    out[i] = temp[i] & 0xFF

int limbs8Mod(int[] limbs, int m)
  int r = 0
  for int i; i < 8; i++
    int byteValue = limbs[7 - i]
    r = (r * 16 + (byteValue >> 4 & 0xF)) % m
    r = (r * 16 + (byteValue & 0xF)) % m
  return r

class Random
  int[] state
  int[] product

  void __init__(int seed)
    state = [0, 0, 0, 0, 0, 0, 0, 0]
    product = [0, 0, 0, 0, 0, 0, 0, 0]
    init(seed)

  void init(int seed)
    limbs8FromInt(state, seed)

  void integer()
    int[] temp = [0, 0, 0, 0, 0, 0, 0, 0]
    int[] RANDOM_MULTIPLIER = [
      23, 135, 51, 54, 119, 101, 33, 88
    ]

    limbs8Copy(temp, state)
    limbs8Shr(temp, 12)
    limbs8Xor(state, temp)

    limbs8Copy(temp, state)
    limbs8Shl(temp, 25)
    limbs8Xor(state, temp)

    limbs8Copy(temp, state)
    limbs8Shr(temp, 27)
    limbs8Xor(state, temp)

    limbs8Mul(product, state, RANDOM_MULTIPLIER)

  int integerRange(int min, int max)
    integer()
    return min + limbs8Mod(product, max + 1 - min)

  float uniform()
    integer()
    float b0 = (float)product[7] / 256.0
    float b1 = (float)product[6] / 65536.0
    float b2 = (float)product[5] / 16777216.0
    float b3 = (float)product[4] / 4294967296.0
    return b0 + b1 + b2 + b3

  float uniformRange(float min, float max)
    return min + uniform() * (max - min)
