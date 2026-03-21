#include <math.h>
#include <stdbool.h>
#include <stdio.h>
#include <cyth.h>
#include <string.h>
#include <raylib.h>
#include <rlgl.h>

typedef struct {
  int id;
  int width;
  int height;
  CyArray* data;
} Img;

typedef struct {
  int width;
  int height;
} Size;

typedef void(*DrawFunc)(int);

Color fill_color;
Color stroke_color;

static void print(CyString* string) {
  fwrite(string->data, 1, string->size, stdout);
  fflush(stdout);
}

static void println(CyString* string) {
  fwrite(string->data, 1, string->size, stdout);
  fwrite("\n", 1, 1, stdout);
}

static void clear(void) {
  ClearBackground(fill_color);
}

static void size(CyString* title, int width, int height) {
  InitWindow(width, height, title->data);
}

static void fill(int r, int g, int b) {
  fill_color.r = r;
  fill_color.g = g;
  fill_color.b = b;
  fill_color.a = 255;
}

static void fill2(int r, int g, int b, int a) {
  fill_color.r = r;
  fill_color.g = g;
  fill_color.b = b;
  fill_color.a = a;
}

static void stroke(int r, int g, int b) {
  stroke_color.r = r;
  stroke_color.g = g;
  stroke_color.b = b;
  stroke_color.a = 255;
}

static void stroke2(int r, int g, int b, int a) {
  stroke_color.r = r;
  stroke_color.g = g;
  stroke_color.b = b;
  stroke_color.a = a;
}

static void rect(int x, int y, int width, int height) {
  DrawRectangle(x, y, width, height, fill_color);
}

static void circle(int x, int y, int radius) {
  DrawCircle(x, y, radius, fill_color);
}

static void line(int x0, int y0, int x1, int y1) {
  DrawLine(x0, y0, x1, y1, stroke_color);
}

static void text(CyString* text, int x, int y, int fontSize) {
  DrawText(text->data, x, y, fontSize, fill_color);
}

static Size* textSize(CyString* text, int fontSize) {
  Vector2 size = MeasureTextEx(GetFontDefault(), text->data, fontSize, 1);
  Size* text_size = cyth_alloc(true, sizeof(Size));
  text_size->width = size.x;
  text_size->height = size.y;

  return text_size;
}

static int createImage(int width, int height) {
  return rlLoadTexture(NULL, width, height, PIXELFORMAT_UNCOMPRESSED_R8G8B8, 1);
}

static void clearImage(Img* image) {
  if (!image)
    return;

  if (image->data->size != image->width * image->height * 3)
    return;

  unsigned char* data = image->data->data;
  for (int i = 0; i < image->width * image->height * 3; i += 3) {
    data[i] = fill_color.r;
    data[i + 1] = fill_color.g;
    data[i + 2] = fill_color.b;
  }
}

static void image(Img* image, int x, int y) {
  if (!image)
    return;

  if (image->data->size != image->width * image->height * 3)
    return; 

  Texture2D texture = {
    .id = image->id,
    .width = image->width,
    .height = image->height,
    .format = PIXELFORMAT_UNCOMPRESSED_R8G8B8, 
    .mipmaps = 1
  };

  UpdateTexture(texture, image->data->data);
  DrawTexture(texture, x, y, (Color){ 255, 255, 255, 255 });
}

