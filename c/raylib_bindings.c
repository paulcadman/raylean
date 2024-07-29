#include <lean/lean.h>
#include <raylib.h>

#define IO_UNIT (lean_io_result_mk_ok(lean_box(0)))

static inline Color color_of_arg(lean_obj_arg color) {
  uint8_t r = lean_ctor_get_uint8(color, 0);
  uint8_t g = lean_ctor_get_uint8(color, 1);
  uint8_t b = lean_ctor_get_uint8(color, 2);
  uint8_t a = lean_ctor_get_uint8(color, 3);
  return (Color) {r,g,b,a};
}

lean_obj_res getRandomValue(uint32_t min, uint32_t max) {
  // SUPPORT_RPRAND_GENERATOR is set however the prand generator always
  // returns the same value in this context
  // uint32_t r = (rand() % (abs((long)max - min) + 1) + min);
  return lean_io_result_mk_ok(lean_box(min));
}

lean_obj_res initWindow(lean_obj_arg width, lean_obj_arg height,
                                   b_lean_obj_arg title) {
  InitWindow(lean_uint32_of_nat_mk(width), lean_uint32_of_nat_mk(height),
             lean_string_cstr(title));
  return IO_UNIT;
}

lean_obj_res windowShouldClose(void) {
  return lean_io_result_mk_ok(lean_box(WindowShouldClose()));
}

lean_obj_res closeWindow(void) {
  CloseWindow();
  return IO_UNIT;
}

lean_obj_res beginDrawing(void) {
  BeginDrawing();
  return IO_UNIT;
}

lean_obj_res endDrawing(void) {
  EndDrawing();
  return IO_UNIT;
}

lean_obj_res clearBackground(lean_obj_arg color) {
  ClearBackground(color_of_arg(color));
  return IO_UNIT;
}

lean_obj_res setTargetFPS(lean_obj_arg fps) {
  SetTargetFPS(lean_uint32_of_nat_mk(fps));
  return IO_UNIT;
}

lean_obj_res drawFPS(lean_obj_arg posX, lean_obj_arg posY) {
   DrawFPS(lean_uint32_of_nat_mk(posX), lean_uint32_of_nat_mk(posY) );
   return IO_UNIT;
}

lean_obj_res drawText(b_lean_obj_arg text, lean_obj_arg posX,
                                 lean_obj_arg posY, lean_obj_arg fontSize,
                                 lean_obj_arg color) {
  DrawText(lean_string_cstr(text), lean_uint32_of_nat_mk(posX),
           lean_uint32_of_nat_mk(posY), lean_uint32_of_nat_mk(fontSize),
           color_of_arg(color));
  return IO_UNIT;
}
