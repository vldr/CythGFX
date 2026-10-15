# Ported from https://github.com/tsoding/ping-pong-love-remastered

int BALL_SIZE = 20
int PADDLE_PADDING = 4 * BALL_SIZE
int PADDLE_LENGTH = BALL_SIZE * 6
int PADDLE_THICKNESS = BALL_SIZE
int NET_COUNT = 51
int NET_GIRTH = 3
int DIGIT_SIZE = BALL_SIZE

float BALL_SPEED = 400.0
float PADDLE_SPEED = BALL_SPEED * 1.2

int width = 1280
int height = 720

float ballX = (float)width / 2.0 - (float)BALL_SIZE / 2.0
float ballY = (float)height / 2.0 - (float)BALL_SIZE / 2.0
float ballDX = -1.0
float ballDY = 1.0

float paddleLeftY = (float)height / 2.0 - (float)PADDLE_LENGTH / 2.0
float paddleRightY = (float)height / 2.0 - (float)PADDLE_LENGTH / 2.0

int scoreLeft
int scoreRight

int lastTime

int[][][] digits = [
  [[1,1,1], [1,0,1], [1,0,1], [1,0,1], [1,1,1]],
  [[0,1,0], [0,1,0], [0,1,0], [0,1,0], [0,1,0]],
  [[1,1,1], [0,0,1], [1,1,1], [1,0,0], [1,1,1]],
  [[1,1,1], [0,0,1], [1,1,1], [0,0,1], [1,1,1]],
  [[1,0,1], [1,0,1], [1,1,1], [0,0,1], [0,0,1]],
  [[1,1,1], [1,0,0], [1,1,1], [0,0,1], [1,1,1]],
  [[1,1,1], [1,0,0], [1,1,1], [1,0,1], [1,1,1]],
  [[1,1,1], [0,0,1], [0,0,1], [0,0,1], [0,0,1]],
  [[1,1,1], [1,0,1], [1,1,1], [1,0,1], [1,1,1]],
  [[1,1,1], [1,0,1], [1,1,1], [0,0,1], [1,1,1]]
]

size("Pong", width, height)

void draw(int time)
  float dt = (time - lastTime) / 1000.0
  lastTime = time

  input(dt)
  update(dt)
  draw()

void draw()
  fill(32, 30, 24)
  clear()

  fill(WHITE)
  float segmentLength = (float)height / (float)NET_COUNT

  for int i = 0; i < NET_COUNT; i += 1
    if i % 2 == 0
      rect(
        width / 2 - NET_GIRTH / 2,
        (int)(i * segmentLength),
        NET_GIRTH,
        (int)(segmentLength / 2.0)
      )

  rect(
    (int)ballX,
    (int)ballY,
    BALL_SIZE,
    BALL_SIZE
  )

  rect(
    PADDLE_PADDING,
    (int)paddleLeftY,
    PADDLE_THICKNESS,
    PADDLE_LENGTH
  )

  rect(
    width - PADDLE_PADDING - PADDLE_THICKNESS,
    (int)paddleRightY,
    PADDLE_THICKNESS,
    PADDLE_LENGTH
  )

  int leftWidth = numberWidth(scoreLeft)

  renderNumber(
    scoreLeft,
    width / 2 - leftWidth - 2 * DIGIT_SIZE,
    2 * DIGIT_SIZE
  )

  renderNumber(
    scoreRight,
    width / 2 + 2 * DIGIT_SIZE,
    2 * DIGIT_SIZE
  )

bool checkRectsCollision(
  float x1, float y1, float w1, float h1,
  float x2, float y2, float w2, float h2
)
  return not (
    x1 + w1 < x2 or
    x2 + w2 < x1 or
    y1 + h1 < y2 or
    y2 + h2 < y1
  )

int countDigits(int n)
  if n == 0
    return 1

  if n < 0
    n *= -1

  int count = 0
  while n > 0
    count += 1
    n /= 10

  return count

int numberWidth(int n)
  return countDigits(n) * 4 * DIGIT_SIZE - DIGIT_SIZE

void renderDigit(int digit, int x, int y)
  for int[] row in digits[digit]
    int cellY = it

    for int cell in row
      int cellX = it

      if cell
        rect(
          x + cellX * DIGIT_SIZE,
          y + cellY * DIGIT_SIZE,
          DIGIT_SIZE,
          DIGIT_SIZE
        )

