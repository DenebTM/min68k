#include <Arduino.h>

#include "init.hpp"
#include "bus.hpp"
#include "sram.hpp"
#include "common.hpp"
#include "srecord.hpp"

String reset_str("reset");

void verify_failed(uint16_t addr, uint16_t expected, uint16_t actual, bool hang = true) {
  Serial.println(" failed at $" + hex_fmt(addr));
  Serial.println("expected $" + hex_fmt(expected) + ", got back $" + hex_fmt(actual));

  if (hang) {
    digitalWrite(SRAM_WE, HIGH);
    digitalWrite(SRAM_CE1, LOW);
    digitalWrite(SRAM_CE2, LOW);
    while (1);
  }
}

void m68k_reset() {
  digitalWrite(M68K_HALT_RESET, LOW);
  delay(500);
  digitalWrite(M68K_HALT_RESET, HIGH);
}

void m68k_init() {
  digitalWrite(M68K_HALT_RESET, HIGH);
  m68k_reset();
}

void sram_serial_init() {
  bus_control(ADDR_DATA);

  // clear memory
  // Serial.print("Clearing memory...");
  // sram_clear();
  // Serial.println(" done.");

  ADDR_H_OUT = 0;
  ADDR_L_OUT = 0;

init_restart:
  Serial.println("Awaiting \"reset\"");
  String str;
  do {
    str = Serial.readString();
    str.trim();
  } while (str != reset_str);

  Serial.println("ready");

  unsigned data_rec_count = 0;
  while (true) {
    // read "command" (only 0xff == terminate is really handled)
    uint8_t command;
    while (Serial.available() < 1);
    command = Serial.read();
    if (command == 0xff) {
      break;
    }
    if (command == 0x10) {
      Serial.print("Clearing memory...");
      sram_clear();
      Serial.println(" done.");
      Serial.println("ok");
      continue;
    }

    // read target address
    union {
      char bytes[2];
      uint16_t val;
    } addr;
    while (Serial.available() < 2);
    Serial.readBytes(addr.bytes, 2);

    // read byte count
    union {
      char bytes[2];
      uint16_t val;
    } data_len;
    while (Serial.available() < 1);
    Serial.readBytes(data_len.bytes, 2);

    // read checksum
    uint8_t checksum_expected;
    while (Serial.available() < 1);
    checksum_expected = Serial.read();

    uint8_t checksum_actual = 0;

    // read data
    uint8_t data_buf[1024];
    char *buf_ptr = data_buf;
    while (buf_ptr < &data_buf[data_len.val]) {

      int data = Serial.read();
      if (data != -1) {
        uint8_t data_byte = (uint8_t)data;
        *(buf_ptr++) = data_byte;
        checksum_actual += data_byte;
      }
    }

    checksum_actual = 255 - checksum_actual;
    if (checksum_expected != checksum_actual) {
      Serial.println("warn: checksum mismatch");
      Serial.println("  is $" + hex_fmt(checksum_actual, 2) + ", expected $" + hex_fmt(checksum_expected, 2));
    }

    // write data to ram
    int attempt = 0;
write_retry:
    attempt++;
    Serial.print("writing " + String(data_len.val) + " bytes to $" + hex_fmt(addr.val) + "...");
    DATA_H_DDR = 0xff;
    DATA_L_DDR = 0xff;
    delayMicroseconds(1);
    for (int i = 0; i < data_len.val; i += 2) {
      uint8_t data_l = data_buf[i];
      uint8_t data_h = data_buf[i+1];
      uint16_t data = (data_l << 8) | data_h;
      sram_write(addr.val + i, data);   
    }
    Serial.println(" done.");

    // verify written data
    Serial.print("verifying...");
    DATA_H_DDR = 0x00;
    DATA_L_DDR = 0x00;
    for (int i = 0; i < data_len.val; i += 2) {
      uint8_t expected_l = data_buf[i];
      uint8_t expected_h = data_buf[i+1];
      uint16_t expected = (expected_l << 8) | expected_h;
      uint16_t actual = sram_read(addr.val + i);

      if (expected != actual) {
        if (attempt < 5) {
          Serial.println(" failed. retrying");
          goto write_retry;
        } else {
          verify_failed(addr.val + i, expected, actual, false);
          digitalWrite(SRAM_WE, HIGH);
          digitalWrite(SRAM_CE1, LOW);
          digitalWrite(SRAM_CE2, LOW);
          Serial.println("err");
          goto init_restart;
        }
      }
    }
    Serial.println(" done.");

    Serial.println("ok");
  }

  // for (long i = 0; i < 0x10000; i += 16) {
  //   Serial.print(hex_fmt(i));
  //   Serial.print(": ");
  //   for (int j = 0; j < 16; j += 2) {
  //     Serial.print(hex_fmt(sram_read(i + j)));
  //     Serial.print(' ');
  //   }
  //   Serial.println();
  // }

  bus_release();
}