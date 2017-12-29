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

  test("Parity test 1", () {
    expect(isParity(0x7F7F), equals(true));
  });

  test("Parity test 2", () {
    expect(isParity(0xFFFE), equals(false));
  });

  test("Parity test 3", () {
    expect(isParity(0x0000), equals(true));
  });
}
