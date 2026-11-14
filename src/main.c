#include <math.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <cyth.h>
#include <string.h>
#include <time.h>
#include <external/glad.h>
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
typedef void(*TraceFunc)(int, CyString* message);

Color fillColor;
Color strokeColor;
TraceFunc traceFunc;

static void clearColor(void) { glClear(GL_COLOR_BUFFER_BIT); }
static void clearDepth(void) { glClear(GL_DEPTH_BUFFER_BIT); }
static void setShader(int shader) { glUseProgram(shader); }
static void setUniformFloat(int uniform, float a) { glUniform1f(uniform, a); }
static void setUniformVec2(int uniform, float x, float y) { glUniform2f(uniform, x, y); }
static void setUniformVec3(int uniform, float x, float y, float z) { glUniform3f(uniform, x, y, z); }
static void setUniformVec4(int uniform, float x, float y, float z, float w) { glUniform4f(uniform, x, y, z, w); }
static void setVertexAttributeFloat(int attribute, float x) { glVertexAttrib1f(attribute, x); }
static void setVertexAttributeVec2(int attribute, float x, float y) { glVertexAttrib2f(attribute, x, y); }
static void setClearColor(float r, float g, float b, float a) { glClearColor(r, g, b, a); }
static void setColorMask(bool r, bool g, bool b, bool a) { glColorMask(r, g, b, a); }
static void setDepthTest(bool enable) { (enable ? glEnable : glDisable)(GL_DEPTH_TEST); }
static void setBackfaceCulling(bool enable) { (enable ? glEnable : glDisable)(GL_CULL_FACE); }
static void setBlending(bool enable) { (enable ? glEnable : glDisable)(GL_BLEND); }
static void setWireMode(bool wire) { glPolygonMode(GL_FRONT_AND_BACK, wire ? GL_LINE : GL_FILL); }
static void setTexture(int texture) { glBindTexture(GL_TEXTURE_2D, texture); }
static void setViewport(int width, int height) { glViewport(0, 0, width, height); }
static void bindVertexArray(int vao) { glBindVertexArray(vao); }
static void bindArrayBuffer(int buffer) { glBindBuffer(GL_ARRAY_BUFFER, buffer); }
static void drawVertexArray(int offset, int count) { glDrawArrays(GL_TRIANGLES, offset, count); }
static void drawVertexArrayLines(int count) { glDrawArrays(GL_LINES, 0, count); }
static int getUniformLocation(int shader, CyString* name) { return glGetUniformLocation(shader, name->data); }
static int getAttributeLocation(int shader, CyString* name) { return glGetAttribLocation(shader, name->data); }

static int createVertexArray(void) {
  GLuint vao;
  glGenVertexArrays(1, &vao);
  return vao;
}

static int createArrayBuffer(void) {
  GLuint buffer;
  glGenBuffers(1, &buffer);
  return buffer;
}

static int createShader(CyString* vertexSource, CyString* fragmentSource) {
  return LoadShaderFromMemory(vertexSource->data, fragmentSource->data).id; 
}

static void setUniformMatrix4(int uniform, CyArray* array) { 
  if (array->size == 16) 
    glUniformMatrix4fv(uniform, 1, GL_FALSE, array->data); 
}

static void updateTextureRegion(int texture, int x, int y, int width, int height, CyArray* array) {
  if (width > 0 && height > 0 && 
      (size_t)width <= SIZE_MAX / 4 / (size_t)height && 
      (size_t)array->size >= (size_t)width * (size_t)height * 4) {
    glBindTexture(GL_TEXTURE_2D, texture);
    glTexSubImage2D(GL_TEXTURE_2D, 0, x, y, width, height, GL_RGBA, GL_UNSIGNED_BYTE, array->data);
  }
}

static void setArrayBufferData(int buffer, CyArray* array, int count) {
  if (count > 0 && count <= array->size)
    glBufferData(GL_ARRAY_BUFFER, count * sizeof(float), array->data, GL_DYNAMIC_DRAW);
}