void renderNumber(int n, int x, int y)
  if n == 0
    renderDigit(0, x, y)
    return

  int count = countDigits(n)
  x += (count - 1) * 4 * DIGIT_SIZE

  while n > 0
    renderDigit(n % 10, x, y)

    n = n / 10
    x -= 4 * DIGIT_SIZE

void resetBall(int direction)
  ballX = (float)width / 2.0 - (float)BALL_SIZE / 2.0
  ballY = (float)height / 2.0 - (float)BALL_SIZE / 2.0
  ballDX = (float)direction
  ballDY = 1.0

void input(float dt)
  float paddleSpeed = PADDLE_SPEED * dt
  
  if isKeyDown(KEY_S)
    float nextY = paddleLeftY + paddleSpeed
    
    if nextY + (float)PADDLE_LENGTH <= (float)height
      if not checkRectsCollision(
        ballX, ballY, (float)BALL_SIZE, (float)BALL_SIZE,
        (float)PADDLE_PADDING, nextY,
        (float)PADDLE_THICKNESS, (float)PADDLE_LENGTH
      )
        paddleLeftY = nextY

  if isKeyDown(KEY_W)
    float nextY = paddleLeftY - paddleSpeed
    if nextY >= 0.0
      if not checkRectsCollision(
        ballX, ballY, (float)BALL_SIZE, (float)BALL_SIZE,
        (float)PADDLE_PADDING, nextY,
        (float)PADDLE_THICKNESS, (float)PADDLE_LENGTH
      )
        paddleLeftY = nextY

  float rightX = (float)width - (float)PADDLE_PADDING - (float)PADDLE_THICKNESS

  if isKeyDown(KEY_DOWN)
    float nextY = paddleRightY + paddleSpeed
    if nextY + (float)PADDLE_LENGTH <= (float)height
      if not checkRectsCollision(
        ballX, ballY, (float)BALL_SIZE, (float)BALL_SIZE,
        rightX, nextY,
        (float)PADDLE_THICKNESS, (float)PADDLE_LENGTH
      )
        paddleRightY = nextY

  if isKeyDown(KEY_UP)
    float nextY = paddleRightY - paddleSpeed
    if nextY >= 0.0
      if not checkRectsCollision(
        ballX, ballY, (float)BALL_SIZE, (float)BALL_SIZE,
        rightX, nextY,
        (float)PADDLE_THICKNESS, (float)PADDLE_LENGTH
      )
        paddleRightY = nextY

void update(float dt)
  if dt < 0.0
    dt = 0.0

  if dt > 0.05
    dt = 0.05

  float leftX = (float)PADDLE_PADDING
  float rightX = (float)width - (float)PADDLE_PADDING - (float)PADDLE_THICKNESS
  float nextX = ballX + ballDX * BALL_SPEED * dt

  if checkRectsCollision(
    nextX, ballY, (float)BALL_SIZE, (float)BALL_SIZE,
    leftX, paddleLeftY,
    (float)PADDLE_THICKNESS, (float)PADDLE_LENGTH
  )
    if ballDX < 0.0
      ballDX = -ballDX
      ballX = leftX + (float)PADDLE_THICKNESS

  else if checkRectsCollision(
    nextX, ballY, (float)BALL_SIZE, (float)BALL_SIZE,
    rightX, paddleRightY,
    (float)PADDLE_THICKNESS, (float)PADDLE_LENGTH
  )
    if ballDX > 0.0
      ballDX = -ballDX
      ballX = rightX - (float)BALL_SIZE
  else if nextX < 0.0
    scoreRight += 1
    resetBall(1)
  else if nextX + (float)BALL_SIZE >= (float)width
    scoreLeft += 1
    resetBall(-1)
  else
    ballX = nextX

  float nextY = ballY + ballDY * BALL_SPEED * dt
  if nextY < 0.0
    ballY = 0.0
    ballDY = 1.0

  else if nextY + (float)BALL_SIZE >= (float)height
    ballY = (float)height - (float)BALL_SIZE
    ballDY = -1.0

  else
    ballY = nextY
