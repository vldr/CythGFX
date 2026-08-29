Tetris game = Tetris()

void draw(int time)
  game.input(time)
  game.update(time)
  game.draw()

class Tetris
  int boardWidth = 10
  int boardHeight = 20
  int cellSize = 28
  int boardX = 28
  int boardY = 28

  Color[] board

  any currentPiece
  any nextPiece

  int pieceX
  int pieceY
  int rotation

  int score
  int lines
  int lastFallTime
  int leftRepeatAt
  int rightRepeatAt
  bool gameOver

  void __init__()
    board.reserve(boardWidth * boardHeight)
    size("Tetris", 500, 620)

    nextPiece = randomPiece()
    spawnPiece()

  void reset()
    for int i = 0; i < board.length; i += 1
      board[i] = null

    score = 0
    lines = 0
    lastFallTime = 0
    leftRepeatAt = 0
    rightRepeatAt = 0
    gameOver = false

    nextPiece = randomPiece()
    spawnPiece()

  void input(int time)
    if gameOver
      if isKeyPressed(KEY_R)
        reset()
      return

    if isKeyPressed(KEY_LEFT)
      if canPlace(currentPiece, pieceX - 1, pieceY, rotation)
        pieceX -= 1
      leftRepeatAt = time + 160
    else if isKeyDown(KEY_LEFT)
      if leftRepeatAt == 0
        leftRepeatAt = time + 160
      else if time >= leftRepeatAt
        if canPlace(currentPiece, pieceX - 1, pieceY, rotation)
          pieceX -= 1
        leftRepeatAt = time + 45
    else
      leftRepeatAt = 0

    if isKeyPressed(KEY_RIGHT)
      if canPlace(currentPiece, pieceX + 1, pieceY, rotation)
        pieceX += 1
      rightRepeatAt = time + 160
    else if isKeyDown(KEY_RIGHT)
      if rightRepeatAt == 0
        rightRepeatAt = time + 160
      else if time >= rightRepeatAt
        if canPlace(currentPiece, pieceX + 1, pieceY, rotation)
          pieceX += 1
        rightRepeatAt = time + 45
    else
      rightRepeatAt = 0

    if isKeyPressed(KEY_Z)
      tryRotate(-1)

    if isKeyPressed(KEY_X) or isKeyPressed(KEY_UP)
      tryRotate(1)

    if isKeyPressed(KEY_SPACE)
      int dropped
      while canPlace(currentPiece, pieceX, pieceY + 1, rotation)
        pieceY += 1
        dropped += 1

      score += dropped * 2
      lockPiece()

  void update(int time)
    if gameOver
      return

    int fallDelay = 650 - lines * 12
    if fallDelay < 90
      fallDelay = 90

    if isKeyDown(KEY_DOWN)
      fallDelay = 55

    if lastFallTime == 0
      lastFallTime = time

    if time - lastFallTime >= fallDelay
      lastFallTime = time

      if canPlace(currentPiece, pieceX, pieceY + 1, rotation)
        pieceY += 1
      else
        lockPiece()

  void draw()
    fill(0, 0, 0)
    clear()

    drawBoard()
    drawLandingGlow()
    drawCurrentPiece()
    drawSidebar()

  void drawBoard()
    for int y = 0; y < boardHeight; y += 1
      for int x = 0; x < boardWidth; x += 1
        int index = y * boardWidth + x
        int px = boardX + x * cellSize
        int py = boardY + y * cellSize

        fill(12, 12, 12)
        rect(px + 1, py + 1, cellSize - 2, cellSize - 2)

        if board[index]
          drawBlock(px, py, board[index])

  void drawLandingGlow()
    if gameOver
      return

    int landingY = pieceY
    while canPlace(currentPiece, pieceX, landingY + 1, rotation)
      landingY += 1

    Color color = pieceColor(currentPiece)

    for int y = 0; y < 4; y += 1
      for int x = 0; x < 4; x += 1
        if cell(currentPiece, rotation, x, y)
          int boardCellX = pieceX + x
          int boardCellY = landingY + y

          if boardCellY >= 0
            int px = boardX + boardCellX * cellSize
            int py = boardY + boardCellY * cellSize

            fill(color.r / 8 + 10, color.g / 8 + 10, color.b / 8 + 10)
            rect(px + 2, py + 2, cellSize - 4, cellSize - 4)

            fill(color.r / 5 + 6, color.g / 5 + 6, color.b / 5 + 6)
            rect(px + 7, py + 7, cellSize - 14, cellSize - 14)

  void drawCurrentPiece()
    if gameOver
      return

    Color color = pieceColor(currentPiece)

    for int y = 0; y < 4; y += 1
      for int x = 0; x < 4; x += 1
        if cell(currentPiece, rotation, x, y)
          int boardCellX = pieceX + x
          int boardCellY = pieceY + y

          if boardCellY >= 0
            drawBlock(
              boardX + boardCellX * cellSize,
              boardY + boardCellY * cellSize,
              color
            )

  void drawSidebar()
    int panelX = boardX + boardWidth * cellSize + 24

    fill(250, 250, 250)
    text("TETRIS", panelX, 30, 28)
    text("Score: " + score, panelX, 78, 18)
    text("Lines: " + lines, panelX, 104, 18)

    text("Next shape:", panelX, 132, 18)

    Color nextColor = pieceColor(nextPiece)
    for int y = 0; y < 4; y += 1
      for int x = 0; x < 4; x += 1
        if cell(nextPiece, 0, x, y)
          int px = panelX + x * 20
          int py = 158 + y * 20

          setPieceColor(nextColor)
          rect(px + 2, py + 2, 16, 16)

    fill(150, 150, 150)
    text("Left/Right: move", panelX, 496, 14)
    text("Down: soft drop", panelX, 522, 14)
    text("Z / X: rotate", panelX, 548, 14)
    text("Space: hard drop", panelX, 574, 14)

    if gameOver
      fill(255, 100, 100)
      text("GAME OVER", panelX, 430, 20)
      fill(210, 210, 210)
      text("Press R", panelX, 460, 16)

  void drawBlock(int x, int y, Color color)
    setPieceColor(color)
    rect(x + 2, y + 2, cellSize - 4, cellSize - 4)

  void tryRotate(int direction)
    int newRotation = (rotation + direction + 4) % 4

    if canPlace(currentPiece, pieceX, pieceY, newRotation)
      rotation = newRotation
      return

    if canPlace(currentPiece, pieceX - 1, pieceY, newRotation)
      pieceX -= 1
      rotation = newRotation
      return

    if canPlace(currentPiece, pieceX + 1, pieceY, newRotation)
      pieceX += 1
      rotation = newRotation

  bool canPlace(any piece, int positionX, int positionY, int pieceRotation)
    for int y = 0; y < 4; y += 1
      for int x = 0; x < 4; x += 1
        if cell(piece, pieceRotation, x, y)
          int bx = positionX + x
          int by = positionY + y

          if bx < 0 or bx >= boardWidth or by >= boardHeight
            return false

          if by >= 0 and board[by * boardWidth + bx]
            return false

    return true

  void lockPiece()
    Color color = pieceColor(currentPiece)

    for int y = 0; y < 4; y += 1
      for int x = 0; x < 4; x += 1
        if cell(currentPiece, rotation, x, y)
          int bx = pieceX + x
          int by = pieceY + y

          if by < 0
            gameOver = true
          else
            board[by * boardWidth + bx] = color

    if gameOver
      return

    clearLines()
    spawnPiece()

  void clearLines()
    int cleared

    for int y = boardHeight - 1; y >= 0; y -= 1
      bool full = true

      for int x = 0; x < boardWidth; x += 1
        if not board[y * boardWidth + x]
          full = false

      if full
        cleared += 1

        for int row = y; row > 0; row -= 1
          for int x = 0; x < boardWidth; x += 1
            board[row * boardWidth + x] = board[(row - 1) * boardWidth + x]

        for int x = 0; x < boardWidth; x += 1
          board[x] = null

        y += 1

    if cleared == 1
      score += 100
    else if cleared == 2
      score += 300
    else if cleared == 3
      score += 500
    else if cleared >= 4
      score += 800

    lines += cleared

  void spawnPiece()
    currentPiece = nextPiece
    nextPiece = randomPiece()

    pieceX = 3
    pieceY = -1
    rotation = 0

    if not canPlace(currentPiece, pieceX, pieceY, rotation)
      gameOver = true

  any randomPiece()
    int kind = getRandomValue(0, 6)

    if kind == 0
      return IPiece()
    else if kind == 1
      return OPiece()
    else if kind == 2
      return TPiece()
    else if kind == 3
      return JPiece()
    else if kind == 4
      return LPiece()
    else if kind == 5
      return SPiece()

    return ZPiece()

  Color pieceColor(any piece)
    match piece
      case IPiece
        return piece.color
      case OPiece
        return piece.color
      case TPiece
        return piece.color
      case JPiece
        return piece.color
      case LPiece
        return piece.color
      case SPiece
        return piece.color
      case ZPiece
        return piece.color
      default
        return null

  bool cell(any piece, int pieceRotation, int x, int y)
    match piece
      case IPiece
        return piece.cell(pieceRotation, x, y)
      case OPiece
        return piece.cell(pieceRotation, x, y)
      case TPiece
        return piece.cell(pieceRotation, x, y)
      case JPiece
        return piece.cell(pieceRotation, x, y)
      case LPiece
        return piece.cell(pieceRotation, x, y)
      case SPiece
        return piece.cell(pieceRotation, x, y)
      case ZPiece
        return piece.cell(pieceRotation, x, y)
      default
        return false

  void setPieceColor(Color color)
    fill(color.r, color.g, color.b)