static void updateArrayBufferData(int buffer, CyArray* array, int count) {
  if (count > 0 && count <= array->size)
    glBufferSubData(GL_ARRAY_BUFFER, 0, count * sizeof(float), array->data);
}

static void setVertexAttributePointer(int attribute, int size, int stride, int offset) {
  glEnableVertexAttribArray(attribute);
  glVertexAttribPointer(attribute, size, GL_FLOAT, GL_FALSE, stride, (const void*)(intptr_t)offset);
}

static int createTexture(CyString* string) {
  Image image = LoadImageFromMemory(".png", (unsigned char*)string->data, string->size);
  Texture2D texture = LoadTextureFromImage(image);

  UnloadImage(image);
  return texture.id;
}

static int createTextureRegion(CyString* string, int x, int y, int width, int height) {
  Image image = LoadImageFromMemory(".png", (unsigned char*)string->data, string->size);
  
  Rectangle cropRect = { x, y, width, height }; 
  ImageCrop(&image, cropRect);

  Texture2D texture = LoadTextureFromImage(image);
  UnloadImage(image);

  return texture.id;
}

static int createColorTexture(float r, float g, float b) {
  unsigned char data[3];
  data[0] = (unsigned char)(r * 255.0f);
  data[1] = (unsigned char)(g * 255.0f);
  data[2] = (unsigned char)(b * 255.0f);

  return LoadTextureFromImage((Image) {data, 1, 1, true, PIXELFORMAT_UNCOMPRESSED_R8G8B8}).id;
}

static int epochTime(void) {
  return (int)time(NULL);
}

static float getMouseDeltaX(void) {
  return GetMouseDelta().x;
}

static float getMouseDeltaY(void) {
  return GetMouseDelta().y;
}

static void print(CyString* string) {
  fwrite(string->data, 1, string->size, stdout);
  fflush(stdout);
}

static void println(CyString* string) {
  fwrite(string->data, 1, string->size, stdout);
  fwrite("\n", 1, 1, stdout);
}

static void clear(void) {
  ClearBackground(fillColor);
}

static void size(CyString* title, int width, int height) {
  InitWindow(width, height, title->data);
}

static void fill(int r, int g, int b, int a) {
  fillColor.r = r;
  fillColor.g = g;
  fillColor.b = b;
  fillColor.a = a;
}

static void fill2(int r, int g, int b) {
  fill(r, g, b, 255);
}

static void fill3(int rgba) {
  fill(rgba >> 24 & 0xFF, rgba >> 16 & 0xFF, rgba >> 8 & 0xFF, rgba & 0xFF);
}

static void stroke(int r, int g, int b, int a) {
  strokeColor.r = r;
  strokeColor.g = g;
  strokeColor.b = b;
  strokeColor.a = a;
}

static void stroke2(int r, int g, int b) {
  stroke(r, g, b, 255);
}

static void stroke3(int rgba) {
  stroke(rgba >> 24 & 0xFF, rgba >> 16 & 0xFF, rgba >> 8 & 0xFF, rgba & 0xFF);
}

static void rect(int x, int y, int width, int height) {
  DrawRectangle(x, y, width, height, fillColor);
}

static void circle(int x, int y, int radius) {
  DrawCircle(x, y, radius, fillColor);
}

static void line(int x0, int y0, int x1, int y1) {
  DrawLine(x0, y0, x1, y1, strokeColor);
}

static void triangle(int x0, int y0, int x1, int y1, int x2, int y2) {
  DrawTriangle((Vector2){x0, y0}, (Vector2){x1, y1}, (Vector2){x2, y2}, fillColor);
}