int main(int argc, char **argv) {
  SetConfigFlags(FLAG_VSYNC_HINT);
  SetConfigFlags(FLAG_MSAA_4X_HINT);
  SetTraceLogLevel(LOG_ERROR); 

  CyVM* vm = cyth_init();
  cyth_load_function(vm, "void size(string title, int width, int height)", (uintptr_t)size);
  cyth_load_function(vm, "void clear()", (uintptr_t)clear);
  cyth_load_function(vm, "void fill(int r, int g, int b)", (uintptr_t)fill);
  cyth_load_function(vm, "void fill(int r, int g, int b, int a)", (uintptr_t)fill2);
  cyth_load_function(vm, "void stroke(int r, int g, int b)", (uintptr_t)stroke);
  cyth_load_function(vm, "void stroke(int r, int g, int b, int a)", (uintptr_t)stroke2);
  cyth_load_function(vm, "void rect(int x, int y, int width, int height)", (uintptr_t)rect);
  cyth_load_function(vm, "void circle(int x, int y, int radius)", (uintptr_t)circle);
  cyth_load_function(vm, "void line(int x0, int y0, int x1, int y1)", (uintptr_t)line);
  cyth_load_function(vm, "void image(Image image, int x, int y)", (uintptr_t)image);
  cyth_load_function(vm, "int createImage(int width, int height)", (uintptr_t)createImage);
  cyth_load_function(vm, "void clearImage(Image image)", (uintptr_t)clearImage);
  cyth_load_function(vm, "void text(string text, int x, int y, int fontSize)", (uintptr_t)text);
  cyth_load_function(vm, "Size textSize(string text, int fontSize)", (uintptr_t)textSize);
  cyth_load_function(vm, "bool isKeyDown(int key)", (uintptr_t)IsKeyDown);
  cyth_load_function(vm, "bool isKeyUp(int key)", (uintptr_t)IsKeyUp);
  cyth_load_function(vm, "bool isKeyPressed(int key)", (uintptr_t)IsKeyPressed);
  cyth_load_function(vm, "bool isKeyReleased(int key)", (uintptr_t)IsKeyReleased);
  cyth_load_function(vm, "bool isMouseButtonDown(int button)", (uintptr_t)IsMouseButtonDown);
  cyth_load_function(vm, "bool isMouseButtonUp(int button)", (uintptr_t)IsMouseButtonUp);
  cyth_load_function(vm, "bool isMouseButtonPressed(int button)", (uintptr_t)IsMouseButtonPressed);
  cyth_load_function(vm, "bool isMouseButtonReleased(int button)", (uintptr_t)IsMouseButtonReleased);
  cyth_load_function(vm, "float getFrameTime()", (uintptr_t)GetFrameTime);
  cyth_load_function(vm, "int getMouseX()", (uintptr_t)GetMouseX);
  cyth_load_function(vm, "int getMouseY()", (uintptr_t)GetMouseY);
  cyth_load_function(vm, "int getRandomValue(int min, int max)", (uintptr_t)GetRandomValue);
  cyth_load_function(vm, "float cos(float a)", (uintptr_t)cosf);
  cyth_load_function(vm, "float sin(float a)", (uintptr_t)sinf);
  cyth_load_function(vm, "float tan(float a)", (uintptr_t)tanf);
  cyth_load_function(vm, "float exp(float a)", (uintptr_t)expf);
  cyth_load_function(vm, "float abs(float a)", (uintptr_t)fabsf);
  cyth_load_function(vm, "float pow(float a, float b)", (uintptr_t)powf);
  cyth_load_function(vm, "void print(string a)", (uintptr_t)print);
  cyth_load_function(vm, "void println(string a)", (uintptr_t)println);
  cyth_load_string(vm,
    "class Image\n"
    "  int id\n"
    "  int width\n"
    "  int height\n"
    "  char[] data\n"

    "  void __init__(int width, int height)\n"
    "    this.id = createImage(width, height)\n"
    "    this.width = width\n"
    "    this.height = height\n"
    "    this.data.reserve(width * height * 3)\n"

    "  void clear()\n"
    "    clearImage(this)\n"

    "  void draw()\n"
    "    image(this, 0, 0)\n"

    "  void draw(int x, int y)\n"
    "    image(this, x, y)\n"

    "class Size\n"
    "  int width\n"
    "  int height\n"

    "int KEY_NULL            = 0\n"
    "int KEY_APOSTROPHE      = 39\n"
    "int KEY_COMMA           = 44\n"
    "int KEY_MINUS           = 45\n"
    "int KEY_PERIOD          = 46\n"
    "int KEY_SLASH           = 47\n"
    "int KEY_ZERO            = 48\n"
    "int KEY_ONE             = 49\n"
    "int KEY_TWO             = 50\n"
    "int KEY_THREE           = 51\n"
    "int KEY_FOUR            = 52\n"
    "int KEY_FIVE            = 53\n"
    "int KEY_SIX             = 54\n"
    "int KEY_SEVEN           = 55\n"
    "int KEY_EIGHT           = 56\n"
    "int KEY_NINE            = 57\n"
    "int KEY_SEMICOLON       = 59\n"
    "int KEY_EQUAL           = 61\n"
    "int KEY_A               = 65\n"
    "int KEY_B               = 66\n"
    "int KEY_C               = 67\n"
    "int KEY_D               = 68\n"
    "int KEY_E               = 69\n"
    "int KEY_F               = 70\n"
    "int KEY_G               = 71\n"
    "int KEY_H               = 72\n"
    "int KEY_I               = 73\n"
    "int KEY_J               = 74\n"
    "int KEY_K               = 75\n"
    "int KEY_L               = 76\n"
    "int KEY_M               = 77\n"
    "int KEY_N               = 78\n"
    "int KEY_O               = 79\n"
    "int KEY_P               = 80\n"
    "int KEY_Q               = 81\n"
    "int KEY_R               = 82\n"
    "int KEY_S               = 83\n"
    "int KEY_T               = 84\n"
    "int KEY_U               = 85\n"
    "int KEY_V               = 86\n"
    "int KEY_W               = 87\n"
    "int KEY_X               = 88\n"
    "int KEY_Y               = 89\n"
    "int KEY_Z               = 90\n"
    "int KEY_LEFT_BRACKET    = 91\n"
    "int KEY_BACKSLASH       = 92\n"
    "int KEY_RIGHT_BRACKET   = 93\n"
    "int KEY_GRAVE           = 96\n"
    "int KEY_SPACE           = 32 \n"
    "int KEY_ESCAPE          = 256\n"
    "int KEY_ENTER           = 257\n"
    "int KEY_TAB             = 258\n"
    "int KEY_BACKSPACE       = 259\n"
    "int KEY_INSERT          = 260\n"
    "int KEY_DELETE          = 261\n"
    "int KEY_RIGHT           = 262\n"
    "int KEY_LEFT            = 263\n"
    "int KEY_DOWN            = 264\n"
    "int KEY_UP              = 265\n"
    "int KEY_PAGE_UP         = 266\n"
    "int KEY_PAGE_DOWN       = 267\n"
    "int KEY_HOME            = 268\n"
    "int KEY_END             = 269\n"
    "int KEY_CAPS_LOCK       = 280\n"
    "int KEY_SCROLL_LOCK     = 281\n"
    "int KEY_NUM_LOCK        = 282\n"
    "int KEY_PRINT_SCREEN    = 283\n"
    "int KEY_PAUSE           = 284\n"
    "int KEY_F1              = 290\n"
    "int KEY_F2              = 291\n"
    "int KEY_F3              = 292\n"
    "int KEY_F4              = 293\n"
    "int KEY_F5              = 294\n"
    "int KEY_F6              = 295\n"
    "int KEY_F7              = 296\n"
    "int KEY_F8              = 297\n"
    "int KEY_F9              = 298\n"
    "int KEY_F10             = 299\n"
    "int KEY_F11             = 300\n"
    "int KEY_F12             = 301\n"
    "int KEY_LEFT_SHIFT      = 340\n"
    "int KEY_LEFT_CONTROL    = 341\n"
    "int KEY_LEFT_ALT        = 342\n"
    "int KEY_LEFT_SUPER      = 343\n"
    "int KEY_RIGHT_SHIFT     = 344\n"
    "int KEY_RIGHT_CONTROL   = 345\n"
    "int KEY_RIGHT_ALT       = 346\n"
    "int KEY_RIGHT_SUPER     = 347\n"
    "int KEY_KB_MENU         = 348\n"
    "int KEY_KP_0            = 320\n"
    "int KEY_KP_1            = 321\n"
    "int KEY_KP_2            = 322\n"
    "int KEY_KP_3            = 323\n"
    "int KEY_KP_4            = 324\n"
    "int KEY_KP_5            = 325\n"
    "int KEY_KP_6            = 326\n"
    "int KEY_KP_7            = 327\n"
    "int KEY_KP_8            = 328\n"
    "int KEY_KP_9            = 329\n"
    "int KEY_KP_DECIMAL      = 330\n"
    "int KEY_KP_DIVIDE       = 331\n"
    "int KEY_KP_MULTIPLY     = 332\n"
    "int KEY_KP_SUBTRACT     = 333\n"
    "int KEY_KP_ADD          = 334\n"
    "int KEY_KP_ENTER        = 335\n"
    "int KEY_KP_EQUAL        = 336\n"
    "int KEY_BACK            = 4\n"
    "int KEY_MENU            = 5\n"
    "int KEY_VOLUME_UP       = 24\n"
    "int KEY_VOLUME_DOWN     = 25\n"

    "int MOUSE_BUTTON_LEFT    = 0\n"
    "int MOUSE_BUTTON_RIGHT   = 1\n"
    "int MOUSE_BUTTON_MIDDLE  = 2\n"
    "int MOUSE_BUTTON_SIDE    = 3\n"
    "int MOUSE_BUTTON_EXTRA   = 4\n"
    "int MOUSE_BUTTON_FORWARD = 5\n"
    "int MOUSE_BUTTON_BACK    = 6\n");

  if (argc < 2) {
    printf("error: provide a path to the source file to run\n");

    cyth_destroy(vm);
    return -1;
  }

  if (!cyth_load_file(vm, argv[1])) {
    printf("error: failed to load source file: %s\n", argv[1]);

    cyth_destroy(vm);
    return -1;
  }

  cyth_compile(vm);
  cyth_run(vm);

  DrawFunc draw = (DrawFunc) cyth_get_function(vm, "draw.void(int)");
  if (draw) {
    cyth_try_catch(vm, {
      while (!WindowShouldClose()) {
        BeginDrawing();
        draw(GetTime() * 1000);
        EndDrawing();
      }
    });
  }

  cyth_destroy(vm);
  return 0;
}