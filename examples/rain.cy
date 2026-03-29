# Ported from https://github.com/formodx/raindrops

int RainWave_COUNT = 3
int RAINDROP_COUNT = 160
int RIPPLE_COUNT = 200

class RainDrop
    float x
    float y
    float speed
    float length

    void __init__()
        reset()
    
    void reset()
        x = (float)getRandomValue(0, screenWidth - 1)
        y = 0.0
        speed = (float)getRandomValue(500, 700)
        length = (float)getRandomValue(10, 16)

class RainRipple
    bool active
    float x
    float age
    float life
    float strength
    float spreadSpeed

class RainWave
    int count
    float amplitude

    void __init__(int count, float amplitude)
        this.count = count
        this.amplitude = amplitude

float clamp(float value, float min, float max)
    if value <= min
        return min
    if value >= max
        return max

    return value

int getWaterY(int x, float time)
    RainWave[] waves = [
        RainWave(1, 7.5),
        RainWave(2, 3.0),
        RainWave(3, 1.3)
    ]

    float y = screenHeight * 0.6
    for RainWave wave in waves
        y += sin(x * 1.0 / screenWidth * 3.14 * 2.0 * wave.count + time) * wave.amplitude

    for RainRipple ripple in ripples
        if ripple.active
            float distance = abs(ripple.x - x)
            float xx = ripple.age * ripple.spreadSpeed
            float timeFade = 1.0 - ripple.age/ripple.life

            if timeFade > 0.0
                float spaceFade = exp(-distance * 0.01)
                spaceFade *= exp(-abs(distance-xx) * 0.2)

                y += sin((distance-xx)*0.2) * ripple.strength * timeFade * spaceFade

    return (int)y

void addRainRipple(int x, float strength)
    int idx = -1
    for RainRipple ripple in ripples
        if not ripple.active
            idx = it
            break

    if idx == -1
        idx = 0
        for RainRipple ripple in ripples
            if(ripple.age / ripple.life > ripples[idx].age / ripples[idx].life)
                idx = it

    RainRipple ripple = ripples[idx]
    ripple.active = true
    ripple.x = (float)x
    ripple.age = 0.0
    ripple.life = 1.0 / 3
    ripple.strength = strength
    ripple.spreadSpeed = 100.0

int screenWidth = 1024
int screenHeight = 600

size("Rain", screenWidth, screenHeight)

RainDrop[] raindrops
raindrops.reserve(RAINDROP_COUNT)
for int i = 0; i< raindrops.length; i += 1
    raindrops[i] = RainDrop()

RainRipple[] ripples
ripples.reserve(RIPPLE_COUNT)

for int i = 0; i < ripples.length; i += 1
    ripples[i] = RainRipple()

float time

void draw(int _)
    float deltaTime = getFrameTime()
    time += deltaTime

    for RainRipple ripple in ripples
        if ripple.active
            ripple.age += deltaTime

            if ripple.age >= ripple.life
                ripple.active = false

    for RainDrop raindrop in raindrops
        raindrop.y += raindrop.speed * deltaTime

        if raindrop.y >= getWaterY((int)raindrop.x, time)
            addRainRipple((int)raindrop.x, clamp(raindrop.speed / 75, 8, 16))
            raindrop.reset()


    fill(8, 24, 48)
    clear()

    for RainDrop raindrop in raindrops
        stroke(180, 220, 255, 170)
        line((int)raindrop.x, (int)raindrop.y, (int)raindrop.x, (int)raindrop.y - (int)raindrop.length)
    
    int previousY = getWaterY(0, time)
    for int x = 1; x < screenWidth; x += 1
        int y = getWaterY(x, time)

        stroke(64, 196, 255)
        line(x - 1, previousY, x, y)

        stroke(18, 86, 140)
        line(x, y, x, screenHeight)

        previousY = y
