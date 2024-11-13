#include "bus.hpp"
#include "common.hpp"

void bus_control(ControlType control = ADDR_DATA) {
  digitalWrite(M68K_BR, LOW);
  while (digitalRead(M68K_BG));
  digitalWrite(M68K_BGACK, LOW);
  delayMicroseconds(1);

  if (control == ADDR_ONLY || control == ADDR_DATA) {
    ADDR_L_DDR = 0xff;
    ADDR_H_DDR = 0xff;
  }
  if (control == DATA_ONLY || control == ADDR_DATA) {
    DATA_L_DDR = 0xff;
    DATA_H_DDR = 0xff;
  }

  digitalWrite(SRAM_WE, HIGH);
  digitalWrite(SRAM_CE1, HIGH);
  digitalWrite(SRAM_CE2, HIGH);
  pinMode(SRAM_WE, OUTPUT);
  pinMode(SRAM_CE1, OUTPUT);
  pinMode(SRAM_CE2, OUTPUT);
}

void bus_release() {
  digitalWrite(SRAM_WE, HIGH);
  digitalWrite(SRAM_CE1, HIGH);
  digitalWrite(SRAM_CE2, HIGH);
  pinMode(SRAM_WE, INPUT);
  pinMode(SRAM_CE1, INPUT);
  pinMode(SRAM_CE2, INPUT);

  delayMicroseconds(1);
  ADDR_L_DDR = 0x00;
  ADDR_H_DDR = 0x00;
  DATA_L_DDR = 0x00;
  DATA_H_DDR = 0x00;
  ADDR_L_OUT = 0x00;
  ADDR_H_OUT = 0x00;
  DATA_L_OUT = 0x00;
  DATA_H_OUT = 0x00;

  delayMicroseconds(1);
  digitalWrite(M68K_BR, HIGH);
  digitalWrite(M68K_BGACK, HIGH);
}