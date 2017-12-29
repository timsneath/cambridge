int highByte(int value) => (value & 0xFF00) >> 8;
int lowByte(int value) => value & 0x00FF;

// Algorithm for counting set bits taken from LLVM optimization proposal at:
//    https://llvm.org/bugs/show_bug.cgi?id=1488
bool isParity(int value) {
  int count = 0;

  for (; value != 0; count++) {
    value &= value - 1; // clear the least significant bit set
  }
  return (count % 2 == 0);
}

bool isBitSet(int value, int bit) => (value & (1 << bit)) == 1 << bit;
int setBit(int value, int bit) => (value | (1 << bit));
int resetBit(int value, int bit) => (value & ~(1 << bit));
bool isSign8(int value) => (value & 0x80) == 0x80;
bool isSign16(int value) => (value & 0x8000) == 0x8000;
bool isZero(int value) => value == 0;

String toHex16(int value) => value.toRadixString(16).padLeft(2, '0');
String toHex32(int value) => value.toRadixString(16).padLeft(4, '0');
