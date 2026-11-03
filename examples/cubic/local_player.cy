import "game.cy"

int LOCAL_PLAYER_INVENTORY_SIZE = 9

float LOCAL_PLAYER_CAMERA_OFFSET = 0.10
float LOCAL_PLAYER_BUILD_SPEED = 5.0
float LOCAL_PLAYER_REACH = 5.0
float LOCAL_PLAYER_CONTROLLER_DEAD_ZONE = 0.20
float LOCAL_PLAYER_CONTROLLER_SPEED = 1.85

class LocalPlayer
  Entity entity
  Vector2 viewAngles
  Vector3 viewPosition
  Vector3 lookAt
  Vector3 up

  Matrix viewMatrix

  float tilt
  float oldTilt
  float bobbing
  float oldBobbing

  float fogRed
  float fogGreen
  float fogBlue
  float fogAlpha
  float fogDistance

  int[] inventory
  int inventoryIndex

  AABBPosition selected
  int selectedIndex

  int lastClick
  float lastMouseWheel

  bool previousRightShoulder
  bool previousLeftShoulder
  bool previousLeftThumb
  bool previousRightThumb

  void __init__()
    entity = Entity()
    entity.init()
    entity.footSize = 0.5
    entity.heightOffset = 1.62

    viewAngles = Vector2()
    viewPosition = Vector3()
    lookAt = Vector3(0.0, 0.0, 1.0)
    up = Vector3(0.0, 1.0, 0.0)
    viewMatrix = matrixIdentity()

    tilt = 0.0
    oldTilt = 0.0
    bobbing = 0.0
    oldBobbing = 0.0

    fogRed = 0.87450
    fogGreen = 0.93725
    fogBlue = 1.0
    fogAlpha = 1.0
    fogDistance = 1000.0

    inventory = [
      BLOCK_STONE,
      BLOCK_COBBLE,
      BLOCK_BRICK,
      BLOCK_DIRT,
      BLOCK_WOOD,
      BLOCK_LOG,
      BLOCK_LEAVES,
      BLOCK_GLASS,
      BLOCK_SLAB
    ]

    inventoryIndex = 0
    selected = AABBPosition()
    selectedIndex = 0
    lastClick = 0
    lastMouseWheel = 0.0

    previousRightShoulder = false
    previousLeftShoulder = false
    previousLeftThumb = false
    previousRightThumb = false

  Vector3 position()
    return entity.position

  Vector2 rotation()
    return entity.rotation

  AABB collisionBox()
    return entity.aabb

  int heldBlockType()
    return inventory[inventoryIndex]

  void setPosition(float x, float y, float z)
    entity.setPosition(x, y, z)
    entity.move(0.0, -entity.heightOffset, 0.0)

  void turn(float rx, float ry)
    entity.turn(rx, ry)

  void previousInventorySlot()
    inventoryIndex--

    if inventoryIndex < 0
      inventoryIndex = LOCAL_PLAYER_INVENTORY_SIZE - 1

    game.heldBlock.update()

  void nextInventorySlot()
    inventoryIndex = (inventoryIndex + 1) % LOCAL_PLAYER_INVENTORY_SIZE

    game.heldBlock.update()

  void selectInventorySlot(int index)
    if index < 0 or index >= LOCAL_PLAYER_INVENTORY_SIZE
      return

    if inventoryIndex != index
      inventoryIndex = index

      game.heldBlock.update()

  void input()
    if isKeyPressed(KEY_R)
      setPosition(game.level.spawn.x, game.level.spawn.y, game.level.spawn.z)

    if isKeyPressed(KEY_ENTER)
      game.level.spawn = entity.position.clone()

    if isKeyPressed(KEY_V)
      entity.noPhysics = not entity.noPhysics

    if isKeyPressed(KEY_ONE)
      selectInventorySlot(0)
    if isKeyPressed(KEY_TWO)
      selectInventorySlot(1)
    if isKeyPressed(KEY_THREE)
      selectInventorySlot(2)
    if isKeyPressed(KEY_FOUR)
      selectInventorySlot(3)
    if isKeyPressed(KEY_FIVE)
      selectInventorySlot(4)
    if isKeyPressed(KEY_SIX)
      selectInventorySlot(5)
    if isKeyPressed(KEY_SEVEN)
      selectInventorySlot(6)
    if isKeyPressed(KEY_EIGHT)
      selectInventorySlot(7)
    if isKeyPressed(KEY_NINE)
      selectInventorySlot(8)

    float wheel = getMouseWheel()

    if wheel < 0.0
      previousInventorySlot()
    else if wheel > 0.0
      nextInventorySlot()

    float mouseX = getMouseDeltaX()
    float mouseY = getMouseDeltaY()

    if mouseX != 0.0 or mouseY != 0.0
      turn(mouseX * 0.15, mouseY * 0.15)

    bool leftShoulder = isGamepadButtonDown(4)
    bool rightShoulder = isGamepadButtonDown(6)
    bool leftThumb = isGamepadButtonDown(11)
    bool rightThumb = isGamepadButtonDown(12)

    if rightShoulder and not previousRightShoulder
      nextInventorySlot()

    if leftShoulder and not previousLeftShoulder
      previousInventorySlot()

    if leftThumb and not previousLeftThumb
      entity.noPhysics = not entity.noPhysics

    previousRightShoulder = rightShoulder
    previousLeftShoulder = leftShoulder
    previousLeftThumb = leftThumb
    previousRightThumb = rightThumb

  void update()
    viewAngles.y = radians(entity.rotation.y)
    viewAngles.x = radians(-entity.rotation.x)

    lookAt.x = sin(viewAngles.x) * cos(viewAngles.y)
    lookAt.y = sin(viewAngles.y)
    lookAt.z = cos(viewAngles.x) * cos(viewAngles.y)

    viewPosition = entity.oldPosition.mix(
      entity.position,
      game.timer.delta
    )

    viewMatrix = matrixLookAt(
      viewPosition,
      viewPosition + lookAt,
      up
    )

    if game.level.isRenderWaterTile(
      viewPosition.x,
      viewPosition.y + LOCAL_PLAYER_CAMERA_OFFSET,
      viewPosition.z
    )
      fogRed = 0.02
      fogGreen = 0.02
      fogBlue = 0.2
      fogAlpha = 1.0
      fogDistance = 20.0

    else if game.level.isLavaTile(
      viewPosition.x,
      viewPosition.y + LOCAL_PLAYER_CAMERA_OFFSET,
      viewPosition.z
    )
      fogRed = 0.6
      fogGreen = 0.0
      fogBlue = 0.1
      fogAlpha = 1.0
      fogDistance = 1.0

    else
      fogRed = 0.87450
      fogGreen = 0.93725
      fogBlue = 1.0
      fogAlpha = 1.0
      fogDistance = 1000.0

    interact()

  void interact()
    selected = game.level.clip(
      viewPosition,
      viewPosition + lookAt * LOCAL_PLAYER_REACH
    )

    if not selected.isValid and entity.onGround
      Int3 ground = Int3(
        (int)viewPosition.x,
        (int)viewPosition.y - 2,
        (int)viewPosition.z
      )

      int groundBlockType = game.level.getTile(ground.x, ground.y, ground.z)
      if (
        not game.level.isAirTile(groundBlockType) and
        not game.level.isWaterTile(groundBlockType) and
        not game.level.isLavaTile(groundBlockType)
      )
        selected = game.level.clip(
          viewPosition,
          viewPosition + lookAt * LOCAL_PLAYER_REACH,
          ground
        )

    float controllerX = getGamepadAxis(2)
    float controllerY = getGamepadAxis(3)

    if abs(controllerX) > LOCAL_PLAYER_CONTROLLER_DEAD_ZONE or abs(controllerY) > LOCAL_PLAYER_CONTROLLER_DEAD_ZONE
      turn(
        controllerX * LOCAL_PLAYER_CONTROLLER_SPEED,
        controllerY * LOCAL_PLAYER_CONTROLLER_SPEED
      )

    bool interactLeft = isMouseButtonDown(MOUSE_BUTTON_LEFT)
    bool interactMiddle = isMouseButtonDown(MOUSE_BUTTON_MIDDLE)
    bool interactRight = isMouseButtonDown(MOUSE_BUTTON_RIGHT)

    if getGamepadAxis(4) > 0.305
      interactRight = true

    if getGamepadAxis(5) > 0.305
      interactLeft = true

    if previousRightThumb
      interactMiddle = true

    if game.timer.ticks - lastClick < (int)(game.timer.ticksPerSecond / LOCAL_PLAYER_BUILD_SPEED)
      return

    if interactLeft
      game.heldBlock.swing()

      lastClick = game.timer.ticks

    if not selected.isValid
      return

    int vx = selected.x
    int vy = selected.y
    int vz = selected.z

    if interactLeft
      int blockType = game.level.getTile(vx, vy, vz)

      if selected.destructible and not game.level.isAirTile(blockType)
        game.level.setTileWithNeighborChange(
          vx,
          vy,
          vz,
          BLOCK_AIR,
          true
        )

        game.particleManager.spawn(
            (float)vx,
            (float)vy,
            (float)vz,
            blockType
        )

    else if interactRight
      if selected.face == 0
        vy--
      if selected.face == 1
        vy++
      if selected.face == 2
        vz--
      if selected.face == 3
        vz++
      if selected.face == 4
        vx--
      if selected.face == 5
        vx++

      int blockType = game.level.getTile(vx, vy, vz)
      int heldType = heldBlockType()
      Definition heldDefinition = blockDefinitions[heldType]
      AABB heldAABB = heldDefinition.boundingBox.move(
        (float)vx,
        (float)vy,
        (float)vz
      )

      if blockType == BLOCK_AIR or game.level.isWaterTile(blockType) or game.level.isLavaTile(blockType)
        if not entity.aabb.intersects(heldAABB)
          game.level.setTileWithNeighborChange(
            vx,
            vy,
            vz,
            heldType,
            false
          )

          game.heldBlock.reset()

          selectedIndex = 0

      lastClick = game.timer.ticks

    else if interactMiddle
      int heldType = heldBlockType()
      int blockType = game.level.getTile(vx, vy, vz)

      if blockType != heldType and blockType != BLOCK_AIR and not game.level.isWaterTile(blockType) and not game.level.isLavaTile(blockType)
        inventory[inventoryIndex] = blockType

        game.heldBlock.update()

      lastClick = game.timer.ticks

  void tick()
    entity.tick()

    oldBobbing = bobbing
    oldTilt = tilt

    float moveX = 0.0
    float moveZ = 0.0
    bool jumping = false
    bool sprinting = false

    if isKeyDown(KEY_S) or isKeyDown(KEY_DOWN)
      moveZ = -0.98

    if isKeyDown(KEY_W) or isKeyDown(KEY_UP)
      moveZ = 0.98

    if isKeyDown(KEY_A) or isKeyDown(KEY_LEFT)
      moveX = 0.98

    if isKeyDown(KEY_D) or isKeyDown(KEY_RIGHT)
      moveX = -0.98

    if isKeyDown(KEY_SPACE) or isGamepadButtonDown(2)
      jumping = true

    if isKeyDown(KEY_LEFT_SHIFT)
      sprinting = true

    float leftX = getGamepadAxis(0)
    float leftY = getGamepadAxis(1)

    if leftY < -0.305
      moveZ = 0.98
    else if leftY > 0.305
      moveZ = -0.98

    if leftX < -0.61
      moveX = 0.98
    else if leftX > 0.61
      moveX = -0.98

    if entity.noPhysics
      float speed = 1.0

      if sprinting
        speed *= 4.0

      entity.velocity = lookAt * (moveZ * speed)
      Vector3 strafe = (lookAt.cross(up)).normalize()
      entity.velocity = entity.velocity - strafe * (moveX * speed)

      if jumping
        entity.velocity.y = speed

      entity.move(
        entity.velocity.x,
        entity.velocity.y,
        entity.velocity.z
      )

      bobbing = 0.0
      tilt = 0.0
      return

    bool inWater = entity.isInWater()
    bool inLava = entity.isInLava()

    if jumping
      if inWater
        entity.velocity.y += 0.04
      else if inLava
        entity.velocity.y += 0.04
      else if entity.onGround
        entity.velocity.y = 0.42

    if inWater or inLava
      entity.moveRelative(moveX, moveZ, 0.02)
      entity.move(
        entity.velocity.x,
        entity.velocity.y,
        entity.velocity.z
      )

      float speed = 0.5

      if inWater
        speed = 0.8

      entity.velocity.x *= speed
      entity.velocity.y *= speed
      entity.velocity.z *= speed
      entity.velocity.y -= 0.02

      if jumping and entity.horizontalCollision and entity.isFree(
        entity.velocity.x,
        entity.velocity.y + 0.6,
        entity.velocity.z
      )
        entity.velocity.y = 0.3
    else
      float relativeSpeed = 0.02

      if entity.onGround
        relativeSpeed = 0.1

      entity.moveRelative(moveX, moveZ, relativeSpeed)
      entity.move(
        entity.velocity.x,
        entity.velocity.y,
        entity.velocity.z
      )

      entity.velocity.x *= 0.91
      entity.velocity.y *= 0.98
      entity.velocity.z *= 0.91
      entity.velocity.y -= 0.08

      if entity.onGround
        entity.velocity.x *= 0.6
        entity.velocity.z *= 0.6

    float bob = (entity.velocity.x * entity.velocity.x + entity.velocity.z * entity.velocity.z).sqrt()
    float currentTilt = atan2(-entity.velocity.y * 0.2, 1.0) * 15.0

    if bob > 0.1
      bob = 0.1

    if not entity.onGround
      bob = 0.0

    if entity.onGround
      currentTilt = 0.0

    bobbing += (bob - bobbing) * 0.4
    tilt += (currentTilt - tilt) * 0.8
