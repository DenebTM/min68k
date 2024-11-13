#include <Arduino.h>

#include "srecord.hpp"
#include "common.hpp"

struct srecord srec_decode(char *buf) {
  struct srecord srec;

  uint8_t checksum = 0;

  srec.type = buf[1];

  srec.byte_count = hex_decode(&buf[2], 2);
  checksum += srec.byte_count;

  unsigned addr_len = 0;
  switch (srec.type) {
    case '3': case '7':
      addr_len = 8;
      break;
    case '2': case '6': case '8':
      addr_len = 6;
      break;
    default:
      addr_len = 4;
  }
  srec.address = hex_decode(&buf[4], addr_len);
  checksum += srec.address >> 8;
  checksum += srec.address & 0xff;

  unsigned data_len = srec.byte_count - (addr_len / 2) - 1;
  uint8_t *data_ptr = srec.data;
  for (unsigned i = 0; i < data_len; i++) {
    uint8_t byte = hex_decode(&buf[4 + addr_len + (i * 2)], 2);
    *(data_ptr++) = byte;
    checksum += byte;
  }

  srec.expected_checksum = hex_decode(&buf[4 + (srec.byte_count - 1) * 2], 2);
  checksum = 255 - checksum;
  if (checksum != srec.expected_checksum) {
    Serial.println("Warning: Checksum mismatch");
    Serial.println("  (is $" + hex_fmt(checksum, 2) + ", expected $" + hex_fmt(srec.expected_checksum, 2) + ")");
  }

  return srec;
}

