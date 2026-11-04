import "math.cy"
import "random.cy"
import "noise.cy"
import "timer.cy"
import "level.cy"
import "chunk.cy"
import "level_generator.cy"
import "level_renderer.cy"
import "local_player.cy"
import "held_block.cy"
import "selected_block.cy"
import "particle.cy"
import "texture_manager.cy"
import "entity.cy"
import "vertex_list.cy"
import "frustum.cy"
import "skybox.cy"
import "aabb.cy"
import "block.cy"
import "resources.cy"

float FIELD_OF_VIEW = 70.0
float NEAR_PLANE = 0.01
float FAR_PLANE = 1000.0
float TICK_RATE = 20.0

string VERTEX_SHADER = "#version 100
  uniform mat4 view;
  uniform mat4 projection;
  uniform mat4 model;

  attribute vec3 position;
  attribute vec2 uv;
  attribute float shade;

  varying vec3 fragmentPosition;
  varying vec2 fragmentTextureCoordinate;
  varying float fragmentShade;

  void main() {
    fragmentPosition = (model * vec4(position, 1.0)).xyz;
    fragmentTextureCoordinate = uv;
    fragmentShade = shade;

    gl_Position = projection * view * model * vec4(position, 1.0);
  }
"

string FRAGMENT_SHADER = "#version 100
  precision highp float;

  uniform sampler2D textureSample;
  uniform vec2 fragmentOffset;
  uniform vec3 playerPosition;
  uniform float fogEnable;
  uniform float fogDistance;
  uniform vec4 fogColor;

  varying vec3 fragmentPosition;
  varying vec2 fragmentTextureCoordinate;
  varying float fragmentShade;

  void main() {
    vec4 color = texture2D(textureSample, fragmentTextureCoordinate + fragmentOffset);
    color.rgb *= fragmentShade;

    if (color.a == 0.0)
      discard;

    float distanceToPlayer = length(fragmentPosition - playerPosition);
    float factor = (fogDistance - distanceToPlayer) / fogDistance;
    factor = max(fogEnable, clamp(factor, 0.0, 1.0));

    gl_FragColor = mix(fogColor, color, factor);
  }
"

Game game = Game()

class Game
  TextureManager textureManager
  LevelRenderer levelRenderer
  LevelGenerator levelGenerator
  HeldBlock heldBlock
  SelectedBlock selectedBlock
  ParticleManager particleManager
  Random random
  Timer timer
  Level level
  LocalPlayer localPlayer

  Matrix perspectiveProjectionMatrix
  Matrix orthographicProjectionMatrix
  Matrix identityMatrix

  int shader
  int atlasTexture

  int projectionMatrixUniform
  int viewMatrixUniform
  int modelMatrixUniform

  int playerPositionUniform
  int fragmentOffsetUniform

  int fogEnableUniform
  int fogDistanceUniform
  int fogColorUniform

  int positionAttribute
  int uvAttribute
  int shadeAttribute

  int width
  int height

  bool wireMode

  void __init__()
    width = 1280
    height = 720

  void init()
    size("Cubic", width, height)

    level = Level()
    random = Random(epochTime())
    timer = Timer()
    timer.init(TICK_RATE)

    setDepthTest(true)
    setBackfaceCulling(true)
    setBlending(true)

    shader = createShader(VERTEX_SHADER, FRAGMENT_SHADER)
    setShader(shader)

    positionAttribute = getAttributeLocation(shader, "position")
    uvAttribute = getAttributeLocation(shader, "uv")
    shadeAttribute = getAttributeLocation(shader, "shade")

    fragmentOffsetUniform = getUniformLocation(shader, "fragmentOffset")
    playerPositionUniform = getUniformLocation(shader, "playerPosition")
    fogEnableUniform = getUniformLocation(shader, "fogEnable")
    fogDistanceUniform = getUniformLocation(shader, "fogDistance")
    fogColorUniform = getUniformLocation(shader, "fogColor")
    projectionMatrixUniform = getUniformLocation(shader, "projection")
    viewMatrixUniform = getUniformLocation(shader, "view")
    modelMatrixUniform = getUniformLocation(shader, "model")

    identityMatrix = matrixIdentity()
    atlasTexture = textureManager.load(terrainResourceTexture)

    localPlayer = LocalPlayer()
    levelRenderer = LevelRenderer()
    levelGenerator = LevelGenerator()
    heldBlock = HeldBlock()
    selectedBlock = SelectedBlock()
    particleManager = ParticleManager()

    levelRenderer.init()
    selectedBlock.init()

    setUniform(modelMatrixUniform, identityMatrix.data)
    setUniform(fragmentOffsetUniform, 0.0, 0.0)

    resize()
    disableCursor()

  void resize()
    width = getRenderWidth()
    height = getRenderHeight()

    if width <= 0
      width = 1

    if height <= 0
      height = 1

    setViewport(width, height)

    perspectiveProjectionMatrix = matrixPerspective(radians(FIELD_OF_VIEW), (float)width / (float)height, NEAR_PLANE, FAR_PLANE)
    orthographicProjectionMatrix = matrixOrtho(
      0.0,
      (float)width,
      (float)height,
      0.0,
      -1000.0,
      1000.0
    )

  void input()
    if isWindowResized()
      resize()

    if isKeyPressed(KEY_F1)
      wireMode = not wireMode
      setWireMode(wireMode)

    localPlayer.input()

  void render()
    input()
    timer.update()

    for int i; i < timer.deltaTicks; i++
      localPlayer.tick()
      particleManager.tick()
      level.tick()
      levelRenderer.tick()
      heldBlock.tick()
      timer.tick()

    setShader(shader)

    levelGenerator.update()
    localPlayer.update()
    levelRenderer.update(perspectiveProjectionMatrix, localPlayer.viewMatrix)

    setClearColor(localPlayer.fogRed, localPlayer.fogGreen, localPlayer.fogBlue, localPlayer.fogAlpha)
    clearColor()
    clearDepth()

    setUniform(projectionMatrixUniform, perspectiveProjectionMatrix.data)
    setUniform(viewMatrixUniform, localPlayer.viewMatrix.data)
    setUniform(modelMatrixUniform, identityMatrix.data)

    setUniform(playerPositionUniform, localPlayer.entity.position.x, localPlayer.entity.position.y, localPlayer.entity.position.z)
    
    setUniform(fogEnableUniform, 0.0)
    setUniform(fogDistanceUniform, localPlayer.fogDistance)
    setUniform(fogColorUniform, localPlayer.fogRed, localPlayer.fogGreen, localPlayer.fogBlue, localPlayer.fogAlpha)

    levelRenderer.render()
    particleManager.render()

    selectedBlock.renderPost()
    levelRenderer.renderPost()

    clearDepth()
    setUniform(fogEnableUniform, 1.0)
    setUniform(viewMatrixUniform, identityMatrix.data)
    setUniform(projectionMatrixUniform, perspectiveProjectionMatrix.data)

    heldBlock.render()