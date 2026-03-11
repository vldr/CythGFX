int width = 500 / 5
int height = 300 / 5
int windowWidth = 500
int windowHeight = 300

int[][] cells
cells.reserve(width, height)

int value
int hue

initWindow(windowWidth, windowHeight, "Falling Sand")

bool hasInteracted
string text = "Click and hold to place sand"
Vector2 fontMetrics = measureTextEx(getFontDefault(), text, 18, 1)

while not windowShouldClose()
    beginDrawing()

    if not hasInteracted
      drawText(text, (int)(windowWidth - 1 - fontMetrics.x) / 2 , (int)(windowHeight - 1 - fontMetrics.y) / 2, 18, Color(255, 255, 255, 255))

    if isMouseButtonDown(0)
        int x = getMouseX()                                  
        int y = getMouseY()

        if x < 0
           x = 0

        float cellX = width * (float)x / windowWidth
        float cellY = height * (float)y / windowHeight

        hue = x
        hasInteracted = true

        addCell((int)cellX, (int)cellY)
        addCell((int)cellX - 1, (int)cellY)
        addCell((int)cellX + 1, (int)cellY)
        addCell((int)cellX, (int)cellY - 1)
        addCell((int)cellX, (int)cellY + 1)

    
    clearBackground(Color(0,0,0,0))
    render()
    nextGeneration()

    endDrawing()

closeWindow()


void addCell(int x, int y)
  if x >= width or y >= height or x < 0 or y < 0
    return

  cells[x][y] = hue

void nextGeneration()
  int[][] newCells

  for int x = 0; x < width; x += 1
    int[] row

    for int y = 0; y < height; y += 1
      row.push(0)

    newCells.push(row)

  for int x = 0; x < width; x += 1
    for int y = 0; y < height; y += 1
      int value = cells[x][y]
      if value
        if y + 1 < height and not cells[x][y + 1]
          newCells[x][y + 1] = value
        else if y + 1 < height and x + 1 < width and not cells[x + 1][y + 1]
          newCells[x + 1][y + 1] = value
        else if y + 1 < height and x - 1 > 0 and not cells[x - 1][y + 1]
          newCells[x - 1][y + 1] = value
        else
          newCells[x][y] = value

  cells = newCells

void render()
  int[] hsvToRgb(float h, float s, float v) 
    float r
    float g
    float b
    
    int i = (int)(h * 6)
    float f = h * 6 - i
    float p = v * (1 - s)
    float q = v * (1 - f * s)
    float t = v * (1 - (1 - f) * s)

    i %= 6

    if i == 0
      r = v
      g = t
      b = p
    else if i == 1
      r = q
      g = v
      b = p
    else if i == 2
      r = p
      g = v
      b = t
    else if i == 3
      r = p
      g = q
      b = v
    else if i == 4
      r = t
      g = p
      b = v
    else
      r = v
      g = p
      b = q

    int[] rgb
    rgb.push((int)(r * 255))
    rgb.push((int)(g * 255))
    rgb.push((int)(b * 255))

    return rgb

  for int x = 0; x < width; x += 1
    for int y = 0; y < height; y += 1
      Color color

      if cells[x][y]
        int[] rgb = hsvToRgb(cells[x][y] / (float)windowWidth, 1.0, 1.0)
        color = Color(rgb[0], rgb[1], rgb[2], 255)
      else
        color = Color(0, 0, 0, 0)
      
      int cx = windowWidth / width
      int cy = windowHeight / height

      drawRectangle(x * cx, y * cy, windowWidth/width, windowHeight/height, color)