class Color
  int r
  int g
  int b

  void __init__(int r, int g, int b)
    this.r = r
    this.g = g
    this.b = b

class IPiece
  Color color = Color(70, 220, 235)

  bool cell(int pieceRotation, int x, int y)
    int r = pieceRotation % 4
    if r == 0 or r == 2
      return y == 1 and x >= 0 and x <= 3
    return x == 2 and y >= 0 and y <= 3

class OPiece
  Color color = Color(245, 220, 70)

  bool cell(int pieceRotation, int x, int y)
    return (x == 1 or x == 2) and (y == 1 or y == 2)

class TPiece
  Color color = Color(180, 80, 220)

  bool cell(int pieceRotation, int x, int y)
    int r = pieceRotation % 4
    if r == 0
      return (y == 0 and x == 1) or (y == 1 and x >= 0 and x <= 2)
    else if r == 1
      return (x == 1 and y >= 0 and y <= 2) or (x == 2 and y == 1)
    else if r == 2
      return (y == 1 and x >= 0 and x <= 2) or (y == 2 and x == 1)
    return (x == 1 and y >= 0 and y <= 2) or (x == 0 and y == 1)

class JPiece
  Color color = Color(70, 100, 230)

  bool cell(int pieceRotation, int x, int y)
    int r = pieceRotation % 4
    if r == 0
      return (x == 0 and y == 0) or (y == 1 and x >= 0 and x <= 2)
    else if r == 1
      return (x == 1 and y >= 0 and y <= 2) or (x == 2 and y == 0)
    else if r == 2
      return (y == 1 and x >= 0 and x <= 2) or (x == 2 and y == 2)
    return (x == 1 and y >= 0 and y <= 2) or (x == 0 and y == 2)

