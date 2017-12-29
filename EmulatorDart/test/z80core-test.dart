import 'package:test/test.dart';

import '../z80.dart';
import '../memory.dart';

void main() {
  test("Initialization test", () {
    var mem = new Memory(true);
    mem.writeByte(0xFFFF, 255);
    var z80 = new Z80(mem);
    z80.b = 0xBE;
    z80.c = 0xEF;
    expect(z80.bc, equals(0xBEEF));
  });

  test("Flags test", () {
    var mem = new Memory(true);
    var z80 = new Z80(mem);
    z80.a = 0;
    z80.f = 0;
    z80.fZ = true;
    z80.fC = true;
    expect(z80.af, equals(0x0041));
    z80.fZ = false;
    z80.fC = false;
    expect(z80.af, equals(0x0000));
  });
}