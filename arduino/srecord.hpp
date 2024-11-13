#include <inttypes.h>

struct srecord {
  char type;
  uint8_t byte_count;
  uint32_t address;
  uint8_t data[64];
  uint16_t expected_checksum;
};

struct srecord srec_decode(char* buf);
