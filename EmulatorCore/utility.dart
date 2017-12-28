int highByte(int value) => (value & 0xFF00) >> 8;
int lowByte(int value) => value & 0x00FF;