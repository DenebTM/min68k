#include <Arduino.h>

#include "defines.hpp"

#define hex2nibble(num) ((num & 0x0f) + ((num >= 'A') ? 9 : 0))
inline uint32_t hex_decode(char *num, unsigned len) {
  uint32_t res = 0;
  for (unsigned i = 0; i < len; i++) {
    res |= hex2nibble(num[i]) << ((len - i - 1) * 4);
  }

  return res;
}

inline String hex_fmt(uint16_t val, unsigned len = 4) {
  static char buf[5];
  // Arduino doesn't implement the * format specifier 👍
  switch (len) {
    case 1:
      snprintf(buf, 5, "%01hX", val);
      break;
    case 2:
      snprintf(buf, 5, "%02hX", val);
      break;
    case 3:
      snprintf(buf, 5, "%03hX", val);
      break;
    case 4:
      snprintf(buf, 5, "%04hX", val);
      break;
  }
  return String(buf);
}