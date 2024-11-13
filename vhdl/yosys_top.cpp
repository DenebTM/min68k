#include "fx68k_tb.cpp"

int main() {
  cxxrtl_design::p_fx68k__tb top;

  top.step();
  while (1) {
    /* user logic */
    top.p_clk.set(false);
    top.step();
    top.p_clk.set(true);
    top.step();
  }
}