class LPiece
  Color color = Color(245, 150, 55)

  bool cell(int pieceRotation, int x, int y)
    int r = pieceRotation % 4
    if r == 0
      return (x == 2 and y == 0) or (y == 1 and x >= 0 and x <= 2)
    else if r == 1
      return (x == 1 and y >= 0 and y <= 2) or (x == 2 and y == 2)
    else if r == 2
      return (y == 1 and x >= 0 and x <= 2) or (x == 0 and y == 2)
    return (x == 1 and y >= 0 and y <= 2) or (x == 0 and y == 0)

class SPiece
  Color color = Color(85, 210, 100)

  bool cell(int pieceRotation, int x, int y)
    int r = pieceRotation % 4
    if r == 0 or r == 2
      return (y == 0 and (x == 1 or x == 2)) or (y == 1 and (x == 0 or x == 1))
    return (x == 1 and (y == 0 or y == 1)) or (x == 2 and (y == 1 or y == 2))

class ZPiece
  Color color = Color(230, 70, 80)

  bool cell(int pieceRotation, int x, int y)
    int r = pieceRotation % 4
    if r == 0 or r == 2
      return (y == 0 and (x == 0 or x == 1)) or (y == 1 and (x == 1 or x == 2))
    return (x == 2 and (y == 0 or y == 1)) or (x == 1 and (y == 1 or y == 2))