static void text(CyString* text, int x, int y, int fontSize) {
  DrawText(text->data, x, y, fontSize, fillColor);
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
    data[i] = fillColor.r;
    data[i + 1] = fillColor.g;
    data[i + 2] = fillColor.b;
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

static int getTime(void) {
  return GetTime() * 1000;
}

static void setTraceCallback(TraceFunc func) {
  traceFunc = func;
  SetTraceLogLevel(LOG_INFO);
}

static void traceCallback(int logLevel, const char *text, va_list args) {
  if (!traceFunc)
    return;

  va_list args_copy;
  va_copy(args_copy, args);
  
  int size = vsnprintf(NULL, 0, text, args);

  CyString* message = cyth_alloc(1, sizeof(CyString) + size + 1);
  message->size = size;

  vsnprintf(message->data, size + 1, text, args_copy);
  va_end(args_copy);

  traceFunc(logLevel, message);  
}

static const char* parseArgs(CyVM* vm, int argc, char **argv) {
  if (argc < 2) {
    printf("usage: cythgfx <input_file>\n\n");
    printf("Available options are:\n"
           "  -l Print IR.\n");

    return NULL;
  }

  const char* filename = NULL;
  
  for (int arg = 1; arg < argc; arg++) {
    if (strcmp(argv[arg], "-l") == 0) {
      cyth_set_logging(vm, true);
    } else {
      if (argv[arg][0] != '-') {
        if (filename == NULL) {
          filename = argv[arg];
        } else {
          fprintf(stderr, "error: unknown non-option: '%s'\n", argv[arg]);
          return NULL;
        }
      } else {
        fprintf(stderr, "error: unknown option: '%s'\n", argv[arg]);
        return NULL;
      }
    }
  }

  if (!filename) {
    fprintf(stderr, "error: no input file provided\n");
    return NULL;
  }

  return filename;
}

int main(int argc, char **argv) {
  SetConfigFlags(FLAG_VSYNC_HINT);
  SetConfigFlags(FLAG_WINDOW_RESIZABLE);
  SetTraceLogLevel(LOG_WARNING);

  CyVM* vm = cyth_init();
  cyth_load_function(vm, "void size(string title, int width, int height)", (uintptr_t)size);
  cyth_load_function(vm, "void clear()", (uintptr_t)clear);
  cyth_load_function(vm, "void fill(int r, int g, int b, int a)", (uintptr_t)fill);
  cyth_load_function(vm, "void fill(int r, int g, int b)", (uintptr_t)fill2);
  cyth_load_function(vm, "void fill(int rgba)", (uintptr_t)fill3);
  cyth_load_function(vm, "void stroke(int r, int g, int b, int a)", (uintptr_t)stroke);
  cyth_load_function(vm, "void stroke(int r, int g, int b)", (uintptr_t)stroke2);
  cyth_load_function(vm, "void stroke(int rgba)", (uintptr_t)stroke3);
  cyth_load_function(vm, "void rect(int x, int y, int width, int height)", (uintptr_t)rect);
  cyth_load_function(vm, "void circle(int x, int y, int radius)", (uintptr_t)circle);
  cyth_load_function(vm, "void line(int x0, int y0, int x1, int y1)", (uintptr_t)line);
  cyth_load_function(vm, "void triangle(int x0, int y0, int x1, int y1, int x2, int y2)", (uintptr_t)triangle);
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
  cyth_load_function(vm, "int getTime()", (uintptr_t)getTime);
  cyth_load_function(vm, "int getMouseX()", (uintptr_t)GetMouseX);
  cyth_load_function(vm, "int getMouseY()", (uintptr_t)GetMouseY);
  cyth_load_function(vm, "int getRandomValue(int min, int max)", (uintptr_t)GetRandomValue);
  cyth_load_function(vm, "float atan2(float y, float x)", (uintptr_t)atan2f);
  cyth_load_function(vm, "float cos(float a)", (uintptr_t)cosf);
  cyth_load_function(vm, "float sin(float a)", (uintptr_t)sinf);
  cyth_load_function(vm, "float tan(float a)", (uintptr_t)tanf);
  cyth_load_function(vm, "float exp(float a)", (uintptr_t)expf);
  cyth_load_function(vm, "float abs(float a)", (uintptr_t)fabsf);
  cyth_load_function(vm, "float pow(float a, float b)", (uintptr_t)powf);
  cyth_load_function(vm, "void print(string a)", (uintptr_t)print);
  cyth_load_function(vm, "void println(string a)", (uintptr_t)println);
  cyth_load_function(vm, "void setTraceCallback(void(int, string) callback)", (uintptr_t)setTraceCallback);
  cyth_load_function(vm, "int createShader(string vertexSource, string fragmentSource)", (uintptr_t)createShader);
  cyth_load_function(vm, "int getUniformLocation(int shader, string name)", (uintptr_t)getUniformLocation);
  cyth_load_function(vm, "int getAttributeLocation(int shader, string name)", (uintptr_t)getAttributeLocation);
  cyth_load_function(vm, "void setUniform(int uniform, float a)", (uintptr_t)setUniformFloat);
  cyth_load_function(vm, "void setUniform(int uniform, float x, float y)", (uintptr_t)setUniformVec2);
  cyth_load_function(vm, "void setUniform(int uniform, float x, float y, float z)", (uintptr_t)setUniformVec3);
  cyth_load_function(vm, "void setUniform(int uniform, float x, float y, float z, float w)", (uintptr_t)setUniformVec4);
  cyth_load_function(vm, "void setUniform(int uniform, float[] m)", (uintptr_t)setUniformMatrix4);
  cyth_load_function(vm, "void setShader(int shader)", (uintptr_t)setShader);
  cyth_load_function(vm, "void setVertexAttribute(int attribute, float x)", (uintptr_t)setVertexAttributeFloat);
  cyth_load_function(vm, "void setVertexAttribute(int attribute, float x, float y)", (uintptr_t)setVertexAttributeVec2);
  cyth_load_function(vm, "void setVertexAttribute(int attribute, int size, int stride, int offset)", (uintptr_t)setVertexAttributePointer);
  cyth_load_function(vm, "int createVertexArray()", (uintptr_t)createVertexArray);
  cyth_load_function(vm, "int createArrayBuffer()", (uintptr_t)createArrayBuffer);
  cyth_load_function(vm, "void bindVertexArray(int vao)", (uintptr_t)bindVertexArray);
  cyth_load_function(vm, "void bindArrayBuffer(int buffer)", (uintptr_t)bindArrayBuffer);
  cyth_load_function(vm, "void setArrayBufferData(int buffer, float[] data, int count)", (uintptr_t)setArrayBufferData);
  cyth_load_function(vm, "void updateArrayBufferData(int buffer, float[] data, int count)", (uintptr_t)updateArrayBufferData);
  cyth_load_function(vm, "void drawVertexArray(int offset, int count)", (uintptr_t)drawVertexArray);
  cyth_load_function(vm, "void drawVertexArrayLines(int count)", (uintptr_t)drawVertexArrayLines);
  cyth_load_function(vm, "void setClearColor(float r, float g, float b, float a)", (uintptr_t)setClearColor);
  cyth_load_function(vm, "void clearColor()", (uintptr_t)clearColor);
  cyth_load_function(vm, "void clearDepth()", (uintptr_t)clearDepth);
  cyth_load_function(vm, "void setDepthTest(bool enable)", (uintptr_t)setDepthTest);
  cyth_load_function(vm, "void setBackfaceCulling(bool enable)", (uintptr_t)setBackfaceCulling);
  cyth_load_function(vm, "void setColorMask(bool r, bool g, bool b, bool a)", (uintptr_t)setColorMask);
  cyth_load_function(vm, "void setBlending(bool enable)", (uintptr_t)setBlending);
  cyth_load_function(vm, "void setWireMode(bool wire)", (uintptr_t)setWireMode);
  cyth_load_function(vm, "int createTexture(string data)", (uintptr_t)createTexture);
  cyth_load_function(vm, "int createTextureRegion(string name, int left, int top, int right, int bottom)", (uintptr_t)createTextureRegion);
  cyth_load_function(vm, "int createColorTexture(float r, float g, float b)", (uintptr_t)createColorTexture);
  cyth_load_function(vm, "void updateTextureRegion(int texture, int x, int y, int width, int height, char[] data)", (uintptr_t)updateTextureRegion);
  cyth_load_function(vm, "void setTexture(int texture)", (uintptr_t)setTexture);
  cyth_load_function(vm, "void setViewport(int width, int height)", (uintptr_t)setViewport);
  cyth_load_function(vm, "bool isWindowResized()", (uintptr_t)IsWindowResized);
  cyth_load_function(vm, "int getWindowWidth()", (uintptr_t)GetScreenWidth);
  cyth_load_function(vm, "int getWindowHeight()", (uintptr_t)GetScreenHeight);
  cyth_load_function(vm, "int getRenderWidth()", (uintptr_t)GetRenderWidth);
  cyth_load_function(vm, "int getRenderHeight()", (uintptr_t)GetRenderHeight);
  cyth_load_function(vm, "void disableCursor()", (uintptr_t)DisableCursor);
  cyth_load_function(vm, "void enableCursor()", (uintptr_t)EnableCursor);
  cyth_load_function(vm, "float getMouseWheel()", (uintptr_t)GetMouseWheelMove);
  cyth_load_function(vm, "int epochTime()", (uintptr_t)epochTime);
  cyth_load_function(vm, "float getMouseDeltaX()", (uintptr_t)getMouseDeltaX);
  cyth_load_function(vm, "float getMouseDeltaY()", (uintptr_t)getMouseDeltaY);
  cyth_load_string(vm, "builtin.cy",
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
    "int MOUSE_BUTTON_BACK    = 6\n"

    "int LIGHTGRAY  = 0xC8C8C8FF\n"
    "int GRAY       = 0x828282FF\n"
    "int DARKGRAY   = 0x505050FF\n"
    "int YELLOW     = 0xFDF900FF\n"
    "int GOLD       = 0xFFCB00FF\n"
    "int ORANGE     = 0xFFA100FF\n"
    "int PINK       = 0xFF6DC2FF\n"
    "int RED        = 0xE62937FF\n"
    "int MAROON     = 0xBE2137FF\n"
    "int GREEN      = 0x00E430FF\n"
    "int LIME       = 0x009E2FFF\n"
    "int DARKGREEN  = 0x00752CFF\n"
    "int SKYBLUE    = 0x66BFFFFF\n"
    "int BLUE       = 0x0079F1FF\n"
    "int DARKBLUE   = 0x0052ACFF\n"
    "int PURPLE     = 0xC87AFFFF\n"
    "int VIOLET     = 0x873CBEFF\n"
    "int DARKPURPLE = 0x701F7EFF\n"
    "int BEIGE      = 0xD3B083FF\n"
    "int BROWN      = 0x7F6A4FFF\n"
    "int DARKBROWN  = 0x4C3F2FFF\n"
    "int WHITE      = 0xFFFFFFFF\n"
    "int BLACK      = 0x000000FF\n"
    "int BLANK      = 0x00000000\n"
    "int MAGENTA    = 0xFF00FFFF\n");

  const char* filename = parseArgs(vm, argc, argv);
  if (!filename) {
    cyth_destroy(vm);
    return -1;
  }

  if (!cyth_load_file(vm, filename)) {
    fprintf(stderr, "error: failed to load file: %s\n", filename);

    cyth_destroy(vm);
    return -1;
  }

  cyth_compile(vm);
  cyth_run(vm);

  DrawFunc draw = (DrawFunc) cyth_get_function(vm, "draw.void(int)");
  if (draw) {
    while (!cyth_error(vm) && !WindowShouldClose()) {
      BeginDrawing();
      draw(getTime());
      EndDrawing();
    }
  }

  cyth_destroy(vm);
  return 0;
}
