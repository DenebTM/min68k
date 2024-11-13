enum ControlType {
  NONE,
  ADDR_ONLY,
  DATA_ONLY,
  ADDR_DATA
};

void bus_control(ControlType control = ADDR_DATA);
void bus_release();