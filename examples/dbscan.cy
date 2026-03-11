# Ported from https://github.com/tsoding/skibidi-scan/

Color LIGHTGRAY = Color(200, 200, 200, 255) 
Color GRAY      = Color(130, 130, 130, 255) 
Color DARKGRAY  = Color(80, 80, 80, 255)    
Color YELLOW    = Color(253, 249, 0, 255)   
Color GOLD      = Color(255, 203, 0, 255)   
Color ORANGE    = Color(255, 161, 0, 255)   
Color PINK      = Color(255, 109, 194, 255) 
Color RED       = Color(230, 41, 55, 255)   
Color MAROON    = Color(190, 33, 55, 255)   
Color GREEN     = Color(0, 228, 48, 255)    
Color LIME      = Color(0, 158, 47, 255)    
Color DARKGREEN = Color(0, 117, 44, 255)    
Color SKYBLUE   = Color(102, 191, 255, 255) 
Color BLUE      = Color(0, 121, 241, 255)   
Color DARKBLUE  = Color(0, 82, 172, 255)    
Color PURPLE    = Color(200, 122, 255, 255) 
Color VIOLET    = Color(135, 60, 190, 255)  
Color DARKPURPLE= Color(112, 31, 126, 255)  
Color BEIGE     = Color(211, 176, 131, 255) 
Color BROWN     = Color(127, 106, 79, 255)  
Color DARKBROWN = Color(76, 63, 47, 255)    
Color WHITE     = Color(255, 255, 255, 255) 
Color BLACK     = Color(0, 0, 0, 255)       
Color BLANK     = Color(0, 0, 0, 0)
Color MAGENTA   = Color(255, 0, 255, 255)   
Color RAYWHITE  = Color(245, 245, 245, 255)

Color[] colors = [
    LIME,
    SKYBLUE,
    PURPLE,
    RED,
    BEIGE,
    GOLD,
    BLUE,
    GREEN,
    DARKBLUE,
    VIOLET,
    YELLOW,
    DARKBROWN,
    MAGENTA,
    DARKPURPLE,
    ORANGE,
    DARKGREEN,
    BROWN,
    PINK,
    MAROON
]

Color POINT_COLOR = RED
Color VISITED_COLOR = BLUE

int MOUSE_BUTTON_LEFT = 0
int KEY_R = 82
int KEY_SPACE = 32

float POINT_RADIUS = 10
float DBSCAN_RADIUS = 50
int DBSCAN_MINPTS = 4

class Point
    Vector2 position
    int label

    float distance(Point other)
        float dx = position.x - other.position.x
        float dy = position.y - other.position.y

        return (dx * dx + dy * dy).sqrt()

void getNeighbors(Point[] points, int target, float radius, int[] neighbors)
    if target >= points.length
        return
    for int index = 0; index < points.length; index += 1
        if index == target
            continue

        if points[index].distance(points[target]) <= radius
            neighbors.push(index)

void bfsCluster(Point[] points)
    for Point point in points
        point.label = -1

    for int label = 1; true; label += 1
        wave.clear()

        for int target = 0; target < points.length; target += 1
            if points[target].label < 0
                neighbors.clear()

                getNeighbors(points, target, DBSCAN_RADIUS, neighbors)

                if neighbors.length + 1 < DBSCAN_MINPTS
                  points[target].label = 0
                else
                  points[target].label = label
                  wave.push(target)
                  break

        if wave.length == 0
          break

        while wave.length > 0
            nextWave.clear()
            for int target in wave
                neighbors.clear()

                getNeighbors(points, target, DBSCAN_RADIUS, neighbors)
                if neighbors.length + 1 < DBSCAN_MINPTS
                  continue
                for int nbor in neighbors
                    if points[nbor].label <= 0
                      nextWave.push(nbor)
                      points[nextWave[nextWave.length - 1]].label = label

            int[] previousWave = wave
            wave = nextWave 
            nextWave = previousWave

int[] wave
int[] nextWave
int[] neighbors
Point[] points
bool showRadius = true

initWindow(800, 600, "DBSCAN")
setTargetFPS(60)

while not windowShouldClose()
    if isMouseButtonPressed(MOUSE_BUTTON_LEFT)
        Point point = Point()
        point.position = getMousePosition()
        point.label = -1

        points.push(point)
    
    if isKeyPressed(KEY_R)
        showRadius = not showRadius
    
    if isKeyPressed(KEY_SPACE)
        bfsCluster(points)

    beginDrawing()
    clearBackground(Color(0,0,0,0))

    for Point point in points
        Color color = GRAY
        if point.label > 0
            color = colors[point.label % colors.length]

        drawCircleV(point.position, POINT_RADIUS, color)

        if showRadius
            drawRing(point.position, DBSCAN_RADIUS, DBSCAN_RADIUS + 2, 0, 360, 69, color)

        drawText((string)point.label, (int)point.position.x, (int)point.position.y, 28, WHITE)

    endDrawing()
closeWindow()