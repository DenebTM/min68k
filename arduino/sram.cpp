#include <Arduino.h>

#include "sram.hpp"
#include "common.hpp"

uint8_t sram_read8(uint16_t addr) {
  digitalWrite(SRAM_WE, HIGH);
  ADDR_L_OUT = addr & 0xff;
  ADDR_H_OUT = addr >> 8;

  delayMicroseconds(DELAY_PRE_US);
  digitalWrite(SRAM_CE1, LOW);
  digitalWrite(SRAM_CE2, LOW);
  delayMicroseconds(DELAY_HOLD_US);
  uint8_t val = DATA_L_IN;
  digitalWrite(SRAM_CE1, HIGH);
  digitalWrite(SRAM_CE2, HIGH);
  delayMicroseconds(DELAY_POST_US);

  return val;
}

uint16_t sram_read(uint16_t addr) {
  digitalWrite(SRAM_WE, HIGH);
  ADDR_L_OUT = addr & 0xff;
  ADDR_H_OUT = addr >> 8;

  delayMicroseconds(DELAY_PRE_US);
  digitalWrite(SRAM_CE1, LOW);
  digitalWrite(SRAM_CE2, LOW);
  delayMicroseconds(DELAY_HOLD_US);
  uint16_t val = ((uint16_t)DATA_H_IN << 8) | DATA_L_IN;
  digitalWrite(SRAM_CE1, HIGH);
  digitalWrite(SRAM_CE2, HIGH);
  delayMicroseconds(DELAY_POST_US);

  return val;
}

void sram_write(uint16_t addr, uint16_t data) {
  ADDR_L_OUT = addr & 0xff;
  ADDR_H_OUT = addr >> 8;
  DATA_L_OUT = data & 0xff;
  DATA_H_OUT = data >> 8;

  digitalWrite(SRAM_WE, LOW);

  delayMicroseconds(DELAY_PRE_US);
  digitalWrite(SRAM_CE1, LOW);
  digitalWrite(SRAM_CE2, LOW);
  delayMicroseconds(DELAY_HOLD_US);
  digitalWrite(SRAM_CE1, HIGH);
  digitalWrite(SRAM_CE2, HIGH);
  delayMicroseconds(DELAY_POST_US);

  digitalWrite(SRAM_WE, HIGH);
}

void sram_clear() {
  for (int32_t addr = 0; addr < 0xffff; addr += 2) {
    sram_write(addr, 0);
  }
}