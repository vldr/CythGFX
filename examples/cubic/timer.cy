int TIMER_MAX_DELTA_TICKS = 100

class Timer
  int ticks
  int deltaTicks
  int lastSystemClock

  float ticksPerSecond
  float tickLength
  float delta

  void __init__()
    ticks = 0
    ticksPerSecond = 0.0
    tickLength = 0.0
    deltaTicks = 0
    delta = 0.0
    lastSystemClock = 0

  void init(float ticksPerSecond)
    this.ticksPerSecond = ticksPerSecond
    this.tickLength = 1000.0 / ticksPerSecond
    this.lastSystemClock = getTime()

  void update()
    int systemClock = getTime()
    delta = delta + (float)(systemClock - lastSystemClock) / tickLength
    deltaTicks = (int)delta
    delta = delta - (float)deltaTicks
    lastSystemClock = systemClock

    if deltaTicks > TIMER_MAX_DELTA_TICKS
      deltaTicks = TIMER_MAX_DELTA_TICKS

  void tick()
    ticks++
