// utility.dart -- common methods for manipulating bytes and words

// High or low byte of a 16-bit value
int highByte(int value) => (value & 0xFF00) >> 8;
int lowByte(int value) => value & 0x00FF;

int createWord(int lowByte, int highByte) => highByte * 256 + lowByte;

// String formatters
String toHex8(int value) => value.toRadixString(16).padLeft(1, '0');
String toHex16(int value) => value.toRadixString(16).padLeft(2, '0');
String toHex32(int value) => value.toRadixString(16).padLeft(4, '0');

String toBin8(int value) => value.toRadixString(2).padLeft(8, '0');
String toBin16(int value) => value.toRadixString(2).padLeft(16, '0');
String toBin32(int value) => value.toRadixString(2).padLeft(32, '0');

// Calculates 2s complement of an 8-bit or 16-bit value
int twocomp8(int value) => -(value & 0x80) + (value & ~0x80);
int twocomp16(int value) => -(value & 0x8000) + (value & ~0x8000);

// Calculate 1s complement of an 8-bit or 16-bit value
int onecomp8(int value) => (~value).toSigned(8) % 0x100;
int onecomp16(int value) => (~value).toSigned(16) % 0x10000;

// Algorithm for counting set bits taken from LLVM optimization proposal at:
//    https://llvm.org/bugs/show_bug.cgi?id=1488
bool isParity(int value) {
  var count = 0;

  for (var v = value; v != 0; count++) {
    v &= v - 1; // clear the least significant bit set
  }
  return count % 2 == 0;
}

bool isBitSet(int value, int bit) => (value & (1 << bit)) == 1 << bit;
int setBit(int value, int bit) => value | (1 << bit);
int resetBit(int value, int bit) => value & ~(1 << bit);
bool isSign8(int value) => (value & 0x80) == 0x80;
bool isSign16(int value) => (value & 0x8000) == 0x8000;
bool isZero(int value) => value == 0;
bool isOdd(int value) => value & 0x01 == 0x01;
bool isEven(int value) => ~value & 0x01 == 0x01;
