/**
 * Arduino Mega 2560 code to interface with a Motorola 68000 computer with SRAM
 * on a breadboard. It does three things:
 *
 * 1. Perform clock generation (up to 8 MHz) using one of the timer outputs.
 *
 * 2. Copy a binary (up to 64k) received via the serial port into SRAM, then
 *    reset the 68000.
 *
 * 3. Watch for 8-bit writes at address 10000h (address line A0 connected to
 *    port D configured as input; all other Port D pins are pulled low) and
 *    writes them out, giving the 68000 a way to output data to the screen. On a
 *    16 MHz ATMega, this only works reliably with the 68000 clock at 4 MHz.
 */

#include "common.hpp"
#include "sram.hpp"
#include "srecord.hpp"
#include "bus.hpp"
#include "init.hpp"

void setup() {
  Serial.begin(115200);
  Serial.println();

  pinMode(M68K_HALT_RESET, OUTPUT);
  pinMode(M68K_BR, OUTPUT);
  pinMode(M68K_BG, INPUT);
  pinMode(M68K_BGACK, OUTPUT);

  // digitalWrite(M68K_HALT_RESET, LOW);

  clock_init();
  sram_serial_init();
  m68k_init();

  DDRD = 0x00;
  PORTD = 0x00;
  DATA_L_DDR = 0x00;
}

void output_addr_data() {
    // stop clock
    TCCR1B = _BV(WGM12);
    delayMicroseconds(2);

    // print values on address and data bus
    uint16_t addr = ((uint16_t)ADDR_H_IN << 8) | ADDR_L_IN;
    uint16_t data = (DATA_H_IN << 8) | DATA_L_IN;

    // resume clock
    TCCR1B = _BV(WGM12) | _BV(CS10);

    Serial.println(hex_fmt(addr) + " = " + hex_fmt(data));
}

void memory_dump() {
    bus_control(ADDR_ONLY);

    Serial.println();
    Serial.println("Memory dump:");
    for (uint32_t i = 0; i < 0x10000; i += 16) {
      Serial.print(hex_fmt(i) + String(":"));

      for (int j = 0; j < 16; j += 2) {
        Serial.print(String(" ") + hex_fmt(sram_read(i + j)));
      }
      Serial.println();
    }

    while (1);
}

int main() {
  init();
  setup();

  unsigned long start_ms = millis();

  for (;;) {
    // output_addr_data();
    // delay(10);

    // "MMIO" at 68000 address 10000h
    if (PIND) {
      Serial.write(DATA_L_IN);
    }

    // serialEventRun(); // seems to be unnecessary

    // if (millis() - start_ms > 3000) {
    //     memory_dump();
    // }
  }
}
