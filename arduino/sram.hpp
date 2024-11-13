#include <inttypes.h>

#define DELAY_PRE_US 1
#define DELAY_HOLD_US 3
#define DELAY_POST_US 1

uint8_t sram_read8(uint16_t addr);
uint16_t sram_read(uint16_t addr);
void sram_write(uint16_t addr, uint16_t data);
void sram_clear();