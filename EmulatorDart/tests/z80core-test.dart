import 'package:test/test.dart';

import '../z80.dart';
import '../memory.dart';

void main() {
  test("Initialization test", () {
    var mem = new Memory();
    mem.isRomProtected = true;
    mem.writeByte(0xFFFF, 255);
    var z80 = new Z80(mem);
    z80.b = 0xBE;
    z80.c = 0xEF;
    expect(z80.bc, equals(0xBEEF));
  });
}