import 'package:test/test.dart';

import '../utility.dart';

void main() {
  test("High byte test 1", () {
    expect(highByte(0xDEAD), equals(0xDE));
  });

  // test that we are treating numbers as 16-bit values
  // and throw away anything else
  test("High byte test 2", () {
    expect(highByte(0xDEADBEEF), equals(0xBE));
  });

  test("Low byte test", () {
    expect(lowByte(0xDEADBEEF), equals(0xEF));
  });

  test("Parity test", () {
    expect(isParity(0x7F7F), equals(true));
    expect(isParity(0xFFFE), equals(false));
    expect(isParity(0x0000), equals(true));
  });

  test("IsBitSet test", () {
    expect(IsBitSet(0xF000, 15), equals(true));
    expect(IsBitSet(0xF000, 7), equals(false));
    expect(IsBitSet(0x0001, 0), equals(true));
    expect(IsBitSet(0xFF, 20), equals(false));
  });

  // TODO: Write more utility tests
}
