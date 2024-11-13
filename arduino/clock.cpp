#include "init.hpp"
#include "defines.hpp"

void clock_init() {
  pinMode(M68K_CLK, OUTPUT);

  TCCR1A = _BV(COM1A0);
  TCCR1B = _BV(WGM12) | _BV(CS10);
  OCR1A =
    // 0xffff;    // 244 Hz
    // 1 << 10;   // 3.9 kHz
    // 4;         // 1 MHz
    // 2;            // 2 MHz
    1;            // 4 MHz
    // 0;         // 8 MHz
}