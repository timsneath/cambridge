// z80registers_test.dart -- test most basic functions of Z80 emulation

// Run tests with
//   pub run test test/z80core_test.dart --no-color > test/results_z80core_test.txt

import 'package:flutter_test/flutter_test.dart';
import 'package:spectrum/core/memory.dart';
import 'package:spectrum/core/z80.dart';

late Memory memory;
late Z80 z80;

void main() {
  setUp(() {
    memory = Memory(isRomProtected: false);
    z80 = Z80(memory, startAddress: 0xA000);
  });
  test("BC registers test", () {
    z80.b = 0xA0;
    z80.c = 0xB1;
    expect(z80.bc, equals(0xA0B1));
    z80.bc = 0x1234;
    expect(z80.b, equals(0x12));
    expect(z80.c, equals(0x34));
  });
  test("DE registers test", () {
    z80.d = 0xC2;
    z80.e = 0xD3;
    expect(z80.de, equals(0xC2D3));
    z80.de = 0x1234;
    expect(z80.d, equals(0x12));
    expect(z80.e, equals(0x34));
  });
  test("HL registers test", () {
    z80.h = 0xE4;
    z80.l = 0xF5;
    expect(z80.hl, equals(0xE4F5));
    z80.hl = 0x1234;
    expect(z80.h, equals(0x12));
    expect(z80.l, equals(0x34));
  });
  test("AF registers test", () {
    z80.a = 0x12;
    z80.f = 0x34;
    expect(z80.af, equals(0x1234));
    z80.af = 0x4321;
    expect(z80.a, equals(0x43));
    expect(z80.f, equals(0x21));
  });
  test("IX registers test", () {
    z80.ix = 0;
    z80.ixh = 0x24;
    z80.ixl = 0x68;
    expect(z80.ix, equals(0x2468));
    z80.ix = 0x9876;
    expect(z80.ixh, equals(0x98));
    expect(z80.ixl, equals(0x76));
  });
  test("IY registers test", () {
    z80.iy = 0;
    z80.iyh = 0x2A;
    z80.iyl = 0x6B;
    expect(z80.iy, equals(0x2A6B));
    z80.iy = 0x9C7D;
    expect(z80.iyh, equals(0x9C));
    expect(z80.iyl, equals(0x7D));
  });
}
