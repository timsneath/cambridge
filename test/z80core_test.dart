// z80core_test.dart -- test most basic functions of Z80 emulation

// Run tests with
//   pub run test test/z80core_test.dart --no-color > test/results_z80core_test.txt

import 'package:flutter_test/flutter_test.dart';
import 'package:spectrum/core/z80.dart';
import 'package:spectrum/core/memory.dart';

void main() {
  test("Initialization test", () {
    final mem = Memory(isRomProtected: true);
    mem.writeByte(0xFFFF, 255);
    final z80 = Z80(mem);
    z80.b = 0xBE;
    z80.c = 0xEF;
    expect(z80.bc, equals(0xBEEF));
  });

  test("Flags test", () {
    final mem = Memory(isRomProtected: true);
    final z80 = Z80(mem);
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
    final mem = Memory(isRomProtected: false);
    final z80 = Z80(mem);
    z80.af = 0;
    z80.b = 0xFF;
    z80.c = 0;
    z80.b = z80.INC(z80.b);
    expect(z80.bc, equals(0x0000), reason: 'BC');
    expect(z80.af, equals(0x0050), reason: 'AF');
  });
}
