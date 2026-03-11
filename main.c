#include <math.h>
#include <stdbool.h>
#include <stdio.h>
#include <cyth.h>
#include <string.h>
#include <raylib.h>
#include <rlgl.h>

typedef struct {
  unsigned int id;
  int width;
  int height;
  CyArray* bitmap;
} ImageTex;

typedef void(*DrawFunc)(int);
typedef void(*KeyFunc)(char);

Color fill_color;

static void print(CyString *string) {
  fwrite(string->data, 1, string->size, stdout);
}

static void println(CyString*string) {
  print(string);
  fwrite("\n", 1, 1, stdout);
}

static float random(void) {
  return (float)GetRandomValue(0, 100) / 100.0f;
}

static void clear(void) {
  ClearBackground(fill_color);
}

static void size(int width, int height) {
  InitWindow(width, height, "");
}

static void fill(int r, int g, int b) {
  fill_color.r = r;
  fill_color.g = g;
  fill_color.b = b;
  fill_color.a = 255;
}

static void rect(int x, int y, int width, int height) {
  DrawRectangle(x, y, width, height, fill_color);
}

static void circle(int x, int y, int radius) {
  DrawCircle(x, y, radius, fill_color);
}

static ImageTex* createImage(int width, int height) {
  ImageTex* image_texture = cyth_alloc(false, sizeof(ImageTex));
  image_texture->id = rlLoadTexture(NULL, width, height, PIXELFORMAT_UNCOMPRESSED_R8G8B8, 1);
  image_texture->width = width;
  image_texture->height = height;

  image_texture->bitmap = cyth_alloc(false, sizeof(CyArray));
  image_texture->bitmap->size = width * height * 3;
  image_texture->bitmap->capacity = image_texture->bitmap->size;
  image_texture->bitmap->data = cyth_alloc(true, image_texture->bitmap->size);
  memset(image_texture->bitmap->data, 0, image_texture->bitmap->size);

  return image_texture;
}

static void clearImage(ImageTex* image_texture) {
  if (!image_texture->bitmap)
    return;

  if (image_texture->bitmap->size != image_texture->width * image_texture->height * 3)
    return;

  unsigned char* data = image_texture->bitmap->data;
  for (int i = 0; i < image_texture->width * image_texture->height * 3; i += 3) {
    data[i] = fill_color.r;
    data[i + 1] = fill_color.g;
    data[i + 2] = fill_color.b;
  }
}

static void drawImage(ImageTex* image_texture, int x, int y) {
  if (!image_texture->bitmap)
    return;

  if (image_texture->bitmap->size != image_texture->width * image_texture->height * 3)
    return;

  Texture2D texture = {
    .id = image_texture->id, 
    .width = image_texture->width, 
    .height = image_texture->height, 
    .format = PIXELFORMAT_UNCOMPRESSED_R8G8B8, 
    .mipmaps = 1
  };

  UpdateTexture(texture, image_texture->bitmap->data);
  DrawTexture(texture, x, y, (Color){255,255,255,255});
}

static void drawText(CyString* text, int x, int y, int fontSize) {
  DrawText(text->data, x, y, fontSize, fill_color);
}

int main(int argc, char **argv) {
  if (argc < 2) {
    printf("error: provide a source file to run\n");
    return -1;
  }

  SetConfigFlags(FLAG_VSYNC_HINT);
  SetConfigFlags(FLAG_MSAA_4X_HINT);
  SetTraceLogLevel(LOG_ERROR); 

  CyVM* vm = cyth_init();
  if (!cyth_load_file(vm, argv[1])) {
    printf("error: failed to load text file\n");
    return -1;
  }

  cyth_load_string(vm, "class Image\n"
                              "  int id\n"
                              "  int width\n"
                              "  int height\n"
                              "  char[] bitmap\n");
  cyth_load_function(vm, "float random()", (uintptr_t)random);
  cyth_load_function(vm, "void clear()", (uintptr_t)clear);
  cyth_load_function(vm, "void size(int width, int height)", (uintptr_t)size);
  cyth_load_function(vm, "void fill(int r, int g, int b)", (uintptr_t)fill);
  cyth_load_function(vm, "void rect(int x, int y, int width, int height)", (uintptr_t)rect);
  cyth_load_function(vm, "void circle(int x, int y, int radius)", (uintptr_t)circle);
  cyth_load_function(vm, "Image createImage(int width, int height)", (uintptr_t)createImage);
  cyth_load_function(vm, "void clearImage(Image image)", (uintptr_t)clearImage);
  cyth_load_function(vm, "void drawImage(Image image, int x, int y)", (uintptr_t)drawImage);
  cyth_load_function(vm, "void drawText(string text, int x, int y, int fontSize)", (uintptr_t)drawText);
  cyth_load_function(vm, "float cos(float a)", (uintptr_t)cosf);
  cyth_load_function(vm, "float sin(float a)", (uintptr_t)sinf);
  cyth_load_function(vm, "float tan(float a)", (uintptr_t)tanf);
  cyth_load_function(vm, "float exp(float a)", (uintptr_t)expf);
  cyth_load_function(vm, "float abs(float a)", (uintptr_t)fabsf);
  cyth_load_function(vm, "float pow(float a, float b)", (uintptr_t)powf);
  cyth_load_function(vm, "void print(string a)", (uintptr_t)print);
  cyth_load_function(vm, "void println(string a)", (uintptr_t)println);
  cyth_compile(vm);
  cyth_run(vm);

  DrawFunc draw = (DrawFunc) cyth_get_function(vm, "draw.void(int)");
  KeyFunc keyPressed = (KeyFunc) cyth_get_function(vm, "keyPressed.void(char)");

  cyth_try_catch(vm, {
    while (draw && !WindowShouldClose()) {
      if (keyPressed) {
        char key = GetKeyPressed();
        if (key)
          keyPressed(key);
      }

      BeginDrawing();
      draw(GetTime() * 1000);
      EndDrawing();
    }
  });

  cyth_destroy(vm);
  return 0;
}