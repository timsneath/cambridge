// z80core_test.dart -- test most basic functions of Z80 emulation

// Run tests with 
//   pub run test test/z80core_test.dart --no-color > test/results_z80core_test.txt

import 'package:test/test.dart';
import 'package:spectrum/spectrum.dart';

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

  test("Instruction test", () {
    var mem = new Memory(false);
    var z80 = new Z80(mem);
    z80.af = 0;
    z80.b = 0xFF;
    z80.c = 0;
    z80.b = z80.INC(z80.b);
    expect(z80.bc, equals(0x0000), reason: 'BC');
    expect(z80.af, equals(0x0050), reason: 'AF');
  });
}