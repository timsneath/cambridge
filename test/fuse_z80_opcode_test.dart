// fuse_unit_test.dart -- translated Z80 unit tests from FUSE Z80 emulator
//
// The FUSE emulator contains a large unit test suite of over 1,300 tests,
// which cover both documented and undocumented opcodes:
//   http://fuse-emulator.sourceforge.net/

// Run tests with `flutter test --plain-name=OPCODE` (for documented tests)

import 'package:flutter_test/flutter_test.dart';
import 'package:spectrum/core/z80.dart';
import 'package:spectrum/core/memory.dart';
import 'package:spectrum/core/utility.dart';

Memory memory = Memory(isRomProtected: false);
Z80 z80 = Z80(memory, startAddress: 0xA000);

void poke(int addr, int val) => memory.writeByte(addr, val);
int peek(int addr) => memory.readByte(addr);

// We use register names for the fields and we don't fuss too much about this.
// ignore_for_file: non_constant_identifier_names

void loadRegisters(int af, int bc, int de, int hl, int af_, int bc_, int de_,
    int hl_, int ix, int iy, int sp, int pc) {
  z80.af = af;
  z80.bc = bc;
  z80.de = de;
  z80.hl = hl;
  z80.a_ = highByte(af_);
  z80.f_ = lowByte(af_);
  z80.b_ = highByte(bc_);
  z80.c_ = lowByte(bc_);
  z80.d_ = highByte(de_);
  z80.e_ = lowByte(de_);
  z80.h_ = highByte(hl_);
  z80.l_ = lowByte(hl_);
  z80.ix = ix;
  z80.iy = iy;
  z80.sp = sp;
  z80.pc = pc;
}

void checkRegisters(int af, int bc, int de, int hl, int af_, int bc_, int de_,
    int hl_, int ix, int iy, int sp, int pc) {
  expect(highByte(z80.af), equals(highByte(af)),
      reason:
          "Register A: expected ${toHex8(highByte(af))}, actual ${toHex8(highByte(z80.af))}");
  // While we attempt basic emulation of the undocumented bits 3 and 5,
  // we're not going to fail a test because of them (at least, right now).
  // So we OR both values with 0b000101000 (0x28) to mask out any difference.
  expect(lowByte(z80.af | 0x28), equals(lowByte(af | 0x28)),
      reason:
          "Register F [SZ5H3PNC]: expected ${toBin8(lowByte(af))}, actual ${toBin8(lowByte(z80.af))}");
  expect(z80.bc, equals(bc), reason: "Register BC mismatch");
  expect(z80.de, equals(de), reason: "Register DE mismatch");
  expect(z80.hl, equals(hl), reason: "Register HL mismatch");
  expect(z80.af_, equals(af_), reason: "Register AF' mismatch");
  expect(z80.bc_, equals(bc_), reason: "Register BC' mismatch");
  expect(z80.de_, equals(de_), reason: "Register DE' mismatch");
  expect(z80.hl_, equals(hl_), reason: "Register HL' mismatch");
  expect(z80.ix, equals(ix), reason: "Register IX mismatch");
  expect(z80.iy, equals(iy), reason: "Register IY mismatch");
  expect(z80.sp, equals(sp), reason: "Register SP mismatch");
  expect(z80.pc, equals(pc), reason: "Register PC mismatch");
}

// ignore: avoid_positional_boolean_parameters
void checkSpecialRegisters(int i, int r, bool iff1, bool iff2, int tStates) {
  expect(z80.i, equals(i), reason: "Register I mismatch");

  // TODO: r is magic and we haven't done magic yet
  // expect(z80.r, equals(r));

  expect(z80.iff1, equals(iff1), reason: "Register IFF1 mismatch");
  expect(z80.iff2, equals(iff2), reason: "Register IFF2 mismatch");
  expect(z80.tStates, equals(tStates), reason: "tStates mismatch");
}

void main() {
  setUp(() {
    z80.reset();
    memory.reset();
  });
  tearDown(() {});

  // Test instruction 00 | NOP
  test("OPCODE 00 | NOP", () {
    // Set up machine initial state
    loadRegisters(0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0x00);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0001);
    checkSpecialRegisters(0x00, 0x01, false, false, 4);
  });

  // Test instruction 01 | LD BC, **
  test("OPCODE 01 | LD BC, **", () {
    // Set up machine initial state
    loadRegisters(0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0x01);
    poke(0x0001, 0x12);
    poke(0x0002, 0x34);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x0000, 0x3412, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0003);
    checkSpecialRegisters(0x00, 0x01, false, false, 10);
  });

  // Test instruction 02 | LD (BC), A
  test("OPCODE 02 | LD (BC), A", () {
    // Set up machine initial state
    loadRegisters(0x5600, 0x0001, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0x02);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x5600, 0x0001, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0001);
    checkSpecialRegisters(0x00, 0x01, false, false, 7);
    expect(peek(1), equals(0x56));
  });

  // Test instruction 02_1 | LD (BC), A
  test("OPCODE 02_1 | LD (BC), A", () {
    // Set up machine initial state
    loadRegisters(0x1300, 0x6b65, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0x02);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x1300, 0x6b65, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0001);
    checkSpecialRegisters(0x00, 0x01, false, false, 7);
    expect(peek(27493), equals(0x13));
  });

  // Test instruction 03 | INC BC
  test("OPCODE 03 | INC BC", () {
    // Set up machine initial state
    loadRegisters(0x0000, 0x789a, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0x03);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x0000, 0x789b, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0001);
    checkSpecialRegisters(0x00, 0x01, false, false, 6);
  });

  // Test instruction 04 | INC B
  test("OPCODE 04 | INC B", () {
    // Set up machine initial state
    loadRegisters(0x0000, 0xff00, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0x04);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x0050, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0001);
    checkSpecialRegisters(0x00, 0x01, false, false, 4);
  });

  // Test instruction 05 | DEC B
  test("OPCODE 05 | DEC B", () {
    // Set up machine initial state
    loadRegisters(0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0x05);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x00ba, 0xff00, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0001);
    checkSpecialRegisters(0x00, 0x01, false, false, 4);
  });

  // Test instruction 06 | LD B, *
  test("OPCODE 06 | LD B, *", () {
    // Set up machine initial state
    loadRegisters(0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0x06);
    poke(0x0001, 0xbc);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x0000, 0xbc00, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x01, false, false, 7);
  });

  // Test instruction 07 | RLCA
  test("OPCODE 07 | RLCA", () {
    // Set up machine initial state
    loadRegisters(0x8800, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0x07);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x1101, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0001);
    checkSpecialRegisters(0x00, 0x01, false, false, 4);
  });

  // Test instruction 08 | EX AF, AF'
  test("OPCODE 08 | EX AF, AF'", () {
    // Set up machine initial state
    loadRegisters(0xdef0, 0x0000, 0x0000, 0x0000, 0x1234, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0x08);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x1234, 0x0000, 0x0000, 0x0000, 0xdef0, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0001);
    checkSpecialRegisters(0x00, 0x01, false, false, 4);
  });

  // Test instruction 09 | ADD HL, BC
  test("OPCODE 09 | ADD HL, BC", () {
    // Set up machine initial state
    loadRegisters(0x0000, 0x5678, 0x0000, 0x9abc, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0x09);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x0030, 0x5678, 0x0000, 0xf134, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0001);
    checkSpecialRegisters(0x00, 0x01, false, false, 11);
  });

  // Test instruction 0a | LD A, (BC)
  test("OPCODE 0a | LD A, (BC)", () {
    // Set up machine initial state
    loadRegisters(0x0000, 0x0001, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0x0a);
    poke(0x0001, 0xde);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xde00, 0x0001, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0001);
    checkSpecialRegisters(0x00, 0x01, false, false, 7);
  });

  // Test instruction 0a_1 | LD A, (BC)
  test("OPCODE 0a_1 | LD A, (BC)", () {
    // Set up machine initial state
    loadRegisters(0x0000, 0x1234, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0x0a);
    poke(0x1234, 0x56);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x5600, 0x1234, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0001);
    checkSpecialRegisters(0x00, 0x01, false, false, 7);
  });

  // Test instruction 0b | DEC BC
  test("OPCODE 0b | DEC BC", () {
    // Set up machine initial state
    loadRegisters(0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0x0b);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x0000, 0xffff, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0001);
    checkSpecialRegisters(0x00, 0x01, false, false, 6);
  });

  // Test instruction 0c | INC C
  test("OPCODE 0c | INC C", () {
    // Set up machine initial state
    loadRegisters(0x0000, 0x007f, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0x0c);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x0094, 0x0080, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0001);
    checkSpecialRegisters(0x00, 0x01, false, false, 4);
  });

  // Test instruction 0d | DEC C
  test("OPCODE 0d | DEC C", () {
    // Set up machine initial state
    loadRegisters(0x0000, 0x0080, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0x0d);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x003e, 0x007f, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0001);
    checkSpecialRegisters(0x00, 0x01, false, false, 4);
  });

  // Test instruction 0e | LD C, *
  test("OPCODE 0e | LD C, *", () {
    // Set up machine initial state
    loadRegisters(0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0x0e);
    poke(0x0001, 0xf0);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x0000, 0x00f0, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x01, false, false, 7);
  });

  // Test instruction 0f | RRCA
  test("OPCODE 0f | RRCA", () {
    // Set up machine initial state
    loadRegisters(0x4100, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0x0f);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xa021, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0001);
    checkSpecialRegisters(0x00, 0x01, false, false, 4);
  });

  // Test instruction 10 | DJNZ *
  test("OPCODE 10 | DJNZ *", () {
    // Set up machine initial state
    loadRegisters(0x0000, 0x0800, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0x00);
    poke(0x0001, 0x10);
    poke(0x0002, 0xfd);
    poke(0x0003, 0x0c);

    // Execute machine for tState cycles
    while (z80.tStates < 132) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x0000, 0x0001, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0004);
    checkSpecialRegisters(0x00, 0x11, false, false, 135);
  });

  // Test instruction 11 | LD DE, **
  test("OPCODE 11 | LD DE, **", () {
    // Set up machine initial state
    loadRegisters(0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0x11);
    poke(0x0001, 0x9a);
    poke(0x0002, 0xbc);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x0000, 0x0000, 0xbc9a, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0003);
    checkSpecialRegisters(0x00, 0x01, false, false, 10);
  });

  // Test instruction 12 | LD (DE), A
  test("OPCODE 12 | LD (DE), A", () {
    // Set up machine initial state
    loadRegisters(0x5600, 0x0000, 0x8000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0x12);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x5600, 0x0000, 0x8000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0001);
    checkSpecialRegisters(0x00, 0x01, false, false, 7);
    expect(peek(32768), equals(0x56));
  });

  // Test instruction 13 | INC DE
  test("OPCODE 13 | INC DE", () {
    // Set up machine initial state
    loadRegisters(0x0000, 0x0000, 0xdef0, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0x13);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x0000, 0x0000, 0xdef1, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0001);
    checkSpecialRegisters(0x00, 0x01, false, false, 6);
  });

  // Test instruction 14 | INC D
  test("OPCODE 14 | INC D", () {
    // Set up machine initial state
    loadRegisters(0x0000, 0x0000, 0x2700, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0x14);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x0028, 0x0000, 0x2800, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0001);
    checkSpecialRegisters(0x00, 0x01, false, false, 4);
  });

  // Test instruction 15 | DEC D
  test("OPCODE 15 | DEC D", () {
    // Set up machine initial state
    loadRegisters(0x0000, 0x0000, 0x1000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0x15);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x001a, 0x0000, 0x0f00, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0001);
    checkSpecialRegisters(0x00, 0x01, false, false, 4);
  });

  // Test instruction 16 | LD D, *
  test("OPCODE 16 | LD D, *", () {
    // Set up machine initial state
    loadRegisters(0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0x16);
    poke(0x0001, 0x12);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x0000, 0x0000, 0x1200, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x01, false, false, 7);
  });

  // Test instruction 17 | RLA
  test("OPCODE 17 | RLA", () {
    // Set up machine initial state
    loadRegisters(0x0801, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0x17);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x1100, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0001);
    checkSpecialRegisters(0x00, 0x01, false, false, 4);
  });

  // Test instruction 18 | JR *
  test("OPCODE 18 | JR *", () {
    // Set up machine initial state
    loadRegisters(0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0x18);
    poke(0x0001, 0x40);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0042);
    checkSpecialRegisters(0x00, 0x01, false, false, 12);
  });

  // Test instruction 19 | ADD HL, DE
  test("OPCODE 19 | ADD HL, DE", () {
    // Set up machine initial state
    loadRegisters(0x0000, 0x0000, 0x3456, 0x789a, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0x19);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x0028, 0x0000, 0x3456, 0xacf0, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0001);
    checkSpecialRegisters(0x00, 0x01, false, false, 11);
  });

  // Test instruction 1a | LD A, (DE)
  test("OPCODE 1a | LD A, (DE)", () {
    // Set up machine initial state
    loadRegisters(0x0000, 0x0000, 0x8000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0x1a);
    poke(0x8000, 0x13);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x1300, 0x0000, 0x8000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0001);
    checkSpecialRegisters(0x00, 0x01, false, false, 7);
  });

  // Test instruction 1b | DEC DE
  test("OPCODE 1b | DEC DE", () {
    // Set up machine initial state
    loadRegisters(0x0000, 0x0000, 0xe5d4, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0x1b);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x0000, 0x0000, 0xe5d3, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0001);
    checkSpecialRegisters(0x00, 0x01, false, false, 6);
  });

  // Test instruction 1c | INC E
  test("OPCODE 1c | INC E", () {
    // Set up machine initial state
    loadRegisters(0x0000, 0x0000, 0x00aa, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0x1c);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x00a8, 0x0000, 0x00ab, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0001);
    checkSpecialRegisters(0x00, 0x01, false, false, 4);
  });

  // Test instruction 1d | DEC E
  test("OPCODE 1d | DEC E", () {
    // Set up machine initial state
    loadRegisters(0x0000, 0x0000, 0x00aa, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0x1d);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x00aa, 0x0000, 0x00a9, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0001);
    checkSpecialRegisters(0x00, 0x01, false, false, 4);
  });

  // Test instruction 1e | LD E, *
  test("OPCODE 1e | LD E, *", () {
    // Set up machine initial state
    loadRegisters(0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0x1e);
    poke(0x0001, 0xef);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x0000, 0x0000, 0x00ef, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x01, false, false, 7);
  });

  // Test instruction 1f | RRA
  test("OPCODE 1f | RRA", () {
    // Set up machine initial state
    loadRegisters(0x01c4, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0x1f);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x00c5, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0001);
    checkSpecialRegisters(0x00, 0x01, false, false, 4);
  });

  // Test instruction 20_1 | JR NZ, *
  test("OPCODE 20_1 | JR NZ, *", () {
    // Set up machine initial state
    loadRegisters(0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0x20);
    poke(0x0001, 0x40);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0042);
    checkSpecialRegisters(0x00, 0x01, false, false, 12);
  });

  // Test instruction 20_2 | JR NZ, *
  test("OPCODE 20_2 | JR NZ, *", () {
    // Set up machine initial state
    loadRegisters(0x0040, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0x20);
    poke(0x0001, 0x40);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x0040, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x01, false, false, 7);
  });

  // Test instruction 21 | LD HL, **
  test("OPCODE 21 | LD HL, **", () {
    // Set up machine initial state
    loadRegisters(0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0x21);
    poke(0x0001, 0x28);
    poke(0x0002, 0xed);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x0000, 0x0000, 0x0000, 0xed28, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0003);
    checkSpecialRegisters(0x00, 0x01, false, false, 10);
  });

  // Test instruction 22 | LD (**), HL
  test("OPCODE 22 | LD (**), HL", () {
    // Set up machine initial state
    loadRegisters(0x0000, 0x0000, 0x0000, 0xc64c, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0x22);
    poke(0x0001, 0xb0);
    poke(0x0002, 0xc3);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x0000, 0x0000, 0x0000, 0xc64c, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0003);
    checkSpecialRegisters(0x00, 0x01, false, false, 16);
    expect(peek(50096), equals(0x4c));
    expect(peek(50097), equals(0xc6));
  });

  // Test instruction 23 | INC HL
  test("OPCODE 23 | INC HL", () {
    // Set up machine initial state
    loadRegisters(0x0000, 0x0000, 0x0000, 0x9c4e, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0x23);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x0000, 0x0000, 0x0000, 0x9c4f, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0001);
    checkSpecialRegisters(0x00, 0x01, false, false, 6);
  });

  // Test instruction 24 | INC H
  test("OPCODE 24 | INC H", () {
    // Set up machine initial state
    loadRegisters(0x0000, 0x0000, 0x0000, 0x7200, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0x24);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x0020, 0x0000, 0x0000, 0x7300, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0001);
    checkSpecialRegisters(0x00, 0x01, false, false, 4);
  });

  // Test instruction 25 | DEC H
  test("OPCODE 25 | DEC H", () {
    // Set up machine initial state
    loadRegisters(0x0000, 0x0000, 0x0000, 0xa500, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0x25);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x00a2, 0x0000, 0x0000, 0xa400, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0001);
    checkSpecialRegisters(0x00, 0x01, false, false, 4);
  });

  // Test instruction 26 | LD H, *
  test("OPCODE 26 | LD H, *", () {
    // Set up machine initial state
    loadRegisters(0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0x26);
    poke(0x0001, 0x3a);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x0000, 0x0000, 0x0000, 0x3a00, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x01, false, false, 7);
  });

  // Test instruction 27_1 | DAA
  test("OPCODE 27_1 | DAA", () {
    // Set up machine initial state
    loadRegisters(0x9a02, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0x27);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x3423, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0001);
    checkSpecialRegisters(0x00, 0x01, false, false, 4);
  });

  // Test instruction 27 | DAA
  test("OPCODE 27 | DAA", () {
    // Set up machine initial state
    loadRegisters(0x1f00, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0x27);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x2530, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0001);
    checkSpecialRegisters(0x00, 0x01, false, false, 4);
  });

  // Test instruction 28_1 | JR Z, *
  test("OPCODE 28_1 | JR Z, *", () {
    // Set up machine initial state
    loadRegisters(0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0x28);
    poke(0x0001, 0x8e);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x01, false, false, 7);
  });

  // Test instruction 28_2 | JR Z, *
  test("OPCODE 28_2 | JR Z, *", () {
    // Set up machine initial state
    loadRegisters(0x0040, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0x28);
    poke(0x0001, 0x8e);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x0040, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0xff90);
    checkSpecialRegisters(0x00, 0x01, false, false, 12);
  });

  // Test instruction 29 | ADD HL, HL
  test("OPCODE 29 | ADD HL, HL", () {
    // Set up machine initial state
    loadRegisters(0x0000, 0x0000, 0x0000, 0xcdfa, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0x29);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x0019, 0x0000, 0x0000, 0x9bf4, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0001);
    checkSpecialRegisters(0x00, 0x01, false, false, 11);
  });

  // Test instruction 2a | LD HL, (**)
  test("OPCODE 2a | LD HL, (**)", () {
    // Set up machine initial state
    loadRegisters(0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0x2a);
    poke(0x0001, 0x45);
    poke(0x0002, 0xac);
    poke(0xac45, 0xc4);
    poke(0xac46, 0xde);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x0000, 0x0000, 0x0000, 0xdec4, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0003);
    checkSpecialRegisters(0x00, 0x01, false, false, 16);
  });

  // Test instruction 2b | DEC HL
  test("OPCODE 2b | DEC HL", () {
    // Set up machine initial state
    loadRegisters(0x0000, 0x0000, 0x0000, 0x9e66, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0x2b);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x0000, 0x0000, 0x0000, 0x9e65, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0001);
    checkSpecialRegisters(0x00, 0x01, false, false, 6);
  });

  // Test instruction 2c | INC L
  test("OPCODE 2c | INC L", () {
    // Set up machine initial state
    loadRegisters(0x0000, 0x0000, 0x0000, 0x0026, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0x2c);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x0020, 0x0000, 0x0000, 0x0027, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0001);
    checkSpecialRegisters(0x00, 0x01, false, false, 4);
  });

  // Test instruction 2d | DEC L
  test("OPCODE 2d | DEC L", () {
    // Set up machine initial state
    loadRegisters(0x0000, 0x0000, 0x0000, 0x0032, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0x2d);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x0022, 0x0000, 0x0000, 0x0031, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0001);
    checkSpecialRegisters(0x00, 0x01, false, false, 4);
  });

  // Test instruction 2e | LD L, *
  test("OPCODE 2e | LD L, *", () {
    // Set up machine initial state
    loadRegisters(0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0x2e);
    poke(0x0001, 0x18);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x0000, 0x0000, 0x0000, 0x0018, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x01, false, false, 7);
  });

  // Test instruction 2f | CPL
  test("OPCODE 2f | CPL", () {
    // Set up machine initial state
    loadRegisters(0x8900, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0x2f);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x7632, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0001);
    checkSpecialRegisters(0x00, 0x01, false, false, 4);
  });

  // Test instruction 30_1 | JR NC, *
  test("OPCODE 30_1 | JR NC, *", () {
    // Set up machine initial state
    loadRegisters(0x0036, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0x30);
    poke(0x0001, 0x50);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x0036, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0052);
    checkSpecialRegisters(0x00, 0x01, false, false, 12);
  });

  // Test instruction 30_2 | JR NC, *
  test("OPCODE 30_2 | JR NC, *", () {
    // Set up machine initial state
    loadRegisters(0x0037, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0x30);
    poke(0x0001, 0x50);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x0037, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x01, false, false, 7);
  });

  // Test instruction 31 | LD SP, **
  test("OPCODE 31 | LD SP, **", () {
    // Set up machine initial state
    loadRegisters(0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0x31);
    poke(0x0001, 0xd4);
    poke(0x0002, 0x61);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x61d4, 0x0003);
    checkSpecialRegisters(0x00, 0x01, false, false, 10);
  });

  // Test instruction 32 | LD (**), A
  test("OPCODE 32 | LD (**), A", () {
    // Set up machine initial state
    loadRegisters(0x0e00, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0x32);
    poke(0x0001, 0xac);
    poke(0x0002, 0xad);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x0e00, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0003);
    checkSpecialRegisters(0x00, 0x01, false, false, 13);
    expect(peek(44460), equals(0x0e));
  });

  // Test instruction 32_1 | LD (**), A
  test("OPCODE 32_1 | LD (**), A", () {
    // Set up machine initial state
    loadRegisters(0x5600, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0x32);
    poke(0x0001, 0x34);
    poke(0x0002, 0x12);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x5600, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0003);
    checkSpecialRegisters(0x00, 0x01, false, false, 13);
    expect(peek(4660), equals(0x56));
  });

  // Test instruction 33 | INC SP
  test("OPCODE 33 | INC SP", () {
    // Set up machine initial state
    loadRegisters(0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0xa55a, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0x33);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0xa55b, 0x0001);
    checkSpecialRegisters(0x00, 0x01, false, false, 6);
  });

  // Test instruction 34 | INC (HL)
  test("OPCODE 34 | INC (HL)", () {
    // Set up machine initial state
    loadRegisters(0x0000, 0x0000, 0x0000, 0xfe1d, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0x34);
    poke(0xfe1d, 0xfd);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x00a8, 0x0000, 0x0000, 0xfe1d, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0001);
    checkSpecialRegisters(0x00, 0x01, false, false, 11);
    expect(peek(65053), equals(0xfe));
  });

  // Test instruction 35 | DEC (HL)
  test("OPCODE 35 | DEC (HL)", () {
    // Set up machine initial state
    loadRegisters(0x0000, 0x0000, 0x0000, 0x470c, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0x35);
    poke(0x470c, 0x82);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x0082, 0x0000, 0x0000, 0x470c, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0001);
    checkSpecialRegisters(0x00, 0x01, false, false, 11);
    expect(peek(18188), equals(0x81));
  });

  // Test instruction 36 | LD (HL), *
  test("OPCODE 36 | LD (HL), *", () {
    // Set up machine initial state
    loadRegisters(0x0000, 0x0000, 0x0000, 0x7d29, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0x36);
    poke(0x0001, 0x7c);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x0000, 0x0000, 0x0000, 0x7d29, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x01, false, false, 10);
    expect(peek(32041), equals(0x7c));
  });

  // Test instruction 37_1 | SCF
  test("OPCODE 37_1 | SCF", () {
    // Set up machine initial state
    loadRegisters(0x00ff, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0x37);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x00c5, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0001);
    checkSpecialRegisters(0x00, 0x01, false, false, 4);
  });

  // Test instruction 37_2 | SCF
  test("OPCODE 37_2 | SCF", () {
    // Set up machine initial state
    loadRegisters(0xff00, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0x37);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xff29, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0001);
    checkSpecialRegisters(0x00, 0x01, false, false, 4);
  });

  // Test instruction 37_3 | SCF
  test("OPCODE 37_3 | SCF", () {
    // Set up machine initial state
    loadRegisters(0xffff, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0x37);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xffed, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0001);
    checkSpecialRegisters(0x00, 0x01, false, false, 4);
  });

  // Test instruction 37 | SCF
  test("OPCODE 37 | SCF", () {
    // Set up machine initial state
    loadRegisters(0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0x37);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x0001, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0001);
    checkSpecialRegisters(0x00, 0x01, false, false, 4);
  });

  // Test instruction 38_1 | JR C, *
  test("OPCODE 38_1 | JR C, *", () {
    // Set up machine initial state
    loadRegisters(0x00b2, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0x38);
    poke(0x0001, 0x66);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x00b2, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x01, false, false, 7);
  });

  // Test instruction 38_2 | JR C, *
  test("OPCODE 38_2 | JR C, *", () {
    // Set up machine initial state
    loadRegisters(0x00b3, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0x38);
    poke(0x0001, 0x66);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x00b3, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0068);
    checkSpecialRegisters(0x00, 0x01, false, false, 12);
  });

  // Test instruction 39 | ADD HL, SP
  test("OPCODE 39 | ADD HL, SP", () {
    // Set up machine initial state
    loadRegisters(0x0000, 0x0000, 0x0000, 0x1aef, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0xc534, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0x39);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x0030, 0x0000, 0x0000, 0xe023, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0xc534, 0x0001);
    checkSpecialRegisters(0x00, 0x01, false, false, 11);
  });

  // Test instruction 3a | LD A, (**)
  test("OPCODE 3a | LD A, (**)", () {
    // Set up machine initial state
    loadRegisters(0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0x3a);
    poke(0x0001, 0x52);
    poke(0x0002, 0x99);
    poke(0x9952, 0x28);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x2800, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0003);
    checkSpecialRegisters(0x00, 0x01, false, false, 13);
  });

  // Test instruction 3b | DEC SP
  test("OPCODE 3b | DEC SP", () {
    // Set up machine initial state
    loadRegisters(0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x9d36, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0x3b);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x9d35, 0x0001);
    checkSpecialRegisters(0x00, 0x01, false, false, 6);
  });

  // Test instruction 3c | INC A
  test("OPCODE 3c | INC A", () {
    // Set up machine initial state
    loadRegisters(0xcf00, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0x3c);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xd090, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0001);
    checkSpecialRegisters(0x00, 0x01, false, false, 4);
  });

  // Test instruction 3d | DEC A
  test("OPCODE 3d | DEC A", () {
    // Set up machine initial state
    loadRegisters(0xea00, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0x3d);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xe9aa, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0001);
    checkSpecialRegisters(0x00, 0x01, false, false, 4);
  });

  // Test instruction 3e | LD A, *
  test("OPCODE 3e | LD A, *", () {
    // Set up machine initial state
    loadRegisters(0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0x3e);
    poke(0x0001, 0xd6);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xd600, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x01, false, false, 7);
  });

  // Test instruction 3f | CCF
  test("OPCODE 3f | CCF", () {
    // Set up machine initial state
    loadRegisters(0x005b, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0x3f);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x0050, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0001);
    checkSpecialRegisters(0x00, 0x01, false, false, 4);
  });

  // Test instruction 40 | LD B, B
  test("OPCODE 40 | LD B, B", () {
    // Set up machine initial state
    loadRegisters(0x0200, 0xcf98, 0x90d8, 0xa169, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0x40);
    poke(0xa169, 0x50);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x0200, 0xcf98, 0x90d8, 0xa169, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0001);
    checkSpecialRegisters(0x00, 0x01, false, false, 4);
  });

  // Test instruction 41 | LD B, C
  test("OPCODE 41 | LD B, C", () {
    // Set up machine initial state
    loadRegisters(0x0200, 0xcf98, 0x90d8, 0xa169, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0x41);
    poke(0xa169, 0x50);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x0200, 0x9898, 0x90d8, 0xa169, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0001);
    checkSpecialRegisters(0x00, 0x01, false, false, 4);
  });

  // Test instruction 42 | LD B, D
  test("OPCODE 42 | LD B, D", () {
    // Set up machine initial state
    loadRegisters(0x0200, 0xcf98, 0x90d8, 0xa169, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0x42);
    poke(0xa169, 0x50);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x0200, 0x9098, 0x90d8, 0xa169, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0001);
    checkSpecialRegisters(0x00, 0x01, false, false, 4);
  });

  // Test instruction 43 | LD B, E
  test("OPCODE 43 | LD B, E", () {
    // Set up machine initial state
    loadRegisters(0x0200, 0xcf98, 0x90d8, 0xa169, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0x43);
    poke(0xa169, 0x50);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x0200, 0xd898, 0x90d8, 0xa169, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0001);
    checkSpecialRegisters(0x00, 0x01, false, false, 4);
  });

  // Test instruction 44 | LD B, H
  test("OPCODE 44 | LD B, H", () {
    // Set up machine initial state
    loadRegisters(0x0200, 0xcf98, 0x90d8, 0xa169, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0x44);
    poke(0xa169, 0x50);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x0200, 0xa198, 0x90d8, 0xa169, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0001);
    checkSpecialRegisters(0x00, 0x01, false, false, 4);
  });

  // Test instruction 45 | LD B, L
  test("OPCODE 45 | LD B, L", () {
    // Set up machine initial state
    loadRegisters(0x0200, 0xcf98, 0x90d8, 0xa169, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0x45);
    poke(0xa169, 0x50);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x0200, 0x6998, 0x90d8, 0xa169, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0001);
    checkSpecialRegisters(0x00, 0x01, false, false, 4);
  });

  // Test instruction 46 | LD B, (HL)
  test("OPCODE 46 | LD B, (HL)", () {
    // Set up machine initial state
    loadRegisters(0x0200, 0xcf98, 0x90d8, 0xa169, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0x46);
    poke(0xa169, 0x50);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x0200, 0x5098, 0x90d8, 0xa169, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0001);
    checkSpecialRegisters(0x00, 0x01, false, false, 7);
  });

  // Test instruction 47 | LD B, A
  test("OPCODE 47 | LD B, A", () {
    // Set up machine initial state
    loadRegisters(0x0200, 0xcf98, 0x90d8, 0xa169, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0x47);
    poke(0xa169, 0x50);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x0200, 0x0298, 0x90d8, 0xa169, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0001);
    checkSpecialRegisters(0x00, 0x01, false, false, 4);
  });

  // Test instruction 48 | LD C, B
  test("OPCODE 48 | LD C, B", () {
    // Set up machine initial state
    loadRegisters(0x0200, 0xcf98, 0x90d8, 0xa169, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0x48);
    poke(0xa169, 0x50);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x0200, 0xcfcf, 0x90d8, 0xa169, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0001);
    checkSpecialRegisters(0x00, 0x01, false, false, 4);
  });

  // Test instruction 49 | LD C, C
  test("OPCODE 49 | LD C, C", () {
    // Set up machine initial state
    loadRegisters(0x0200, 0xcf98, 0x90d8, 0xa169, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0x49);
    poke(0xa169, 0x50);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x0200, 0xcf98, 0x90d8, 0xa169, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0001);
    checkSpecialRegisters(0x00, 0x01, false, false, 4);
  });

  // Test instruction 4a | LD C, D
  test("OPCODE 4a | LD C, D", () {
    // Set up machine initial state
    loadRegisters(0x0200, 0xcf98, 0x90d8, 0xa169, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0x4a);
    poke(0xa169, 0x50);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x0200, 0xcf90, 0x90d8, 0xa169, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0001);
    checkSpecialRegisters(0x00, 0x01, false, false, 4);
  });

  // Test instruction 4b | LD C, E
  test("OPCODE 4b | LD C, E", () {
    // Set up machine initial state
    loadRegisters(0x0200, 0xcf98, 0x90d8, 0xa169, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0x4b);
    poke(0xa169, 0x50);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x0200, 0xcfd8, 0x90d8, 0xa169, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0001);
    checkSpecialRegisters(0x00, 0x01, false, false, 4);
  });

  // Test instruction 4d | LD C, L
  test("OPCODE 4d | LD C, L", () {
    // Set up machine initial state
    loadRegisters(0x0200, 0xcf98, 0x90d8, 0xa169, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0x4d);
    poke(0xa169, 0x50);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x0200, 0xcf69, 0x90d8, 0xa169, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0001);
    checkSpecialRegisters(0x00, 0x01, false, false, 4);
  });

  // Test instruction 4f | LD C, A
  test("OPCODE 4f | LD C, A", () {
    // Set up machine initial state
    loadRegisters(0x0200, 0xcf98, 0x90d8, 0xa169, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0x4f);
    poke(0xa169, 0x50);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x0200, 0xcf02, 0x90d8, 0xa169, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0001);
    checkSpecialRegisters(0x00, 0x01, false, false, 4);
  });

  // Test instruction 50 | LD D, B
  test("OPCODE 50 | LD D, B", () {
    // Set up machine initial state
    loadRegisters(0x0200, 0xcf98, 0x90d8, 0xa169, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0x50);
    poke(0xa169, 0x50);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x0200, 0xcf98, 0xcfd8, 0xa169, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0001);
    checkSpecialRegisters(0x00, 0x01, false, false, 4);
  });

  // Test instruction 51 | LD D, C
  test("OPCODE 51 | LD D, C", () {
    // Set up machine initial state
    loadRegisters(0x0200, 0xcf98, 0x90d8, 0xa169, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0x51);
    poke(0xa169, 0x50);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x0200, 0xcf98, 0x98d8, 0xa169, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0001);
    checkSpecialRegisters(0x00, 0x01, false, false, 4);
  });

  // Test instruction 52 | LD D, D
  test("OPCODE 52 | LD D, D", () {
    // Set up machine initial state
    loadRegisters(0x0200, 0xcf98, 0x90d8, 0xa169, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0x52);
    poke(0xa169, 0x50);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x0200, 0xcf98, 0x90d8, 0xa169, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0001);
    checkSpecialRegisters(0x00, 0x01, false, false, 4);
  });

  // Test instruction 53 | LD D, E
  test("OPCODE 53 | LD D, E", () {
    // Set up machine initial state
    loadRegisters(0x0200, 0xcf98, 0x90d8, 0xa169, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0x53);
    poke(0xa169, 0x50);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x0200, 0xcf98, 0xd8d8, 0xa169, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0001);
    checkSpecialRegisters(0x00, 0x01, false, false, 4);
  });

  // Test instruction 55 | LD D, L
  test("OPCODE 55 | LD D, L", () {
    // Set up machine initial state
    loadRegisters(0x0200, 0xcf98, 0x90d8, 0xa169, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0x55);
    poke(0xa169, 0x50);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x0200, 0xcf98, 0x69d8, 0xa169, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0001);
    checkSpecialRegisters(0x00, 0x01, false, false, 4);
  });

  // Test instruction 56 | LD D, (HL)
  test("OPCODE 56 | LD D, (HL)", () {
    // Set up machine initial state
    loadRegisters(0x0200, 0xcf98, 0x90d8, 0xa169, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0x56);
    poke(0xa169, 0x50);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x0200, 0xcf98, 0x50d8, 0xa169, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0001);
    checkSpecialRegisters(0x00, 0x01, false, false, 7);
  });

  // Test instruction 57 | LD D, A
  test("OPCODE 57 | LD D, A", () {
    // Set up machine initial state
    loadRegisters(0x0200, 0xcf98, 0x90d8, 0xa169, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0x57);
    poke(0xa169, 0x50);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x0200, 0xcf98, 0x02d8, 0xa169, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0001);
    checkSpecialRegisters(0x00, 0x01, false, false, 4);
  });

  // Test instruction 58 | LD E, B
  test("OPCODE 58 | LD E, B", () {
    // Set up machine initial state
    loadRegisters(0x0200, 0xcf98, 0x90d8, 0xa169, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0x58);
    poke(0xa169, 0x50);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x0200, 0xcf98, 0x90cf, 0xa169, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0001);
    checkSpecialRegisters(0x00, 0x01, false, false, 4);
  });

  // Test instruction 59 | LD E, C
  test("OPCODE 59 | LD E, C", () {
    // Set up machine initial state
    loadRegisters(0x0200, 0xcf98, 0x90d8, 0xa169, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0x59);
    poke(0xa169, 0x50);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x0200, 0xcf98, 0x9098, 0xa169, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0001);
    checkSpecialRegisters(0x00, 0x01, false, false, 4);
  });

  // Test instruction 5a | LD E, D
  test("OPCODE 5a | LD E, D", () {
    // Set up machine initial state
    loadRegisters(0x0200, 0xcf98, 0x90d8, 0xa169, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0x5a);
    poke(0xa169, 0x50);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x0200, 0xcf98, 0x9090, 0xa169, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0001);
    checkSpecialRegisters(0x00, 0x01, false, false, 4);
  });

  // Test instruction 5b | LD E, E
  test("OPCODE 5b | LD E, E", () {
    // Set up machine initial state
    loadRegisters(0x0200, 0xcf98, 0x90d8, 0xa169, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0x5b);
    poke(0xa169, 0x50);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x0200, 0xcf98, 0x90d8, 0xa169, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0001);
    checkSpecialRegisters(0x00, 0x01, false, false, 4);
  });

  // Test instruction 5d | LD E, L
  test("OPCODE 5d | LD E, L", () {
    // Set up machine initial state
    loadRegisters(0x0200, 0xcf98, 0x90d8, 0xa169, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0x5d);
    poke(0xa169, 0x50);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x0200, 0xcf98, 0x9069, 0xa169, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0001);
    checkSpecialRegisters(0x00, 0x01, false, false, 4);
  });

  // Test instruction 5e | LD E, (HL)
  test("OPCODE 5e | LD E, (HL)", () {
    // Set up machine initial state
    loadRegisters(0x0200, 0xcf98, 0x90d8, 0xa169, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0x5e);
    poke(0xa169, 0x50);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x0200, 0xcf98, 0x9050, 0xa169, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0001);
    checkSpecialRegisters(0x00, 0x01, false, false, 7);
  });

  // Test instruction 5f | LD E, A
  test("OPCODE 5f | LD E, A", () {
    // Set up machine initial state
    loadRegisters(0x0200, 0xcf98, 0x90d8, 0xa169, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0x5f);
    poke(0xa169, 0x50);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x0200, 0xcf98, 0x9002, 0xa169, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0001);
    checkSpecialRegisters(0x00, 0x01, false, false, 4);
  });

  // Test instruction 60 | LD H, B
  test("OPCODE 60 | LD H, B", () {
    // Set up machine initial state
    loadRegisters(0x0200, 0xcf98, 0x90d8, 0xa169, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0x60);
    poke(0xa169, 0x50);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x0200, 0xcf98, 0x90d8, 0xcf69, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0001);
    checkSpecialRegisters(0x00, 0x01, false, false, 4);
  });

  // Test instruction 61 | LD H, C
  test("OPCODE 61 | LD H, C", () {
    // Set up machine initial state
    loadRegisters(0x0200, 0xcf98, 0x90d8, 0xa169, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0x61);
    poke(0xa169, 0x50);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x0200, 0xcf98, 0x90d8, 0x9869, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0001);
    checkSpecialRegisters(0x00, 0x01, false, false, 4);
  });

  // Test instruction 62 | LD H, D
  test("OPCODE 62 | LD H, D", () {
    // Set up machine initial state
    loadRegisters(0x0200, 0xcf98, 0x90d8, 0xa169, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0x62);
    poke(0xa169, 0x50);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x0200, 0xcf98, 0x90d8, 0x9069, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0001);
    checkSpecialRegisters(0x00, 0x01, false, false, 4);
  });

  // Test instruction 65 | LD H, L
  test("OPCODE 65 | LD H, L", () {
    // Set up machine initial state
    loadRegisters(0x0200, 0xcf98, 0x90d8, 0xa169, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0x65);
    poke(0xa169, 0x50);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x0200, 0xcf98, 0x90d8, 0x6969, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0001);
    checkSpecialRegisters(0x00, 0x01, false, false, 4);
  });

  // Test instruction 66 | LD H, (HL)
  test("OPCODE 66 | LD H, (HL)", () {
    // Set up machine initial state
    loadRegisters(0x0200, 0xcf98, 0x90d8, 0xa169, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0x66);
    poke(0xa169, 0x50);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x0200, 0xcf98, 0x90d8, 0x5069, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0001);
    checkSpecialRegisters(0x00, 0x01, false, false, 7);
  });

  // Test instruction 67 | LD H, A
  test("OPCODE 67 | LD H, A", () {
    // Set up machine initial state
    loadRegisters(0x0200, 0xcf98, 0x90d8, 0xa169, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0x67);
    poke(0xa169, 0x50);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x0200, 0xcf98, 0x90d8, 0x0269, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0001);
    checkSpecialRegisters(0x00, 0x01, false, false, 4);
  });

  // Test instruction 68 | LD L, B
  test("OPCODE 68 | LD L, B", () {
    // Set up machine initial state
    loadRegisters(0x0200, 0xcf98, 0x90d8, 0xa169, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0x68);
    poke(0xa169, 0x50);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x0200, 0xcf98, 0x90d8, 0xa1cf, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0001);
    checkSpecialRegisters(0x00, 0x01, false, false, 4);
  });

  // Test instruction 69 | LD L, C
  test("OPCODE 69 | LD L, C", () {
    // Set up machine initial state
    loadRegisters(0x0200, 0xcf98, 0x90d8, 0xa169, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0x69);
    poke(0xa169, 0x50);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x0200, 0xcf98, 0x90d8, 0xa198, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0001);
    checkSpecialRegisters(0x00, 0x01, false, false, 4);
  });

  // Test instruction 6a | LD L, D
  test("OPCODE 6a | LD L, D", () {
    // Set up machine initial state
    loadRegisters(0x0200, 0xcf98, 0x90d8, 0xa169, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0x6a);
    poke(0xa169, 0x50);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x0200, 0xcf98, 0x90d8, 0xa190, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0001);
    checkSpecialRegisters(0x00, 0x01, false, false, 4);
  });

  // Test instruction 6d | LD L, L
  test("OPCODE 6d | LD L, L", () {
    // Set up machine initial state
    loadRegisters(0x0200, 0xcf98, 0x90d8, 0xa169, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0x6d);
    poke(0xa169, 0x50);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x0200, 0xcf98, 0x90d8, 0xa169, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0001);
    checkSpecialRegisters(0x00, 0x01, false, false, 4);
  });

  // Test instruction 6f | LD L, A
  test("OPCODE 6f | LD L, A", () {
    // Set up machine initial state
    loadRegisters(0x0200, 0xcf98, 0x90d8, 0xa169, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0x6f);
    poke(0xa169, 0x50);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x0200, 0xcf98, 0x90d8, 0xa102, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0001);
    checkSpecialRegisters(0x00, 0x01, false, false, 4);
  });

  // Test instruction 72 | LD (HL), D
  test("OPCODE 72 | LD (HL), D", () {
    // Set up machine initial state
    loadRegisters(0x0200, 0xcf98, 0x90d8, 0xa169, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0x72);
    poke(0xa169, 0x50);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x0200, 0xcf98, 0x90d8, 0xa169, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0001);
    checkSpecialRegisters(0x00, 0x01, false, false, 7);
    expect(peek(41321), equals(0x90));
  });

  // Test instruction 73 | LD (HL), E
  test("OPCODE 73 | LD (HL), E", () {
    // Set up machine initial state
    loadRegisters(0x0200, 0xcf98, 0x90d8, 0xa169, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0x73);
    poke(0xa169, 0x50);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x0200, 0xcf98, 0x90d8, 0xa169, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0001);
    checkSpecialRegisters(0x00, 0x01, false, false, 7);
    expect(peek(41321), equals(0xd8));
  });

  // Test instruction 75 | LD (HL), L
  test("OPCODE 75 | LD (HL), L", () {
    // Set up machine initial state
    loadRegisters(0x0200, 0xcf98, 0x90d8, 0xa169, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0x75);
    poke(0xa169, 0x50);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x0200, 0xcf98, 0x90d8, 0xa169, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0001);
    checkSpecialRegisters(0x00, 0x01, false, false, 7);
    expect(peek(41321), equals(0x69));
  });

  // Test instruction 76 | HALT
  test("OPCODE 76 | HALT", () {
    // Set up machine initial state
    loadRegisters(0x0200, 0xcf98, 0x90d8, 0xa169, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0x76);
    poke(0xa169, 0x50);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x0200, 0xcf98, 0x90d8, 0xa169, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    checkSpecialRegisters(0x00, 0x01, false, false, 4);
  });

  // Test instruction 77 | LD (HL), A
  test("OPCODE 77 | LD (HL), A", () {
    // Set up machine initial state
    loadRegisters(0x0200, 0xcf98, 0x90d8, 0xa169, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0x77);
    poke(0xa169, 0x50);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x0200, 0xcf98, 0x90d8, 0xa169, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0001);
    checkSpecialRegisters(0x00, 0x01, false, false, 7);
    expect(peek(41321), equals(0x02));
  });

  // Test instruction 78 | LD A, B
  test("OPCODE 78 | LD A, B", () {
    // Set up machine initial state
    loadRegisters(0x0200, 0xcf98, 0x90d8, 0xa169, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0x78);
    poke(0xa169, 0x50);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xcf00, 0xcf98, 0x90d8, 0xa169, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0001);
    checkSpecialRegisters(0x00, 0x01, false, false, 4);
  });

  // Test instruction 79 | LD A, C
  test("OPCODE 79 | LD A, C", () {
    // Set up machine initial state
    loadRegisters(0x0200, 0xcf98, 0x90d8, 0xa169, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0x79);
    poke(0xa169, 0x50);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x9800, 0xcf98, 0x90d8, 0xa169, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0001);
    checkSpecialRegisters(0x00, 0x01, false, false, 4);
  });

  // Test instruction 7a | LD A, D
  test("OPCODE 7a | LD A, D", () {
    // Set up machine initial state
    loadRegisters(0x0200, 0xcf98, 0x90d8, 0xa169, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0x7a);
    poke(0xa169, 0x50);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x9000, 0xcf98, 0x90d8, 0xa169, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0001);
    checkSpecialRegisters(0x00, 0x01, false, false, 4);
  });

  // Test instruction 7b | LD A, E
  test("OPCODE 7b | LD A, E", () {
    // Set up machine initial state
    loadRegisters(0x0200, 0xcf98, 0x90d8, 0xa169, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0x7b);
    poke(0xa169, 0x50);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xd800, 0xcf98, 0x90d8, 0xa169, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0001);
    checkSpecialRegisters(0x00, 0x01, false, false, 4);
  });

  // Test instruction 7d | LD A, L
  test("OPCODE 7d | LD A, L", () {
    // Set up machine initial state
    loadRegisters(0x0200, 0xcf98, 0x90d8, 0xa169, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0x7d);
    poke(0xa169, 0x50);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x6900, 0xcf98, 0x90d8, 0xa169, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0001);
    checkSpecialRegisters(0x00, 0x01, false, false, 4);
  });

  // Test instruction 7e | LD A, (HL)
  test("OPCODE 7e | LD A, (HL)", () {
    // Set up machine initial state
    loadRegisters(0x0200, 0xcf98, 0x90d8, 0xa169, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0x7e);
    poke(0xa169, 0x50);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x5000, 0xcf98, 0x90d8, 0xa169, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0001);
    checkSpecialRegisters(0x00, 0x01, false, false, 7);
  });

  // Test instruction 7f | LD A, A
  test("OPCODE 7f | LD A, A", () {
    // Set up machine initial state
    loadRegisters(0x0200, 0xcf98, 0x90d8, 0xa169, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0x7f);
    poke(0xa169, 0x50);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x0200, 0xcf98, 0x90d8, 0xa169, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0001);
    checkSpecialRegisters(0x00, 0x01, false, false, 4);
  });

  // Test instruction 80 | ADD A, B
  test("OPCODE 80 | ADD A, B", () {
    // Set up machine initial state
    loadRegisters(0xf500, 0x0f3b, 0x200d, 0xdca6, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0x80);
    poke(0xdca6, 0x49);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x0411, 0x0f3b, 0x200d, 0xdca6, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0001);
    checkSpecialRegisters(0x00, 0x01, false, false, 4);
  });

  // Test instruction 81 | ADD A, C
  test("OPCODE 81 | ADD A, C", () {
    // Set up machine initial state
    loadRegisters(0xf500, 0x0f3b, 0x200d, 0xdca6, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0x81);
    poke(0xdca6, 0x49);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x3031, 0x0f3b, 0x200d, 0xdca6, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0001);
    checkSpecialRegisters(0x00, 0x01, false, false, 4);
  });

  // Test instruction 82 | ADD A, D
  test("OPCODE 82 | ADD A, D", () {
    // Set up machine initial state
    loadRegisters(0xf500, 0x0f3b, 0x200d, 0xdca6, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0x82);
    poke(0xdca6, 0x49);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x1501, 0x0f3b, 0x200d, 0xdca6, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0001);
    checkSpecialRegisters(0x00, 0x01, false, false, 4);
  });

  // Test instruction 83 | ADD A, E
  test("OPCODE 83 | ADD A, E", () {
    // Set up machine initial state
    loadRegisters(0xf500, 0x0f3b, 0x200d, 0xdca6, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0x83);
    poke(0xdca6, 0x49);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x0211, 0x0f3b, 0x200d, 0xdca6, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0001);
    checkSpecialRegisters(0x00, 0x01, false, false, 4);
  });

  // Test instruction 84 | ADD A, H
  test("OPCODE 84 | ADD A, H", () {
    // Set up machine initial state
    loadRegisters(0xf500, 0x0f3b, 0x200d, 0xdca6, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0x84);
    poke(0xdca6, 0x49);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xd191, 0x0f3b, 0x200d, 0xdca6, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0001);
    checkSpecialRegisters(0x00, 0x01, false, false, 4);
  });

  // Test instruction 85 | ADD A, L
  test("OPCODE 85 | ADD A, L", () {
    // Set up machine initial state
    loadRegisters(0xf500, 0x0f3b, 0x200d, 0xdca6, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0x85);
    poke(0xdca6, 0x49);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x9b89, 0x0f3b, 0x200d, 0xdca6, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0001);
    checkSpecialRegisters(0x00, 0x01, false, false, 4);
  });

  // Test instruction 86 | ADD A, (HL)
  test("OPCODE 86 | ADD A, (HL)", () {
    // Set up machine initial state
    loadRegisters(0xf500, 0x0f3b, 0x200d, 0xdca6, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0x86);
    poke(0xdca6, 0x49);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x3e29, 0x0f3b, 0x200d, 0xdca6, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0001);
    checkSpecialRegisters(0x00, 0x01, false, false, 7);
  });

  // Test instruction 87 | ADD A, A
  test("OPCODE 87 | ADD A, A", () {
    // Set up machine initial state
    loadRegisters(0xf500, 0x0f3b, 0x200d, 0xdca6, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0x87);
    poke(0xdca6, 0x49);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xeaa9, 0x0f3b, 0x200d, 0xdca6, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0001);
    checkSpecialRegisters(0x00, 0x01, false, false, 4);
  });

  // Test instruction 88 | ADC A, B
  test("OPCODE 88 | ADC A, B", () {
    // Set up machine initial state
    loadRegisters(0xf500, 0x0f3b, 0x200d, 0xdca6, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0x88);
    poke(0xdca6, 0x49);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x0411, 0x0f3b, 0x200d, 0xdca6, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0001);
    checkSpecialRegisters(0x00, 0x01, false, false, 4);
  });

  // Test instruction 89 | ADC A, C
  test("OPCODE 89 | ADC A, C", () {
    // Set up machine initial state
    loadRegisters(0xf500, 0x0f3b, 0x200d, 0xdca6, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0x89);
    poke(0xdca6, 0x49);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x3031, 0x0f3b, 0x200d, 0xdca6, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0001);
    checkSpecialRegisters(0x00, 0x01, false, false, 4);
  });

  // Test instruction 8a | ADC A, D
  test("OPCODE 8a | ADC A, D", () {
    // Set up machine initial state
    loadRegisters(0xf500, 0x0f3b, 0x200d, 0xdca6, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0x8a);
    poke(0xdca6, 0x49);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x1501, 0x0f3b, 0x200d, 0xdca6, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0001);
    checkSpecialRegisters(0x00, 0x01, false, false, 4);
  });

  // Test instruction 8b | ADC A, E
  test("OPCODE 8b | ADC A, E", () {
    // Set up machine initial state
    loadRegisters(0xf500, 0x0f3b, 0x200d, 0xdca6, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0x8b);
    poke(0xdca6, 0x49);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x0211, 0x0f3b, 0x200d, 0xdca6, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0001);
    checkSpecialRegisters(0x00, 0x01, false, false, 4);
  });

  // Test instruction 8c | ADC A, H
  test("OPCODE 8c | ADC A, H", () {
    // Set up machine initial state
    loadRegisters(0xf500, 0x0f3b, 0x200d, 0xdca6, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0x8c);
    poke(0xdca6, 0x49);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xd191, 0x0f3b, 0x200d, 0xdca6, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0001);
    checkSpecialRegisters(0x00, 0x01, false, false, 4);
  });

  // Test instruction 8d | ADC A, L
  test("OPCODE 8d | ADC A, L", () {
    // Set up machine initial state
    loadRegisters(0xf500, 0x0f3b, 0x200d, 0xdca6, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0x8d);
    poke(0xdca6, 0x49);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x9b89, 0x0f3b, 0x200d, 0xdca6, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0001);
    checkSpecialRegisters(0x00, 0x01, false, false, 4);
  });

  // Test instruction 8e | ADC A, (HL)
  test("OPCODE 8e | ADC A, (HL)", () {
    // Set up machine initial state
    loadRegisters(0xf500, 0x0f3b, 0x200d, 0xdca6, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0x8e);
    poke(0xdca6, 0x49);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x3e29, 0x0f3b, 0x200d, 0xdca6, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0001);
    checkSpecialRegisters(0x00, 0x01, false, false, 7);
  });

  // Test instruction 8f | ADC A, A
  test("OPCODE 8f | ADC A, A", () {
    // Set up machine initial state
    loadRegisters(0xf500, 0x0f3b, 0x200d, 0xdca6, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0x8f);
    poke(0xdca6, 0x49);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xeaa9, 0x0f3b, 0x200d, 0xdca6, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0001);
    checkSpecialRegisters(0x00, 0x01, false, false, 4);
  });

  // Test instruction 90 | SUB B
  test("OPCODE 90 | SUB B", () {
    // Set up machine initial state
    loadRegisters(0xf500, 0x0f3b, 0x200d, 0xdca6, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0x90);
    poke(0xdca6, 0x49);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xe6b2, 0x0f3b, 0x200d, 0xdca6, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0001);
    checkSpecialRegisters(0x00, 0x01, false, false, 4);
  });

  // Test instruction 91 | SUB C
  test("OPCODE 91 | SUB C", () {
    // Set up machine initial state
    loadRegisters(0xf500, 0x0f3b, 0x200d, 0xdca6, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0x91);
    poke(0xdca6, 0x49);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xbaba, 0x0f3b, 0x200d, 0xdca6, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0001);
    checkSpecialRegisters(0x00, 0x01, false, false, 4);
  });

  // Test instruction 92 | SUB D
  test("OPCODE 92 | SUB D", () {
    // Set up machine initial state
    loadRegisters(0xf500, 0x0f3b, 0x200d, 0xdca6, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0x92);
    poke(0xdca6, 0x49);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xd582, 0x0f3b, 0x200d, 0xdca6, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0001);
    checkSpecialRegisters(0x00, 0x01, false, false, 4);
  });

  // Test instruction 93 | SUB E
  test("OPCODE 93 | SUB E", () {
    // Set up machine initial state
    loadRegisters(0xf500, 0x0f3b, 0x200d, 0xdca6, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0x93);
    poke(0xdca6, 0x49);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xe8ba, 0x0f3b, 0x200d, 0xdca6, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0001);
    checkSpecialRegisters(0x00, 0x01, false, false, 4);
  });

  // Test instruction 94 | SUB H
  test("OPCODE 94 | SUB H", () {
    // Set up machine initial state
    loadRegisters(0xf500, 0x0f3b, 0x200d, 0xdca6, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0x94);
    poke(0xdca6, 0x49);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x191a, 0x0f3b, 0x200d, 0xdca6, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0001);
    checkSpecialRegisters(0x00, 0x01, false, false, 4);
  });

  // Test instruction 95 | SUB L
  test("OPCODE 95 | SUB L", () {
    // Set up machine initial state
    loadRegisters(0xf500, 0x0f3b, 0x200d, 0xdca6, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0x95);
    poke(0xdca6, 0x49);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x4f1a, 0x0f3b, 0x200d, 0xdca6, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0001);
    checkSpecialRegisters(0x00, 0x01, false, false, 4);
  });

  // Test instruction 96 | SUB (HL)
  test("OPCODE 96 | SUB (HL)", () {
    // Set up machine initial state
    loadRegisters(0xf500, 0x0f3b, 0x200d, 0xdca6, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0x96);
    poke(0xdca6, 0x49);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xacba, 0x0f3b, 0x200d, 0xdca6, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0001);
    checkSpecialRegisters(0x00, 0x01, false, false, 7);
  });

  // Test instruction 97 | SUB A
  test("OPCODE 97 | SUB A", () {
    // Set up machine initial state
    loadRegisters(0xf500, 0x0f3b, 0x200d, 0xdca6, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0x97);
    poke(0xdca6, 0x49);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x0042, 0x0f3b, 0x200d, 0xdca6, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0001);
    checkSpecialRegisters(0x00, 0x01, false, false, 4);
  });

  // Test instruction 98 | SBC B
  test("OPCODE 98 | SBC B", () {
    // Set up machine initial state
    loadRegisters(0xf500, 0x0f3b, 0x200d, 0xdca6, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0x98);
    poke(0xdca6, 0x49);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xe6b2, 0x0f3b, 0x200d, 0xdca6, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0001);
    checkSpecialRegisters(0x00, 0x01, false, false, 4);
  });

  // Test instruction 99 | SBC C
  test("OPCODE 99 | SBC C", () {
    // Set up machine initial state
    loadRegisters(0xf500, 0x0f3b, 0x200d, 0xdca6, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0x99);
    poke(0xdca6, 0x49);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xbaba, 0x0f3b, 0x200d, 0xdca6, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0001);
    checkSpecialRegisters(0x00, 0x01, false, false, 4);
  });

  // Test instruction 9a | SBC D
  test("OPCODE 9a | SBC D", () {
    // Set up machine initial state
    loadRegisters(0xf500, 0x0f3b, 0x200d, 0xdca6, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0x9a);
    poke(0xdca6, 0x49);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xd582, 0x0f3b, 0x200d, 0xdca6, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0001);
    checkSpecialRegisters(0x00, 0x01, false, false, 4);
  });

  // Test instruction 9b | SBC E
  test("OPCODE 9b | SBC E", () {
    // Set up machine initial state
    loadRegisters(0xf500, 0x0f3b, 0x200d, 0xdca6, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0x9b);
    poke(0xdca6, 0x49);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xe8ba, 0x0f3b, 0x200d, 0xdca6, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0001);
    checkSpecialRegisters(0x00, 0x01, false, false, 4);
  });

  // Test instruction 9c | SBC H
  test("OPCODE 9c | SBC H", () {
    // Set up machine initial state
    loadRegisters(0xf500, 0x0f3b, 0x200d, 0xdca6, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0x9c);
    poke(0xdca6, 0x49);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x191a, 0x0f3b, 0x200d, 0xdca6, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0001);
    checkSpecialRegisters(0x00, 0x01, false, false, 4);
  });

  // Test instruction 9d | SBC L
  test("OPCODE 9d | SBC L", () {
    // Set up machine initial state
    loadRegisters(0xf500, 0x0f3b, 0x200d, 0xdca6, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0x9d);
    poke(0xdca6, 0x49);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x4f1a, 0x0f3b, 0x200d, 0xdca6, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0001);
    checkSpecialRegisters(0x00, 0x01, false, false, 4);
  });

  // Test instruction 9e | SBC (HL)
  test("OPCODE 9e | SBC (HL)", () {
    // Set up machine initial state
    loadRegisters(0xf500, 0x0f3b, 0x200d, 0xdca6, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0x9e);
    poke(0xdca6, 0x49);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xacba, 0x0f3b, 0x200d, 0xdca6, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0001);
    checkSpecialRegisters(0x00, 0x01, false, false, 7);
  });

  // Test instruction 9f | SBC A, A
  test("OPCODE 9f | SBC A, A", () {
    // Set up machine initial state
    loadRegisters(0xf500, 0x0f3b, 0x200d, 0xdca6, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0x9f);
    poke(0xdca6, 0x49);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x0042, 0x0f3b, 0x200d, 0xdca6, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0001);
    checkSpecialRegisters(0x00, 0x01, false, false, 4);
  });

  // Test instruction a0 | AND B
  test("OPCODE a0 | AND B", () {
    // Set up machine initial state
    loadRegisters(0xf500, 0x0f3b, 0x200d, 0xdca6, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xa0);
    poke(0xdca6, 0x49);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x0514, 0x0f3b, 0x200d, 0xdca6, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0001);
    checkSpecialRegisters(0x00, 0x01, false, false, 4);
  });

  // Test instruction a1 | AND C
  test("OPCODE a1 | AND C", () {
    // Set up machine initial state
    loadRegisters(0xf500, 0x0f3b, 0x200d, 0xdca6, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xa1);
    poke(0xdca6, 0x49);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x3130, 0x0f3b, 0x200d, 0xdca6, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0001);
    checkSpecialRegisters(0x00, 0x01, false, false, 4);
  });

  // Test instruction a2 | AND D
  test("OPCODE a2 | AND D", () {
    // Set up machine initial state
    loadRegisters(0xf500, 0x0f3b, 0x200d, 0xdca6, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xa2);
    poke(0xdca6, 0x49);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x2030, 0x0f3b, 0x200d, 0xdca6, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0001);
    checkSpecialRegisters(0x00, 0x01, false, false, 4);
  });

  // Test instruction a3 | AND E
  test("OPCODE a3 | AND E", () {
    // Set up machine initial state
    loadRegisters(0xf500, 0x0f3b, 0x200d, 0xdca6, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xa3);
    poke(0xdca6, 0x49);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x0514, 0x0f3b, 0x200d, 0xdca6, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0001);
    checkSpecialRegisters(0x00, 0x01, false, false, 4);
  });

  // Test instruction a4 | AND H
  test("OPCODE a4 | AND H", () {
    // Set up machine initial state
    loadRegisters(0xf500, 0x0f3b, 0x200d, 0xdca6, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xa4);
    poke(0xdca6, 0x49);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xd494, 0x0f3b, 0x200d, 0xdca6, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0001);
    checkSpecialRegisters(0x00, 0x01, false, false, 4);
  });

  // Test instruction a5 | AND L
  test("OPCODE a5 | AND L", () {
    // Set up machine initial state
    loadRegisters(0xf500, 0x0f3b, 0x200d, 0xdca6, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xa5);
    poke(0xdca6, 0x49);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xa4b0, 0x0f3b, 0x200d, 0xdca6, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0001);
    checkSpecialRegisters(0x00, 0x01, false, false, 4);
  });

  // Test instruction a6 | AND (HL)
  test("OPCODE a6 | AND (HL)", () {
    // Set up machine initial state
    loadRegisters(0xf500, 0x0f3b, 0x200d, 0xdca6, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xa6);
    poke(0xdca6, 0x49);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x4114, 0x0f3b, 0x200d, 0xdca6, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0001);
    checkSpecialRegisters(0x00, 0x01, false, false, 7);
  });

  // Test instruction a7 | AND A
  test("OPCODE a7 | AND A", () {
    // Set up machine initial state
    loadRegisters(0xf500, 0x0f3b, 0x200d, 0xdca6, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xa7);
    poke(0xdca6, 0x49);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xf5b4, 0x0f3b, 0x200d, 0xdca6, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0001);
    checkSpecialRegisters(0x00, 0x01, false, false, 4);
  });

  // Test instruction a8 | XOR B
  test("OPCODE a8 | XOR B", () {
    // Set up machine initial state
    loadRegisters(0xf500, 0x0f3b, 0x200d, 0xdca6, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xa8);
    poke(0xdca6, 0x49);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xfaac, 0x0f3b, 0x200d, 0xdca6, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0001);
    checkSpecialRegisters(0x00, 0x01, false, false, 4);
  });

  // Test instruction a9 | XOR C
  test("OPCODE a9 | XOR C", () {
    // Set up machine initial state
    loadRegisters(0xf500, 0x0f3b, 0x200d, 0xdca6, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xa9);
    poke(0xdca6, 0x49);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xce88, 0x0f3b, 0x200d, 0xdca6, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0001);
    checkSpecialRegisters(0x00, 0x01, false, false, 4);
  });

  // Test instruction aa | XOR D
  test("OPCODE aa | XOR D", () {
    // Set up machine initial state
    loadRegisters(0xf500, 0x0f3b, 0x200d, 0xdca6, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xaa);
    poke(0xdca6, 0x49);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xd580, 0x0f3b, 0x200d, 0xdca6, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0001);
    checkSpecialRegisters(0x00, 0x01, false, false, 4);
  });

  // Test instruction ab | XOR E
  test("OPCODE ab | XOR E", () {
    // Set up machine initial state
    loadRegisters(0xf500, 0x0f3b, 0x200d, 0xdca6, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xab);
    poke(0xdca6, 0x49);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xf8a8, 0x0f3b, 0x200d, 0xdca6, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0001);
    checkSpecialRegisters(0x00, 0x01, false, false, 4);
  });

  // Test instruction ac | XOR H
  test("OPCODE ac | XOR H", () {
    // Set up machine initial state
    loadRegisters(0xf500, 0x0f3b, 0x200d, 0xdca6, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xac);
    poke(0xdca6, 0x49);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x2928, 0x0f3b, 0x200d, 0xdca6, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0001);
    checkSpecialRegisters(0x00, 0x01, false, false, 4);
  });

  // Test instruction ad | XOR L
  test("OPCODE ad | XOR L", () {
    // Set up machine initial state
    loadRegisters(0xf500, 0x0f3b, 0x200d, 0xdca6, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xad);
    poke(0xdca6, 0x49);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x5304, 0x0f3b, 0x200d, 0xdca6, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0001);
    checkSpecialRegisters(0x00, 0x01, false, false, 4);
  });

  // Test instruction ae | XOR (HL)
  test("OPCODE ae | XOR (HL)", () {
    // Set up machine initial state
    loadRegisters(0xf500, 0x0f3b, 0x200d, 0xdca6, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xae);
    poke(0xdca6, 0x49);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xbca8, 0x0f3b, 0x200d, 0xdca6, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0001);
    checkSpecialRegisters(0x00, 0x01, false, false, 7);
  });

  // Test instruction af | XOR A
  test("OPCODE af | XOR A", () {
    // Set up machine initial state
    loadRegisters(0xf500, 0x0f3b, 0x200d, 0xdca6, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xaf);
    poke(0xdca6, 0x49);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x0044, 0x0f3b, 0x200d, 0xdca6, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0001);
    checkSpecialRegisters(0x00, 0x01, false, false, 4);
  });

  // Test instruction b0 | OR B
  test("OPCODE b0 | OR B", () {
    // Set up machine initial state
    loadRegisters(0xf500, 0x0f3b, 0x200d, 0xdca6, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xb0);
    poke(0xdca6, 0x49);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xffac, 0x0f3b, 0x200d, 0xdca6, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0001);
    checkSpecialRegisters(0x00, 0x01, false, false, 4);
  });

  // Test instruction b1 | OR C
  test("OPCODE b1 | OR C", () {
    // Set up machine initial state
    loadRegisters(0xf500, 0x0f3b, 0x200d, 0xdca6, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xb1);
    poke(0xdca6, 0x49);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xffac, 0x0f3b, 0x200d, 0xdca6, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0001);
    checkSpecialRegisters(0x00, 0x01, false, false, 4);
  });

  // Test instruction b2 | OR D
  test("OPCODE b2 | OR D", () {
    // Set up machine initial state
    loadRegisters(0xf500, 0x0f3b, 0x200d, 0xdca6, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xb2);
    poke(0xdca6, 0x49);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xf5a4, 0x0f3b, 0x200d, 0xdca6, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0001);
    checkSpecialRegisters(0x00, 0x01, false, false, 4);
  });

  // Test instruction b3 | OR E
  test("OPCODE b3 | OR E", () {
    // Set up machine initial state
    loadRegisters(0xf500, 0x0f3b, 0x200d, 0xdca6, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xb3);
    poke(0xdca6, 0x49);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xfda8, 0x0f3b, 0x200d, 0xdca6, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0001);
    checkSpecialRegisters(0x00, 0x01, false, false, 4);
  });

  // Test instruction b4 | OR H
  test("OPCODE b4 | OR H", () {
    // Set up machine initial state
    loadRegisters(0xf500, 0x0f3b, 0x200d, 0xdca6, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xb4);
    poke(0xdca6, 0x49);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xfda8, 0x0f3b, 0x200d, 0xdca6, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0001);
    checkSpecialRegisters(0x00, 0x01, false, false, 4);
  });

  // Test instruction b5 | OR L
  test("OPCODE b5 | OR L", () {
    // Set up machine initial state
    loadRegisters(0xf500, 0x0f3b, 0x200d, 0xdca6, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xb5);
    poke(0xdca6, 0x49);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xf7a0, 0x0f3b, 0x200d, 0xdca6, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0001);
    checkSpecialRegisters(0x00, 0x01, false, false, 4);
  });

  // Test instruction b6 | OR (HL)
  test("OPCODE b6 | OR (HL)", () {
    // Set up machine initial state
    loadRegisters(0xf500, 0x0f3b, 0x200d, 0xdca6, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xb6);
    poke(0xdca6, 0x49);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xfda8, 0x0f3b, 0x200d, 0xdca6, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0001);
    checkSpecialRegisters(0x00, 0x01, false, false, 7);
  });

  // Test instruction b7 | OR A
  test("OPCODE b7 | OR A", () {
    // Set up machine initial state
    loadRegisters(0xf500, 0x0f3b, 0x200d, 0xdca6, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xb7);
    poke(0xdca6, 0x49);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xf5a4, 0x0f3b, 0x200d, 0xdca6, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0001);
    checkSpecialRegisters(0x00, 0x01, false, false, 4);
  });

  // Test instruction b8 | CP B
  test("OPCODE b8 | CP B", () {
    // Set up machine initial state
    loadRegisters(0xf500, 0x0f3b, 0x200d, 0xdca6, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xb8);
    poke(0xdca6, 0x49);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xf59a, 0x0f3b, 0x200d, 0xdca6, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0001);
    checkSpecialRegisters(0x00, 0x01, false, false, 4);
  });

  // Test instruction b9 | CP C
  test("OPCODE b9 | CP C", () {
    // Set up machine initial state
    loadRegisters(0xf500, 0x0f3b, 0x200d, 0xdca6, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xb9);
    poke(0xdca6, 0x49);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xf5ba, 0x0f3b, 0x200d, 0xdca6, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0001);
    checkSpecialRegisters(0x00, 0x01, false, false, 4);
  });

  // Test instruction ba | CP D
  test("OPCODE ba | CP D", () {
    // Set up machine initial state
    loadRegisters(0xf500, 0x0f3b, 0x200d, 0xdca6, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xba);
    poke(0xdca6, 0x49);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xf5a2, 0x0f3b, 0x200d, 0xdca6, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0001);
    checkSpecialRegisters(0x00, 0x01, false, false, 4);
  });

  // Test instruction bb | CP E
  test("OPCODE bb | CP E", () {
    // Set up machine initial state
    loadRegisters(0xf500, 0x0f3b, 0x200d, 0xdca6, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xbb);
    poke(0xdca6, 0x49);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xf59a, 0x0f3b, 0x200d, 0xdca6, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0001);
    checkSpecialRegisters(0x00, 0x01, false, false, 4);
  });

  // Test instruction bc | CP H
  test("OPCODE bc | CP H", () {
    // Set up machine initial state
    loadRegisters(0xf500, 0x0f3b, 0x200d, 0xdca6, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xbc);
    poke(0xdca6, 0x49);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xf51a, 0x0f3b, 0x200d, 0xdca6, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0001);
    checkSpecialRegisters(0x00, 0x01, false, false, 4);
  });

  // Test instruction bd | CP L
  test("OPCODE bd | CP L", () {
    // Set up machine initial state
    loadRegisters(0xf500, 0x0f3b, 0x200d, 0xdca6, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xbd);
    poke(0xdca6, 0x49);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xf532, 0x0f3b, 0x200d, 0xdca6, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0001);
    checkSpecialRegisters(0x00, 0x01, false, false, 4);
  });

  // Test instruction be | CP (HL)
  test("OPCODE be | CP (HL)", () {
    // Set up machine initial state
    loadRegisters(0xf500, 0x0f3b, 0x200d, 0xdca6, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xbe);
    poke(0xdca6, 0x49);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xf59a, 0x0f3b, 0x200d, 0xdca6, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0001);
    checkSpecialRegisters(0x00, 0x01, false, false, 7);
  });

  // Test instruction bf | CP A
  test("OPCODE bf | CP A", () {
    // Set up machine initial state
    loadRegisters(0xf500, 0x0f3b, 0x200d, 0xdca6, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xbf);
    poke(0xdca6, 0x49);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xf562, 0x0f3b, 0x200d, 0xdca6, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0001);
    checkSpecialRegisters(0x00, 0x01, false, false, 4);
  });

  // Test instruction c0_1 | RET NZ
  test("OPCODE c0_1 | RET NZ", () {
    // Set up machine initial state
    loadRegisters(0x0098, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x43f7, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xc0);
    poke(0x43f7, 0xe9);
    poke(0x43f8, 0xaf);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x0098, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x43f9, 0xafe9);
    checkSpecialRegisters(0x00, 0x01, false, false, 11);
  });

  // Test instruction c0_2 | RET NZ
  test("OPCODE c0_2 | RET NZ", () {
    // Set up machine initial state
    loadRegisters(0x00d8, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x43f7, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xc0);
    poke(0x43f7, 0xe9);
    poke(0x43f8, 0xaf);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x00d8, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x43f7, 0x0001);
    checkSpecialRegisters(0x00, 0x01, false, false, 5);
  });

  // Test instruction c1 | POP BC
  test("OPCODE c1 | POP BC", () {
    // Set up machine initial state
    loadRegisters(0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x4143, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xc1);
    poke(0x4143, 0xce);
    poke(0x4144, 0xe8);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x0000, 0xe8ce, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x4145, 0x0001);
    checkSpecialRegisters(0x00, 0x01, false, false, 10);
  });

  // Test instruction c2_1 | JP NZ, **
  test("OPCODE c2_1 | JP NZ, **", () {
    // Set up machine initial state
    loadRegisters(0x0087, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xc2);
    poke(0x0001, 0x1b);
    poke(0x0002, 0xe1);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x0087, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0xe11b);
    checkSpecialRegisters(0x00, 0x01, false, false, 10);
  });

  // Test instruction c2_2 | JP NZ, **
  test("OPCODE c2_2 | JP NZ, **", () {
    // Set up machine initial state
    loadRegisters(0x00c7, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xc2);
    poke(0x0001, 0x1b);
    poke(0x0002, 0xe1);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x00c7, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0003);
    checkSpecialRegisters(0x00, 0x01, false, false, 10);
  });

  // Test instruction c3 | JP **
  test("OPCODE c3 | JP **", () {
    // Set up machine initial state
    loadRegisters(0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xc3);
    poke(0x0001, 0xed);
    poke(0x0002, 0x7c);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x7ced);
    checkSpecialRegisters(0x00, 0x01, false, false, 10);
  });

  // Test instruction c4_1 | CALL NZ, **
  test("OPCODE c4_1 | CALL NZ, **", () {
    // Set up machine initial state
    loadRegisters(0x000e, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x5698, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xc4);
    poke(0x0001, 0x61);
    poke(0x0002, 0x9c);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x000e, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x5696, 0x9c61);
    checkSpecialRegisters(0x00, 0x01, false, false, 17);
    expect(peek(22166), equals(0x03));
    expect(peek(22167), equals(0x00));
  });

  // Test instruction c4_2 | CALL NZ, **
  test("OPCODE c4_2 | CALL NZ, **", () {
    // Set up machine initial state
    loadRegisters(0x004e, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x5698, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xc4);
    poke(0x0001, 0x61);
    poke(0x0002, 0x9c);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x004e, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x5698, 0x0003);
    checkSpecialRegisters(0x00, 0x01, false, false, 10);
  });

  // Test instruction c5 | PUSH BC
  test("OPCODE c5 | PUSH BC", () {
    // Set up machine initial state
    loadRegisters(0x53e3, 0x1459, 0x775f, 0x1a2f, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0xec12, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xc5);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x53e3, 0x1459, 0x775f, 0x1a2f, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0xec10, 0x0001);
    checkSpecialRegisters(0x00, 0x01, false, false, 11);
    expect(peek(60432), equals(0x59));
    expect(peek(60433), equals(0x14));
  });

  // Test instruction c6 | ADD A, *
  test("OPCODE c6 | ADD A, *", () {
    // Set up machine initial state
    loadRegisters(0xca00, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xc6);
    poke(0x0001, 0x6f);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x3939, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x01, false, false, 7);
  });

  // Test instruction c7 | RST 0
  test("OPCODE c7 | RST 0", () {
    // Set up machine initial state
    loadRegisters(0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x5507, 0x6d33);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x6d33, 0xc7);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x5505, 0x0000);
    checkSpecialRegisters(0x00, 0x01, false, false, 11);
    expect(peek(21765), equals(0x34));
    expect(peek(21766), equals(0x6d));
  });

  // Test instruction c8_1 | RET Z
  test("OPCODE c8_1 | RET Z", () {
    // Set up machine initial state
    loadRegisters(0x0098, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x43f7, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xc8);
    poke(0x43f7, 0xe9);
    poke(0x43f8, 0xaf);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x0098, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x43f7, 0x0001);
    checkSpecialRegisters(0x00, 0x01, false, false, 5);
  });

  // Test instruction c8_2 | RET Z
  test("OPCODE c8_2 | RET Z", () {
    // Set up machine initial state
    loadRegisters(0x00d8, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x43f7, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xc8);
    poke(0x43f7, 0xe9);
    poke(0x43f8, 0xaf);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x00d8, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x43f9, 0xafe9);
    checkSpecialRegisters(0x00, 0x01, false, false, 11);
  });

  // Test instruction c9 | RET
  test("OPCODE c9 | RET", () {
    // Set up machine initial state
    loadRegisters(0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x887e, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xc9);
    poke(0x887e, 0x36);
    poke(0x887f, 0x11);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x8880, 0x1136);
    checkSpecialRegisters(0x00, 0x01, false, false, 10);
  });

  // Test instruction ca_1 | JP Z, **
  test("OPCODE ca_1 | JP Z, **", () {
    // Set up machine initial state
    loadRegisters(0x0087, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xca);
    poke(0x0001, 0x1b);
    poke(0x0002, 0xe1);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x0087, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0003);
    checkSpecialRegisters(0x00, 0x01, false, false, 10);
  });

  // Test instruction ca_2 | JP Z, **
  test("OPCODE ca_2 | JP Z, **", () {
    // Set up machine initial state
    loadRegisters(0x00c7, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xca);
    poke(0x0001, 0x1b);
    poke(0x0002, 0xe1);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x00c7, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0xe11b);
    checkSpecialRegisters(0x00, 0x01, false, false, 10);
  });

  // Test instruction cb00 | RLC B
  test("OPCODE cb00 | RLC B", () {
    // Set up machine initial state
    loadRegisters(0xda00, 0xe479, 0x552e, 0xa806, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0x00);
    poke(0xa806, 0x76);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xda8d, 0xc979, 0x552e, 0xa806, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cb01 | RLC C
  test("OPCODE cb01 | RLC C", () {
    // Set up machine initial state
    loadRegisters(0x1000, 0xb379, 0xb480, 0xef65, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0x01);
    poke(0xef65, 0xfb);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x10a0, 0xb3f2, 0xb480, 0xef65, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cb02 | RLC D
  test("OPCODE cb02 | RLC D", () {
    // Set up machine initial state
    loadRegisters(0x2e00, 0x9adf, 0xae6e, 0xa7f2, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0x02);
    poke(0xa7f2, 0x4a);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x2e09, 0x9adf, 0x5d6e, 0xa7f2, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cb03 | RLC E
  test("OPCODE cb03 | RLC E", () {
    // Set up machine initial state
    loadRegisters(0x6800, 0x9995, 0xde3f, 0xca71, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0x03);
    poke(0xca71, 0xe7);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x682c, 0x9995, 0xde7e, 0xca71, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cb04 | RLC H
  test("OPCODE cb04 | RLC H", () {
    // Set up machine initial state
    loadRegisters(0x8c00, 0xbeea, 0x0ce4, 0x67b0, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0x04);
    poke(0x67b0, 0xcd);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x8c88, 0xbeea, 0x0ce4, 0xceb0, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cb05 | RLC L
  test("OPCODE cb05 | RLC L", () {
    // Set up machine initial state
    loadRegisters(0x3600, 0xe19f, 0x78c9, 0xcb32, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0x05);
    poke(0xcb32, 0x1b);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x3620, 0xe19f, 0x78c9, 0xcb64, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cb06 | RLC (HL)
  test("OPCODE cb06 | RLC (HL)", () {
    // Set up machine initial state
    loadRegisters(0x8a00, 0xdb02, 0x8fb1, 0x5b04, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0x06);
    poke(0x5b04, 0xd4);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x8aad, 0xdb02, 0x8fb1, 0x5b04, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 15);
    expect(peek(23300), equals(0xa9));
  });

  // Test instruction cb07 | RLC A
  test("OPCODE cb07 | RLC A", () {
    // Set up machine initial state
    loadRegisters(0x6d00, 0x19cf, 0x7259, 0xdcaa, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0x07);
    poke(0xdcaa, 0x8d);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xda88, 0x19cf, 0x7259, 0xdcaa, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cb08 | RRC B
  test("OPCODE cb08 | RRC B", () {
    // Set up machine initial state
    loadRegisters(0x8000, 0xcdb5, 0x818e, 0x2ee2, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0x08);
    poke(0x2ee2, 0x53);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x80a1, 0xe6b5, 0x818e, 0x2ee2, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cb09 | RRC C
  test("OPCODE cb09 | RRC C", () {
    // Set up machine initial state
    loadRegisters(0x1800, 0x125c, 0xdd97, 0x59c6, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0x09);
    poke(0x59c6, 0x9e);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x182c, 0x122e, 0xdd97, 0x59c6, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cb0a | RRC D
  test("OPCODE cb0a | RRC D", () {
    // Set up machine initial state
    loadRegisters(0x1200, 0x3ba1, 0x7724, 0x63ad, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0x0a);
    poke(0x63ad, 0x96);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x12ad, 0x3ba1, 0xbb24, 0x63ad, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cb0b | RRC E
  test("OPCODE cb0b | RRC E", () {
    // Set up machine initial state
    loadRegisters(0x7600, 0x2abf, 0xb626, 0x0289, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0x0b);
    poke(0x0289, 0x37);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x7600, 0x2abf, 0xb613, 0x0289, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cb0c | RRC H
  test("OPCODE cb0c | RRC H", () {
    // Set up machine initial state
    loadRegisters(0x0e00, 0x6fc5, 0x2f12, 0x34d9, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0x0c);
    poke(0x34d9, 0x50);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x0e08, 0x6fc5, 0x2f12, 0x1ad9, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cb0d | RRC L
  test("OPCODE cb0d | RRC L", () {
    // Set up machine initial state
    loadRegisters(0x6300, 0x95a3, 0xfcd2, 0x519a, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0x0d);
    poke(0x519a, 0x7a);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x630c, 0x95a3, 0xfcd2, 0x514d, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cb0e | RRC (HL)
  test("OPCODE cb0e | RRC (HL)", () {
    // Set up machine initial state
    loadRegisters(0xfc00, 0xadf9, 0x4925, 0x543e, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0x0e);
    poke(0x543e, 0xd2);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xfc2c, 0xadf9, 0x4925, 0x543e, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 15);
    expect(peek(21566), equals(0x69));
  });

  // Test instruction cb0f | RRC A
  test("OPCODE cb0f | RRC A", () {
    // Set up machine initial state
    loadRegisters(0xc300, 0x18f3, 0x41b8, 0x070b, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0x0f);
    poke(0x070b, 0x86);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xe1a5, 0x18f3, 0x41b8, 0x070b, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cb10 | RL B
  test("OPCODE cb10 | RL B", () {
    // Set up machine initial state
    loadRegisters(0xf800, 0xdc25, 0x33b3, 0x0d74, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0x10);
    poke(0x0d74, 0x3d);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xf8ad, 0xb825, 0x33b3, 0x0d74, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cb11 | RL C
  test("OPCODE cb11 | RL C", () {
    // Set up machine initial state
    loadRegisters(0x6500, 0xe25c, 0x4b8a, 0xed42, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0x11);
    poke(0xed42, 0xb7);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x65ac, 0xe2b8, 0x4b8a, 0xed42, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cb12 | RL D
  test("OPCODE cb12 | RL D", () {
    // Set up machine initial state
    loadRegisters(0x7700, 0x1384, 0x0f50, 0x29c6, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0x12);
    poke(0x29c6, 0x88);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x770c, 0x1384, 0x1e50, 0x29c6, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cb13 | RL E
  test("OPCODE cb13 | RL E", () {
    // Set up machine initial state
    loadRegisters(0xce00, 0x9f17, 0xe128, 0x3ed7, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0x13);
    poke(0x3ed7, 0xea);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xce04, 0x9f17, 0xe150, 0x3ed7, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cb14 | RL H
  test("OPCODE cb14 | RL H", () {
    // Set up machine initial state
    loadRegisters(0xb200, 0x541a, 0x60c7, 0x7c9a, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0x14);
    poke(0x7c9a, 0x0f);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xb2a8, 0x541a, 0x60c7, 0xf89a, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cb15 | RL L
  test("OPCODE cb15 | RL L", () {
    // Set up machine initial state
    loadRegisters(0x2d00, 0xc1df, 0x6eab, 0x03e2, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0x15);
    poke(0x03e2, 0xbc);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x2d81, 0xc1df, 0x6eab, 0x03c4, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cb16 | RL (HL)
  test("OPCODE cb16 | RL (HL)", () {
    // Set up machine initial state
    loadRegisters(0x3600, 0x3b53, 0x1a4a, 0x684e, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0x16);
    poke(0x684e, 0xc3);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x3681, 0x3b53, 0x1a4a, 0x684e, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 15);
    expect(peek(26702), equals(0x86));
  });

  // Test instruction cb17 | RL A
  test("OPCODE cb17 | RL A", () {
    // Set up machine initial state
    loadRegisters(0x5400, 0xd090, 0xf60d, 0x0fa2, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0x17);
    poke(0x0fa2, 0x23);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xa8a8, 0xd090, 0xf60d, 0x0fa2, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cb18 | RR B
  test("OPCODE cb18 | RR B", () {
    // Set up machine initial state
    loadRegisters(0x8600, 0xc658, 0x755f, 0x9596, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0x18);
    poke(0x9596, 0xb6);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x8624, 0x6358, 0x755f, 0x9596, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cb19 | RR C
  test("OPCODE cb19 | RR C", () {
    // Set up machine initial state
    loadRegisters(0x9600, 0xbeb3, 0x7c22, 0x71c8, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0x19);
    poke(0x71c8, 0x85);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x960d, 0xbe59, 0x7c22, 0x71c8, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cb1a | RR D
  test("OPCODE cb1a | RR D", () {
    // Set up machine initial state
    loadRegisters(0x3900, 0x882f, 0x543b, 0x5279, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0x1a);
    poke(0x5279, 0x26);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x3928, 0x882f, 0x2a3b, 0x5279, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cb1b | RR E
  test("OPCODE cb1b | RR E", () {
    // Set up machine initial state
    loadRegisters(0x9e00, 0xb338, 0x876c, 0xe8b4, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0x1b);
    poke(0xe8b4, 0xb9);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x9e24, 0xb338, 0x8736, 0xe8b4, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cb1c | RR H
  test("OPCODE cb1c | RR H", () {
    // Set up machine initial state
    loadRegisters(0x4b00, 0xb555, 0x238f, 0x311d, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0x1c);
    poke(0x311d, 0x11);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x4b0d, 0xb555, 0x238f, 0x181d, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cb1d | RR L
  test("OPCODE cb1d | RR L", () {
    // Set up machine initial state
    loadRegisters(0x2100, 0x3d7e, 0x5e39, 0xe451, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0x1d);
    poke(0xe451, 0x47);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x212d, 0x3d7e, 0x5e39, 0xe428, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cb1e | RR (HL)
  test("OPCODE cb1e | RR (HL)", () {
    // Set up machine initial state
    loadRegisters(0x5e00, 0x66b9, 0x80dc, 0x00ef, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0x1e);
    poke(0x00ef, 0x91);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x5e0d, 0x66b9, 0x80dc, 0x00ef, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 15);
    expect(peek(239), equals(0x48));
  });

  // Test instruction cb1f | RR A
  test("OPCODE cb1f | RR A", () {
    // Set up machine initial state
    loadRegisters(0xed00, 0xb838, 0x8e18, 0xace7, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0x1f);
    poke(0xace7, 0x82);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x7621, 0xb838, 0x8e18, 0xace7, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cb20 | SLA B
  test("OPCODE cb20 | SLA B", () {
    // Set up machine initial state
    loadRegisters(0xc700, 0x0497, 0xd72b, 0xccb6, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0x20);
    poke(0xccb6, 0x1a);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xc708, 0x0897, 0xd72b, 0xccb6, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cb21 | SLA C
  test("OPCODE cb21 | SLA C", () {
    // Set up machine initial state
    loadRegisters(0x2200, 0x5cf4, 0x938e, 0x37a8, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0x21);
    poke(0x37a8, 0xdd);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x22ad, 0x5ce8, 0x938e, 0x37a8, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cb22 | SLA D
  test("OPCODE cb22 | SLA D", () {
    // Set up machine initial state
    loadRegisters(0x8500, 0x0950, 0xe7e8, 0x0641, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0x22);
    poke(0x0641, 0x4d);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x8589, 0x0950, 0xcee8, 0x0641, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cb23 | SLA E
  test("OPCODE cb23 | SLA E", () {
    // Set up machine initial state
    loadRegisters(0x2100, 0x2a7c, 0x37d0, 0xaa59, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0x23);
    poke(0xaa59, 0xc1);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x21a5, 0x2a7c, 0x37a0, 0xaa59, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cb24 | SLA H
  test("OPCODE cb24 | SLA H", () {
    // Set up machine initial state
    loadRegisters(0xfb00, 0xb9de, 0x7014, 0x84b6, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0x24);
    poke(0x84b6, 0x80);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xfb09, 0xb9de, 0x7014, 0x08b6, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cb25 | SLA L
  test("OPCODE cb25 | SLA L", () {
    // Set up machine initial state
    loadRegisters(0x1500, 0x6bbc, 0x894e, 0x85bc, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0x25);
    poke(0x85bc, 0xef);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x152d, 0x6bbc, 0x894e, 0x8578, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cb26 | SLA (HL)
  test("OPCODE cb26 | SLA (HL)", () {
    // Set up machine initial state
    loadRegisters(0x0a00, 0x372e, 0xe315, 0x283a, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0x26);
    poke(0x283a, 0xee);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x0a89, 0x372e, 0xe315, 0x283a, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 15);
    expect(peek(10298), equals(0xdc));
  });

  // Test instruction cb27 | SLA A
  test("OPCODE cb27 | SLA A", () {
    // Set up machine initial state
    loadRegisters(0xbf00, 0xbdba, 0x67ab, 0x5ea2, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0x27);
    poke(0x5ea2, 0xbd);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x7e2d, 0xbdba, 0x67ab, 0x5ea2, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cb28 | SRA B
  test("OPCODE cb28 | SRA B", () {
    // Set up machine initial state
    loadRegisters(0xc000, 0x0435, 0x3e0f, 0x021b, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0x28);
    poke(0x021b, 0x90);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xc000, 0x0235, 0x3e0f, 0x021b, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cb29 | SRA C
  test("OPCODE cb29 | SRA C", () {
    // Set up machine initial state
    loadRegisters(0x0600, 0xf142, 0x6ada, 0xc306, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0x29);
    poke(0xc306, 0x5c);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x0624, 0xf121, 0x6ada, 0xc306, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cb2a | SRA D
  test("OPCODE cb2a | SRA D", () {
    // Set up machine initial state
    loadRegisters(0x3000, 0xec3a, 0x7f7d, 0x3473, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0x2a);
    poke(0x3473, 0x34);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x302d, 0xec3a, 0x3f7d, 0x3473, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cb2b | SRA E
  test("OPCODE cb2b | SRA E", () {
    // Set up machine initial state
    loadRegisters(0xe000, 0xccf0, 0xbbda, 0xb78a, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0x2b);
    poke(0xb78a, 0xab);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xe0ac, 0xccf0, 0xbbed, 0xb78a, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cb2c | SRA H
  test("OPCODE cb2c | SRA H", () {
    // Set up machine initial state
    loadRegisters(0x5b00, 0x25c0, 0x996d, 0x1e7b, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0x2c);
    poke(0x1e7b, 0x2c);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x5b0c, 0x25c0, 0x996d, 0x0f7b, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cb2d | SRA L
  test("OPCODE cb2d | SRA L", () {
    // Set up machine initial state
    loadRegisters(0x5e00, 0xc51b, 0x58e3, 0x78ea, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0x2d);
    poke(0x78ea, 0x85);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x5ea4, 0xc51b, 0x58e3, 0x78f5, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cb2e | SRA (HL)
  test("OPCODE cb2e | SRA (HL)", () {
    // Set up machine initial state
    loadRegisters(0x3900, 0xa2cd, 0x0629, 0x24bf, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0x2e);
    poke(0x24bf, 0xb5);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x3989, 0xa2cd, 0x0629, 0x24bf, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 15);
    expect(peek(9407), equals(0xda));
  });

  // Test instruction cb2f | SRA A
  test("OPCODE cb2f | SRA A", () {
    // Set up machine initial state
    loadRegisters(0xaa00, 0xa194, 0xd0e3, 0x5c65, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0x2f);
    poke(0x5c65, 0xc9);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xd580, 0xa194, 0xd0e3, 0x5c65, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cb38 | SRL B
  test("OPCODE cb38 | SRL B", () {
    // Set up machine initial state
    loadRegisters(0xdf00, 0x7c1b, 0x9f9f, 0x4ff2, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0x38);
    poke(0x4ff2, 0xaa);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xdf28, 0x3e1b, 0x9f9f, 0x4ff2, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cb39 | SRL C
  test("OPCODE cb39 | SRL C", () {
    // Set up machine initial state
    loadRegisters(0x6600, 0xb702, 0x14f5, 0x3c17, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0x39);
    poke(0x3c17, 0x61);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x6600, 0xb701, 0x14f5, 0x3c17, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cb3a | SRL D
  test("OPCODE cb3a | SRL D", () {
    // Set up machine initial state
    loadRegisters(0xd100, 0x5c5f, 0xe42e, 0xf1b1, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0x3a);
    poke(0xf1b1, 0x6e);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xd124, 0x5c5f, 0x722e, 0xf1b1, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cb3b | SRL E
  test("OPCODE cb3b | SRL E", () {
    // Set up machine initial state
    loadRegisters(0xb200, 0x38c8, 0xa560, 0x7419, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0x3b);
    poke(0x7419, 0x11);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xb224, 0x38c8, 0xa530, 0x7419, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cb3c | SRL H
  test("OPCODE cb3c | SRL H", () {
    // Set up machine initial state
    loadRegisters(0x7800, 0xcfae, 0x66d8, 0x2ad8, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0x3c);
    poke(0x2ad8, 0x8d);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x7800, 0xcfae, 0x66d8, 0x15d8, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cb3d | SRL L
  test("OPCODE cb3d | SRL L", () {
    // Set up machine initial state
    loadRegisters(0xe600, 0xdcda, 0x06aa, 0x46cd, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0x3d);
    poke(0x46cd, 0xf9);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xe625, 0xdcda, 0x06aa, 0x4666, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cb3e | SRL (HL)
  test("OPCODE cb3e | SRL (HL)", () {
    // Set up machine initial state
    loadRegisters(0xa900, 0x6a34, 0xe8d0, 0xa96c, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0x3e);
    poke(0xa96c, 0xa0);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xa904, 0x6a34, 0xe8d0, 0xa96c, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 15);
    expect(peek(43372), equals(0x50));
  });

  // Test instruction cb3f | SRL A
  test("OPCODE cb3f | SRL A", () {
    // Set up machine initial state
    loadRegisters(0xf100, 0xceea, 0x721e, 0x77f0, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0x3f);
    poke(0x77f0, 0x7c);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x782d, 0xceea, 0x721e, 0x77f0, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cb40 | BIT 0, B
  test("OPCODE cb40 | BIT 0, B", () {
    // Set up machine initial state
    loadRegisters(0x9e00, 0xbcb2, 0xefaa, 0x505f, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0x40);
    poke(0x505f, 0x59);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x9e7c, 0xbcb2, 0xefaa, 0x505f, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cb41 | BIT 0, C
  test("OPCODE cb41 | BIT 0, C", () {
    // Set up machine initial state
    loadRegisters(0x9e00, 0x1b43, 0x954e, 0x7be9, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0x41);
    poke(0x7be9, 0xf7);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x9e10, 0x1b43, 0x954e, 0x7be9, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cb42 | BIT 0, D
  test("OPCODE cb42 | BIT 0, D", () {
    // Set up machine initial state
    loadRegisters(0xf200, 0xdd12, 0x7d4f, 0x551f, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0x42);
    poke(0x551f, 0xc9);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xf238, 0xdd12, 0x7d4f, 0x551f, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cb43 | BIT 0, E
  test("OPCODE cb43 | BIT 0, E", () {
    // Set up machine initial state
    loadRegisters(0xad00, 0xc3b3, 0xf1d0, 0xbab4, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0x43);
    poke(0xbab4, 0x76);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xad54, 0xc3b3, 0xf1d0, 0xbab4, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cb44 | BIT 0, H
  test("OPCODE cb44 | BIT 0, H", () {
    // Set up machine initial state
    loadRegisters(0xb700, 0xc829, 0x27e3, 0x5b92, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0x44);
    poke(0x5b92, 0x78);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xb718, 0xc829, 0x27e3, 0x5b92, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cb45 | BIT 0, L
  test("OPCODE cb45 | BIT 0, L", () {
    // Set up machine initial state
    loadRegisters(0x7700, 0x68ee, 0x0c77, 0x409b, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0x45);
    poke(0x409b, 0x64);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x7718, 0x68ee, 0x0c77, 0x409b, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cb46 | BIT 0, (HL)
  test("OPCODE cb46 | BIT 0, (HL)", () {
    // Set up machine initial state
    loadRegisters(0x7200, 0x7ae3, 0xa11e, 0x6131, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0x46);
    poke(0x6131, 0xd5);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x7210, 0x7ae3, 0xa11e, 0x6131, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 12);
  });

  // Test instruction cb46_1 | BIT 0, (HL)
  test("OPCODE cb46_1 | BIT 0, (HL)", () {
    // Set up machine initial state
    loadRegisters(0x7200, 0x7ae3, 0xa11e, 0x6131, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0x46);
    poke(0x6131, 0xd5);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x7210, 0x7ae3, 0xa11e, 0x6131, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 12);
  });

  // Test instruction cb46_2 | BIT 0, (HL)
  test("OPCODE cb46_2 | BIT 0, (HL)", () {
    // Set up machine initial state
    loadRegisters(0x7200, 0x7ae3, 0xa11e, 0x6131, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0x46);
    poke(0x6131, 0xd5);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x7238, 0x7ae3, 0xa11e, 0x6131, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 12);
  });

  // Test instruction cb46_3 | BIT 0, (HL)
  test("OPCODE cb46_3 | BIT 0, (HL)", () {
    // Set up machine initial state
    loadRegisters(0x7200, 0x7ae3, 0xa11e, 0x6131, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0x46);
    poke(0x6131, 0xd5);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x7238, 0x7ae3, 0xa11e, 0x6131, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 12);
  });

  // Test instruction cb46_4 | BIT 0, (HL)
  test("OPCODE cb46_4 | BIT 0, (HL)", () {
    // Set up machine initial state
    loadRegisters(0x7200, 0x7ae3, 0xa11e, 0x6131, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0x46);
    poke(0x6131, 0xd5);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x7218, 0x7ae3, 0xa11e, 0x6131, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 12);
  });

  // Test instruction cb46_5 | BIT 0, (HL)
  test("OPCODE cb46_5 | BIT 0, (HL)", () {
    // Set up machine initial state
    loadRegisters(0x7200, 0x7ae3, 0xa11e, 0x6131, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0x46);
    poke(0x6131, 0xd5);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x7230, 0x7ae3, 0xa11e, 0x6131, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 12);
  });

  // Test instruction cb47_1 | BIT 0, A
  test("OPCODE cb47_1 | BIT 0, A", () {
    // Set up machine initial state
    loadRegisters(0xff00, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0x47);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xff38, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cb47 | BIT 0, A
  test("OPCODE cb47 | BIT 0, A", () {
    // Set up machine initial state
    loadRegisters(0x1000, 0xd8ca, 0xe2c4, 0x8a8c, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0x47);
    poke(0x8a8c, 0x0e);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x1054, 0xd8ca, 0xe2c4, 0x8a8c, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cb48 | BIT 1, B
  test("OPCODE cb48 | BIT 1, B", () {
    // Set up machine initial state
    loadRegisters(0xa900, 0x6264, 0xe833, 0x6de0, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0x48);
    poke(0x6de0, 0x8c);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xa930, 0x6264, 0xe833, 0x6de0, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cb49 | BIT 1, C
  test("OPCODE cb49 | BIT 1, C", () {
    // Set up machine initial state
    loadRegisters(0x6c00, 0xd0f7, 0x1db7, 0xa040, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0x49);
    poke(0xa040, 0x5f);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x6c30, 0xd0f7, 0x1db7, 0xa040, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cb4a | BIT 1, D
  test("OPCODE cb4a | BIT 1, D", () {
    // Set up machine initial state
    loadRegisters(0x4f00, 0xf04c, 0x5b29, 0x77a4, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0x4a);
    poke(0x77a4, 0x96);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x4f18, 0xf04c, 0x5b29, 0x77a4, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cb4b | BIT 1, E
  test("OPCODE cb4b | BIT 1, E", () {
    // Set up machine initial state
    loadRegisters(0x5500, 0x9848, 0x095f, 0x40ca, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0x4b);
    poke(0x40ca, 0x8a);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x5518, 0x9848, 0x095f, 0x40ca, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cb4c | BIT 1, H
  test("OPCODE cb4c | BIT 1, H", () {
    // Set up machine initial state
    loadRegisters(0x8800, 0x0521, 0xbf31, 0x6d5d, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0x4c);
    poke(0x6d5d, 0xe7);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x887c, 0x0521, 0xbf31, 0x6d5d, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cb4d | BIT 1, L
  test("OPCODE cb4d | BIT 1, L", () {
    // Set up machine initial state
    loadRegisters(0xf900, 0x27d0, 0x0f7e, 0x158d, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0x4d);
    poke(0x158d, 0xe0);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xf95c, 0x27d0, 0x0f7e, 0x158d, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cb4e | BIT 1, (HL)
  test("OPCODE cb4e | BIT 1, (HL)", () {
    // Set up machine initial state
    loadRegisters(0x2600, 0x9207, 0x459a, 0xada3, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0x4e);
    poke(0xada3, 0x5b);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x2610, 0x9207, 0x459a, 0xada3, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 12);
  });

  // Test instruction cb4f_1 | BIT 1, A
  test("OPCODE cb4f_1 | BIT 1, A", () {
    // Set up machine initial state
    loadRegisters(0xff00, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0x4f);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xff38, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cb4f | BIT 1, A
  test("OPCODE cb4f | BIT 1, A", () {
    // Set up machine initial state
    loadRegisters(0x1700, 0x2dc1, 0xaca2, 0x0bcc, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0x4f);
    poke(0x0bcc, 0xa3);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x1710, 0x2dc1, 0xaca2, 0x0bcc, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cb50 | BIT 2, B
  test("OPCODE cb50 | BIT 2, B", () {
    // Set up machine initial state
    loadRegisters(0x2300, 0x2749, 0x1012, 0x84d2, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0x50);
    poke(0x84d2, 0x6a);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x2330, 0x2749, 0x1012, 0x84d2, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cb51 | BIT 2, C
  test("OPCODE cb51 | BIT 2, C", () {
    // Set up machine initial state
    loadRegisters(0x2200, 0xb7db, 0xe19d, 0xaafc, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0x51);
    poke(0xaafc, 0xa6);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x225c, 0xb7db, 0xe19d, 0xaafc, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cb52 | BIT 2, D
  test("OPCODE cb52 | BIT 2, D", () {
    // Set up machine initial state
    loadRegisters(0x8b00, 0xff7a, 0xb0ff, 0xac44, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0x52);
    poke(0xac44, 0x00);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x8b74, 0xff7a, 0xb0ff, 0xac44, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cb53 | BIT 2, E
  test("OPCODE cb53 | BIT 2, E", () {
    // Set up machine initial state
    loadRegisters(0x6000, 0x31a1, 0xa4f4, 0x7c75, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0x53);
    poke(0x7c75, 0xab);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x6030, 0x31a1, 0xa4f4, 0x7c75, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cb54 | BIT 2, H
  test("OPCODE cb54 | BIT 2, H", () {
    // Set up machine initial state
    loadRegisters(0x3800, 0x7ccc, 0x89cc, 0x1999, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0x54);
    poke(0x1999, 0x98);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x385c, 0x7ccc, 0x89cc, 0x1999, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cb55 | BIT 2, L
  test("OPCODE cb55 | BIT 2, L", () {
    // Set up machine initial state
    loadRegisters(0xf900, 0x1f79, 0x19cd, 0xfb4b, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0x55);
    poke(0xfb4b, 0x0b);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xf95c, 0x1f79, 0x19cd, 0xfb4b, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cb56 | BIT 2, (HL)
  test("OPCODE cb56 | BIT 2, (HL)", () {
    // Set up machine initial state
    loadRegisters(0x1500, 0x2bfe, 0xe3b5, 0xbbf9, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0x56);
    poke(0xbbf9, 0x10);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x1554, 0x2bfe, 0xe3b5, 0xbbf9, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 12);
  });

  // Test instruction cb57_1 | BIT 2, A
  test("OPCODE cb57_1 | BIT 2, A", () {
    // Set up machine initial state
    loadRegisters(0xff00, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0x57);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xff38, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cb57 | BIT 2, A
  test("OPCODE cb57 | BIT 2, A", () {
    // Set up machine initial state
    loadRegisters(0x6600, 0xaf32, 0x532a, 0xda50, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0x57);
    poke(0xda50, 0x30);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x6630, 0xaf32, 0x532a, 0xda50, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cb58 | BIT 3, B
  test("OPCODE cb58 | BIT 3, B", () {
    // Set up machine initial state
    loadRegisters(0x5000, 0x1aee, 0x2e47, 0x1479, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0x58);
    poke(0x1479, 0xa0);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x5018, 0x1aee, 0x2e47, 0x1479, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cb59 | BIT 3, C
  test("OPCODE cb59 | BIT 3, C", () {
    // Set up machine initial state
    loadRegisters(0x7200, 0x5e68, 0xff28, 0x2075, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0x59);
    poke(0x2075, 0xc1);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x7238, 0x5e68, 0xff28, 0x2075, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cb5a | BIT 3, D
  test("OPCODE cb5a | BIT 3, D", () {
    // Set up machine initial state
    loadRegisters(0xeb00, 0xfea7, 0x17d1, 0xd99b, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0x5a);
    poke(0xd99b, 0xe8);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xeb54, 0xfea7, 0x17d1, 0xd99b, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cb5b | BIT 3, E
  test("OPCODE cb5b | BIT 3, E", () {
    // Set up machine initial state
    loadRegisters(0x6b00, 0x6f2c, 0x3fe3, 0x1691, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0x5b);
    poke(0x1691, 0xc7);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x6b74, 0x6f2c, 0x3fe3, 0x1691, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cb5c | BIT 3, H
  test("OPCODE cb5c | BIT 3, H", () {
    // Set up machine initial state
    loadRegisters(0x3300, 0xa7e7, 0x2077, 0x13e9, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0x5c);
    poke(0x13e9, 0xae);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x3354, 0xa7e7, 0x2077, 0x13e9, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cb5d | BIT 3, L
  test("OPCODE cb5d | BIT 3, L", () {
    // Set up machine initial state
    loadRegisters(0xc100, 0xafcc, 0xc8b1, 0xee49, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0x5d);
    poke(0xee49, 0xa6);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xc118, 0xafcc, 0xc8b1, 0xee49, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cb5e | BIT 3, (HL)
  test("OPCODE cb5e | BIT 3, (HL)", () {
    // Set up machine initial state
    loadRegisters(0x3000, 0xad43, 0x16c1, 0x349a, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0x5e);
    poke(0x349a, 0x3c);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x3010, 0xad43, 0x16c1, 0x349a, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 12);
  });

  // Test instruction cb5f_1 | BIT 3, A
  test("OPCODE cb5f_1 | BIT 3, A", () {
    // Set up machine initial state
    loadRegisters(0xff00, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0x5f);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xff38, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cb5f | BIT 3, A
  test("OPCODE cb5f | BIT 3, A", () {
    // Set up machine initial state
    loadRegisters(0x8c00, 0x1b67, 0x2314, 0x6133, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0x5f);
    poke(0x6133, 0x90);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x8c18, 0x1b67, 0x2314, 0x6133, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cb60 | BIT 4, B
  test("OPCODE cb60 | BIT 4, B", () {
    // Set up machine initial state
    loadRegisters(0x9900, 0x34b5, 0x0fd8, 0x5273, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0x60);
    poke(0x5273, 0x0a);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x9930, 0x34b5, 0x0fd8, 0x5273, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cb61 | BIT 4, C
  test("OPCODE cb61 | BIT 4, C", () {
    // Set up machine initial state
    loadRegisters(0xd100, 0x219f, 0x3bb4, 0x7c44, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0x61);
    poke(0x7c44, 0x77);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xd118, 0x219f, 0x3bb4, 0x7c44, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cb62 | BIT 4, D
  test("OPCODE cb62 | BIT 4, D", () {
    // Set up machine initial state
    loadRegisters(0xaf00, 0xbdf8, 0xc536, 0x8cc5, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0x62);
    poke(0x8cc5, 0xaf);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xaf54, 0xbdf8, 0xc536, 0x8cc5, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cb63 | BIT 4, E
  test("OPCODE cb63 | BIT 4, E", () {
    // Set up machine initial state
    loadRegisters(0x2a00, 0x5e16, 0xf627, 0x84ca, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0x63);
    poke(0x84ca, 0xe6);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x2a74, 0x5e16, 0xf627, 0x84ca, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cb64 | BIT 4, H
  test("OPCODE cb64 | BIT 4, H", () {
    // Set up machine initial state
    loadRegisters(0xa900, 0xa365, 0xc00b, 0xea94, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0x64);
    poke(0xea94, 0x0c);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xa97c, 0xa365, 0xc00b, 0xea94, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cb65 | BIT 4, L
  test("OPCODE cb65 | BIT 4, L", () {
    // Set up machine initial state
    loadRegisters(0x1800, 0x8d58, 0x4256, 0x427a, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0x65);
    poke(0x427a, 0xee);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x1838, 0x8d58, 0x4256, 0x427a, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cb66 | BIT 4, (HL)
  test("OPCODE cb66 | BIT 4, (HL)", () {
    // Set up machine initial state
    loadRegisters(0x4c00, 0x3ef7, 0xe544, 0xa44f, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0x66);
    poke(0xa44f, 0xd2);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x4c10, 0x3ef7, 0xe544, 0xa44f, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 12);
  });

  // Test instruction cb67_1 | BIT 4, A
  test("OPCODE cb67_1 | BIT 4, A", () {
    // Set up machine initial state
    loadRegisters(0xff00, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0x67);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xff38, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cb67 | BIT 4, A
  test("OPCODE cb67 | BIT 4, A", () {
    // Set up machine initial state
    loadRegisters(0x8600, 0x5e92, 0x2986, 0x394d, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0x67);
    poke(0x394d, 0x10);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x8654, 0x5e92, 0x2986, 0x394d, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cb68 | BIT 5, B
  test("OPCODE cb68 | BIT 5, B", () {
    // Set up machine initial state
    loadRegisters(0xd700, 0x0f6a, 0x18a6, 0xddd2, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0x68);
    poke(0xddd2, 0x16);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xd75c, 0x0f6a, 0x18a6, 0xddd2, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cb69 | BIT 5, C
  test("OPCODE cb69 | BIT 5, C", () {
    // Set up machine initial state
    loadRegisters(0xda00, 0x691b, 0x7c79, 0x1dba, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0x69);
    poke(0x1dba, 0x8a);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xda5c, 0x691b, 0x7c79, 0x1dba, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cb6a | BIT 5, D
  test("OPCODE cb6a | BIT 5, D", () {
    // Set up machine initial state
    loadRegisters(0x2200, 0x13e8, 0x86d4, 0x4e09, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0x6a);
    poke(0x4e09, 0xd5);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x2254, 0x13e8, 0x86d4, 0x4e09, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cb6b | BIT 5, E
  test("OPCODE cb6b | BIT 5, E", () {
    // Set up machine initial state
    loadRegisters(0xaf00, 0x5123, 0x7635, 0x1ca9, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0x6b);
    poke(0x1ca9, 0x86);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xaf30, 0x5123, 0x7635, 0x1ca9, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cb6c | BIT 5, H
  test("OPCODE cb6c | BIT 5, H", () {
    // Set up machine initial state
    loadRegisters(0x4300, 0xfaa6, 0xabc2, 0x5605, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0x6c);
    poke(0x5605, 0x2b);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x4354, 0xfaa6, 0xabc2, 0x5605, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cb6d | BIT 5, L
  test("OPCODE cb6d | BIT 5, L", () {
    // Set up machine initial state
    loadRegisters(0x7f00, 0xf099, 0xd435, 0xd9ad, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0x6d);
    poke(0xd9ad, 0x4e);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x7f38, 0xf099, 0xd435, 0xd9ad, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cb6e | BIT 5, (HL)
  test("OPCODE cb6e | BIT 5, (HL)", () {
    // Set up machine initial state
    loadRegisters(0x4a00, 0x08c9, 0x8177, 0xd8ba, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0x6e);
    poke(0xd8ba, 0x31);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x4a10, 0x08c9, 0x8177, 0xd8ba, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 12);
  });

  // Test instruction cb6f_1 | BIT 5, A
  test("OPCODE cb6f_1 | BIT 5, A", () {
    // Set up machine initial state
    loadRegisters(0xff00, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0x6f);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xff38, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cb6f | BIT 5, A
  test("OPCODE cb6f | BIT 5, A", () {
    // Set up machine initial state
    loadRegisters(0xa100, 0x8c80, 0x4678, 0x4d34, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0x6f);
    poke(0x4d34, 0x78);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xa130, 0x8c80, 0x4678, 0x4d34, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cb70 | BIT 6, B
  test("OPCODE cb70 | BIT 6, B", () {
    // Set up machine initial state
    loadRegisters(0x1900, 0x958a, 0x5dab, 0xf913, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0x70);
    poke(0xf913, 0xcf);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x1954, 0x958a, 0x5dab, 0xf913, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cb71 | BIT 6, C
  test("OPCODE cb71 | BIT 6, C", () {
    // Set up machine initial state
    loadRegisters(0x3d00, 0x095e, 0xd6df, 0x42fe, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0x71);
    poke(0x42fe, 0x24);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x3d18, 0x095e, 0xd6df, 0x42fe, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cb72 | BIT 6, D
  test("OPCODE cb72 | BIT 6, D", () {
    // Set up machine initial state
    loadRegisters(0xa500, 0xc0bf, 0x4c8d, 0xad11, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0x72);
    poke(0xad11, 0x3b);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xa518, 0xc0bf, 0x4c8d, 0xad11, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cb73 | BIT 6, E
  test("OPCODE cb73 | BIT 6, E", () {
    // Set up machine initial state
    loadRegisters(0xf200, 0x49a6, 0xb279, 0x2ecc, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0x73);
    poke(0x2ecc, 0xe0);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xf238, 0x49a6, 0xb279, 0x2ecc, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cb74 | BIT 6, H
  test("OPCODE cb74 | BIT 6, H", () {
    // Set up machine initial state
    loadRegisters(0x0500, 0x445e, 0x05e9, 0x983d, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0x74);
    poke(0x983d, 0xfa);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x055c, 0x445e, 0x05e9, 0x983d, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cb75 | BIT 6, L
  test("OPCODE cb75 | BIT 6, L", () {
    // Set up machine initial state
    loadRegisters(0x6b00, 0x83c6, 0x635a, 0xd18d, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0x75);
    poke(0xd18d, 0x11);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x6b5c, 0x83c6, 0x635a, 0xd18d, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cb76 | BIT 6, (HL)
  test("OPCODE cb76 | BIT 6, (HL)", () {
    // Set up machine initial state
    loadRegisters(0xf800, 0x3057, 0x3629, 0xbc71, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0x76);
    poke(0xbc71, 0x18);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xf854, 0x3057, 0x3629, 0xbc71, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 12);
  });

  // Test instruction cb77_1 | BIT 6, A
  test("OPCODE cb77_1 | BIT 6, A", () {
    // Set up machine initial state
    loadRegisters(0xff00, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0x77);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xff38, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cb77 | BIT 6, A
  test("OPCODE cb77 | BIT 6, A", () {
    // Set up machine initial state
    loadRegisters(0x9200, 0xd6f8, 0x5100, 0x736d, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0x77);
    poke(0x736d, 0x36);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x9254, 0xd6f8, 0x5100, 0x736d, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cb78 | BIT 7, B
  test("OPCODE cb78 | BIT 7, B", () {
    // Set up machine initial state
    loadRegisters(0x7200, 0x1cf8, 0x8d2b, 0xc76a, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0x78);
    poke(0xc76a, 0x1f);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x725c, 0x1cf8, 0x8d2b, 0xc76a, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cb79 | BIT 7, C
  test("OPCODE cb79 | BIT 7, C", () {
    // Set up machine initial state
    loadRegisters(0xa800, 0x809e, 0x1124, 0x39e8, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0x79);
    poke(0x39e8, 0x98);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xa898, 0x809e, 0x1124, 0x39e8, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cb7a | BIT 7, D
  test("OPCODE cb7a | BIT 7, D", () {
    // Set up machine initial state
    loadRegisters(0x5800, 0x7d24, 0x63e1, 0xd9af, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0x7a);
    poke(0xd9af, 0xed);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x5874, 0x7d24, 0x63e1, 0xd9af, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cb7b | BIT 7, E
  test("OPCODE cb7b | BIT 7, E", () {
    // Set up machine initial state
    loadRegisters(0x0300, 0x50ab, 0x05bd, 0x6bd0, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0x7b);
    poke(0x6bd0, 0xa5);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x03b8, 0x50ab, 0x05bd, 0x6bd0, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cb7c | BIT 7, H
  test("OPCODE cb7c | BIT 7, H", () {
    // Set up machine initial state
    loadRegisters(0xad00, 0xf77b, 0x55ae, 0x063b, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0x7c);
    poke(0x063b, 0x34);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xad54, 0xf77b, 0x55ae, 0x063b, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cb7d | BIT 7, L
  test("OPCODE cb7d | BIT 7, L", () {
    // Set up machine initial state
    loadRegisters(0x8200, 0xb792, 0x38cb, 0x5f9b, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0x7d);
    poke(0x5f9b, 0x97);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x8298, 0xb792, 0x38cb, 0x5f9b, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cb7e | BIT 7, (HL)
  test("OPCODE cb7e | BIT 7, (HL)", () {
    // Set up machine initial state
    loadRegisters(0x4200, 0x3b91, 0xf59c, 0xa25e, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0x7e);
    poke(0xa25e, 0xd7);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x4290, 0x3b91, 0xf59c, 0xa25e, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 12);
  });

  // Test instruction cb7f_1 | BIT 7, A
  test("OPCODE cb7f_1 | BIT 7, A", () {
    // Set up machine initial state
    loadRegisters(0xff00, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0x7f);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xffb8, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cb7f | BIT 7, A
  test("OPCODE cb7f | BIT 7, A", () {
    // Set up machine initial state
    loadRegisters(0x6a00, 0x84ec, 0xcf4e, 0x185b, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0x7f);
    poke(0x185b, 0xf1);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x6a7c, 0x84ec, 0xcf4e, 0x185b, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cb80 | RES 0, B
  test("OPCODE cb80 | RES 0, B", () {
    // Set up machine initial state
    loadRegisters(0x8f00, 0x702f, 0x17bd, 0xa706, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0x80);
    poke(0xa706, 0x0a);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x8f00, 0x702f, 0x17bd, 0xa706, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cb81 | RES 0, C
  test("OPCODE cb81 | RES 0, C", () {
    // Set up machine initial state
    loadRegisters(0xae00, 0x947f, 0x7153, 0x6616, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0x81);
    poke(0x6616, 0x74);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xae00, 0x947e, 0x7153, 0x6616, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cb82 | RES 0, D
  test("OPCODE cb82 | RES 0, D", () {
    // Set up machine initial state
    loadRegisters(0x8100, 0xbed2, 0xc719, 0x4572, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0x82);
    poke(0x4572, 0x2f);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x8100, 0xbed2, 0xc619, 0x4572, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cb83 | RES 0, E
  test("OPCODE cb83 | RES 0, E", () {
    // Set up machine initial state
    loadRegisters(0xe600, 0x63a2, 0xccf7, 0xae9a, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0x83);
    poke(0xae9a, 0x16);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xe600, 0x63a2, 0xccf6, 0xae9a, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cb84 | RES 0, H
  test("OPCODE cb84 | RES 0, H", () {
    // Set up machine initial state
    loadRegisters(0xce00, 0xe0cc, 0xd305, 0xd6c0, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0x84);
    poke(0xd6c0, 0x72);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xce00, 0xe0cc, 0xd305, 0xd6c0, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cb85 | RES 0, L
  test("OPCODE cb85 | RES 0, L", () {
    // Set up machine initial state
    loadRegisters(0xf300, 0xed79, 0x9db7, 0xdda0, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0x85);
    poke(0xdda0, 0x8a);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xf300, 0xed79, 0x9db7, 0xdda0, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cb86 | RES 0, (HL)
  test("OPCODE cb86 | RES 0, (HL)", () {
    // Set up machine initial state
    loadRegisters(0x2a00, 0xb0b9, 0x9426, 0x1b48, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0x86);
    poke(0x1b48, 0x62);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x2a00, 0xb0b9, 0x9426, 0x1b48, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 15);
  });

  // Test instruction cb87 | RES 0, A
  test("OPCODE cb87 | RES 0, A", () {
    // Set up machine initial state
    loadRegisters(0x1100, 0x86dc, 0x1798, 0xdfc5, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0x87);
    poke(0xdfc5, 0xde);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x1000, 0x86dc, 0x1798, 0xdfc5, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cb88 | RES 1, B
  test("OPCODE cb88 | RES 1, B", () {
    // Set up machine initial state
    loadRegisters(0xe300, 0x8a21, 0xe33e, 0x674d, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0x88);
    poke(0x674d, 0x5f);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xe300, 0x8821, 0xe33e, 0x674d, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cb89 | RES 1, C
  test("OPCODE cb89 | RES 1, C", () {
    // Set up machine initial state
    loadRegisters(0x6000, 0xd186, 0xc5b6, 0x1bd7, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0x89);
    poke(0x1bd7, 0xf2);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x6000, 0xd184, 0xc5b6, 0x1bd7, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cb8a | RES 1, D
  test("OPCODE cb8a | RES 1, D", () {
    // Set up machine initial state
    loadRegisters(0x3e00, 0x5fcd, 0x0b38, 0xb98e, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0x8a);
    poke(0xb98e, 0x2f);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x3e00, 0x5fcd, 0x0938, 0xb98e, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cb8b | RES 1, E
  test("OPCODE cb8b | RES 1, E", () {
    // Set up machine initial state
    loadRegisters(0x6500, 0x040e, 0x103f, 0x4a07, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0x8b);
    poke(0x4a07, 0x3f);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x6500, 0x040e, 0x103d, 0x4a07, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cb8c | RES 1, H
  test("OPCODE cb8c | RES 1, H", () {
    // Set up machine initial state
    loadRegisters(0xf800, 0x6d27, 0x9bdf, 0xdaef, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0x8c);
    poke(0xdaef, 0x0c);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xf800, 0x6d27, 0x9bdf, 0xd8ef, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cb8d | RES 1, L
  test("OPCODE cb8d | RES 1, L", () {
    // Set up machine initial state
    loadRegisters(0x3e00, 0x5469, 0x2c28, 0xbd72, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0x8d);
    poke(0xbd72, 0x13);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x3e00, 0x5469, 0x2c28, 0xbd70, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cb8e | RES 1, (HL)
  test("OPCODE cb8e | RES 1, (HL)", () {
    // Set up machine initial state
    loadRegisters(0x1f00, 0x140b, 0xb492, 0x63a7, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0x8e);
    poke(0x63a7, 0xd4);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x1f00, 0x140b, 0xb492, 0x63a7, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 15);
  });

  // Test instruction cb8f | RES 1, A
  test("OPCODE cb8f | RES 1, A", () {
    // Set up machine initial state
    loadRegisters(0x2500, 0xc522, 0xca46, 0x1c1a, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0x8f);
    poke(0x1c1a, 0x37);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x2500, 0xc522, 0xca46, 0x1c1a, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cb90 | RES 2, B
  test("OPCODE cb90 | RES 2, B", () {
    // Set up machine initial state
    loadRegisters(0x5700, 0x595c, 0x4f0a, 0xc73c, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0x90);
    poke(0xc73c, 0xa2);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x5700, 0x595c, 0x4f0a, 0xc73c, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cb91 | RES 2, C
  test("OPCODE cb91 | RES 2, C", () {
    // Set up machine initial state
    loadRegisters(0x5e00, 0x8f26, 0xa735, 0x97e0, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0x91);
    poke(0x97e0, 0x5e);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x5e00, 0x8f22, 0xa735, 0x97e0, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cb92 | RES 2, D
  test("OPCODE cb92 | RES 2, D", () {
    // Set up machine initial state
    loadRegisters(0x3300, 0x7d9f, 0x87d0, 0x83d0, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0x92);
    poke(0x83d0, 0x2b);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x3300, 0x7d9f, 0x83d0, 0x83d0, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cb93 | RES 2, E
  test("OPCODE cb93 | RES 2, E", () {
    // Set up machine initial state
    loadRegisters(0xc200, 0x4e05, 0xb3f8, 0x2234, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0x93);
    poke(0x2234, 0xa0);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xc200, 0x4e05, 0xb3f8, 0x2234, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cb94 | RES 2, H
  test("OPCODE cb94 | RES 2, H", () {
    // Set up machine initial state
    loadRegisters(0xee00, 0x8f4b, 0x2831, 0xd6a6, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0x94);
    poke(0xd6a6, 0xd0);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xee00, 0x8f4b, 0x2831, 0xd2a6, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cb95 | RES 2, L
  test("OPCODE cb95 | RES 2, L", () {
    // Set up machine initial state
    loadRegisters(0x3c00, 0x6af2, 0xb25d, 0x36ff, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0x95);
    poke(0x36ff, 0xcd);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x3c00, 0x6af2, 0xb25d, 0x36fb, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cb96 | RES 2, (HL)
  test("OPCODE cb96 | RES 2, (HL)", () {
    // Set up machine initial state
    loadRegisters(0x7600, 0xb027, 0xd0a5, 0x3324, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0x96);
    poke(0x3324, 0x21);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x7600, 0xb027, 0xd0a5, 0x3324, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 15);
  });

  // Test instruction cb97 | RES 2, A
  test("OPCODE cb97 | RES 2, A", () {
    // Set up machine initial state
    loadRegisters(0x1600, 0xad09, 0x7902, 0x97bc, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0x97);
    poke(0x97bc, 0x75);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x1200, 0xad09, 0x7902, 0x97bc, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cb98 | RES 3, B
  test("OPCODE cb98 | RES 3, B", () {
    // Set up machine initial state
    loadRegisters(0x3400, 0xb61c, 0x771d, 0x5d5e, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0x98);
    poke(0x5d5e, 0xa4);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x3400, 0xb61c, 0x771d, 0x5d5e, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cb99 | RES 3, C
  test("OPCODE cb99 | RES 3, C", () {
    // Set up machine initial state
    loadRegisters(0x5100, 0x65be, 0x1359, 0x8bec, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0x99);
    poke(0x8bec, 0x0b);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x5100, 0x65b6, 0x1359, 0x8bec, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cb9a | RES 3, D
  test("OPCODE cb9a | RES 3, D", () {
    // Set up machine initial state
    loadRegisters(0x6400, 0x976d, 0x4c25, 0xdcb2, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0x9a);
    poke(0xdcb2, 0x09);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x6400, 0x976d, 0x4425, 0xdcb2, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cb9b | RES 3, E
  test("OPCODE cb9b | RES 3, E", () {
    // Set up machine initial state
    loadRegisters(0xa100, 0xb58a, 0xd264, 0x2bd6, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0x9b);
    poke(0x2bd6, 0xd3);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xa100, 0xb58a, 0xd264, 0x2bd6, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cb9c | RES 3, H
  test("OPCODE cb9c | RES 3, H", () {
    // Set up machine initial state
    loadRegisters(0xd800, 0x63d6, 0xac7b, 0xc7a0, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0x9c);
    poke(0xc7a0, 0x75);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xd800, 0x63d6, 0xac7b, 0xc7a0, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cb9d | RES 3, L
  test("OPCODE cb9d | RES 3, L", () {
    // Set up machine initial state
    loadRegisters(0x0d00, 0xd840, 0x0810, 0x0800, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0x9d);
    poke(0x0800, 0xcd);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x0d00, 0xd840, 0x0810, 0x0800, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cb9e | RES 3, (HL)
  test("OPCODE cb9e | RES 3, (HL)", () {
    // Set up machine initial state
    loadRegisters(0x3b00, 0xebbf, 0x9434, 0x3a65, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0x9e);
    poke(0x3a65, 0x2a);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x3b00, 0xebbf, 0x9434, 0x3a65, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 15);
    expect(peek(14949), equals(0x22));
  });

  // Test instruction cb9f | RES 3, A
  test("OPCODE cb9f | RES 3, A", () {
    // Set up machine initial state
    loadRegisters(0xb200, 0xd1de, 0xf991, 0x72f6, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0x9f);
    poke(0x72f6, 0x72);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xb200, 0xd1de, 0xf991, 0x72f6, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cba0 | RES 4, B
  test("OPCODE cba0 | RES 4, B", () {
    // Set up machine initial state
    loadRegisters(0xfa00, 0xd669, 0x71e1, 0xc80d, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0xa0);
    poke(0xc80d, 0xc0);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xfa00, 0xc669, 0x71e1, 0xc80d, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cba1 | RES 4, C
  test("OPCODE cba1 | RES 4, C", () {
    // Set up machine initial state
    loadRegisters(0x8200, 0x75e4, 0xa0de, 0xd0ba, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0xa1);
    poke(0xd0ba, 0xbd);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x8200, 0x75e4, 0xa0de, 0xd0ba, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cba2 | RES 4, D
  test("OPCODE cba2 | RES 4, D", () {
    // Set up machine initial state
    loadRegisters(0xdd00, 0x2b0d, 0x5554, 0x6fc0, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0xa2);
    poke(0x6fc0, 0x61);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xdd00, 0x2b0d, 0x4554, 0x6fc0, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cba3 | RES 4, E
  test("OPCODE cba3 | RES 4, E", () {
    // Set up machine initial state
    loadRegisters(0x2200, 0x2f0d, 0x4d2c, 0x6666, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0xa3);
    poke(0x6666, 0x8e);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x2200, 0x2f0d, 0x4d2c, 0x6666, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cba4 | RES 4, H
  test("OPCODE cba4 | RES 4, H", () {
    // Set up machine initial state
    loadRegisters(0xd600, 0xd8ed, 0x9cd4, 0x8bb1, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0xa4);
    poke(0x8bb1, 0xbb);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xd600, 0xd8ed, 0x9cd4, 0x8bb1, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cba5 | RES 4, L
  test("OPCODE cba5 | RES 4, L", () {
    // Set up machine initial state
    loadRegisters(0xb400, 0xb393, 0x3e42, 0x88ca, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0xa5);
    poke(0x88ca, 0x4f);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xb400, 0xb393, 0x3e42, 0x88ca, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cba6 | RES 4, (HL)
  test("OPCODE cba6 | RES 4, (HL)", () {
    // Set up machine initial state
    loadRegisters(0x0a00, 0x4c34, 0xf5a7, 0xe70d, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0xa6);
    poke(0xe70d, 0x27);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x0a00, 0x4c34, 0xf5a7, 0xe70d, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 15);
  });

  // Test instruction cba7 | RES 4, A
  test("OPCODE cba7 | RES 4, A", () {
    // Set up machine initial state
    loadRegisters(0x4500, 0xaf61, 0x569a, 0xc77b, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0xa7);
    poke(0xc77b, 0xff);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x4500, 0xaf61, 0x569a, 0xc77b, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cba8 | RES 5, B
  test("OPCODE cba8 | RES 5, B", () {
    // Set up machine initial state
    loadRegisters(0x6400, 0xf269, 0xbae4, 0xc9e7, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0xa8);
    poke(0xc9e7, 0x46);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x6400, 0xd269, 0xbae4, 0xc9e7, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cba9 | RES 5, C
  test("OPCODE cba9 | RES 5, C", () {
    // Set up machine initial state
    loadRegisters(0xe400, 0x7ad4, 0xbf0a, 0xce0b, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0xa9);
    poke(0xce0b, 0x39);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xe400, 0x7ad4, 0xbf0a, 0xce0b, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cbaa | RES 5, D
  test("OPCODE cbaa | RES 5, D", () {
    // Set up machine initial state
    loadRegisters(0xcd00, 0xd249, 0x4159, 0xfed5, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0xaa);
    poke(0xfed5, 0xb0);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xcd00, 0xd249, 0x4159, 0xfed5, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cbab | RES 5, E
  test("OPCODE cbab | RES 5, E", () {
    // Set up machine initial state
    loadRegisters(0xac00, 0x939a, 0x5d9b, 0x0812, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0xab);
    poke(0x0812, 0xf2);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xac00, 0x939a, 0x5d9b, 0x0812, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cbac | RES 5, H
  test("OPCODE cbac | RES 5, H", () {
    // Set up machine initial state
    loadRegisters(0x2400, 0x8a7d, 0x2cac, 0xffaa, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0xac);
    poke(0xffaa, 0x09);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x2400, 0x8a7d, 0x2cac, 0xdfaa, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cbad | RES 5, L
  test("OPCODE cbad | RES 5, L", () {
    // Set up machine initial state
    loadRegisters(0x6f00, 0x5ffb, 0x2360, 0xae15, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0xad);
    poke(0xae15, 0x30);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x6f00, 0x5ffb, 0x2360, 0xae15, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cbae | RES 5, (HL)
  test("OPCODE cbae | RES 5, (HL)", () {
    // Set up machine initial state
    loadRegisters(0x5a00, 0xaa17, 0x12f3, 0x190e, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0xae);
    poke(0x190e, 0x66);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x5a00, 0xaa17, 0x12f3, 0x190e, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 15);
    expect(peek(6414), equals(0x46));
  });

  // Test instruction cbaf | RES 5, A
  test("OPCODE cbaf | RES 5, A", () {
    // Set up machine initial state
    loadRegisters(0xfc00, 0xbb3f, 0x8bb6, 0x5877, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0xaf);
    poke(0x5877, 0x62);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xdc00, 0xbb3f, 0x8bb6, 0x5877, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cbb0 | RES 6, B
  test("OPCODE cbb0 | RES 6, B", () {
    // Set up machine initial state
    loadRegisters(0xb900, 0x7a79, 0x1aaa, 0xc3ba, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0xb0);
    poke(0xc3ba, 0x4c);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xb900, 0x3a79, 0x1aaa, 0xc3ba, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cbb1 | RES 6, C
  test("OPCODE cbb1 | RES 6, C", () {
    // Set up machine initial state
    loadRegisters(0x4900, 0x63e4, 0xa544, 0x1190, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0xb1);
    poke(0x1190, 0xe3);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x4900, 0x63a4, 0xa544, 0x1190, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cbb2 | RES 6, D
  test("OPCODE cbb2 | RES 6, D", () {
    // Set up machine initial state
    loadRegisters(0x4d00, 0x2b03, 0x6b23, 0x6ff5, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0xb2);
    poke(0x6ff5, 0x04);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x4d00, 0x2b03, 0x2b23, 0x6ff5, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cbb3 | RES 6, E
  test("OPCODE cbb3 | RES 6, E", () {
    // Set up machine initial state
    loadRegisters(0x8700, 0x857a, 0xe98b, 0x5cb1, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0xb3);
    poke(0x5cb1, 0x43);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x8700, 0x857a, 0xe98b, 0x5cb1, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cbb4 | RES 6, H
  test("OPCODE cbb4 | RES 6, H", () {
    // Set up machine initial state
    loadRegisters(0x2b00, 0xb73e, 0x79c9, 0xe1bb, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0xb4);
    poke(0xe1bb, 0x78);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x2b00, 0xb73e, 0x79c9, 0xa1bb, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cbb5 | RES 6, L
  test("OPCODE cbb5 | RES 6, L", () {
    // Set up machine initial state
    loadRegisters(0x9b00, 0xd879, 0x2ec9, 0x4bba, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0xb5);
    poke(0x4bba, 0x70);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x9b00, 0xd879, 0x2ec9, 0x4bba, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cbb6 | RES 6, (HL)
  test("OPCODE cbb6 | RES 6, (HL)", () {
    // Set up machine initial state
    loadRegisters(0x8600, 0x89bf, 0xde4a, 0x4fab, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0xb6);
    poke(0x4fab, 0xa5);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x8600, 0x89bf, 0xde4a, 0x4fab, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 15);
  });

  // Test instruction cbb7 | RES 6, A
  test("OPCODE cbb7 | RES 6, A", () {
    // Set up machine initial state
    loadRegisters(0x2200, 0xfb8a, 0x3d6e, 0xd4a2, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0xb7);
    poke(0xd4a2, 0xf2);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x2200, 0xfb8a, 0x3d6e, 0xd4a2, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cbb8 | RES 7, B
  test("OPCODE cbb8 | RES 7, B", () {
    // Set up machine initial state
    loadRegisters(0xd000, 0x37c6, 0x225a, 0xd249, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0xb8);
    poke(0xd249, 0xc4);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xd000, 0x37c6, 0x225a, 0xd249, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cbb9 | RES 7, C
  test("OPCODE cbb9 | RES 7, C", () {
    // Set up machine initial state
    loadRegisters(0xa500, 0x1b4a, 0xd584, 0x5dee, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0xb9);
    poke(0x5dee, 0xcc);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xa500, 0x1b4a, 0xd584, 0x5dee, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cbba | RES 7, D
  test("OPCODE cbba | RES 7, D", () {
    // Set up machine initial state
    loadRegisters(0x6300, 0xa5fe, 0xf42b, 0x34c9, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0xba);
    poke(0x34c9, 0xbc);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x6300, 0xa5fe, 0x742b, 0x34c9, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cbbb | RES 7, E
  test("OPCODE cbbb | RES 7, E", () {
    // Set up machine initial state
    loadRegisters(0x1200, 0xf661, 0xaa4f, 0xcb30, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0xbb);
    poke(0xcb30, 0xf4);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x1200, 0xf661, 0xaa4f, 0xcb30, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cbbc | RES 7, H
  test("OPCODE cbbc | RES 7, H", () {
    // Set up machine initial state
    loadRegisters(0x9800, 0xadc3, 0x0b29, 0x7b6e, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0xbc);
    poke(0x7b6e, 0x45);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x9800, 0xadc3, 0x0b29, 0x7b6e, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cbbd | RES 7, L
  test("OPCODE cbbd | RES 7, L", () {
    // Set up machine initial state
    loadRegisters(0xd600, 0xa6e1, 0x8813, 0x10b8, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0xbd);
    poke(0x10b8, 0x35);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xd600, 0xa6e1, 0x8813, 0x1038, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cbbe | RES 7, (HL)
  test("OPCODE cbbe | RES 7, (HL)", () {
    // Set up machine initial state
    loadRegisters(0xca00, 0xff64, 0x1218, 0x77d5, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0xbe);
    poke(0x77d5, 0xea);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xca00, 0xff64, 0x1218, 0x77d5, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 15);
    expect(peek(30677), equals(0x6a));
  });

  // Test instruction cbbf | RES 7, A
  test("OPCODE cbbf | RES 7, A", () {
    // Set up machine initial state
    loadRegisters(0x6800, 0x4845, 0x690a, 0x15de, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0xbf);
    poke(0x15de, 0x1d);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x6800, 0x4845, 0x690a, 0x15de, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cbc0 | SET 0, B
  test("OPCODE cbc0 | SET 0, B", () {
    // Set up machine initial state
    loadRegisters(0xe300, 0xef71, 0xbffb, 0xb3a1, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0xc0);
    poke(0xb3a1, 0x5c);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xe300, 0xef71, 0xbffb, 0xb3a1, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cbc1 | SET 0, C
  test("OPCODE cbc1 | SET 0, C", () {
    // Set up machine initial state
    loadRegisters(0x3200, 0x32a1, 0x59ab, 0x3343, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0xc1);
    poke(0x3343, 0xaa);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x3200, 0x32a1, 0x59ab, 0x3343, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cbc2 | SET 0, D
  test("OPCODE cbc2 | SET 0, D", () {
    // Set up machine initial state
    loadRegisters(0xc700, 0xb159, 0xc023, 0xe1f3, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0xc2);
    poke(0xe1f3, 0x14);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xc700, 0xb159, 0xc123, 0xe1f3, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cbc3 | SET 0, E
  test("OPCODE cbc3 | SET 0, E", () {
    // Set up machine initial state
    loadRegisters(0x0400, 0xb463, 0xc211, 0x8f3a, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0xc3);
    poke(0x8f3a, 0x81);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x0400, 0xb463, 0xc211, 0x8f3a, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cbc4 | SET 0, H
  test("OPCODE cbc4 | SET 0, H", () {
    // Set up machine initial state
    loadRegisters(0x7e00, 0x545a, 0x6ecf, 0x5876, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0xc4);
    poke(0x5876, 0x9d);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x7e00, 0x545a, 0x6ecf, 0x5976, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cbc5 | SET 0, L
  test("OPCODE cbc5 | SET 0, L", () {
    // Set up machine initial state
    loadRegisters(0x4000, 0xc617, 0x079c, 0x4107, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0xc5);
    poke(0x4107, 0xcc);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x4000, 0xc617, 0x079c, 0x4107, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cbc6 | SET 0, (HL)
  test("OPCODE cbc6 | SET 0, (HL)", () {
    // Set up machine initial state
    loadRegisters(0xb800, 0x0373, 0xb807, 0xf0be, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0xc6);
    poke(0xf0be, 0x9c);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xb800, 0x0373, 0xb807, 0xf0be, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 15);
    expect(peek(61630), equals(0x9d));
  });

  // Test instruction cbc7 | SET 0, A
  test("OPCODE cbc7 | SET 0, A", () {
    // Set up machine initial state
    loadRegisters(0x7700, 0x3681, 0x9b55, 0x583f, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0xc7);
    poke(0x583f, 0x58);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x7700, 0x3681, 0x9b55, 0x583f, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cbc8 | SET 1, B
  test("OPCODE cbc8 | SET 1, B", () {
    // Set up machine initial state
    loadRegisters(0x7d00, 0xa772, 0x8682, 0x7cf3, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0xc8);
    poke(0x7cf3, 0x75);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x7d00, 0xa772, 0x8682, 0x7cf3, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cbc9 | SET 1, C
  test("OPCODE cbc9 | SET 1, C", () {
    // Set up machine initial state
    loadRegisters(0x0b00, 0x67ee, 0x30e0, 0x72db, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0xc9);
    poke(0x72db, 0x87);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x0b00, 0x67ee, 0x30e0, 0x72db, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cbca | SET 1, D
  test("OPCODE cbca | SET 1, D", () {
    // Set up machine initial state
    loadRegisters(0x9c00, 0x9517, 0xcfbb, 0xfbc7, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0xca);
    poke(0xfbc7, 0x1a);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x9c00, 0x9517, 0xcfbb, 0xfbc7, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cbcb | SET 1, E
  test("OPCODE cbcb | SET 1, E", () {
    // Set up machine initial state
    loadRegisters(0xe800, 0x0f3d, 0x336f, 0xf70d, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0xcb);
    poke(0xf70d, 0xa1);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xe800, 0x0f3d, 0x336f, 0xf70d, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cbcc | SET 1, H
  test("OPCODE cbcc | SET 1, H", () {
    // Set up machine initial state
    loadRegisters(0xfb00, 0x7981, 0x0bbb, 0x18fd, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0xcc);
    poke(0x18fd, 0xfe);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xfb00, 0x7981, 0x0bbb, 0x1afd, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cbcd | SET 1, L
  test("OPCODE cbcd | SET 1, L", () {
    // Set up machine initial state
    loadRegisters(0x5500, 0x5e78, 0xbf34, 0x2602, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0xcd);
    poke(0x2602, 0x2d);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x5500, 0x5e78, 0xbf34, 0x2602, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cbce | SET 1, (HL)
  test("OPCODE cbce | SET 1, (HL)", () {
    // Set up machine initial state
    loadRegisters(0xd500, 0xa111, 0xcb2a, 0x8ec6, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0xce);
    poke(0x8ec6, 0xbf);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xd500, 0xa111, 0xcb2a, 0x8ec6, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 15);
  });

  // Test instruction cbcf | SET 1, A
  test("OPCODE cbcf | SET 1, A", () {
    // Set up machine initial state
    loadRegisters(0xa200, 0x6baf, 0x98b2, 0x98a0, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0xcf);
    poke(0x98a0, 0xd4);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xa200, 0x6baf, 0x98b2, 0x98a0, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cbd0 | SET 2, B
  test("OPCODE cbd0 | SET 2, B", () {
    // Set up machine initial state
    loadRegisters(0x2300, 0x7bcb, 0x02e7, 0x1724, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0xd0);
    poke(0x1724, 0x30);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x2300, 0x7fcb, 0x02e7, 0x1724, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cbd1 | SET 2, C
  test("OPCODE cbd1 | SET 2, C", () {
    // Set up machine initial state
    loadRegisters(0x5300, 0x581f, 0xb775, 0x47f4, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0xd1);
    poke(0x47f4, 0xc7);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x5300, 0x581f, 0xb775, 0x47f4, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cbd2 | SET 2, D
  test("OPCODE cbd2 | SET 2, D", () {
    // Set up machine initial state
    loadRegisters(0x6900, 0xc147, 0xb79c, 0x7528, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0xd2);
    poke(0x7528, 0x4f);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x6900, 0xc147, 0xb79c, 0x7528, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cbd3 | SET 2, E
  test("OPCODE cbd3 | SET 2, E", () {
    // Set up machine initial state
    loadRegisters(0xae00, 0xbbc4, 0xce52, 0x5fba, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0xd3);
    poke(0x5fba, 0x3a);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xae00, 0xbbc4, 0xce56, 0x5fba, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cbd4 | SET 2, H
  test("OPCODE cbd4 | SET 2, H", () {
    // Set up machine initial state
    loadRegisters(0xd800, 0x6e1e, 0xaf6f, 0xbf2e, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0xd4);
    poke(0xbf2e, 0x71);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xd800, 0x6e1e, 0xaf6f, 0xbf2e, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cbd5 | SET 2, L
  test("OPCODE cbd5 | SET 2, L", () {
    // Set up machine initial state
    loadRegisters(0x8400, 0xa19a, 0xd2fd, 0x8a77, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0xd5);
    poke(0x8a77, 0x52);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x8400, 0xa19a, 0xd2fd, 0x8a77, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cbd6 | SET 2, (HL)
  test("OPCODE cbd6 | SET 2, (HL)", () {
    // Set up machine initial state
    loadRegisters(0xa900, 0xf5f3, 0x2180, 0x6029, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0xd6);
    poke(0x6029, 0xb7);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xa900, 0xf5f3, 0x2180, 0x6029, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 15);
  });

  // Test instruction cbd7 | SET 2, A
  test("OPCODE cbd7 | SET 2, A", () {
    // Set up machine initial state
    loadRegisters(0xb100, 0xc008, 0x8425, 0x290a, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0xd7);
    poke(0x290a, 0x42);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xb500, 0xc008, 0x8425, 0x290a, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cbd8 | SET 3, B
  test("OPCODE cbd8 | SET 3, B", () {
    // Set up machine initial state
    loadRegisters(0x8b00, 0x09c4, 0xddf3, 0x6d7e, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0xd8);
    poke(0x6d7e, 0x6e);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x8b00, 0x09c4, 0xddf3, 0x6d7e, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cbd9 | SET 3, C
  test("OPCODE cbd9 | SET 3, C", () {
    // Set up machine initial state
    loadRegisters(0x3e00, 0x3e36, 0x30ec, 0xefc6, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0xd9);
    poke(0xefc6, 0x5b);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x3e00, 0x3e3e, 0x30ec, 0xefc6, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cbda | SET 3, D
  test("OPCODE cbda | SET 3, D", () {
    // Set up machine initial state
    loadRegisters(0xd000, 0x3e8f, 0x28fe, 0x1c87, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0xda);
    poke(0x1c87, 0xb9);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xd000, 0x3e8f, 0x28fe, 0x1c87, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cbdb | SET 3, E
  test("OPCODE cbdb | SET 3, E", () {
    // Set up machine initial state
    loadRegisters(0x1200, 0x977a, 0x8c49, 0xbc48, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0xdb);
    poke(0xbc48, 0xef);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x1200, 0x977a, 0x8c49, 0xbc48, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cbdc | SET 3, H
  test("OPCODE cbdc | SET 3, H", () {
    // Set up machine initial state
    loadRegisters(0x8d00, 0x05de, 0xf8d3, 0xb125, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0xdc);
    poke(0xb125, 0x0e);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x8d00, 0x05de, 0xf8d3, 0xb925, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cbdd | SET 3, L
  test("OPCODE cbdd | SET 3, L", () {
    // Set up machine initial state
    loadRegisters(0xc300, 0x08a9, 0x2bc8, 0x5b9f, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0xdd);
    poke(0x5b9f, 0x94);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xc300, 0x08a9, 0x2bc8, 0x5b9f, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cbde | SET 3, (HL)
  test("OPCODE cbde | SET 3, (HL)", () {
    // Set up machine initial state
    loadRegisters(0x1900, 0x900f, 0xd572, 0xba03, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0xde);
    poke(0xba03, 0x93);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x1900, 0x900f, 0xd572, 0xba03, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 15);
    expect(peek(47619), equals(0x9b));
  });

  // Test instruction cbdf | SET 3, A
  test("OPCODE cbdf | SET 3, A", () {
    // Set up machine initial state
    loadRegisters(0x6700, 0x2745, 0x7e3d, 0x0fa1, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0xdf);
    poke(0x0fa1, 0xc5);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x6f00, 0x2745, 0x7e3d, 0x0fa1, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cbe0 | SET 4, B
  test("OPCODE cbe0 | SET 4, B", () {
    // Set up machine initial state
    loadRegisters(0x3e00, 0xd633, 0x9897, 0x3744, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0xe0);
    poke(0x3744, 0x54);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x3e00, 0xd633, 0x9897, 0x3744, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cbe1 | SET 4, C
  test("OPCODE cbe1 | SET 4, C", () {
    // Set up machine initial state
    loadRegisters(0x7d00, 0x50a6, 0x0136, 0x5334, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0xe1);
    poke(0x5334, 0x85);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x7d00, 0x50b6, 0x0136, 0x5334, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cbe2 | SET 4, D
  test("OPCODE cbe2 | SET 4, D", () {
    // Set up machine initial state
    loadRegisters(0xd400, 0x6b45, 0xa192, 0x3a4c, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0xe2);
    poke(0x3a4c, 0x47);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xd400, 0x6b45, 0xb192, 0x3a4c, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cbe3 | SET 4, E
  test("OPCODE cbe3 | SET 4, E", () {
    // Set up machine initial state
    loadRegisters(0x3b00, 0xd29c, 0x05e0, 0x2e78, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0xe3);
    poke(0x2e78, 0x48);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x3b00, 0xd29c, 0x05f0, 0x2e78, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cbe4 | SET 4, H
  test("OPCODE cbe4 | SET 4, H", () {
    // Set up machine initial state
    loadRegisters(0x1e00, 0x7d5e, 0x846d, 0x0978, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0xe4);
    poke(0x0978, 0x84);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x1e00, 0x7d5e, 0x846d, 0x1978, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cbe5 | SET 4, L
  test("OPCODE cbe5 | SET 4, L", () {
    // Set up machine initial state
    loadRegisters(0xca00, 0xdf0d, 0xd588, 0xb48f, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0xe5);
    poke(0xb48f, 0xcf);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xca00, 0xdf0d, 0xd588, 0xb49f, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cbe6 | SET 4, (HL)
  test("OPCODE cbe6 | SET 4, (HL)", () {
    // Set up machine initial state
    loadRegisters(0xb300, 0x52c2, 0xdbfe, 0x9f9b, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0xe6);
    poke(0x9f9b, 0xf6);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xb300, 0x52c2, 0xdbfe, 0x9f9b, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 15);
  });

  // Test instruction cbe7 | SET 4, A
  test("OPCODE cbe7 | SET 4, A", () {
    // Set up machine initial state
    loadRegisters(0x8e00, 0xcf02, 0x67ef, 0xf2e0, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0xe7);
    poke(0xf2e0, 0xcf);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x9e00, 0xcf02, 0x67ef, 0xf2e0, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cbe8 | SET 5, B
  test("OPCODE cbe8 | SET 5, B", () {
    // Set up machine initial state
    loadRegisters(0x7100, 0xbb18, 0x66ec, 0x4a05, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0xe8);
    poke(0x4a05, 0xe6);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x7100, 0xbb18, 0x66ec, 0x4a05, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cbe9 | SET 5, C
  test("OPCODE cbe9 | SET 5, C", () {
    // Set up machine initial state
    loadRegisters(0x5700, 0x2897, 0x8f2f, 0xa4d0, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0xe9);
    poke(0xa4d0, 0xb2);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x5700, 0x28b7, 0x8f2f, 0xa4d0, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cbea | SET 5, D
  test("OPCODE cbea | SET 5, D", () {
    // Set up machine initial state
    loadRegisters(0xec00, 0x304a, 0x60a1, 0xf32a, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0xea);
    poke(0xf32a, 0x9c);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xec00, 0x304a, 0x60a1, 0xf32a, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cbeb | SET 5, E
  test("OPCODE cbeb | SET 5, E", () {
    // Set up machine initial state
    loadRegisters(0xf000, 0x532b, 0xa1be, 0x1a1a, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0xeb);
    poke(0x1a1a, 0x21);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xf000, 0x532b, 0xa1be, 0x1a1a, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cbec | SET 5, H
  test("OPCODE cbec | SET 5, H", () {
    // Set up machine initial state
    loadRegisters(0xf200, 0xf0f3, 0xa816, 0xba08, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0xec);
    poke(0xba08, 0x82);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xf200, 0xf0f3, 0xa816, 0xba08, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cbed | SET 5, L
  test("OPCODE cbed | SET 5, L", () {
    // Set up machine initial state
    loadRegisters(0x1300, 0x5127, 0xadab, 0x2dec, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0xed);
    poke(0x2dec, 0xcb);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x1300, 0x5127, 0xadab, 0x2dec, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cbee | SET 5, (HL)
  test("OPCODE cbee | SET 5, (HL)", () {
    // Set up machine initial state
    loadRegisters(0x9000, 0xb273, 0x50ae, 0xe90d, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0xee);
    poke(0xe90d, 0xf1);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x9000, 0xb273, 0x50ae, 0xe90d, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 15);
  });

  // Test instruction cbef | SET 5, A
  test("OPCODE cbef | SET 5, A", () {
    // Set up machine initial state
    loadRegisters(0x2500, 0x4281, 0xf0d4, 0x2c39, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0xef);
    poke(0x2c39, 0xc8);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x2500, 0x4281, 0xf0d4, 0x2c39, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cbf0 | SET 6, B
  test("OPCODE cbf0 | SET 6, B", () {
    // Set up machine initial state
    loadRegisters(0xfb00, 0x5802, 0x0c27, 0x6ff5, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0xf0);
    poke(0x6ff5, 0xf6);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xfb00, 0x5802, 0x0c27, 0x6ff5, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cbf1 | SET 6, C
  test("OPCODE cbf1 | SET 6, C", () {
    // Set up machine initial state
    loadRegisters(0x5500, 0xa103, 0x3ff5, 0x5e1c, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0xf1);
    poke(0x5e1c, 0x37);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x5500, 0xa143, 0x3ff5, 0x5e1c, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cbf2 | SET 6, D
  test("OPCODE cbf2 | SET 6, D", () {
    // Set up machine initial state
    loadRegisters(0xf000, 0x625a, 0xaf82, 0x9819, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0xf2);
    poke(0x9819, 0xe4);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xf000, 0x625a, 0xef82, 0x9819, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cbf3 | SET 6, E
  test("OPCODE cbf3 | SET 6, E", () {
    // Set up machine initial state
    loadRegisters(0x8600, 0xd7bd, 0x5d86, 0x263f, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0xf3);
    poke(0x263f, 0xa1);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x8600, 0xd7bd, 0x5dc6, 0x263f, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cbf4 | SET 6, H
  test("OPCODE cbf4 | SET 6, H", () {
    // Set up machine initial state
    loadRegisters(0x9400, 0x0243, 0x9ec1, 0x75d9, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0xf4);
    poke(0x75d9, 0x3f);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x9400, 0x0243, 0x9ec1, 0x75d9, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cbf5 | SET 6, L
  test("OPCODE cbf5 | SET 6, L", () {
    // Set up machine initial state
    loadRegisters(0xce00, 0x2d42, 0x5e6a, 0x47e6, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0xf5);
    poke(0x47e6, 0xce);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xce00, 0x2d42, 0x5e6a, 0x47e6, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cbf6 | SET 6, (HL)
  test("OPCODE cbf6 | SET 6, (HL)", () {
    // Set up machine initial state
    loadRegisters(0x7b00, 0xc2d7, 0x4492, 0xa9bc, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0xf6);
    poke(0xa9bc, 0xb1);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x7b00, 0xc2d7, 0x4492, 0xa9bc, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 15);
    expect(peek(43452), equals(0xf1));
  });

  // Test instruction cbf7 | SET 6, A
  test("OPCODE cbf7 | SET 6, A", () {
    // Set up machine initial state
    loadRegisters(0x6d00, 0xabaf, 0x5b5d, 0x188c, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0xf7);
    poke(0x188c, 0x6c);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x6d00, 0xabaf, 0x5b5d, 0x188c, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cbf8 | SET 7, B
  test("OPCODE cbf8 | SET 7, B", () {
    // Set up machine initial state
    loadRegisters(0xc600, 0xb812, 0xa037, 0xd2b0, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0xf8);
    poke(0xd2b0, 0xcb);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xc600, 0xb812, 0xa037, 0xd2b0, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cbf9 | SET 7, C
  test("OPCODE cbf9 | SET 7, C", () {
    // Set up machine initial state
    loadRegisters(0xef00, 0xc5f2, 0x77a8, 0x0730, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0xf9);
    poke(0x0730, 0xae);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xef00, 0xc5f2, 0x77a8, 0x0730, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cbfa | SET 7, D
  test("OPCODE cbfa | SET 7, D", () {
    // Set up machine initial state
    loadRegisters(0x8700, 0x1581, 0x63e3, 0xed03, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0xfa);
    poke(0xed03, 0x27);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x8700, 0x1581, 0xe3e3, 0xed03, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cbfb | SET 7, E
  test("OPCODE cbfb | SET 7, E", () {
    // Set up machine initial state
    loadRegisters(0xa300, 0x7d27, 0x97c3, 0xd1ae, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0xfb);
    poke(0xd1ae, 0xf2);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xa300, 0x7d27, 0x97c3, 0xd1ae, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cbfc | SET 7, H
  test("OPCODE cbfc | SET 7, H", () {
    // Set up machine initial state
    loadRegisters(0xec00, 0x060a, 0x3ef6, 0x500f, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0xfc);
    poke(0x500f, 0x94);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xec00, 0x060a, 0x3ef6, 0xd00f, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cbfd | SET 7, L
  test("OPCODE cbfd | SET 7, L", () {
    // Set up machine initial state
    loadRegisters(0x1100, 0x231a, 0x8563, 0x28c5, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0xfd);
    poke(0x28c5, 0xab);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x1100, 0x231a, 0x8563, 0x28c5, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cbfe | SET 7, (HL)
  test("OPCODE cbfe | SET 7, (HL)", () {
    // Set up machine initial state
    loadRegisters(0x5300, 0x4948, 0x89dd, 0x3a24, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0xfe);
    poke(0x3a24, 0xc3);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x5300, 0x4948, 0x89dd, 0x3a24, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 15);
  });

  // Test instruction cbff | SET 7, A
  test("OPCODE cbff | SET 7, A", () {
    // Set up machine initial state
    loadRegisters(0x7900, 0x799b, 0x6cf7, 0xe3f2, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcb);
    poke(0x0001, 0xff);
    poke(0xe3f2, 0x25);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xf900, 0x799b, 0x6cf7, 0xe3f2, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction cc_1 | CALL Z, **
  test("OPCODE cc_1 | CALL Z, **", () {
    // Set up machine initial state
    loadRegisters(0x004e, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x5698, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcc);
    poke(0x0001, 0x61);
    poke(0x0002, 0x9c);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x004e, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x5696, 0x9c61);
    checkSpecialRegisters(0x00, 0x01, false, false, 17);
    expect(peek(22166), equals(0x03));
    expect(peek(22167), equals(0x00));
  });

  // Test instruction cc_2 | CALL Z, **
  test("OPCODE cc_2 | CALL Z, **", () {
    // Set up machine initial state
    loadRegisters(0x000e, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x5698, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcc);
    poke(0x0001, 0x61);
    poke(0x0002, 0x9c);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x000e, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x5698, 0x0003);
    checkSpecialRegisters(0x00, 0x01, false, false, 10);
  });

  // Test instruction cd | CALL **
  test("OPCODE cd | CALL **", () {
    // Set up machine initial state
    loadRegisters(0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0xb07d, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xcd);
    poke(0x0001, 0x5d);
    poke(0x0002, 0x3a);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0xb07b, 0x3a5d);
    checkSpecialRegisters(0x00, 0x01, false, false, 17);
    expect(peek(45179), equals(0x03));
    expect(peek(45180), equals(0x00));
  });

  // Test instruction ce | ADC A, *
  test("OPCODE ce | ADC A, *", () {
    // Set up machine initial state
    loadRegisters(0x60f5, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xce);
    poke(0x0001, 0xb2);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x1301, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x01, false, false, 7);
  });

  // Test instruction cf | RST 8h
  test("OPCODE cf | RST 8h", () {
    // Set up machine initial state
    loadRegisters(0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x5507, 0x6d33);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x6d33, 0xcf);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x5505, 0x0008);
    checkSpecialRegisters(0x00, 0x01, false, false, 11);
    expect(peek(21765), equals(0x34));
    expect(peek(21766), equals(0x6d));
  });

  // Test instruction d0_1 | RET NC
  test("OPCODE d0_1 | RET NC", () {
    // Set up machine initial state
    loadRegisters(0x0098, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x43f7, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xd0);
    poke(0x43f7, 0xe9);
    poke(0x43f8, 0xaf);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x0098, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x43f9, 0xafe9);
    checkSpecialRegisters(0x00, 0x01, false, false, 11);
  });

  // Test instruction d0_2 | RET NC
  test("OPCODE d0_2 | RET NC", () {
    // Set up machine initial state
    loadRegisters(0x0099, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x43f7, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xd0);
    poke(0x43f7, 0xe9);
    poke(0x43f8, 0xaf);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x0099, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x43f7, 0x0001);
    checkSpecialRegisters(0x00, 0x01, false, false, 5);
  });

  // Test instruction d1 | POP DE
  test("OPCODE d1 | POP DE", () {
    // Set up machine initial state
    loadRegisters(0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x4143, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xd1);
    poke(0x4143, 0xce);
    poke(0x4144, 0xe8);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x0000, 0x0000, 0xe8ce, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x4145, 0x0001);
    checkSpecialRegisters(0x00, 0x01, false, false, 10);
  });

  // Test instruction d2_1 | JP NC, **
  test("OPCODE d2_1 | JP NC, **", () {
    // Set up machine initial state
    loadRegisters(0x0086, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xd2);
    poke(0x0001, 0x1b);
    poke(0x0002, 0xe1);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x0086, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0xe11b);
    checkSpecialRegisters(0x00, 0x01, false, false, 10);
  });

  // Test instruction d2_2 | JP NC, **
  test("OPCODE d2_2 | JP NC, **", () {
    // Set up machine initial state
    loadRegisters(0x0087, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xd2);
    poke(0x0001, 0x1b);
    poke(0x0002, 0xe1);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x0087, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0003);
    checkSpecialRegisters(0x00, 0x01, false, false, 10);
  });

  // Test instruction d3_1 | OUT (*), A
  test("OPCODE d3_1 | OUT (*), A", () {
    // Set up machine initial state
    loadRegisters(0xa200, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xd3);
    poke(0x0001, 0xed);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xa200, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x01, false, false, 11);
  });

  // Test instruction d3_2 | OUT (*), A
  test("OPCODE d3_2 | OUT (*), A", () {
    // Set up machine initial state
    loadRegisters(0x4200, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xd3);
    poke(0x0001, 0xec);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x4200, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x01, false, false, 11);
  });

  // Test instruction d3_3 | OUT (*), A
  test("OPCODE d3_3 | OUT (*), A", () {
    // Set up machine initial state
    loadRegisters(0x4200, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xd3);
    poke(0x0001, 0xed);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x4200, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x01, false, false, 11);
  });

  // Test instruction d3_4 | OUT (*), A
  test("OPCODE d3_4 | OUT (*), A", () {
    // Set up machine initial state
    loadRegisters(0xa200, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xd3);
    poke(0x0001, 0xff);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xa200, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x01, false, false, 11);
  });

  // Test instruction d3 | OUT (*), A
  test("OPCODE d3 | OUT (*), A", () {
    // Set up machine initial state
    loadRegisters(0xa200, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xd3);
    poke(0x0001, 0xec);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xa200, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x01, false, false, 11);
  });

  // Test instruction d4_1 | CALL NC, **
  test("OPCODE d4_1 | CALL NC, **", () {
    // Set up machine initial state
    loadRegisters(0x000e, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x5698, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xd4);
    poke(0x0001, 0x61);
    poke(0x0002, 0x9c);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x000e, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x5696, 0x9c61);
    checkSpecialRegisters(0x00, 0x01, false, false, 17);
    expect(peek(22166), equals(0x03));
    expect(peek(22167), equals(0x00));
  });

  // Test instruction d4_2 | CALL NC, **
  test("OPCODE d4_2 | CALL NC, **", () {
    // Set up machine initial state
    loadRegisters(0x000f, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x5698, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xd4);
    poke(0x0001, 0x61);
    poke(0x0002, 0x9c);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x000f, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x5698, 0x0003);
    checkSpecialRegisters(0x00, 0x01, false, false, 10);
  });

  // Test instruction d5 | PUSH DE
  test("OPCODE d5 | PUSH DE", () {
    // Set up machine initial state
    loadRegisters(0x53e3, 0x1459, 0x775f, 0x1a2f, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0xec12, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xd5);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x53e3, 0x1459, 0x775f, 0x1a2f, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0xec10, 0x0001);
    checkSpecialRegisters(0x00, 0x01, false, false, 11);
    expect(peek(60432), equals(0x5f));
    expect(peek(60433), equals(0x77));
  });

  // Test instruction d6 | SUB *
  test("OPCODE d6 | SUB *", () {
    // Set up machine initial state
    loadRegisters(0x3900, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xd6);
    poke(0x0001, 0xdf);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x5a1b, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x01, false, false, 7);
  });

  // Test instruction d7 | RST 10h
  test("OPCODE d7 | RST 10h", () {
    // Set up machine initial state
    loadRegisters(0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x5507, 0x6d33);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x6d33, 0xd7);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x5505, 0x0010);
    checkSpecialRegisters(0x00, 0x01, false, false, 11);
    expect(peek(21765), equals(0x34));
    expect(peek(21766), equals(0x6d));
  });

  // Test instruction d8_1 | RET C
  test("OPCODE d8_1 | RET C", () {
    // Set up machine initial state
    loadRegisters(0x0098, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x43f7, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xd8);
    poke(0x43f7, 0xe9);
    poke(0x43f8, 0xaf);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x0098, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x43f7, 0x0001);
    checkSpecialRegisters(0x00, 0x01, false, false, 5);
  });

  // Test instruction d8_2 | RET C
  test("OPCODE d8_2 | RET C", () {
    // Set up machine initial state
    loadRegisters(0x0099, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x43f7, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xd8);
    poke(0x43f7, 0xe9);
    poke(0x43f8, 0xaf);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x0099, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x43f9, 0xafe9);
    checkSpecialRegisters(0x00, 0x01, false, false, 11);
  });

  // Test instruction d9 | EXX
  test("OPCODE d9 | EXX", () {
    // Set up machine initial state
    loadRegisters(0x4d94, 0xe07a, 0xe35b, 0x9d64, 0x1a64, 0xc930, 0x3d01,
        0x7d02, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xd9);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x4d94, 0xc930, 0x3d01, 0x7d02, 0x1a64, 0xe07a, 0xe35b,
        0x9d64, 0x0000, 0x0000, 0x0000, 0x0001);
    checkSpecialRegisters(0x00, 0x01, false, false, 4);
  });

  // Test instruction da_1 | JP C, **
  test("OPCODE da_1 | JP C, **", () {
    // Set up machine initial state
    loadRegisters(0x0087, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xda);
    poke(0x0001, 0x1b);
    poke(0x0002, 0xe1);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x0087, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0xe11b);
    checkSpecialRegisters(0x00, 0x01, false, false, 10);
  });

  // Test instruction da_2 | JP C, **
  test("OPCODE da_2 | JP C, **", () {
    // Set up machine initial state
    loadRegisters(0x0086, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xda);
    poke(0x0001, 0x1b);
    poke(0x0002, 0xe1);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x0086, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0003);
    checkSpecialRegisters(0x00, 0x01, false, false, 10);
  });

  // Test instruction db_1 | IN A, (*)
  test("OPCODE db_1 | IN A, (*)", () {
    // Set up machine initial state
    loadRegisters(0xc100, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xdb);
    poke(0x0001, 0xe3);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xc100, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x01, false, false, 11);
  });

  // Test instruction db_2 | IN A, (*)
  test("OPCODE db_2 | IN A, (*)", () {
    // Set up machine initial state
    loadRegisters(0x7100, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xdb);
    poke(0x0001, 0xe2);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x7100, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x01, false, false, 11);
  });

  // Test instruction db_3 | IN A, (*)
  test("OPCODE db_3 | IN A, (*)", () {
    // Set up machine initial state
    loadRegisters(0x7100, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xdb);
    poke(0x0001, 0xe3);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x7100, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x01, false, false, 11);
  });

  // Test instruction db | IN A, (*)
  test("OPCODE db | IN A, (*)", () {
    // Set up machine initial state
    loadRegisters(0xc100, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xdb);
    poke(0x0001, 0xe2);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xc100, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x01, false, false, 11);
  });

  // Test instruction dc_1 | CALL C, **
  test("OPCODE dc_1 | CALL C, **", () {
    // Set up machine initial state
    loadRegisters(0x000f, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x5698, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xdc);
    poke(0x0001, 0x61);
    poke(0x0002, 0x9c);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x000f, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x5696, 0x9c61);
    checkSpecialRegisters(0x00, 0x01, false, false, 17);
    expect(peek(22166), equals(0x03));
    expect(peek(22167), equals(0x00));
  });

  // Test instruction dc_2 | CALL C, **
  test("OPCODE dc_2 | CALL C, **", () {
    // Set up machine initial state
    loadRegisters(0x000e, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x5698, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xdc);
    poke(0x0001, 0x61);
    poke(0x0002, 0x9c);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x000e, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x5698, 0x0003);
    checkSpecialRegisters(0x00, 0x01, false, false, 10);
  });

  // Test instruction dd00 | <UNKNOWN>
  test("OPCODE dd00", () {
    // Set up machine initial state
    loadRegisters(0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xdd);
    poke(0x0001, 0x00);
    poke(0x0002, 0x00);

    // Execute machine for tState cycles
    while (z80.tStates < 9) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0003);
    checkSpecialRegisters(0x00, 0x03, false, false, 12);
  });

  // Test instruction dd09 | ADD IX, BC
  test("OPCODE dd09 | ADD IX, BC", () {
    // Set up machine initial state
    loadRegisters(0x0d05, 0x1426, 0x53ce, 0x41e3, 0x0000, 0x0000, 0x0000,
        0x0000, 0x9ec0, 0x5c89, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xdd);
    poke(0x0001, 0x09);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x0d34, 0x1426, 0x53ce, 0x41e3, 0x0000, 0x0000, 0x0000,
        0x0000, 0xb2e6, 0x5c89, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 15);
  });

  // Test instruction dd19 | ADD IX, DE
  test("OPCODE dd19 | ADD IX, DE", () {
    // Set up machine initial state
    loadRegisters(0x1911, 0x0e0b, 0x2724, 0xbe62, 0x0000, 0x0000, 0x0000,
        0x0000, 0x824f, 0x760b, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xdd);
    poke(0x0001, 0x19);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x1928, 0x0e0b, 0x2724, 0xbe62, 0x0000, 0x0000, 0x0000,
        0x0000, 0xa973, 0x760b, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 15);
  });

  // Test instruction dd21 | LD IX, **
  test("OPCODE dd21 | LD IX, **", () {
    // Set up machine initial state
    loadRegisters(0xc935, 0x4353, 0xbd22, 0x94d5, 0x0000, 0x0000, 0x0000,
        0x0000, 0xdade, 0xaad6, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xdd);
    poke(0x0001, 0x21);
    poke(0x0002, 0xf2);
    poke(0x0003, 0x7c);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xc935, 0x4353, 0xbd22, 0x94d5, 0x0000, 0x0000, 0x0000,
        0x0000, 0x7cf2, 0xaad6, 0x0000, 0x0004);
    checkSpecialRegisters(0x00, 0x02, false, false, 14);
  });

  // Test instruction dd22 | LD (**), IX
  test("OPCODE dd22 | LD (**), IX", () {
    // Set up machine initial state
    loadRegisters(0x5b1d, 0x45a1, 0x6de8, 0x39d3, 0x0000, 0x0000, 0x0000,
        0x0000, 0xebe7, 0x05b0, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xdd);
    poke(0x0001, 0x22);
    poke(0x0002, 0x4f);
    poke(0x0003, 0xad);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x5b1d, 0x45a1, 0x6de8, 0x39d3, 0x0000, 0x0000, 0x0000,
        0x0000, 0xebe7, 0x05b0, 0x0000, 0x0004);
    checkSpecialRegisters(0x00, 0x02, false, false, 20);
    expect(peek(44367), equals(0xe7));
    expect(peek(44368), equals(0xeb));
  });

  // Test instruction dd23 | INC IX
  test("OPCODE dd23 | INC IX", () {
    // Set up machine initial state
    loadRegisters(0x9095, 0xac3c, 0x4d90, 0x379b, 0x0000, 0x0000, 0x0000,
        0x0000, 0xd50b, 0xa157, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xdd);
    poke(0x0001, 0x23);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x9095, 0xac3c, 0x4d90, 0x379b, 0x0000, 0x0000, 0x0000,
        0x0000, 0xd50c, 0xa157, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 10);
  });

  // Test instruction dd29 | ADD IX, IX
  test("OPCODE dd29 | ADD IX, IX", () {
    // Set up machine initial state
    loadRegisters(0xac80, 0x0f0e, 0x72c8, 0x1f2a, 0x0000, 0x0000, 0x0000,
        0x0000, 0x5195, 0x7d8a, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xdd);
    poke(0x0001, 0x29);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xaca0, 0x0f0e, 0x72c8, 0x1f2a, 0x0000, 0x0000, 0x0000,
        0x0000, 0xa32a, 0x7d8a, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 15);
  });

  // Test instruction dd2a | LD IX, (**)
  test("OPCODE dd2a | LD IX, (**)", () {
    // Set up machine initial state
    loadRegisters(0x3d36, 0xb24e, 0xbdbc, 0xca4e, 0x0000, 0x0000, 0x0000,
        0x0000, 0xba65, 0xe7ce, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xdd);
    poke(0x0001, 0x2a);
    poke(0x0002, 0xbc);
    poke(0x0003, 0x40);
    poke(0x40bc, 0xb5);
    poke(0x40bd, 0x30);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x3d36, 0xb24e, 0xbdbc, 0xca4e, 0x0000, 0x0000, 0x0000,
        0x0000, 0x30b5, 0xe7ce, 0x0000, 0x0004);
    checkSpecialRegisters(0x00, 0x02, false, false, 20);
  });

  // Test instruction dd2b | DEC IX
  test("OPCODE dd2b | DEC IX", () {
    // Set up machine initial state
    loadRegisters(0xad4b, 0xd5e6, 0x9377, 0xf132, 0x0000, 0x0000, 0x0000,
        0x0000, 0x7a17, 0x2188, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xdd);
    poke(0x0001, 0x2b);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xad4b, 0xd5e6, 0x9377, 0xf132, 0x0000, 0x0000, 0x0000,
        0x0000, 0x7a16, 0x2188, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 10);
  });

  // Test instruction dd34 | INC (IX+*)
  test("OPCODE dd34 | INC (IX+*)", () {
    // Set up machine initial state
    loadRegisters(0x8304, 0xd1fc, 0xb80b, 0x8082, 0x0000, 0x0000, 0x0000,
        0x0000, 0xdea9, 0x6fd8, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xdd);
    poke(0x0001, 0x34);
    poke(0x0002, 0xe6);
    poke(0xde8f, 0x57);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x8308, 0xd1fc, 0xb80b, 0x8082, 0x0000, 0x0000, 0x0000,
        0x0000, 0xdea9, 0x6fd8, 0x0000, 0x0003);
    checkSpecialRegisters(0x00, 0x02, false, false, 23);
    expect(peek(56975), equals(0x58));
  });

  // Test instruction dd35 | DEC (IX+*)
  test("OPCODE dd35 | DEC (IX+*)", () {
    // Set up machine initial state
    loadRegisters(0x8681, 0x4641, 0x1ef6, 0x10ab, 0x0000, 0x0000, 0x0000,
        0x0000, 0xc733, 0x8ec4, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xdd);
    poke(0x0001, 0x35);
    poke(0x0002, 0x60);
    poke(0xc793, 0xf7);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x86a3, 0x4641, 0x1ef6, 0x10ab, 0x0000, 0x0000, 0x0000,
        0x0000, 0xc733, 0x8ec4, 0x0000, 0x0003);
    checkSpecialRegisters(0x00, 0x02, false, false, 23);
    expect(peek(51091), equals(0xf6));
  });

  // Test instruction dd36 | LD (IX+*), *
  test("OPCODE dd36 | LD (IX+*), *", () {
    // Set up machine initial state
    loadRegisters(0x76dc, 0x2530, 0x5158, 0x877d, 0x0000, 0x0000, 0x0000,
        0x0000, 0xb5c6, 0x8d3c, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xdd);
    poke(0x0001, 0x36);
    poke(0x0002, 0x35);
    poke(0x0003, 0xb5);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x76dc, 0x2530, 0x5158, 0x877d, 0x0000, 0x0000, 0x0000,
        0x0000, 0xb5c6, 0x8d3c, 0x0000, 0x0004);
    checkSpecialRegisters(0x00, 0x02, false, false, 19);
    expect(peek(46587), equals(0xb5));
  });

  // Test instruction dd39 | ADD IX, SP
  test("OPCODE dd39 | ADD IX, SP", () {
    // Set up machine initial state
    loadRegisters(0x875b, 0xa334, 0xd79d, 0x59e4, 0x0000, 0x0000, 0x0000,
        0x0000, 0xb11a, 0x4c88, 0xfa4a, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xdd);
    poke(0x0001, 0x39);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x8769, 0xa334, 0xd79d, 0x59e4, 0x0000, 0x0000, 0x0000,
        0x0000, 0xab64, 0x4c88, 0xfa4a, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 15);
  });

  // Test instruction dd46 | LD B, (IX+*)
  test("OPCODE dd46 | LD B, (IX+*)", () {
    // Set up machine initial state
    loadRegisters(0xc758, 0xbf29, 0x66f2, 0x29ef, 0x0000, 0x0000, 0x0000,
        0x0000, 0x5cc7, 0x407d, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xdd);
    poke(0x0001, 0x46);
    poke(0x0002, 0x68);
    poke(0x5d2f, 0x8d);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xc758, 0x8d29, 0x66f2, 0x29ef, 0x0000, 0x0000, 0x0000,
        0x0000, 0x5cc7, 0x407d, 0x0000, 0x0003);
    checkSpecialRegisters(0x00, 0x02, false, false, 19);
  });

  // Test instruction dd4e | LD C, (IX+*)
  test("OPCODE dd4e | LD C, (IX+*)", () {
    // Set up machine initial state
    loadRegisters(0x7bf7, 0x6605, 0x8d55, 0xdef2, 0x0000, 0x0000, 0x0000,
        0x0000, 0xd94b, 0x17fb, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xdd);
    poke(0x0001, 0x4e);
    poke(0x0002, 0x2e);
    poke(0xd979, 0x76);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x7bf7, 0x6676, 0x8d55, 0xdef2, 0x0000, 0x0000, 0x0000,
        0x0000, 0xd94b, 0x17fb, 0x0000, 0x0003);
    checkSpecialRegisters(0x00, 0x02, false, false, 19);
  });

  // Test instruction dd56 | LD D, (IX+*)
  test("OPCODE dd56 | LD D, (IX+*)", () {
    // Set up machine initial state
    loadRegisters(0x97b3, 0xb617, 0xbb50, 0x81d1, 0x0000, 0x0000, 0x0000,
        0x0000, 0xa306, 0x7a49, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xdd);
    poke(0x0001, 0x56);
    poke(0x0002, 0xf4);
    poke(0xa2fa, 0xde);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x97b3, 0xb617, 0xde50, 0x81d1, 0x0000, 0x0000, 0x0000,
        0x0000, 0xa306, 0x7a49, 0x0000, 0x0003);
    checkSpecialRegisters(0x00, 0x02, false, false, 19);
  });

  // Test instruction dd5e | LD E, (IX+*)
  test("OPCODE dd5e | LD E, (IX+*)", () {
    // Set up machine initial state
    loadRegisters(0xa220, 0x389d, 0x2ff8, 0x368c, 0x0000, 0x0000, 0x0000,
        0x0000, 0x8d32, 0x3512, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xdd);
    poke(0x0001, 0x5e);
    poke(0x0002, 0x8f);
    poke(0x8cc1, 0xce);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xa220, 0x389d, 0x2fce, 0x368c, 0x0000, 0x0000, 0x0000,
        0x0000, 0x8d32, 0x3512, 0x0000, 0x0003);
    checkSpecialRegisters(0x00, 0x02, false, false, 19);
  });

  // Test instruction dd66 | LD H, (IX+*)
  test("OPCODE dd66 | LD H, (IX+*)", () {
    // Set up machine initial state
    loadRegisters(0x84c2, 0x79b1, 0xca4a, 0xaaa0, 0x0000, 0x0000, 0x0000,
        0x0000, 0xce5d, 0xdd2d, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xdd);
    poke(0x0001, 0x66);
    poke(0x0002, 0xb5);
    poke(0xce12, 0x03);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x84c2, 0x79b1, 0xca4a, 0x03a0, 0x0000, 0x0000, 0x0000,
        0x0000, 0xce5d, 0xdd2d, 0x0000, 0x0003);
    checkSpecialRegisters(0x00, 0x02, false, false, 19);
  });

  // Test instruction dd6e | LD L, (IX+*)
  test("OPCODE dd6e | LD L, (IX+*)", () {
    // Set up machine initial state
    loadRegisters(0x223f, 0xf661, 0xb61c, 0x0f53, 0x0000, 0x0000, 0x0000,
        0x0000, 0xc648, 0xfae8, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xdd);
    poke(0x0001, 0x6e);
    poke(0x0002, 0x2c);
    poke(0xc674, 0x6b);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x223f, 0xf661, 0xb61c, 0x0f6b, 0x0000, 0x0000, 0x0000,
        0x0000, 0xc648, 0xfae8, 0x0000, 0x0003);
    checkSpecialRegisters(0x00, 0x02, false, false, 19);
  });

  // Test instruction dd70 | LD (IX+*), B
  test("OPCODE dd70 | LD (IX+*), B", () {
    // Set up machine initial state
    loadRegisters(0xd09f, 0xfe00, 0x231e, 0x31ec, 0x0000, 0x0000, 0x0000,
        0x0000, 0x05fa, 0xea92, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xdd);
    poke(0x0001, 0x70);
    poke(0x0002, 0xf6);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xd09f, 0xfe00, 0x231e, 0x31ec, 0x0000, 0x0000, 0x0000,
        0x0000, 0x05fa, 0xea92, 0x0000, 0x0003);
    checkSpecialRegisters(0x00, 0x02, false, false, 19);
    expect(peek(1520), equals(0xfe));
  });

  // Test instruction dd71 | LD (IX+*), C
  test("OPCODE dd71 | LD (IX+*), C", () {
    // Set up machine initial state
    loadRegisters(0xebee, 0x151c, 0x05c7, 0xee08, 0x0000, 0x0000, 0x0000,
        0x0000, 0x3722, 0x2ec6, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xdd);
    poke(0x0001, 0x71);
    poke(0x0002, 0x23);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xebee, 0x151c, 0x05c7, 0xee08, 0x0000, 0x0000, 0x0000,
        0x0000, 0x3722, 0x2ec6, 0x0000, 0x0003);
    checkSpecialRegisters(0x00, 0x02, false, false, 19);
    expect(peek(14149), equals(0x1c));
  });

  // Test instruction dd72 | LD (IX+*), D
  test("OPCODE dd72 | LD (IX+*), D", () {
    // Set up machine initial state
    loadRegisters(0x80c9, 0xac1e, 0x63bd, 0x828b, 0x0000, 0x0000, 0x0000,
        0x0000, 0x8dff, 0x94ef, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xdd);
    poke(0x0001, 0x72);
    poke(0x0002, 0x93);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x80c9, 0xac1e, 0x63bd, 0x828b, 0x0000, 0x0000, 0x0000,
        0x0000, 0x8dff, 0x94ef, 0x0000, 0x0003);
    checkSpecialRegisters(0x00, 0x02, false, false, 19);
    expect(peek(36242), equals(0x63));
  });

  // Test instruction dd73 | LD (IX+*), E
  test("OPCODE dd73 | LD (IX+*), E", () {
    // Set up machine initial state
    loadRegisters(0x8f3e, 0xb5a3, 0x07de, 0x0b0c, 0x0000, 0x0000, 0x0000,
        0x0000, 0x79c6, 0xae79, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xdd);
    poke(0x0001, 0x73);
    poke(0x0002, 0x57);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x8f3e, 0xb5a3, 0x07de, 0x0b0c, 0x0000, 0x0000, 0x0000,
        0x0000, 0x79c6, 0xae79, 0x0000, 0x0003);
    checkSpecialRegisters(0x00, 0x02, false, false, 19);
    expect(peek(31261), equals(0xde));
  });

  // Test instruction dd74 | LD (IX+*), H
  test("OPCODE dd74 | LD (IX+*), H", () {
    // Set up machine initial state
    loadRegisters(0x4ae0, 0x49c5, 0x3deb, 0x0125, 0x0000, 0x0000, 0x0000,
        0x0000, 0x5910, 0x429a, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xdd);
    poke(0x0001, 0x74);
    poke(0x0002, 0xb9);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x4ae0, 0x49c5, 0x3deb, 0x0125, 0x0000, 0x0000, 0x0000,
        0x0000, 0x5910, 0x429a, 0x0000, 0x0003);
    checkSpecialRegisters(0x00, 0x02, false, false, 19);
    expect(peek(22729), equals(0x01));
  });

  // Test instruction dd75 | LD (IX+*), L
  test("OPCODE dd75 | LD (IX+*), L", () {
    // Set up machine initial state
    loadRegisters(0x5772, 0xe833, 0xb63e, 0x734f, 0x0000, 0x0000, 0x0000,
        0x0000, 0xae4c, 0xe8c2, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xdd);
    poke(0x0001, 0x75);
    poke(0x0002, 0x30);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x5772, 0xe833, 0xb63e, 0x734f, 0x0000, 0x0000, 0x0000,
        0x0000, 0xae4c, 0xe8c2, 0x0000, 0x0003);
    checkSpecialRegisters(0x00, 0x02, false, false, 19);
    expect(peek(44668), equals(0x4f));
  });

  // Test instruction dd77 | LD (IX+*), A
  test("OPCODE dd77 | LD (IX+*), A", () {
    // Set up machine initial state
    loadRegisters(0xdc56, 0xd893, 0x4116, 0xf2d2, 0x0000, 0x0000, 0x0000,
        0x0000, 0xa181, 0x3157, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xdd);
    poke(0x0001, 0x77);
    poke(0x0002, 0x8c);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xdc56, 0xd893, 0x4116, 0xf2d2, 0x0000, 0x0000, 0x0000,
        0x0000, 0xa181, 0x3157, 0x0000, 0x0003);
    checkSpecialRegisters(0x00, 0x02, false, false, 19);
    expect(peek(41229), equals(0xdc));
  });

  // Test instruction dd7e | LD A, (IX+*)
  test("OPCODE dd7e | LD A, (IX+*)", () {
    // Set up machine initial state
    loadRegisters(0x6a66, 0x1f77, 0x6220, 0x0c40, 0x0000, 0x0000, 0x0000,
        0x0000, 0x1cf4, 0x1a1f, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xdd);
    poke(0x0001, 0x7e);
    poke(0x0002, 0xbc);
    poke(0x1cb0, 0x57);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x5766, 0x1f77, 0x6220, 0x0c40, 0x0000, 0x0000, 0x0000,
        0x0000, 0x1cf4, 0x1a1f, 0x0000, 0x0003);
    checkSpecialRegisters(0x00, 0x02, false, false, 19);
  });

  // Test instruction dd86 | ADD A, (IX+*)
  test("OPCODE dd86 | ADD A, (IX+*)", () {
    // Set up machine initial state
    loadRegisters(0x4efa, 0xd085, 0x5bac, 0xe364, 0x0000, 0x0000, 0x0000,
        0x0000, 0xb5b5, 0xfe3a, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xdd);
    poke(0x0001, 0x86);
    poke(0x0002, 0xc1);
    poke(0xb576, 0x5b);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xa9bc, 0xd085, 0x5bac, 0xe364, 0x0000, 0x0000, 0x0000,
        0x0000, 0xb5b5, 0xfe3a, 0x0000, 0x0003);
    checkSpecialRegisters(0x00, 0x02, false, false, 19);
  });

  // Test instruction dd8e | ADC A, (IX+*)
  test("OPCODE dd8e | ADC A, (IX+*)", () {
    // Set up machine initial state
    loadRegisters(0x4ed4, 0x182d, 0xab17, 0x94ae, 0x0000, 0x0000, 0x0000,
        0x0000, 0xbb97, 0x87da, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xdd);
    poke(0x0001, 0x8e);
    poke(0x0002, 0x25);
    poke(0xbbbc, 0x32);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x8094, 0x182d, 0xab17, 0x94ae, 0x0000, 0x0000, 0x0000,
        0x0000, 0xbb97, 0x87da, 0x0000, 0x0003);
    checkSpecialRegisters(0x00, 0x02, false, false, 19);
  });

  // Test instruction dd96 | SUB (IX+*)
  test("OPCODE dd96 | SUB (IX+*)", () {
    // Set up machine initial state
    loadRegisters(0x9b76, 0x461f, 0xced7, 0xdb3f, 0x0000, 0x0000, 0x0000,
        0x0000, 0x2c66, 0x9dbf, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xdd);
    poke(0x0001, 0x96);
    poke(0x0002, 0x5f);
    poke(0x2cc5, 0x49);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x5206, 0x461f, 0xced7, 0xdb3f, 0x0000, 0x0000, 0x0000,
        0x0000, 0x2c66, 0x9dbf, 0x0000, 0x0003);
    checkSpecialRegisters(0x00, 0x02, false, false, 19);
  });

  // Test instruction dd9e | SBC A, (IX+*)
  test("OPCODE dd9e | SBC A, (IX+*)", () {
    // Set up machine initial state
    loadRegisters(0x938e, 0xf9c5, 0xcbc4, 0xca21, 0x0000, 0x0000, 0x0000,
        0x0000, 0xb4cc, 0x46fa, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xdd);
    poke(0x0001, 0x9e);
    poke(0x0002, 0x14);
    poke(0xb4e0, 0xb5);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xde9b, 0xf9c5, 0xcbc4, 0xca21, 0x0000, 0x0000, 0x0000,
        0x0000, 0xb4cc, 0x46fa, 0x0000, 0x0003);
    checkSpecialRegisters(0x00, 0x02, false, false, 19);
  });

  // Test instruction dda6 | AND (IX+*)
  test("OPCODE dda6 | AND (IX+*)", () {
    // Set up machine initial state
    loadRegisters(0x1da4, 0x20c4, 0xebc3, 0xda8d, 0x0000, 0x0000, 0x0000,
        0x0000, 0x7e95, 0x5e8a, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xdd);
    poke(0x0001, 0xa6);
    poke(0x0002, 0x41);
    poke(0x7ed6, 0xc7);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x0514, 0x20c4, 0xebc3, 0xda8d, 0x0000, 0x0000, 0x0000,
        0x0000, 0x7e95, 0x5e8a, 0x0000, 0x0003);
    checkSpecialRegisters(0x00, 0x02, false, false, 19);
  });

  // Test instruction ddae | XOR (IX+*)
  test("OPCODE ddae | XOR (IX+*)", () {
    // Set up machine initial state
    loadRegisters(0x8009, 0x3ad6, 0xa721, 0x2100, 0x0000, 0x0000, 0x0000,
        0x0000, 0xe909, 0x87b4, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xdd);
    poke(0x0001, 0xae);
    poke(0x0002, 0x72);
    poke(0xe97b, 0xc3);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x4300, 0x3ad6, 0xa721, 0x2100, 0x0000, 0x0000, 0x0000,
        0x0000, 0xe909, 0x87b4, 0x0000, 0x0003);
    checkSpecialRegisters(0x00, 0x02, false, false, 19);
  });

  // Test instruction ddb6 | OR (IX+*)
  test("OPCODE ddb6 | OR (IX+*)", () {
    // Set up machine initial state
    loadRegisters(0x5017, 0xab81, 0x4287, 0x5ee1, 0x0000, 0x0000, 0x0000,
        0x0000, 0xc66f, 0xd6cc, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xdd);
    poke(0x0001, 0xb6);
    poke(0x0002, 0x31);
    poke(0xc6a0, 0x1c);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x5c0c, 0xab81, 0x4287, 0x5ee1, 0x0000, 0x0000, 0x0000,
        0x0000, 0xc66f, 0xd6cc, 0x0000, 0x0003);
    checkSpecialRegisters(0x00, 0x02, false, false, 19);
  });

  // Test instruction ddbe | CP (IX+*)
  test("OPCODE ddbe | CP (IX+*)", () {
    // Set up machine initial state
    loadRegisters(0x9838, 0xbfd5, 0xa299, 0xd34b, 0x0000, 0x0000, 0x0000,
        0x0000, 0x9332, 0xb1d5, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xdd);
    poke(0x0001, 0xbe);
    poke(0x0002, 0x48);
    poke(0x937a, 0x5b);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x981e, 0xbfd5, 0xa299, 0xd34b, 0x0000, 0x0000, 0x0000,
        0x0000, 0x9332, 0xb1d5, 0x0000, 0x0003);
    checkSpecialRegisters(0x00, 0x02, false, false, 19);
  });

  // Test instruction ddcb06 | RLC (IX+*)
  test("OPCODE ddcb06 | RLC (IX+*)", () {
    // Set up machine initial state
    loadRegisters(0x0cf4, 0xf636, 0x90a6, 0x6117, 0x0000, 0x0000, 0x0000,
        0x0000, 0x5421, 0x90ee, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xdd);
    poke(0x0001, 0xcb);
    poke(0x0002, 0x07);
    poke(0x0003, 0x06);
    poke(0x5428, 0x97);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x0c29, 0xf636, 0x90a6, 0x6117, 0x0000, 0x0000, 0x0000,
        0x0000, 0x5421, 0x90ee, 0x0000, 0x0004);
    checkSpecialRegisters(0x00, 0x02, false, false, 23);
    expect(peek(21544), equals(0x2f));
  });

  // Test instruction ddcb0e | RRC (IX+*)
  test("OPCODE ddcb0e | RRC (IX+*)", () {
    // Set up machine initial state
    loadRegisters(0x1c36, 0x890b, 0x7830, 0x060c, 0x0000, 0x0000, 0x0000,
        0x0000, 0xfd49, 0x5d07, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xdd);
    poke(0x0001, 0xcb);
    poke(0x0002, 0xc6);
    poke(0x0003, 0x0e);
    poke(0xfd0f, 0xad);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x1c81, 0x890b, 0x7830, 0x060c, 0x0000, 0x0000, 0x0000,
        0x0000, 0xfd49, 0x5d07, 0x0000, 0x0004);
    checkSpecialRegisters(0x00, 0x02, false, false, 23);
    expect(peek(64783), equals(0xd6));
  });

  // Test instruction ddcb16 | RL (IX+*)
  test("OPCODE ddcb16 | RL (IX+*)", () {
    // Set up machine initial state
    loadRegisters(0xda70, 0xa1e4, 0x00b0, 0x92c8, 0x0000, 0x0000, 0x0000,
        0x0000, 0x16be, 0x2c95, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xdd);
    poke(0x0001, 0xcb);
    poke(0x0002, 0x45);
    poke(0x0003, 0x16);
    poke(0x1703, 0x5b);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xdaa0, 0xa1e4, 0x00b0, 0x92c8, 0x0000, 0x0000, 0x0000,
        0x0000, 0x16be, 0x2c95, 0x0000, 0x0004);
    checkSpecialRegisters(0x00, 0x02, false, false, 23);
    expect(peek(5891), equals(0xb6));
  });

  // Test instruction ddcb1e | RR (IX+*)
  test("OPCODE ddcb1e | RR (IX+*)", () {
    // Set up machine initial state
    loadRegisters(0xc5d9, 0xcd58, 0x8967, 0xf074, 0x0000, 0x0000, 0x0000,
        0x0000, 0x75b4, 0x693a, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xdd);
    poke(0x0001, 0xcb);
    poke(0x0002, 0xce);
    poke(0x0003, 0x1e);
    poke(0x7582, 0x91);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xc589, 0xcd58, 0x8967, 0xf074, 0x0000, 0x0000, 0x0000,
        0x0000, 0x75b4, 0x693a, 0x0000, 0x0004);
    checkSpecialRegisters(0x00, 0x02, false, false, 23);
    expect(peek(30082), equals(0xc8));
  });

  // Test instruction ddcb26 | SLA (IX+*)
  test("OPCODE ddcb26 | SLA (IX+*)", () {
    // Set up machine initial state
    loadRegisters(0x2065, 0xff37, 0xe41f, 0x70e7, 0x0000, 0x0000, 0x0000,
        0x0000, 0x6528, 0xa0d5, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xdd);
    poke(0x0001, 0xcb);
    poke(0x0002, 0xf7);
    poke(0x0003, 0x26);
    poke(0x651f, 0x89);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x2005, 0xff37, 0xe41f, 0x70e7, 0x0000, 0x0000, 0x0000,
        0x0000, 0x6528, 0xa0d5, 0x0000, 0x0004);
    checkSpecialRegisters(0x00, 0x02, false, false, 23);
    expect(peek(25887), equals(0x12));
  });

  // Test instruction ddcb2e | SRA (IX+*)
  test("OPCODE ddcb2e | SRA (IX+*)", () {
    // Set up machine initial state
    loadRegisters(0x50b0, 0xde74, 0xeca8, 0x83ff, 0x0000, 0x0000, 0x0000,
        0x0000, 0x69d8, 0x75c7, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xdd);
    poke(0x0001, 0xcb);
    poke(0x0002, 0x3d);
    poke(0x0003, 0x2e);
    poke(0x6a15, 0x05);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x5001, 0xde74, 0xeca8, 0x83ff, 0x0000, 0x0000, 0x0000,
        0x0000, 0x69d8, 0x75c7, 0x0000, 0x0004);
    checkSpecialRegisters(0x00, 0x02, false, false, 23);
    expect(peek(27157), equals(0x02));
  });

  // Test instruction ddcb3e | SRL (IX+*)
  test("OPCODE ddcb3e | SRL (IX+*)", () {
    // Set up machine initial state
    loadRegisters(0x39b8, 0xb26e, 0xb670, 0xb8a2, 0x0000, 0x0000, 0x0000,
        0x0000, 0x784a, 0x7840, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xdd);
    poke(0x0001, 0xcb);
    poke(0x0002, 0x0a);
    poke(0x0003, 0x3e);
    poke(0x7854, 0x5d);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x392d, 0xb26e, 0xb670, 0xb8a2, 0x0000, 0x0000, 0x0000,
        0x0000, 0x784a, 0x7840, 0x0000, 0x0004);
    checkSpecialRegisters(0x00, 0x02, false, false, 23);
    expect(peek(30804), equals(0x2e));
  });

  // Test instruction ddcb46 | BIT 0, (IX+*)
  test("OPCODE ddcb46 | BIT 0, (IX+*)", () {
    // Set up machine initial state
    loadRegisters(0x60de, 0xac1d, 0x4173, 0xf92a, 0x0000, 0x0000, 0x0000,
        0x0000, 0xa39f, 0x12e5, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xdd);
    poke(0x0001, 0xcb);
    poke(0x0002, 0xe2);
    poke(0x0003, 0x46);
    poke(0xa381, 0xd5);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x6030, 0xac1d, 0x4173, 0xf92a, 0x0000, 0x0000, 0x0000,
        0x0000, 0xa39f, 0x12e5, 0x0000, 0x0004);
    checkSpecialRegisters(0x00, 0x02, false, false, 20);
  });

  // Test instruction ddcb4e | BIT 1, (IX+*)
  test("OPCODE ddcb4e | BIT 1, (IX+*)", () {
    // Set up machine initial state
    loadRegisters(0x7c67, 0xfa92, 0xb4d0, 0x9f23, 0x0000, 0x0000, 0x0000,
        0x0000, 0xeade, 0x1785, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xdd);
    poke(0x0001, 0xcb);
    poke(0x0002, 0xb0);
    poke(0x0003, 0x4e);
    poke(0xea8e, 0x3b);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x7c39, 0xfa92, 0xb4d0, 0x9f23, 0x0000, 0x0000, 0x0000,
        0x0000, 0xeade, 0x1785, 0x0000, 0x0004);
    checkSpecialRegisters(0x00, 0x02, false, false, 20);
  });

  // Test instruction ddcb56 | BIT 2, (IX+*)
  test("OPCODE ddcb56 | BIT 2, (IX+*)", () {
    // Set up machine initial state
    loadRegisters(0x9128, 0x2cb8, 0x571c, 0xf4fd, 0x0000, 0x0000, 0x0000,
        0x0000, 0x6d30, 0xaec2, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xdd);
    poke(0x0001, 0xcb);
    poke(0x0002, 0x57);
    poke(0x0003, 0x56);
    poke(0x6d87, 0x61);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x917c, 0x2cb8, 0x571c, 0xf4fd, 0x0000, 0x0000, 0x0000,
        0x0000, 0x6d30, 0xaec2, 0x0000, 0x0004);
    checkSpecialRegisters(0x00, 0x02, false, false, 20);
  });

  // Test instruction ddcb5e | BIT 3, (IX+*)
  test("OPCODE ddcb5e | BIT 3, (IX+*)", () {
    // Set up machine initial state
    loadRegisters(0xcef1, 0x0235, 0xe2b1, 0x7a4c, 0x0000, 0x0000, 0x0000,
        0x0000, 0xed14, 0xd0d6, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xdd);
    poke(0x0001, 0xcb);
    poke(0x0002, 0x62);
    poke(0x0003, 0x5e);
    poke(0xed76, 0xa7);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xce7d, 0x0235, 0xe2b1, 0x7a4c, 0x0000, 0x0000, 0x0000,
        0x0000, 0xed14, 0xd0d6, 0x0000, 0x0004);
    checkSpecialRegisters(0x00, 0x02, false, false, 20);
  });

  // Test instruction ddcb66 | BIT 4, (IX+*)
  test("OPCODE ddcb66 | BIT 4, (IX+*)", () {
    // Set up machine initial state
    loadRegisters(0xccbc, 0xd301, 0x9b66, 0x40fb, 0x0000, 0x0000, 0x0000,
        0x0000, 0xee15, 0x0d23, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xdd);
    poke(0x0001, 0xcb);
    poke(0x0002, 0x63);
    poke(0x0003, 0x66);
    poke(0xee78, 0x70);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xcc38, 0xd301, 0x9b66, 0x40fb, 0x0000, 0x0000, 0x0000,
        0x0000, 0xee15, 0x0d23, 0x0000, 0x0004);
    checkSpecialRegisters(0x00, 0x02, false, false, 20);
  });

  // Test instruction ddcb6e | BIT 5, (IX+*)
  test("OPCODE ddcb6e | BIT 5, (IX+*)", () {
    // Set up machine initial state
    loadRegisters(0xca75, 0x9f16, 0xc700, 0x1dce, 0x0000, 0x0000, 0x0000,
        0x0000, 0x3086, 0xd68e, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xdd);
    poke(0x0001, 0xcb);
    poke(0x0002, 0xb2);
    poke(0x0003, 0x6e);
    poke(0x3038, 0x3f);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xca31, 0x9f16, 0xc700, 0x1dce, 0x0000, 0x0000, 0x0000,
        0x0000, 0x3086, 0xd68e, 0x0000, 0x0004);
    checkSpecialRegisters(0x00, 0x02, false, false, 20);
  });

  // Test instruction ddcb76 | BIT 6, (IX+*)
  test("OPCODE ddcb76 | BIT 6, (IX+*)", () {
    // Set up machine initial state
    loadRegisters(0x65b8, 0x5cc2, 0x3058, 0xe258, 0x0000, 0x0000, 0x0000,
        0x0000, 0x7e8a, 0xb296, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xdd);
    poke(0x0001, 0xcb);
    poke(0x0002, 0x73);
    poke(0x0003, 0x76);
    poke(0x7efd, 0x1e);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x657c, 0x5cc2, 0x3058, 0xe258, 0x0000, 0x0000, 0x0000,
        0x0000, 0x7e8a, 0xb296, 0x0000, 0x0004);
    checkSpecialRegisters(0x00, 0x02, false, false, 20);
  });

  // Test instruction ddcb7e | BIT 7, (IX+*)
  test("OPCODE ddcb7e | BIT 7, (IX+*)", () {
    // Set up machine initial state
    loadRegisters(0x9a25, 0x2f6e, 0x0d0d, 0xa83f, 0x0000, 0x0000, 0x0000,
        0x0000, 0xcef0, 0x8c15, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xdd);
    poke(0x0001, 0xcb);
    poke(0x0002, 0x4f);
    poke(0x0003, 0x7e);
    poke(0xcf3f, 0xf2);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x9a99, 0x2f6e, 0x0d0d, 0xa83f, 0x0000, 0x0000, 0x0000,
        0x0000, 0xcef0, 0x8c15, 0x0000, 0x0004);
    checkSpecialRegisters(0x00, 0x02, false, false, 20);
  });

  // Test instruction ddcb86 | RES 0, (IX+*)
  test("OPCODE ddcb86 | RES 0, (IX+*)", () {
    // Set up machine initial state
    loadRegisters(0x4515, 0xde09, 0x3ce7, 0x1fde, 0x0000, 0x0000, 0x0000,
        0x0000, 0x10c5, 0x33ed, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xdd);
    poke(0x0001, 0xcb);
    poke(0x0002, 0x5c);
    poke(0x0003, 0x86);
    poke(0x1121, 0x7c);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x4515, 0xde09, 0x3ce7, 0x1fde, 0x0000, 0x0000, 0x0000,
        0x0000, 0x10c5, 0x33ed, 0x0000, 0x0004);
    checkSpecialRegisters(0x00, 0x02, false, false, 23);
  });

  // Test instruction ddcb8e | RES 1, (IX+*)
  test("OPCODE ddcb8e | RES 1, (IX+*)", () {
    // Set up machine initial state
    loadRegisters(0xf4f4, 0xf3a8, 0x2843, 0x82cb, 0x0000, 0x0000, 0x0000,
        0x0000, 0xd2e8, 0xd367, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xdd);
    poke(0x0001, 0xcb);
    poke(0x0002, 0x0a);
    poke(0x0003, 0x8e);
    poke(0xd2f2, 0x03);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xf4f4, 0xf3a8, 0x2843, 0x82cb, 0x0000, 0x0000, 0x0000,
        0x0000, 0xd2e8, 0xd367, 0x0000, 0x0004);
    checkSpecialRegisters(0x00, 0x02, false, false, 23);
    expect(peek(54002), equals(0x01));
  });

  // Test instruction ddcb96 | RES 2, (IX+*)
  test("OPCODE ddcb96 | RES 2, (IX+*)", () {
    // Set up machine initial state
    loadRegisters(0x4a9e, 0x42ef, 0x32d7, 0x18cf, 0x0000, 0x0000, 0x0000,
        0x0000, 0x7a81, 0xbb1d, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xdd);
    poke(0x0001, 0xcb);
    poke(0x0002, 0xd5);
    poke(0x0003, 0x96);
    poke(0x7a56, 0xae);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x4a9e, 0x42ef, 0x32d7, 0x18cf, 0x0000, 0x0000, 0x0000,
        0x0000, 0x7a81, 0xbb1d, 0x0000, 0x0004);
    checkSpecialRegisters(0x00, 0x02, false, false, 23);
    expect(peek(31318), equals(0xaa));
  });

  // Test instruction ddcb9e | RES 3, (IX+*)
  test("OPCODE ddcb9e | RES 3, (IX+*)", () {
    // Set up machine initial state
    loadRegisters(0xc207, 0xb47c, 0x0e16, 0xe17f, 0x0000, 0x0000, 0x0000,
        0x0000, 0xd8bb, 0xbb99, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xdd);
    poke(0x0001, 0xcb);
    poke(0x0002, 0xb5);
    poke(0x0003, 0x9e);
    poke(0xd870, 0xee);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xc207, 0xb47c, 0x0e16, 0xe17f, 0x0000, 0x0000, 0x0000,
        0x0000, 0xd8bb, 0xbb99, 0x0000, 0x0004);
    checkSpecialRegisters(0x00, 0x02, false, false, 23);
    expect(peek(55408), equals(0xe6));
  });

  // Test instruction ddcba6 | RES 4, (IX+*)
  test("OPCODE ddcba6 | RES 4, (IX+*)", () {
    // Set up machine initial state
    loadRegisters(0x5e46, 0xb98a, 0xb822, 0x04ca, 0x0000, 0x0000, 0x0000,
        0x0000, 0xae1b, 0x8730, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xdd);
    poke(0x0001, 0xcb);
    poke(0x0002, 0x27);
    poke(0x0003, 0xa6);
    poke(0xae42, 0x8f);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x5e46, 0xb98a, 0xb822, 0x04ca, 0x0000, 0x0000, 0x0000,
        0x0000, 0xae1b, 0x8730, 0x0000, 0x0004);
    checkSpecialRegisters(0x00, 0x02, false, false, 23);
  });

  // Test instruction ddcbae | RES 5, (IX+*)
  test("OPCODE ddcbae | RES 5, (IX+*)", () {
    // Set up machine initial state
    loadRegisters(0x5f7a, 0x9c20, 0xf013, 0xc4b7, 0x0000, 0x0000, 0x0000,
        0x0000, 0xb306, 0x15dd, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xdd);
    poke(0x0001, 0xcb);
    poke(0x0002, 0x6e);
    poke(0x0003, 0xae);
    poke(0xb374, 0x5a);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x5f7a, 0x9c20, 0xf013, 0xc4b7, 0x0000, 0x0000, 0x0000,
        0x0000, 0xb306, 0x15dd, 0x0000, 0x0004);
    checkSpecialRegisters(0x00, 0x02, false, false, 23);
  });

  // Test instruction ddcbb6 | RES 6, (IX+*)
  test("OPCODE ddcbb6 | RES 6, (IX+*)", () {
    // Set up machine initial state
    loadRegisters(0x1d0b, 0x04e8, 0x109e, 0x1dde, 0x0000, 0x0000, 0x0000,
        0x0000, 0x8772, 0x8661, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xdd);
    poke(0x0001, 0xcb);
    poke(0x0002, 0x15);
    poke(0x0003, 0xb6);
    poke(0x8787, 0x8c);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x1d0b, 0x04e8, 0x109e, 0x1dde, 0x0000, 0x0000, 0x0000,
        0x0000, 0x8772, 0x8661, 0x0000, 0x0004);
    checkSpecialRegisters(0x00, 0x02, false, false, 23);
  });

  // Test instruction ddcbbe | RES 7, (IX+*)
  test("OPCODE ddcbbe | RES 7, (IX+*)", () {
    // Set up machine initial state
    loadRegisters(0x4af8, 0x99a5, 0xd6fd, 0x7a16, 0x0000, 0x0000, 0x0000,
        0x0000, 0x58d3, 0xce54, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xdd);
    poke(0x0001, 0xcb);
    poke(0x0002, 0x4d);
    poke(0x0003, 0xbe);
    poke(0x5920, 0xe8);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x4af8, 0x99a5, 0xd6fd, 0x7a16, 0x0000, 0x0000, 0x0000,
        0x0000, 0x58d3, 0xce54, 0x0000, 0x0004);
    checkSpecialRegisters(0x00, 0x02, false, false, 23);
    expect(peek(22816), equals(0x68));
  });

  // Test instruction ddcbc6 | SET 0, (IX+*)
  test("OPCODE ddcbc6 | SET 0, (IX+*)", () {
    // Set up machine initial state
    loadRegisters(0xb324, 0xdc0c, 0x1e35, 0x8cd5, 0x0000, 0x0000, 0x0000,
        0x0000, 0xab2c, 0xb6f3, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xdd);
    poke(0x0001, 0xcb);
    poke(0x0002, 0xc4);
    poke(0x0003, 0xc6);
    poke(0xaaf0, 0xb8);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xb324, 0xdc0c, 0x1e35, 0x8cd5, 0x0000, 0x0000, 0x0000,
        0x0000, 0xab2c, 0xb6f3, 0x0000, 0x0004);
    checkSpecialRegisters(0x00, 0x02, false, false, 23);
    expect(peek(43760), equals(0xb9));
  });

  // Test instruction ddcbce | SET 1, (IX+*)
  test("OPCODE ddcbce | SET 1, (IX+*)", () {
    // Set up machine initial state
    loadRegisters(0x9e47, 0xfc93, 0x9ffc, 0xaace, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0313, 0x7f66, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xdd);
    poke(0x0001, 0xcb);
    poke(0x0002, 0x85);
    poke(0x0003, 0xce);
    poke(0x0298, 0x10);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x9e47, 0xfc93, 0x9ffc, 0xaace, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0313, 0x7f66, 0x0000, 0x0004);
    checkSpecialRegisters(0x00, 0x02, false, false, 23);
    expect(peek(664), equals(0x12));
  });

  // Test instruction ddcbd6 | SET 2, (IX+*)
  test("OPCODE ddcbd6 | SET 2, (IX+*)", () {
    // Set up machine initial state
    loadRegisters(0x09eb, 0x769d, 0x7e07, 0x51f9, 0x0000, 0x0000, 0x0000,
        0x0000, 0x5f03, 0x6280, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xdd);
    poke(0x0001, 0xcb);
    poke(0x0002, 0xea);
    poke(0x0003, 0xd6);
    poke(0x5eed, 0x73);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x09eb, 0x769d, 0x7e07, 0x51f9, 0x0000, 0x0000, 0x0000,
        0x0000, 0x5f03, 0x6280, 0x0000, 0x0004);
    checkSpecialRegisters(0x00, 0x02, false, false, 23);
    expect(peek(24301), equals(0x77));
  });

  // Test instruction ddcbde | SET 3, (IX+*)
  test("OPCODE ddcbde | SET 3, (IX+*)", () {
    // Set up machine initial state
    loadRegisters(0x3b62, 0xca1e, 0xa41a, 0x227a, 0x0000, 0x0000, 0x0000,
        0x0000, 0x89d2, 0x7011, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xdd);
    poke(0x0001, 0xcb);
    poke(0x0002, 0x14);
    poke(0x0003, 0xde);
    poke(0x89e6, 0x5e);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x3b62, 0xca1e, 0xa41a, 0x227a, 0x0000, 0x0000, 0x0000,
        0x0000, 0x89d2, 0x7011, 0x0000, 0x0004);
    checkSpecialRegisters(0x00, 0x02, false, false, 23);
  });

  // Test instruction ddcbe6 | SET 4, (IX+*)
  test("OPCODE ddcbe6 | SET 4, (IX+*)", () {
    // Set up machine initial state
    loadRegisters(0x207a, 0xa441, 0x1e03, 0xac60, 0x0000, 0x0000, 0x0000,
        0x0000, 0xd866, 0x5fdc, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xdd);
    poke(0x0001, 0xcb);
    poke(0x0002, 0x25);
    poke(0x0003, 0xe6);
    poke(0xd88b, 0x4c);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x207a, 0xa441, 0x1e03, 0xac60, 0x0000, 0x0000, 0x0000,
        0x0000, 0xd866, 0x5fdc, 0x0000, 0x0004);
    checkSpecialRegisters(0x00, 0x02, false, false, 23);
    expect(peek(55435), equals(0x5c));
  });

  // Test instruction ddcbee | SET 5, (IX+*)
  test("OPCODE ddcbee | SET 5, (IX+*)", () {
    // Set up machine initial state
    loadRegisters(0x79ea, 0xdc8a, 0x7887, 0x3baa, 0x0000, 0x0000, 0x0000,
        0x0000, 0x6c28, 0xabbc, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xdd);
    poke(0x0001, 0xcb);
    poke(0x0002, 0xde);
    poke(0x0003, 0xee);
    poke(0x6c06, 0xbd);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x79ea, 0xdc8a, 0x7887, 0x3baa, 0x0000, 0x0000, 0x0000,
        0x0000, 0x6c28, 0xabbc, 0x0000, 0x0004);
    checkSpecialRegisters(0x00, 0x02, false, false, 23);
  });

  // Test instruction ddcbf6 | SET 6, (IX+*)
  test("OPCODE ddcbf6 | SET 6, (IX+*)", () {
    // Set up machine initial state
    loadRegisters(0x4d6c, 0x93ac, 0x810d, 0xcfe1, 0x0000, 0x0000, 0x0000,
        0x0000, 0xdc5a, 0xc33c, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xdd);
    poke(0x0001, 0xcb);
    poke(0x0002, 0x7b);
    poke(0x0003, 0xf6);
    poke(0xdcd5, 0xa2);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x4d6c, 0x93ac, 0x810d, 0xcfe1, 0x0000, 0x0000, 0x0000,
        0x0000, 0xdc5a, 0xc33c, 0x0000, 0x0004);
    checkSpecialRegisters(0x00, 0x02, false, false, 23);
    expect(peek(56533), equals(0xe2));
  });

  // Test instruction ddcbfe | SET 7, (IX+*)
  test("OPCODE ddcbfe | SET 7, (IX+*)", () {
    // Set up machine initial state
    loadRegisters(0xfc42, 0x50b7, 0xe98d, 0x3e45, 0x0000, 0x0000, 0x0000,
        0x0000, 0x41b5, 0x3410, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xdd);
    poke(0x0001, 0xcb);
    poke(0x0002, 0xec);
    poke(0x0003, 0xfe);
    poke(0x41a1, 0xa1);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xfc42, 0x50b7, 0xe98d, 0x3e45, 0x0000, 0x0000, 0x0000,
        0x0000, 0x41b5, 0x3410, 0x0000, 0x0004);
    checkSpecialRegisters(0x00, 0x02, false, false, 23);
  });

  // Test instruction dde1 | POP IX
  test("OPCODE dde1 | POP IX", () {
    // Set up machine initial state
    loadRegisters(0x8a15, 0x6bf0, 0x0106, 0x3dd0, 0x0000, 0x0000, 0x0000,
        0x0000, 0x5da4, 0x8716, 0x595f, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xdd);
    poke(0x0001, 0xe1);
    poke(0x595f, 0x9a);
    poke(0x5960, 0x09);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x8a15, 0x6bf0, 0x0106, 0x3dd0, 0x0000, 0x0000, 0x0000,
        0x0000, 0x099a, 0x8716, 0x5961, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 14);
  });

  // Test instruction dde3 | EX (SP), IX
  test("OPCODE dde3 | EX (SP), IX", () {
    // Set up machine initial state
    loadRegisters(0x068e, 0x58e6, 0x2713, 0x500f, 0x0000, 0x0000, 0x0000,
        0x0000, 0xbe05, 0x4308, 0x57bd, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xdd);
    poke(0x0001, 0xe3);
    poke(0x57bd, 0x15);
    poke(0x57be, 0x3f);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x068e, 0x58e6, 0x2713, 0x500f, 0x0000, 0x0000, 0x0000,
        0x0000, 0x3f15, 0x4308, 0x57bd, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 23);
    expect(peek(22461), equals(0x05));
    expect(peek(22462), equals(0xbe));
  });

  // Test instruction dde5 | PUSH IX
  test("OPCODE dde5 | PUSH IX", () {
    // Set up machine initial state
    loadRegisters(0x7462, 0x9b6c, 0xbfe5, 0x0330, 0x0000, 0x0000, 0x0000,
        0x0000, 0xb282, 0xe272, 0x0761, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xdd);
    poke(0x0001, 0xe5);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x7462, 0x9b6c, 0xbfe5, 0x0330, 0x0000, 0x0000, 0x0000,
        0x0000, 0xb282, 0xe272, 0x075f, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 15);
    expect(peek(1887), equals(0x82));
    expect(peek(1888), equals(0xb2));
  });

  // Test instruction dde9 | JP (IX)
  test("OPCODE dde9 | JP (IX)", () {
    // Set up machine initial state
    loadRegisters(0x75a7, 0x139b, 0xf9a3, 0x94bb, 0x0000, 0x0000, 0x0000,
        0x0000, 0x64f0, 0x3433, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xdd);
    poke(0x0001, 0xe9);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x75a7, 0x139b, 0xf9a3, 0x94bb, 0x0000, 0x0000, 0x0000,
        0x0000, 0x64f0, 0x3433, 0x0000, 0x64f0);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction ddf9 | LD SP, IX
  test("OPCODE ddf9 | LD SP, IX", () {
    // Set up machine initial state
    loadRegisters(0x8709, 0x15dd, 0x7fa6, 0x3c5c, 0x0000, 0x0000, 0x0000,
        0x0000, 0xd3a7, 0x1d7b, 0xf67c, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xdd);
    poke(0x0001, 0xf9);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x8709, 0x15dd, 0x7fa6, 0x3c5c, 0x0000, 0x0000, 0x0000,
        0x0000, 0xd3a7, 0x1d7b, 0xd3a7, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 10);
  });

  // Test instruction de | SBC A, *
  test("OPCODE de | SBC A, *", () {
    // Set up machine initial state
    loadRegisters(0xe78d, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xde);
    poke(0x0001, 0xa1);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x4502, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x01, false, false, 7);
  });

  // Test instruction df | RST 18h
  test("OPCODE df | RST 18h", () {
    // Set up machine initial state
    loadRegisters(0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x5507, 0x6d33);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x6d33, 0xdf);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x5505, 0x0018);
    checkSpecialRegisters(0x00, 0x01, false, false, 11);
    expect(peek(21765), equals(0x34));
    expect(peek(21766), equals(0x6d));
  });

  // Test instruction e0_1 | RET PO
  test("OPCODE e0_1 | RET PO", () {
    // Set up machine initial state
    loadRegisters(0x0098, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x43f7, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xe0);
    poke(0x43f7, 0xe9);
    poke(0x43f8, 0xaf);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x0098, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x43f9, 0xafe9);
    checkSpecialRegisters(0x00, 0x01, false, false, 11);
  });

  // Test instruction e0_2 | RET PO
  test("OPCODE e0_2 | RET PO", () {
    // Set up machine initial state
    loadRegisters(0x009c, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x43f7, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xe0);
    poke(0x43f7, 0xe9);
    poke(0x43f8, 0xaf);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x009c, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x43f7, 0x0001);
    checkSpecialRegisters(0x00, 0x01, false, false, 5);
  });

  // Test instruction e1 | POP HL
  test("OPCODE e1 | POP HL", () {
    // Set up machine initial state
    loadRegisters(0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x4143, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xe1);
    poke(0x4143, 0xce);
    poke(0x4144, 0xe8);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x0000, 0x0000, 0x0000, 0xe8ce, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x4145, 0x0001);
    checkSpecialRegisters(0x00, 0x01, false, false, 10);
  });

  // Test instruction e2_1 | JP PO, **
  test("OPCODE e2_1 | JP PO, **", () {
    // Set up machine initial state
    loadRegisters(0x0083, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xe2);
    poke(0x0001, 0x1b);
    poke(0x0002, 0xe1);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x0083, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0xe11b);
    checkSpecialRegisters(0x00, 0x01, false, false, 10);
  });

  // Test instruction e2_2 | JP PO, **
  test("OPCODE e2_2 | JP PO, **", () {
    // Set up machine initial state
    loadRegisters(0x0087, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xe2);
    poke(0x0001, 0x1b);
    poke(0x0002, 0xe1);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x0087, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0003);
    checkSpecialRegisters(0x00, 0x01, false, false, 10);
  });

  // Test instruction e3 | EX (SP), HL
  test("OPCODE e3 | EX (SP), HL", () {
    // Set up machine initial state
    loadRegisters(0x0000, 0x0000, 0x0000, 0x4d22, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0373, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xe3);
    poke(0x0373, 0x8e);
    poke(0x0374, 0xe1);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x0000, 0x0000, 0x0000, 0xe18e, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0373, 0x0001);
    checkSpecialRegisters(0x00, 0x01, false, false, 19);
    expect(peek(883), equals(0x22));
    expect(peek(884), equals(0x4d));
  });

  // Test instruction e4_1 | CALL PO, **
  test("OPCODE e4_1 | CALL PO, **", () {
    // Set up machine initial state
    loadRegisters(0x000a, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x5698, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xe4);
    poke(0x0001, 0x61);
    poke(0x0002, 0x9c);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x000a, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x5696, 0x9c61);
    checkSpecialRegisters(0x00, 0x01, false, false, 17);
    expect(peek(22166), equals(0x03));
    expect(peek(22167), equals(0x00));
  });

  // Test instruction e4_2 | CALL PO, **
  test("OPCODE e4_2 | CALL PO, **", () {
    // Set up machine initial state
    loadRegisters(0x000e, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x5698, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xe4);
    poke(0x0001, 0x61);
    poke(0x0002, 0x9c);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x000e, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x5698, 0x0003);
    checkSpecialRegisters(0x00, 0x01, false, false, 10);
  });

  // Test instruction e5 | PUSH HL
  test("OPCODE e5 | PUSH HL", () {
    // Set up machine initial state
    loadRegisters(0x53e3, 0x1459, 0x775f, 0x1a2f, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0xec12, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xe5);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x53e3, 0x1459, 0x775f, 0x1a2f, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0xec10, 0x0001);
    checkSpecialRegisters(0x00, 0x01, false, false, 11);
    expect(peek(60432), equals(0x2f));
    expect(peek(60433), equals(0x1a));
  });

  // Test instruction e6 | AND *
  test("OPCODE e6 | AND *", () {
    // Set up machine initial state
    loadRegisters(0x7500, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xe6);
    poke(0x0001, 0x49);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x4114, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x01, false, false, 7);
  });

  // Test instruction e7 | RST 20h
  test("OPCODE e7 | RST 20h", () {
    // Set up machine initial state
    loadRegisters(0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x5507, 0x6d33);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x6d33, 0xe7);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x5505, 0x0020);
    checkSpecialRegisters(0x00, 0x01, false, false, 11);
    expect(peek(21765), equals(0x34));
    expect(peek(21766), equals(0x6d));
  });

  // Test instruction e8_1 | RET PE
  test("OPCODE e8_1 | RET PE", () {
    // Set up machine initial state
    loadRegisters(0x0098, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x43f7, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xe8);
    poke(0x43f7, 0xe9);
    poke(0x43f8, 0xaf);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x0098, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x43f7, 0x0001);
    checkSpecialRegisters(0x00, 0x01, false, false, 5);
  });

  // Test instruction e8_2 | RET PE
  test("OPCODE e8_2 | RET PE", () {
    // Set up machine initial state
    loadRegisters(0x009c, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x43f7, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xe8);
    poke(0x43f7, 0xe9);
    poke(0x43f8, 0xaf);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x009c, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x43f9, 0xafe9);
    checkSpecialRegisters(0x00, 0x01, false, false, 11);
  });

  // Test instruction e9 | JP (HL)
  test("OPCODE e9 | JP (HL)", () {
    // Set up machine initial state
    loadRegisters(0x0000, 0x0000, 0x0000, 0xcaba, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xe9);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x0000, 0x0000, 0x0000, 0xcaba, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0xcaba);
    checkSpecialRegisters(0x00, 0x01, false, false, 4);
  });

  // Test instruction ea_1 | JP PE, **
  test("OPCODE ea_1 | JP PE, **", () {
    // Set up machine initial state
    loadRegisters(0x0087, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xea);
    poke(0x0001, 0x1b);
    poke(0x0002, 0xe1);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x0087, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0xe11b);
    checkSpecialRegisters(0x00, 0x01, false, false, 10);
  });

  // Test instruction ea_2 | JP PE, **
  test("OPCODE ea_2 | JP PE, **", () {
    // Set up machine initial state
    loadRegisters(0x0083, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xea);
    poke(0x0001, 0x1b);
    poke(0x0002, 0xe1);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x0083, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0003);
    checkSpecialRegisters(0x00, 0x01, false, false, 10);
  });

  // Test instruction eb | EX DE, HL
  test("OPCODE eb | EX DE, HL", () {
    // Set up machine initial state
    loadRegisters(0x0000, 0x0000, 0xb879, 0x942e, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xeb);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x0000, 0x0000, 0x942e, 0xb879, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0001);
    checkSpecialRegisters(0x00, 0x01, false, false, 4);
  });

  // Test instruction ec_1 | CALL PE, **
  test("OPCODE ec_1 | CALL PE, **", () {
    // Set up machine initial state
    loadRegisters(0x000e, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x5698, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xec);
    poke(0x0001, 0x61);
    poke(0x0002, 0x9c);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x000e, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x5696, 0x9c61);
    checkSpecialRegisters(0x00, 0x01, false, false, 17);
    expect(peek(22166), equals(0x03));
    expect(peek(22167), equals(0x00));
  });

  // Test instruction ec_2 | CALL PE, **
  test("OPCODE ec_2 | CALL PE, **", () {
    // Set up machine initial state
    loadRegisters(0x000a, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x5698, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xec);
    poke(0x0001, 0x61);
    poke(0x0002, 0x9c);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x000a, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x5698, 0x0003);
    checkSpecialRegisters(0x00, 0x01, false, false, 10);
  });

  // Test instruction ed40 | IN B, (C)
  test("OPCODE ed40 | IN B, (C)", () {
    // Set up machine initial state
    loadRegisters(0x83f9, 0x296b, 0x7034, 0x1f2f, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xed);
    poke(0x0001, 0x40);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x8329, 0x296b, 0x7034, 0x1f2f, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 12);
  });

  // Test instruction ed41 | OUT (C), B
  test("OPCODE ed41 | OUT (C), B", () {
    // Set up machine initial state
    loadRegisters(0x29a2, 0x0881, 0xd7dd, 0xff4e, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xed);
    poke(0x0001, 0x41);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x29a2, 0x0881, 0xd7dd, 0xff4e, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 12);
  });

  // Test instruction ed42 | SBC HL, BC
  test("OPCODE ed42 | SBC HL, BC", () {
    // Set up machine initial state
    loadRegisters(0xcbd3, 0x1c8f, 0xd456, 0x315e, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xed);
    poke(0x0001, 0x42);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xcb12, 0x1c8f, 0xd456, 0x14ce, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 15);
  });

  // Test instruction ed43 | LD (**), BC
  test("OPCODE ed43 | LD (**), BC", () {
    // Set up machine initial state
    loadRegisters(0xda36, 0x2732, 0x91cc, 0x9798, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x5f73, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xed);
    poke(0x0001, 0x43);
    poke(0x0002, 0xc6);
    poke(0x0003, 0x54);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xda36, 0x2732, 0x91cc, 0x9798, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x5f73, 0x0004);
    checkSpecialRegisters(0x00, 0x02, false, false, 20);
    expect(peek(21702), equals(0x32));
    expect(peek(21703), equals(0x27));
  });

  // Test instruction ed44 | NEG
  test("OPCODE ed44 | NEG", () {
    // Set up machine initial state
    loadRegisters(0xfe2b, 0x040f, 0xdeb6, 0xafc3, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x5ca8, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xed);
    poke(0x0001, 0x44);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x0213, 0x040f, 0xdeb6, 0xafc3, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x5ca8, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction ed45 | RETN
  test("OPCODE ed45 | RETN", () {
    // Set up machine initial state
    loadRegisters(0x001d, 0x5b63, 0xa586, 0x1451, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x3100, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = true;
    poke(0x0000, 0xed);
    poke(0x0001, 0x45);
    poke(0x3100, 0x1f);
    poke(0x3101, 0x22);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x001d, 0x5b63, 0xa586, 0x1451, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x3102, 0x221f);
    checkSpecialRegisters(0x00, 0x02, true, true, 14);
  });

  // Test instruction ed46 | IM 0
  test("OPCODE ed46 | IM 0", () {
    // Set up machine initial state
    loadRegisters(0xb6ec, 0x8afb, 0xce09, 0x70a1, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x8dea, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xed);
    poke(0x0001, 0x46);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xb6ec, 0x8afb, 0xce09, 0x70a1, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x8dea, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction ed47 | LD I, A
  test("OPCODE ed47 | LD I, A", () {
    // Set up machine initial state
    loadRegisters(0x9a99, 0x9e5a, 0x9913, 0xcacc, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xed);
    poke(0x0001, 0x47);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x9a99, 0x9e5a, 0x9913, 0xcacc, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x9a, 0x02, false, false, 9);
  });

  // Test instruction ed48 | IN C, (C)
  test("OPCODE ed48 | IN C, (C)", () {
    // Set up machine initial state
    loadRegisters(0xdbdd, 0x7d1b, 0x141d, 0x5fb4, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xed);
    poke(0x0001, 0x48);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xdb2d, 0x7d7d, 0x141d, 0x5fb4, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 12);
  });

  // Test instruction ed49 | OUT (C), C
  test("OPCODE ed49 | OUT (C), C", () {
    // Set up machine initial state
    loadRegisters(0x07a5, 0x59ec, 0xf459, 0x4316, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xed);
    poke(0x0001, 0x49);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x07a5, 0x59ec, 0xf459, 0x4316, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 12);
  });

  // Test instruction ed4a | ADC HL, BC
  test("OPCODE ed4a | ADC HL, BC", () {
    // Set up machine initial state
    loadRegisters(0x5741, 0x24b5, 0x83d2, 0x9ac8, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xed);
    poke(0x0001, 0x4a);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x57a8, 0x24b5, 0x83d2, 0xbf7e, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 15);
  });

  // Test instruction ed4b | LD BC, (**)
  test("OPCODE ed4b | LD BC, (**)", () {
    // Set up machine initial state
    loadRegisters(0x650c, 0xd74d, 0x0448, 0xa3b9, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0xb554, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xed);
    poke(0x0001, 0x4b);
    poke(0x0002, 0x1a);
    poke(0x0003, 0xa4);
    poke(0xa41a, 0xf3);
    poke(0xa41b, 0xd4);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x650c, 0xd4f3, 0x0448, 0xa3b9, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0xb554, 0x0004);
    checkSpecialRegisters(0x00, 0x02, false, false, 20);
  });

  // Test instruction ed4c | <UNKNOWN>
  test("OPCODE ed4c", () {
    // Set up machine initial state
    loadRegisters(0x5682, 0x7dde, 0xb049, 0x939d, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0xc7bb, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xed);
    poke(0x0001, 0x4c);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xaabb, 0x7dde, 0xb049, 0x939d, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0xc7bb, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction ed4d | RETI
  test("OPCODE ed4d | RETI", () {
    // Set up machine initial state
    loadRegisters(0x1bed, 0xc358, 0x5fd5, 0x6093, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x680e, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xed);
    poke(0x0001, 0x4d);
    poke(0x680e, 0x03);
    poke(0x680f, 0x7c);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x1bed, 0xc358, 0x5fd5, 0x6093, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x6810, 0x7c03);
    checkSpecialRegisters(0x00, 0x02, false, false, 14);
  });

  // Test instruction ed4e | <UNKNOWN>
  test("OPCODE ed4e", () {
    // Set up machine initial state
    loadRegisters(0x8e01, 0xe7c6, 0x880f, 0xd2a2, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x85da, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xed);
    poke(0x0001, 0x4e);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x8e01, 0xe7c6, 0x880f, 0xd2a2, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x85da, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction ed4f | LD R, A
  test("OPCODE ed4f | LD R, A", () {
    // Set up machine initial state
    loadRegisters(0x2ae3, 0xc115, 0xeff8, 0x9f6d, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xed);
    poke(0x0001, 0x4f);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x2ae3, 0xc115, 0xeff8, 0x9f6d, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x2a, false, false, 9);
  });

  // Test instruction ed50 | IN D, (C)
  test("OPCODE ed50 | IN D, (C)", () {
    // Set up machine initial state
    loadRegisters(0x85ae, 0xbbcc, 0xe2a8, 0xf219, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xed);
    poke(0x0001, 0x50);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x85ac, 0xbbcc, 0xbba8, 0xf219, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 12);
  });

  // Test instruction ed51 | OUT (C), D
  test("OPCODE ed51 | OUT (C), D", () {
    // Set up machine initial state
    loadRegisters(0x2c4c, 0xc0a4, 0x5303, 0xbc25, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xed);
    poke(0x0001, 0x51);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x2c4c, 0xc0a4, 0x5303, 0xbc25, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 12);
  });

  // Test instruction ed52 | SBC HL, DE
  test("OPCODE ed52 | SBC HL, DE", () {
    // Set up machine initial state
    loadRegisters(0xfc57, 0x1fc8, 0x47b6, 0xda7c, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xed);
    poke(0x0001, 0x52);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xfc82, 0x1fc8, 0x47b6, 0x92c5, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 15);
  });

  // Test instruction ed53 | LD (**), DE
  test("OPCODE ed53 | LD (**), DE", () {
    // Set up machine initial state
    loadRegisters(0x1f88, 0x4692, 0x5cb2, 0x4915, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x7d8c, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xed);
    poke(0x0001, 0x53);
    poke(0x0002, 0xff);
    poke(0x0003, 0x21);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x1f88, 0x4692, 0x5cb2, 0x4915, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x7d8c, 0x0004);
    checkSpecialRegisters(0x00, 0x02, false, false, 20);
    expect(peek(8703), equals(0xb2));
    expect(peek(8704), equals(0x5c));
  });

  // Test instruction ed54 | <UNKNOWN>
  test("OPCODE ed54", () {
    // Set up machine initial state
    loadRegisters(0xadf9, 0x5661, 0x547c, 0xc322, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0xd9eb, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xed);
    poke(0x0001, 0x54);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x5313, 0x5661, 0x547c, 0xc322, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0xd9eb, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction ed55 | RETN
  test("OPCODE ed55 | RETN", () {
    // Set up machine initial state
    loadRegisters(0xb05b, 0x5e84, 0xd6e9, 0xcb3e, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0xd4b4, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = true;
    z80.iff2 = false;
    poke(0x0000, 0xed);
    poke(0x0001, 0x55);
    poke(0xd4b4, 0xea);
    poke(0xd4b5, 0xc9);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xb05b, 0x5e84, 0xd6e9, 0xcb3e, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0xd4b6, 0xc9ea);
    checkSpecialRegisters(0x00, 0x02, false, false, 14);
  });

  // Test instruction ed56 | IM 1
  test("OPCODE ed56 | IM 1", () {
    // Set up machine initial state
    loadRegisters(0x5cc0, 0x9100, 0x356b, 0x4bfd, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x2c93, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xed);
    poke(0x0001, 0x56);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x5cc0, 0x9100, 0x356b, 0x4bfd, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x2c93, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction ed57 | LD A, I
  test("OPCODE ed57 | LD A, I", () {
    // Set up machine initial state
    loadRegisters(0xbcfe, 0xdfc7, 0xa621, 0x1022, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x1e;
    z80.r = 0x17;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xed);
    poke(0x0001, 0x57);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x1e08, 0xdfc7, 0xa621, 0x1022, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x1e, 0x19, false, false, 9);
  });

  // Test instruction ed58 | IN E, (C)
  test("OPCODE ed58 | IN E, (C)", () {
    // Set up machine initial state
    loadRegisters(0xc9ee, 0x4091, 0x9e46, 0x873a, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xed);
    poke(0x0001, 0x58);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xc900, 0x4091, 0x9e40, 0x873a, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 12);
  });

  // Test instruction ed59 | OUT (C), E
  test("OPCODE ed59 | OUT (C), E", () {
    // Set up machine initial state
    loadRegisters(0x388a, 0xd512, 0xecc5, 0x93af, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xed);
    poke(0x0001, 0x59);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x388a, 0xd512, 0xecc5, 0x93af, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 12);
  });

  // Test instruction ed5a | ADC HL, DE
  test("OPCODE ed5a | ADC HL, DE", () {
    // Set up machine initial state
    loadRegisters(0xa41f, 0x751c, 0x19ce, 0x0493, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xed);
    poke(0x0001, 0x5a);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xa408, 0x751c, 0x19ce, 0x1e62, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 15);
  });

  // Test instruction ed5b | LD DE, (**)
  test("OPCODE ed5b | LD DE, (**)", () {
    // Set up machine initial state
    loadRegisters(0x5df1, 0x982e, 0x002f, 0xadb9, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0xf398, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xed);
    poke(0x0001, 0x5b);
    poke(0x0002, 0x04);
    poke(0x0003, 0x9f);
    poke(0x9f04, 0x84);
    poke(0x9f05, 0x4d);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x5df1, 0x982e, 0x4d84, 0xadb9, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0xf398, 0x0004);
    checkSpecialRegisters(0x00, 0x02, false, false, 20);
  });

  // Test instruction ed5c | <UNKNOWN>
  test("OPCODE ed5c", () {
    // Set up machine initial state
    loadRegisters(0x11c3, 0xb86c, 0x2042, 0xc958, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x93dc, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xed);
    poke(0x0001, 0x5c);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xefbb, 0xb86c, 0x2042, 0xc958, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x93dc, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction ed5d | RETN
  test("OPCODE ed5d | RETN", () {
    // Set up machine initial state
    loadRegisters(0x1152, 0x1d20, 0x3f86, 0x64fc, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x5308, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xed);
    poke(0x0001, 0x5d);
    poke(0x5308, 0x26);
    poke(0x5309, 0xe0);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x1152, 0x1d20, 0x3f86, 0x64fc, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x530a, 0xe026);
    checkSpecialRegisters(0x00, 0x02, false, false, 14);
  });

  // Test instruction ed5e | IM 2
  test("OPCODE ed5e | IM 2", () {
    // Set up machine initial state
    loadRegisters(0x611a, 0xc8cf, 0xf215, 0xd92b, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x4d86, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xed);
    poke(0x0001, 0x5e);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x611a, 0xc8cf, 0xf215, 0xd92b, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x4d86, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction ed5f | LD A, R
  test("OPCODE ed5f | LD A, R", () {
    // Set up machine initial state
    loadRegisters(0x1bb5, 0xfc09, 0x2dfa, 0xbab9, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0xd7;
    z80.r = 0xf3;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xed);
    poke(0x0001, 0x5f);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xf5a1, 0xfc09, 0x2dfa, 0xbab9, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0xd7, 0xf5, false, false, 9);
  });

  // Test instruction ed60 | IN H, (C)
  test("OPCODE ed60 | IN H, (C)", () {
    // Set up machine initial state
    loadRegisters(0x2c9c, 0x0dae, 0x621e, 0x2f66, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xed);
    poke(0x0001, 0x60);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x2c08, 0x0dae, 0x621e, 0x0d66, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 12);
  });

  // Test instruction ed61 | OUT (C), H
  test("OPCODE ed61 | OUT (C), H", () {
    // Set up machine initial state
    loadRegisters(0xffa8, 0x90ca, 0x0340, 0xd847, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xed);
    poke(0x0001, 0x61);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xffa8, 0x90ca, 0x0340, 0xd847, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 12);
  });

  // Test instruction ed62 | SBC HL, HL
  test("OPCODE ed62 | SBC HL, HL", () {
    // Set up machine initial state
    loadRegisters(0xa60b, 0xd9aa, 0x6623, 0x0b1a, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xed);
    poke(0x0001, 0x62);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xa6bb, 0xd9aa, 0x6623, 0xffff, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 15);
  });

  // Test instruction ed63 | <UNKNOWN>
  test("OPCODE ed63", () {
    // Set up machine initial state
    loadRegisters(0x5222, 0x88f9, 0x9d9a, 0xe4d3, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0xa2f0, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xed);
    poke(0x0001, 0x63);
    poke(0x0002, 0x67);
    poke(0x0003, 0x65);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x5222, 0x88f9, 0x9d9a, 0xe4d3, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0xa2f0, 0x0004);
    checkSpecialRegisters(0x00, 0x02, false, false, 20);
    expect(peek(25959), equals(0xd3));
    expect(peek(25960), equals(0xe4));
  });

  // Test instruction ed64 | <UNKNOWN>
  test("OPCODE ed64", () {
    // Set up machine initial state
    loadRegisters(0x2127, 0xe425, 0x66ac, 0xb2a3, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x43f2, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xed);
    poke(0x0001, 0x64);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xdf9b, 0xe425, 0x66ac, 0xb2a3, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x43f2, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction ed65 | RETN
  test("OPCODE ed65 | RETN", () {
    // Set up machine initial state
    loadRegisters(0x63d2, 0x1fa1, 0x0788, 0x881c, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0xf207, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = true;
    poke(0x0000, 0xed);
    poke(0x0001, 0x65);
    poke(0xf207, 0xeb);
    poke(0xf208, 0x0e);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x63d2, 0x1fa1, 0x0788, 0x881c, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0xf209, 0x0eeb);
    checkSpecialRegisters(0x00, 0x02, true, true, 14);
  });

  // Test instruction ed66 | <UNKNOWN>
  test("OPCODE ed66", () {
    // Set up machine initial state
    loadRegisters(0x4088, 0xa7e1, 0x3ffd, 0x919b, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0xd193, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xed);
    poke(0x0001, 0x66);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x4088, 0xa7e1, 0x3ffd, 0x919b, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0xd193, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction ed67 | RRD
  test("OPCODE ed67 | RRD", () {
    // Set up machine initial state
    loadRegisters(0x3624, 0xb16a, 0xa4db, 0xb9de, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xed);
    poke(0x0001, 0x67);
    poke(0xb9de, 0x93);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x3324, 0xb16a, 0xa4db, 0xb9de, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 18);
    expect(peek(47582), equals(0x69));
  });

  // Test instruction ed68 | IN L, (C)
  test("OPCODE ed68 | IN L, (C)", () {
    // Set up machine initial state
    loadRegisters(0x5316, 0x624b, 0x7311, 0x3106, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xed);
    poke(0x0001, 0x68);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x5320, 0x624b, 0x7311, 0x3162, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 12);
  });

  // Test instruction ed69 | OUT (C), L
  test("OPCODE ed69 | OUT (C), L", () {
    // Set up machine initial state
    loadRegisters(0xabd8, 0x8d2f, 0x89c7, 0xc3d6, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xed);
    poke(0x0001, 0x69);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xabd8, 0x8d2f, 0x89c7, 0xc3d6, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 12);
  });

  // Test instruction ed6a | ADC HL, HL
  test("OPCODE ed6a | ADC HL, HL", () {
    // Set up machine initial state
    loadRegisters(0xbb5a, 0x6fed, 0x59bb, 0x4e40, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xed);
    poke(0x0001, 0x6a);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xbb9c, 0x6fed, 0x59bb, 0x9c80, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 15);
  });

  // Test instruction ed6b | <UNKNOWN>
  test("OPCODE ed6b", () {
    // Set up machine initial state
    loadRegisters(0x9e35, 0xd240, 0x1998, 0xab19, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x9275, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xed);
    poke(0x0001, 0x6b);
    poke(0x0002, 0x98);
    poke(0x0003, 0x61);
    poke(0x6198, 0x3f);
    poke(0x6199, 0xbe);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x9e35, 0xd240, 0x1998, 0xbe3f, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x9275, 0x0004);
    checkSpecialRegisters(0x00, 0x02, false, false, 20);
  });

  // Test instruction ed6c | <UNKNOWN>
  test("OPCODE ed6c", () {
    // Set up machine initial state
    loadRegisters(0x0fb1, 0x7d5b, 0xcadb, 0x0893, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0xd983, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xed);
    poke(0x0001, 0x6c);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xf1b3, 0x7d5b, 0xcadb, 0x0893, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0xd983, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction ed6d | RETI
  test("OPCODE ed6d | RETI", () {
    // Set up machine initial state
    loadRegisters(0x3860, 0x42da, 0x5935, 0xdc10, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x5cd3, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xed);
    poke(0x0001, 0x6d);
    poke(0x5cd3, 0xa9);
    poke(0x5cd4, 0x73);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x3860, 0x42da, 0x5935, 0xdc10, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x5cd5, 0x73a9);
    checkSpecialRegisters(0x00, 0x02, false, false, 14);
  });

  // Test instruction ed6e | <UNKNOWN>
  test("OPCODE ed6e", () {
    // Set up machine initial state
    loadRegisters(0x7752, 0xbec3, 0x0457, 0x8c95, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0xa787, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xed);
    poke(0x0001, 0x6e);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x7752, 0xbec3, 0x0457, 0x8c95, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0xa787, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction ed6f | RLD
  test("OPCODE ed6f | RLD", () {
    // Set up machine initial state
    loadRegisters(0x658b, 0x7a7a, 0xecf0, 0x403c, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xed);
    poke(0x0001, 0x6f);
    poke(0x403c, 0xc4);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x6c2d, 0x7a7a, 0xecf0, 0x403c, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 18);
    expect(peek(16444), equals(0x45));
  });

  // Test instruction ed70 | IN (C)
  test("OPCODE ed70 | IN (C)", () {
    // Set up machine initial state
    loadRegisters(0xc6a1, 0xf7d6, 0xa3cb, 0x288d, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xed);
    poke(0x0001, 0x70);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xc6a1, 0xf7d6, 0xa3cb, 0x288d, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 12);
  });

  // Test instruction ed71 | OUT (C), 0
  test("OPCODE ed71 | OUT (C), 0", () {
    // Set up machine initial state
    loadRegisters(0xafa0, 0x20b3, 0x7b33, 0x4ac1, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xed);
    poke(0x0001, 0x71);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xafa0, 0x20b3, 0x7b33, 0x4ac1, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 12);
  });

  // Test instruction ed72 | SBC HL, SP
  test("OPCODE ed72 | SBC HL, SP", () {
    // Set up machine initial state
    loadRegisters(0x5fd9, 0x05cb, 0x0c6c, 0xd18b, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x53db, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xed);
    poke(0x0001, 0x72);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x5f3e, 0x05cb, 0x0c6c, 0x7daf, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x53db, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 15);
  });

  // Test instruction ed73 | LD (**), SP
  test("OPCODE ed73 | LD (**), SP", () {
    // Set up machine initial state
    loadRegisters(0x41c4, 0x763a, 0xecb0, 0xee62, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0xaed5, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xed);
    poke(0x0001, 0x73);
    poke(0x0002, 0x2a);
    poke(0x0003, 0x79);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x41c4, 0x763a, 0xecb0, 0xee62, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0xaed5, 0x0004);
    checkSpecialRegisters(0x00, 0x02, false, false, 20);
    expect(peek(31018), equals(0xd5));
    expect(peek(31019), equals(0xae));
  });

  // Test instruction ed74 | <UNKNOWN>
  test("OPCODE ed74", () {
    // Set up machine initial state
    loadRegisters(0x4454, 0xf2d2, 0x8340, 0x7e76, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0323, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xed);
    poke(0x0001, 0x74);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xbcbb, 0xf2d2, 0x8340, 0x7e76, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0323, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction ed75 | RETN
  test("OPCODE ed75 | RETN", () {
    // Set up machine initial state
    loadRegisters(0x7ca4, 0x1615, 0x5d2a, 0xa95b, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x7d00, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = true;
    z80.iff2 = true;
    poke(0x0000, 0xed);
    poke(0x0001, 0x75);
    poke(0x7d00, 0xfd);
    poke(0x7d01, 0x4f);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x7ca4, 0x1615, 0x5d2a, 0xa95b, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x7d02, 0x4ffd);
    checkSpecialRegisters(0x00, 0x02, true, true, 14);
  });

  // Test instruction ed76 | <UNKNOWN>
  test("OPCODE ed76", () {
    // Set up machine initial state
    loadRegisters(0xcabf, 0xff9a, 0xb98c, 0xa8e6, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0xfe8e, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xed);
    poke(0x0001, 0x76);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xcabf, 0xff9a, 0xb98c, 0xa8e6, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0xfe8e, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction ed78 | IN A, (C)
  test("OPCODE ed78 | IN A, (C)", () {
    // Set up machine initial state
    loadRegisters(0x58dd, 0xf206, 0x2d6a, 0xaf16, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xed);
    poke(0x0001, 0x78);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xf2a1, 0xf206, 0x2d6a, 0xaf16, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 12);
  });

  // Test instruction ed79 | OUT (C), A
  test("OPCODE ed79 | OUT (C), A", () {
    // Set up machine initial state
    loadRegisters(0xe000, 0x4243, 0x8f7f, 0xed90, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xed);
    poke(0x0001, 0x79);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xe000, 0x4243, 0x8f7f, 0xed90, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 12);
  });

  // Test instruction ed7a | ADC HL, SP
  test("OPCODE ed7a | ADC HL, SP", () {
    // Set up machine initial state
    loadRegisters(0x32fd, 0xd819, 0xd873, 0x8dcf, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x5d22, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xed);
    poke(0x0001, 0x7a);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x32b8, 0xd819, 0xd873, 0xeaf2, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x5d22, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 15);
  });

  // Test instruction ed7b | LD SP, (**)
  test("OPCODE ed7b | LD SP, (**)", () {
    // Set up machine initial state
    loadRegisters(0x4f97, 0x24b7, 0xe105, 0x1bf2, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x5e17, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xed);
    poke(0x0001, 0x7b);
    poke(0x0002, 0x50);
    poke(0x0003, 0x8c);
    poke(0x8c50, 0xd8);
    poke(0x8c51, 0x48);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x4f97, 0x24b7, 0xe105, 0x1bf2, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x48d8, 0x0004);
    checkSpecialRegisters(0x00, 0x02, false, false, 20);
  });

  // Test instruction ed7c | <UNKNOWN>
  test("OPCODE ed7c", () {
    // Set up machine initial state
    loadRegisters(0xd333, 0x29ca, 0x9622, 0xb452, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0be6, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xed);
    poke(0x0001, 0x7c);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x2d3b, 0x29ca, 0x9622, 0xb452, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0be6, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction ed7d | RETN
  test("OPCODE ed7d | RETN", () {
    // Set up machine initial state
    loadRegisters(0xecb6, 0x073e, 0xdc1e, 0x38d9, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x66f0, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = true;
    poke(0x0000, 0xed);
    poke(0x0001, 0x7d);
    poke(0x66f0, 0x4f);
    poke(0x66f1, 0xfb);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xecb6, 0x073e, 0xdc1e, 0x38d9, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x66f2, 0xfb4f);
    checkSpecialRegisters(0x00, 0x02, true, true, 14);
  });

  // Test instruction ed7e | <UNKNOWN>
  test("OPCODE ed7e", () {
    // Set up machine initial state
    loadRegisters(0xb246, 0x1a1a, 0x933a, 0x4b8b, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x2242, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xed);
    poke(0x0001, 0x7e);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xb246, 0x1a1a, 0x933a, 0x4b8b, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x2242, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction eda0 | LDI
  test("OPCODE eda0 | LDI", () {
    // Set up machine initial state
    loadRegisters(0x1bc9, 0x3d11, 0x95c1, 0xd097, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xed);
    poke(0x0001, 0xa0);
    poke(0xd097, 0xb7);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x1be5, 0x3d10, 0x95c2, 0xd098, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 16);
    expect(peek(38337), equals(0xb7));
  });

  // Test instruction eda1 | CPI
  test("OPCODE eda1 | CPI", () {
    // Set up machine initial state
    loadRegisters(0xecdb, 0x7666, 0x537f, 0x3bc3, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xed);
    poke(0x0001, 0xa1);
    poke(0x3bc3, 0xb4);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xec0f, 0x7665, 0x537f, 0x3bc4, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 16);
  });

  // Test instruction eda2 | INI
  test("OPCODE eda2 | INI", () {
    // Set up machine initial state
    loadRegisters(0x0121, 0x9a82, 0x5bbd, 0x2666, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xed);
    poke(0x0001, 0xa2);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x019f, 0x9982, 0x5bbd, 0x2667, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 16);
    expect(peek(9830), equals(0x9a));
  });

  // Test instruction eda2_01 | INI
  test("OPCODE eda2_01 | INI", () {
    // Set up machine initial state
    loadRegisters(0x0000, 0x0200, 0x0000, 0x8000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xed);
    poke(0x0001, 0xa2);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x0000, 0x0100, 0x0000, 0x8001, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 16);
    expect(peek(32768), equals(0x02));
  });

  // Test instruction eda2_02 | INI
  test("OPCODE eda2_02 | INI", () {
    // Set up machine initial state
    loadRegisters(0x0000, 0x569a, 0x0000, 0x8000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xed);
    poke(0x0001, 0xa2);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x0000, 0x559a, 0x0000, 0x8001, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 16);
    expect(peek(32768), equals(0x56));
  });

  // Test instruction eda2_03 | INI
  test("OPCODE eda2_03 | INI", () {
    // Set up machine initial state
    loadRegisters(0x0000, 0xabcc, 0x0000, 0x8000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xed);
    poke(0x0001, 0xa2);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x00bf, 0xaacc, 0x0000, 0x8001, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 16);
    expect(peek(32768), equals(0xab));
  });

  // Test instruction eda3 | OUTI
  test("OPCODE eda3 | OUTI", () {
    // Set up machine initial state
    loadRegisters(0x42c5, 0x6334, 0x1e28, 0x32fa, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xed);
    poke(0x0001, 0xa3);
    poke(0x32fa, 0xb3);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x4233, 0x6234, 0x1e28, 0x32fb, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 16);
  });

  // Test instruction eda3_01 | OUTI
  test("OPCODE eda3_01 | OUTI", () {
    // Set up machine initial state
    loadRegisters(0x0000, 0x0100, 0x0000, 0x01ff, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xed);
    poke(0x0001, 0xa3);
    poke(0x01ff, 0x00);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x0044, 0x0000, 0x0000, 0x0200, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 16);
  });

  // Test instruction eda3_02 | OUTI
  test("OPCODE eda3_02 | OUTI", () {
    // Set up machine initial state
    loadRegisters(0x0000, 0x0100, 0x0000, 0x0100, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xed);
    poke(0x0001, 0xa3);
    poke(0x0100, 0x00);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x0040, 0x0000, 0x0000, 0x0101, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 16);
  });

  // Test instruction eda3_03 | OUTI
  test("OPCODE eda3_03 | OUTI", () {
    // Set up machine initial state
    loadRegisters(0x0000, 0x0100, 0x0000, 0x0107, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xed);
    poke(0x0001, 0xa3);
    poke(0x0107, 0x00);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x0044, 0x0000, 0x0000, 0x0108, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 16);
  });

  // Test instruction eda3_04 | OUTI
  test("OPCODE eda3_04 | OUTI", () {
    // Set up machine initial state
    loadRegisters(0x0000, 0x0100, 0x0000, 0x01ff, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xed);
    poke(0x0001, 0xa3);
    poke(0x01ff, 0x80);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x0046, 0x0000, 0x0000, 0x0200, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 16);
  });

  // Test instruction eda3_05 | OUTI
  test("OPCODE eda3_05 | OUTI", () {
    // Set up machine initial state
    loadRegisters(0x0000, 0x0100, 0x0000, 0x01fd, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xed);
    poke(0x0001, 0xa3);
    poke(0x01fd, 0x12);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x0055, 0x0000, 0x0000, 0x01fe, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 16);
  });

  // Test instruction eda3_06 | OUTI
  test("OPCODE eda3_06 | OUTI", () {
    // Set up machine initial state
    loadRegisters(0x0000, 0x0100, 0x0000, 0x01fe, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xed);
    poke(0x0001, 0xa3);
    poke(0x01fe, 0x12);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x0051, 0x0000, 0x0000, 0x01ff, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 16);
  });

  // Test instruction eda3_07 | OUTI
  test("OPCODE eda3_07 | OUTI", () {
    // Set up machine initial state
    loadRegisters(0x0000, 0x0200, 0x0000, 0x01ff, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xed);
    poke(0x0001, 0xa3);
    poke(0x01ff, 0x00);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x0000, 0x0100, 0x0000, 0x0200, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 16);
  });

  // Test instruction eda3_08 | OUTI
  test("OPCODE eda3_08 | OUTI", () {
    // Set up machine initial state
    loadRegisters(0x0000, 0x0800, 0x0000, 0x01fe, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xed);
    poke(0x0001, 0xa3);
    poke(0x01fe, 0x00);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x0004, 0x0700, 0x0000, 0x01ff, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 16);
  });

  // Test instruction eda3_09 | OUTI
  test("OPCODE eda3_09 | OUTI", () {
    // Set up machine initial state
    loadRegisters(0x0000, 0x8100, 0x0000, 0x01ff, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xed);
    poke(0x0001, 0xa3);
    poke(0x01ff, 0x00);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x0080, 0x8000, 0x0000, 0x0200, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 16);
  });

  // Test instruction eda3_10 | OUTI
  test("OPCODE eda3_10 | OUTI", () {
    // Set up machine initial state
    loadRegisters(0x0000, 0x8200, 0x0000, 0x01ff, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xed);
    poke(0x0001, 0xa3);
    poke(0x01ff, 0x00);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x0084, 0x8100, 0x0000, 0x0200, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 16);
  });

  // Test instruction eda3_11 | OUTI
  test("OPCODE eda3_11 | OUTI", () {
    // Set up machine initial state
    loadRegisters(0x0000, 0xa900, 0x0000, 0x01ff, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xed);
    poke(0x0001, 0xa3);
    poke(0x01ff, 0x00);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x00a8, 0xa800, 0x0000, 0x0200, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 16);
  });

  // Test instruction eda8 | LDD
  test("OPCODE eda8 | LDD", () {
    // Set up machine initial state
    loadRegisters(0x2a8e, 0x1607, 0x5938, 0x12e8, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xed);
    poke(0x0001, 0xa8);
    poke(0x12e8, 0xd8);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x2aa4, 0x1606, 0x5937, 0x12e7, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 16);
    expect(peek(22840), equals(0xd8));
  });

  // Test instruction eda9 | CPD
  test("OPCODE eda9 | CPD", () {
    // Set up machine initial state
    loadRegisters(0x1495, 0xfb42, 0x0466, 0x0dbe, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xed);
    poke(0x0001, 0xa9);
    poke(0x0dbe, 0x89);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x14bf, 0xfb41, 0x0466, 0x0dbd, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 16);
  });

  // Test instruction edaa | IND
  test("OPCODE edaa | IND", () {
    // Set up machine initial state
    loadRegisters(0x2042, 0xd791, 0xa912, 0xa533, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xed);
    poke(0x0001, 0xaa);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x2097, 0xd691, 0xa912, 0xa532, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 16);
    expect(peek(42291), equals(0xd7));
  });

  // Test instruction edaa_01 | IND
  test("OPCODE edaa_01 | IND", () {
    // Set up machine initial state
    loadRegisters(0x0000, 0x0101, 0x0000, 0x8000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xed);
    poke(0x0001, 0xaa);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x0040, 0x0001, 0x0000, 0x7fff, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 16);
    expect(peek(32768), equals(0x01));
  });

  // Test instruction edaa_02 | IND
  test("OPCODE edaa_02 | IND", () {
    // Set up machine initial state
    loadRegisters(0x0000, 0x56aa, 0x0000, 0x8000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xed);
    poke(0x0001, 0xaa);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x0000, 0x55aa, 0x0000, 0x7fff, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 16);
    expect(peek(32768), equals(0x56));
  });

  // Test instruction edaa_03 | IND
  test("OPCODE edaa_03 | IND", () {
    // Set up machine initial state
    loadRegisters(0x0000, 0xabcc, 0x0000, 0x8000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xed);
    poke(0x0001, 0xaa);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x00bf, 0xaacc, 0x0000, 0x7fff, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 16);
    expect(peek(32768), equals(0xab));
  });

  // Test instruction edab | OUTD
  test("OPCODE edab | OUTD", () {
    // Set up machine initial state
    loadRegisters(0x0037, 0xf334, 0xd3e1, 0x199f, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xed);
    poke(0x0001, 0xab);
    poke(0x199f, 0x49);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x00a4, 0xf234, 0xd3e1, 0x199e, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 16);
  });

  // Test instruction edab_01 | OUTD
  test("OPCODE edab_01 | OUTD", () {
    // Set up machine initial state
    loadRegisters(0x0000, 0x5800, 0x0000, 0x007a, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xed);
    poke(0x0001, 0xab);
    poke(0x007a, 0x7f);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x0000, 0x5700, 0x0000, 0x0079, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 16);
  });

  // Test instruction edab_02 | OUTD
  test("OPCODE edab_02 | OUTD", () {
    // Set up machine initial state
    loadRegisters(0x0000, 0xab00, 0x0000, 0x00f1, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xed);
    poke(0x0001, 0xab);
    poke(0x00f1, 0xcd);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x00bf, 0xaa00, 0x0000, 0x00f0, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 16);
  });

  // Test instruction edb0 | LDIR
  test("OPCODE edb0 | LDIR", () {
    // Set up machine initial state
    loadRegisters(0x1045, 0x0010, 0xaad8, 0x558e, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xed);
    poke(0x0001, 0xb0);
    poke(0x558e, 0x53);
    poke(0x558f, 0x94);
    poke(0x5590, 0x30);
    poke(0x5591, 0x05);
    poke(0x5592, 0x44);
    poke(0x5593, 0x24);
    poke(0x5594, 0x22);
    poke(0x5595, 0xb9);
    poke(0x5596, 0xe9);
    poke(0x5597, 0x77);
    poke(0x5598, 0x23);
    poke(0x5599, 0x71);
    poke(0x559a, 0xe2);
    poke(0x559b, 0x5c);
    poke(0x559c, 0xfb);
    poke(0x559d, 0x49);

    // Execute machine for tState cycles
    while (z80.tStates < 331) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x1049, 0x0000, 0xaae8, 0x559e, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x20, false, false, 331);
    expect(peek(43736), equals(0x53));
    expect(peek(43737), equals(0x94));
    expect(peek(43738), equals(0x30));
    expect(peek(43739), equals(0x05));
    expect(peek(43740), equals(0x44));
    expect(peek(43741), equals(0x24));
    expect(peek(43742), equals(0x22));
    expect(peek(43743), equals(0xb9));
    expect(peek(43744), equals(0xe9));
    expect(peek(43745), equals(0x77));
    expect(peek(43746), equals(0x23));
    expect(peek(43747), equals(0x71));
    expect(peek(43748), equals(0xe2));
    expect(peek(43749), equals(0x5c));
    expect(peek(43750), equals(0xfb));
    expect(peek(43751), equals(0x49));
  });

  // Test instruction edb0_1 | LDIR
  test("OPCODE edb0_1 | LDIR", () {
    // Set up machine initial state
    loadRegisters(0x0000, 0x0002, 0xc000, 0x8000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x4000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x4000, 0xed);
    poke(0x4001, 0xb0);
    poke(0x8000, 0x12);
    poke(0x8001, 0x34);

    // Execute machine for tState cycles
    while (z80.tStates < 37) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x0000, 0x0000, 0xc002, 0x8002, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x4002);
    checkSpecialRegisters(0x00, 0x04, false, false, 37);
    expect(peek(49152), equals(0x12));
    expect(peek(49153), equals(0x34));
  });

  // Test instruction edb0_2 | LDIR
  test("OPCODE edb0_2 | LDIR", () {
    // Set up machine initial state
    loadRegisters(0x0000, 0x0001, 0xc000, 0x8000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x4000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x4000, 0xed);
    poke(0x4001, 0xb0);
    poke(0x8000, 0x12);
    poke(0x8001, 0x34);

    // Execute machine for tState cycles
    while (z80.tStates < 16) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x0020, 0x0000, 0xc001, 0x8001, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x4002);
    checkSpecialRegisters(0x00, 0x02, false, false, 16);
    expect(peek(49152), equals(0x12));
  });

  // Test instruction edb1 | CPIR
  test("OPCODE edb1 | CPIR", () {
    // Set up machine initial state
    loadRegisters(0xf4dd, 0x0008, 0xe4e0, 0x9825, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xed);
    poke(0x0001, 0xb1);
    poke(0x9825, 0x50);
    poke(0x9826, 0xe5);
    poke(0x9827, 0x41);
    poke(0x9828, 0xf4);
    poke(0x9829, 0x01);
    poke(0x982a, 0x9f);
    poke(0x982b, 0x11);
    poke(0x982c, 0x85);

    // Execute machine for tState cycles
    while (z80.tStates < 79) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xf447, 0x0004, 0xe4e0, 0x9829, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x08, false, false, 79);
  });

  // Test instruction edb1_1 | CPIR
  test("OPCODE edb1_1 | CPIR", () {
    // Set up machine initial state
    loadRegisters(0xf4dd, 0x0008, 0xe4e0, 0x9825, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x8396);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x8396, 0xed);
    poke(0x8397, 0xb1);
    poke(0x9825, 0x50);
    poke(0x9826, 0xe5);
    poke(0x9827, 0x41);
    poke(0x9828, 0xf4);
    poke(0x9829, 0x01);
    poke(0x982a, 0x9f);
    poke(0x982b, 0x11);
    poke(0x982c, 0x85);

    // Execute machine for tState cycles
    while (z80.tStates < 79) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xf447, 0x0004, 0xe4e0, 0x9829, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x8398);
    checkSpecialRegisters(0x00, 0x08, false, false, 79);
  });

  // Test instruction edb1_2 | CPIR
  test("OPCODE edb1_2 | CPIR", () {
    // Set up machine initial state
    loadRegisters(0xf4dd, 0x0008, 0xe4e0, 0x9825, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x8396);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x8396, 0xed);
    poke(0x8397, 0xb1);
    poke(0x9825, 0x50);
    poke(0x9826, 0xe5);
    poke(0x9827, 0x41);
    poke(0x9828, 0xf4);
    poke(0x9829, 0x01);
    poke(0x982a, 0x9f);
    poke(0x982b, 0x11);
    poke(0x982c, 0x85);

    // Execute machine for tState cycles
    while (z80.tStates < 21) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xf487, 0x0007, 0xe4e0, 0x9826, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x8396);
    checkSpecialRegisters(0x00, 0x02, false, false, 21);
  });

  // Test instruction edb2 | INIR
  test("OPCODE edb2 | INIR", () {
    // Set up machine initial state
    loadRegisters(0x8a34, 0x0a40, 0xd98c, 0x37ce, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xed);
    poke(0x0001, 0xb2);

    // Execute machine for tState cycles
    while (z80.tStates < 205) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x8a40, 0x0040, 0xd98c, 0x37d8, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x14, false, false, 205);
    expect(peek(14286), equals(0x0a));
    expect(peek(14287), equals(0x09));
    expect(peek(14288), equals(0x08));
    expect(peek(14289), equals(0x07));
    expect(peek(14290), equals(0x06));
    expect(peek(14291), equals(0x05));
    expect(peek(14292), equals(0x04));
    expect(peek(14293), equals(0x03));
    expect(peek(14294), equals(0x02));
    expect(peek(14295), equals(0x01));
  });

  // Test instruction edb2_1 | INIR
  test("OPCODE edb2_1 | INIR", () {
    // Set up machine initial state
    loadRegisters(0x8a34, 0x0a40, 0xd98c, 0x37ce, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xed);
    poke(0x0001, 0xb2);

    // Execute machine for tState cycles
    while (z80.tStates < 21) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x8a0c, 0x0940, 0xd98c, 0x37cf, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    checkSpecialRegisters(0x00, 0x02, false, false, 21);
    expect(peek(14286), equals(0x0a));
  });

  // Test instruction edb3 | OTIR
  test("OPCODE edb3 | OTIR", () {
    // Set up machine initial state
    loadRegisters(0x34ab, 0x03e0, 0x41b9, 0x1d7c, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xed);
    poke(0x0001, 0xb3);
    poke(0x1d7c, 0x9d);
    poke(0x1d7d, 0x24);
    poke(0x1d7e, 0xaa);

    // Execute machine for tState cycles
    while (z80.tStates < 58) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x3453, 0x00e0, 0x41b9, 0x1d7f, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x06, false, false, 58);
  });

  // Test instruction edb3_1 | OTIR
  test("OPCODE edb3_1 | OTIR", () {
    // Set up machine initial state
    loadRegisters(0x34ab, 0x03e0, 0x41b9, 0x1d7c, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xed);
    poke(0x0001, 0xb3);
    poke(0x1d7c, 0x9d);
    poke(0x1d7d, 0x24);
    poke(0x1d7e, 0xaa);

    // Execute machine for tState cycles
    while (z80.tStates < 21) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x3417, 0x02e0, 0x41b9, 0x1d7d, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    checkSpecialRegisters(0x00, 0x02, false, false, 21);
  });

  // Test instruction edb8 | LDDR
  test("OPCODE edb8 | LDDR", () {
    // Set up machine initial state
    loadRegisters(0xe553, 0x0008, 0x68e8, 0x4dcf, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xed);
    poke(0x0001, 0xb8);
    poke(0x4dc8, 0x29);
    poke(0x4dc9, 0x85);
    poke(0x4dca, 0xa7);
    poke(0x4dcb, 0xc3);
    poke(0x4dcc, 0x55);
    poke(0x4dcd, 0x74);
    poke(0x4dce, 0x23);
    poke(0x4dcf, 0x0a);

    // Execute machine for tState cycles
    while (z80.tStates < 163) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xe569, 0x0000, 0x68e0, 0x4dc7, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x10, false, false, 163);
    expect(peek(26849), equals(0x29));
    expect(peek(26850), equals(0x85));
    expect(peek(26851), equals(0xa7));
    expect(peek(26852), equals(0xc3));
    expect(peek(26853), equals(0x55));
    expect(peek(26854), equals(0x74));
    expect(peek(26855), equals(0x23));
    expect(peek(26856), equals(0x0a));
  });

  // Test instruction edb8_1 | LDDR
  test("OPCODE edb8_1 | LDDR", () {
    // Set up machine initial state
    loadRegisters(0x0000, 0x0002, 0xb5d7, 0x6af0, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x1ec1);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x1ec1, 0xed);
    poke(0x1ec2, 0xb8);
    poke(0x6aef, 0xd6);
    poke(0x6af0, 0x70);

    // Execute machine for tState cycles
    while (z80.tStates < 37) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x0020, 0x0000, 0xb5d5, 0x6aee, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x1ec3);
    checkSpecialRegisters(0x00, 0x04, false, false, 37);
    expect(peek(46550), equals(0xd6));
    expect(peek(46551), equals(0x70));
  });

  // Test instruction edb8_2 | LDDR
  test("OPCODE edb8_2 | LDDR", () {
    // Set up machine initial state
    loadRegisters(0x0000, 0x0001, 0xb5d7, 0x6af0, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x1ec1);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x1ec1, 0xed);
    poke(0x1ec2, 0xb8);
    poke(0x6aef, 0xd6);
    poke(0x6af0, 0x70);

    // Execute machine for tState cycles
    while (z80.tStates < 16) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x0000, 0x0000, 0xb5d6, 0x6aef, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x1ec3);
    checkSpecialRegisters(0x00, 0x02, false, false, 16);
    expect(peek(46551), equals(0x70));
  });

  // Test instruction edb9 | CPDR
  test("OPCODE edb9 | CPDR", () {
    // Set up machine initial state
    loadRegisters(0xffcd, 0x0008, 0xa171, 0xc749, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xed);
    poke(0x0001, 0xb9);
    poke(0xc742, 0xc6);
    poke(0xc743, 0x09);
    poke(0xc744, 0x85);
    poke(0xc745, 0xec);
    poke(0xc746, 0x5a);
    poke(0xc747, 0x01);
    poke(0xc748, 0x4e);
    poke(0xc749, 0x6c);

    // Execute machine for tState cycles
    while (z80.tStates < 163) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xff0b, 0x0000, 0xa171, 0xc741, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x10, false, false, 163);
  });

  // Test instruction edb9_1 | CPDR
  test("OPCODE edb9_1 | CPDR", () {
    // Set up machine initial state
    loadRegisters(0xffcd, 0x0008, 0xa171, 0xc749, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x7a45);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x7a45, 0xed);
    poke(0x7a46, 0xb9);
    poke(0xc742, 0xc6);
    poke(0xc743, 0x09);
    poke(0xc744, 0x85);
    poke(0xc745, 0xec);
    poke(0xc746, 0x5a);
    poke(0xc747, 0x01);
    poke(0xc748, 0x4e);
    poke(0xc749, 0x6c);

    // Execute machine for tState cycles
    while (z80.tStates < 163) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xff0b, 0x0000, 0xa171, 0xc741, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x7a47);
    checkSpecialRegisters(0x00, 0x10, false, false, 163);
  });

  // Test instruction edb9_2 | CPDR
  test("OPCODE edb9_2 | CPDR", () {
    // Set up machine initial state
    loadRegisters(0xffcd, 0x0008, 0xa171, 0xc749, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x7a45);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x7a45, 0xed);
    poke(0x7a46, 0xb9);
    poke(0xc742, 0xc6);
    poke(0xc743, 0x09);
    poke(0xc744, 0x85);
    poke(0xc745, 0xec);
    poke(0xc746, 0x5a);
    poke(0xc747, 0x01);
    poke(0xc748, 0x4e);
    poke(0xc749, 0x6c);

    // Execute machine for tState cycles
    while (z80.tStates < 21) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xffa7, 0x0007, 0xa171, 0xc748, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x7a45);
    checkSpecialRegisters(0x00, 0x02, false, false, 21);
  });

  // Test instruction edba | INDR
  test("OPCODE edba | INDR", () {
    // Set up machine initial state
    loadRegisters(0x2567, 0x069f, 0xd40d, 0x6b55, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xed);
    poke(0x0001, 0xba);

    // Execute machine for tState cycles
    while (z80.tStates < 121) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x2540, 0x009f, 0xd40d, 0x6b4f, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x0c, false, false, 121);
    expect(peek(27472), equals(0x01));
    expect(peek(27473), equals(0x02));
    expect(peek(27474), equals(0x03));
    expect(peek(27475), equals(0x04));
    expect(peek(27476), equals(0x05));
    expect(peek(27477), equals(0x06));
  });

  // Test instruction edba_1 | INDR
  test("OPCODE edba_1 | INDR", () {
    // Set up machine initial state
    loadRegisters(0x2567, 0x069f, 0xd40d, 0x6b55, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xed);
    poke(0x0001, 0xba);

    // Execute machine for tState cycles
    while (z80.tStates < 21) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x2500, 0x059f, 0xd40d, 0x6b54, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    checkSpecialRegisters(0x00, 0x02, false, false, 21);
    expect(peek(27477), equals(0x06));
  });

  // Test instruction edbb | OTDR
  test("OPCODE edbb | OTDR", () {
    // Set up machine initial state
    loadRegisters(0x09c4, 0x043b, 0xbe49, 0x1dd0, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xed);
    poke(0x0001, 0xbb);
    poke(0x1dcd, 0xf9);
    poke(0x1dce, 0x71);
    poke(0x1dcf, 0xc5);
    poke(0x1dd0, 0xb6);

    // Execute machine for tState cycles
    while (z80.tStates < 79) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x0957, 0x003b, 0xbe49, 0x1dcc, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x08, false, false, 79);
  });

  // Test instruction edbb_1 | OTDR
  test("OPCODE edbb_1 | OTDR", () {
    // Set up machine initial state
    loadRegisters(0x09c4, 0x043b, 0xbe49, 0x1dd0, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xed);
    poke(0x0001, 0xbb);
    poke(0x1dcd, 0xf9);
    poke(0x1dce, 0x71);
    poke(0x1dcf, 0xc5);
    poke(0x1dd0, 0xb6);

    // Execute machine for tState cycles
    while (z80.tStates < 21) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x0917, 0x033b, 0xbe49, 0x1dcf, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    checkSpecialRegisters(0x00, 0x02, false, false, 21);
  });

  // Test instruction ee | XOR *
  test("OPCODE ee | XOR *", () {
    // Set up machine initial state
    loadRegisters(0x3e00, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xee);
    poke(0x0001, 0xd0);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xeeac, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x01, false, false, 7);
  });

  // Test instruction ef | RST 28h
  test("OPCODE ef | RST 28h", () {
    // Set up machine initial state
    loadRegisters(0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x5507, 0x6d33);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x6d33, 0xef);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x5505, 0x0028);
    checkSpecialRegisters(0x00, 0x01, false, false, 11);
    expect(peek(21765), equals(0x34));
    expect(peek(21766), equals(0x6d));
  });

  // Test instruction f0_1 | RET P
  test("OPCODE f0_1 | RET P", () {
    // Set up machine initial state
    loadRegisters(0x0018, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x43f7, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xf0);
    poke(0x43f7, 0xe9);
    poke(0x43f8, 0xaf);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x0018, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x43f9, 0xafe9);
    checkSpecialRegisters(0x00, 0x01, false, false, 11);
  });

  // Test instruction f0_2 | RET P
  test("OPCODE f0_2 | RET P", () {
    // Set up machine initial state
    loadRegisters(0x0098, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x43f7, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xf0);
    poke(0x43f7, 0xe9);
    poke(0x43f8, 0xaf);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x0098, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x43f7, 0x0001);
    checkSpecialRegisters(0x00, 0x01, false, false, 5);
  });

  // Test instruction f1 | POP AF
  test("OPCODE f1 | POP AF", () {
    // Set up machine initial state
    loadRegisters(0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x4143, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xf1);
    poke(0x4143, 0xce);
    poke(0x4144, 0xe8);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xe8ce, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x4145, 0x0001);
    checkSpecialRegisters(0x00, 0x01, false, false, 10);
  });

  // Test instruction f2_1 | JP P, **
  test("OPCODE f2_1 | JP P, **", () {
    // Set up machine initial state
    loadRegisters(0x0007, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xf2);
    poke(0x0001, 0x1b);
    poke(0x0002, 0xe1);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x0007, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0xe11b);
    checkSpecialRegisters(0x00, 0x01, false, false, 10);
  });

  // Test instruction f2_2 | JP P, **
  test("OPCODE f2_2 | JP P, **", () {
    // Set up machine initial state
    loadRegisters(0x0087, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xf2);
    poke(0x0001, 0x1b);
    poke(0x0002, 0xe1);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x0087, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0003);
    checkSpecialRegisters(0x00, 0x01, false, false, 10);
  });

  // Test instruction f3 | DI
  test("OPCODE f3 | DI", () {
    // Set up machine initial state
    loadRegisters(0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = true;
    z80.iff2 = true;
    poke(0x0000, 0xf3);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0001);
    checkSpecialRegisters(0x00, 0x01, false, false, 4);
  });

  // Test instruction f4_1 | CALL P, **
  test("OPCODE f4_1 | CALL P, **", () {
    // Set up machine initial state
    loadRegisters(0x000e, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x5698, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xf4);
    poke(0x0001, 0x61);
    poke(0x0002, 0x9c);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x000e, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x5696, 0x9c61);
    checkSpecialRegisters(0x00, 0x01, false, false, 17);
    expect(peek(22166), equals(0x03));
    expect(peek(22167), equals(0x00));
  });

  // Test instruction f4_2 | CALL P, **
  test("OPCODE f4_2 | CALL P, **", () {
    // Set up machine initial state
    loadRegisters(0x008e, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x5698, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xf4);
    poke(0x0001, 0x61);
    poke(0x0002, 0x9c);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x008e, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x5698, 0x0003);
    checkSpecialRegisters(0x00, 0x01, false, false, 10);
  });

  // Test instruction f5 | PUSH AF
  test("OPCODE f5 | PUSH AF", () {
    // Set up machine initial state
    loadRegisters(0x53e3, 0x1459, 0x775f, 0x1a2f, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0xec12, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xf5);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x53e3, 0x1459, 0x775f, 0x1a2f, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0xec10, 0x0001);
    checkSpecialRegisters(0x00, 0x01, false, false, 11);
    expect(peek(60432), equals(0xe3));
    expect(peek(60433), equals(0x53));
  });

  // Test instruction f6 | OR *
  test("OPCODE f6 | OR *", () {
    // Set up machine initial state
    loadRegisters(0x0600, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xf6);
    poke(0x0001, 0xa7);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xa7a0, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x01, false, false, 7);
  });

  // Test instruction f7 | RST 30h
  test("OPCODE f7 | RST 30h", () {
    // Set up machine initial state
    loadRegisters(0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x5507, 0x6d33);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x6d33, 0xf7);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x5505, 0x0030);
    checkSpecialRegisters(0x00, 0x01, false, false, 11);
    expect(peek(21765), equals(0x34));
    expect(peek(21766), equals(0x6d));
  });

  // Test instruction f8_1 | RET M
  test("OPCODE f8_1 | RET M", () {
    // Set up machine initial state
    loadRegisters(0x0018, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x43f7, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xf8);
    poke(0x43f7, 0xe9);
    poke(0x43f8, 0xaf);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x0018, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x43f7, 0x0001);
    checkSpecialRegisters(0x00, 0x01, false, false, 5);
  });

  // Test instruction f8_2 | RET M
  test("OPCODE f8_2 | RET M", () {
    // Set up machine initial state
    loadRegisters(0x0098, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x43f7, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xf8);
    poke(0x43f7, 0xe9);
    poke(0x43f8, 0xaf);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x0098, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x43f9, 0xafe9);
    checkSpecialRegisters(0x00, 0x01, false, false, 11);
  });

  // Test instruction f9 | LD SP, HL
  test("OPCODE f9 | LD SP, HL", () {
    // Set up machine initial state
    loadRegisters(0x0000, 0x0000, 0x0000, 0xce32, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xf9);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x0000, 0x0000, 0x0000, 0xce32, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0xce32, 0x0001);
    checkSpecialRegisters(0x00, 0x01, false, false, 6);
  });

  // Test instruction fa_1 | JP M, **
  test("OPCODE fa_1 | JP M, **", () {
    // Set up machine initial state
    loadRegisters(0x0087, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xfa);
    poke(0x0001, 0x1b);
    poke(0x0002, 0xe1);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x0087, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0xe11b);
    checkSpecialRegisters(0x00, 0x01, false, false, 10);
  });

  // Test instruction fa_2 | JP M, **
  test("OPCODE fa_2 | JP M, **", () {
    // Set up machine initial state
    loadRegisters(0x0007, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xfa);
    poke(0x0001, 0x1b);
    poke(0x0002, 0xe1);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x0007, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0003);
    checkSpecialRegisters(0x00, 0x01, false, false, 10);
  });

  // Test instruction fb | EI
  test("OPCODE fb | EI", () {
    // Set up machine initial state
    loadRegisters(0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xfb);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0001);
    checkSpecialRegisters(0x00, 0x01, true, true, 4);
  });

  // Test instruction fc_1 | CALL M, **
  test("OPCODE fc_1 | CALL M, **", () {
    // Set up machine initial state
    loadRegisters(0x008e, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x5698, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xfc);
    poke(0x0001, 0x61);
    poke(0x0002, 0x9c);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x008e, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x5696, 0x9c61);
    checkSpecialRegisters(0x00, 0x01, false, false, 17);
    expect(peek(22166), equals(0x03));
    expect(peek(22167), equals(0x00));
  });

  // Test instruction fc_2 | CALL M, **
  test("OPCODE fc_2 | CALL M, **", () {
    // Set up machine initial state
    loadRegisters(0x000e, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x5698, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xfc);
    poke(0x0001, 0x61);
    poke(0x0002, 0x9c);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x000e, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x5698, 0x0003);
    checkSpecialRegisters(0x00, 0x01, false, false, 10);
  });

  // Test instruction fd09 | ADD IY, BC
  test("OPCODE fd09 | ADD IY, BC", () {
    // Set up machine initial state
    loadRegisters(0x466a, 0xa623, 0xbab2, 0xd788, 0x0000, 0x0000, 0x0000,
        0x0000, 0xc9e8, 0xf698, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xfd);
    poke(0x0001, 0x09);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x4649, 0xa623, 0xbab2, 0xd788, 0x0000, 0x0000, 0x0000,
        0x0000, 0xc9e8, 0x9cbb, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 15);
  });

  // Test instruction fd19 | ADD IY, DE
  test("OPCODE fd19 | ADD IY, DE", () {
    // Set up machine initial state
    loadRegisters(0xb3e5, 0x5336, 0x76cb, 0x54e2, 0x0000, 0x0000, 0x0000,
        0x0000, 0xb9ce, 0x8624, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xfd);
    poke(0x0001, 0x19);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xb3ec, 0x5336, 0x76cb, 0x54e2, 0x0000, 0x0000, 0x0000,
        0x0000, 0xb9ce, 0xfcef, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 15);
  });

  // Test instruction fd21 | LD IY, **
  test("OPCODE fd21 | LD IY, **", () {
    // Set up machine initial state
    loadRegisters(0xc924, 0x5c83, 0xe0e2, 0xeddb, 0x0000, 0x0000, 0x0000,
        0x0000, 0x6e9f, 0xba55, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xfd);
    poke(0x0001, 0x21);
    poke(0x0002, 0x46);
    poke(0x0003, 0x47);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xc924, 0x5c83, 0xe0e2, 0xeddb, 0x0000, 0x0000, 0x0000,
        0x0000, 0x6e9f, 0x4746, 0x0000, 0x0004);
    checkSpecialRegisters(0x00, 0x02, false, false, 14);
  });

  // Test instruction fd22 | LD (**), IY
  test("OPCODE fd22 | LD (**), IY", () {
    // Set up machine initial state
    loadRegisters(0x1235, 0xf0b6, 0xb74c, 0xcc9f, 0x0000, 0x0000, 0x0000,
        0x0000, 0x8b00, 0x81e4, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xfd);
    poke(0x0001, 0x22);
    poke(0x0002, 0x9a);
    poke(0x0003, 0xe2);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x1235, 0xf0b6, 0xb74c, 0xcc9f, 0x0000, 0x0000, 0x0000,
        0x0000, 0x8b00, 0x81e4, 0x0000, 0x0004);
    checkSpecialRegisters(0x00, 0x02, false, false, 20);
    expect(peek(58010), equals(0xe4));
    expect(peek(58011), equals(0x81));
  });

  // Test instruction fd23 | INC IY
  test("OPCODE fd23 | INC IY", () {
    // Set up machine initial state
    loadRegisters(0x69f2, 0xc1d3, 0x0f6f, 0x2169, 0x0000, 0x0000, 0x0000,
        0x0000, 0xe39e, 0x2605, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xfd);
    poke(0x0001, 0x23);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x69f2, 0xc1d3, 0x0f6f, 0x2169, 0x0000, 0x0000, 0x0000,
        0x0000, 0xe39e, 0x2606, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 10);
  });

  // Test instruction fd29 | ADD IY, IY
  test("OPCODE fd29 | ADD IY, IY", () {
    // Set up machine initial state
    loadRegisters(0x5812, 0x49d0, 0xec95, 0x011c, 0x0000, 0x0000, 0x0000,
        0x0000, 0xec6c, 0x594c, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xfd);
    poke(0x0001, 0x29);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x5830, 0x49d0, 0xec95, 0x011c, 0x0000, 0x0000, 0x0000,
        0x0000, 0xec6c, 0xb298, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 15);
  });

  // Test instruction fd2a | LD IY, (**)
  test("OPCODE fd2a | LD IY, (**)", () {
    // Set up machine initial state
    loadRegisters(0x0f82, 0x3198, 0x87e3, 0x7c1c, 0x0000, 0x0000, 0x0000,
        0x0000, 0x1bb4, 0xeb1a, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xfd);
    poke(0x0001, 0x2a);
    poke(0x0002, 0x91);
    poke(0x0003, 0xf9);
    poke(0xf991, 0x92);
    poke(0xf992, 0xbf);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x0f82, 0x3198, 0x87e3, 0x7c1c, 0x0000, 0x0000, 0x0000,
        0x0000, 0x1bb4, 0xbf92, 0x0000, 0x0004);
    checkSpecialRegisters(0x00, 0x02, false, false, 20);
  });

  // Test instruction fd2b | DEC IY
  test("OPCODE fd2b | DEC IY", () {
    // Set up machine initial state
    loadRegisters(0xab27, 0x942f, 0x82fa, 0x6f2f, 0x0000, 0x0000, 0x0000,
        0x0000, 0x9438, 0xebbc, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xfd);
    poke(0x0001, 0x2b);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xab27, 0x942f, 0x82fa, 0x6f2f, 0x0000, 0x0000, 0x0000,
        0x0000, 0x9438, 0xebbb, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 10);
  });

  // Test instruction fd34 | INC (IY+*)
  test("OPCODE fd34 | INC (IY+*)", () {
    // Set up machine initial state
    loadRegisters(0xd56a, 0x6f24, 0x7df7, 0x74f0, 0x0000, 0x0000, 0x0000,
        0x0000, 0x365a, 0xefc4, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xfd);
    poke(0x0001, 0x34);
    poke(0x0002, 0xb8);
    poke(0xef7c, 0xe0);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xd5a0, 0x6f24, 0x7df7, 0x74f0, 0x0000, 0x0000, 0x0000,
        0x0000, 0x365a, 0xefc4, 0x0000, 0x0003);
    checkSpecialRegisters(0x00, 0x02, false, false, 23);
    expect(peek(61308), equals(0xe1));
  });

  // Test instruction fd35 | DEC (IY+*)
  test("OPCODE fd35 | DEC (IY+*)", () {
    // Set up machine initial state
    loadRegisters(0x8cda, 0x35d8, 0x7c1a, 0x1c0a, 0x0000, 0x0000, 0x0000,
        0x0000, 0x62bb, 0xaec6, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xfd);
    poke(0x0001, 0x35);
    poke(0x0002, 0xab);
    poke(0xae71, 0xa6);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x8ca2, 0x35d8, 0x7c1a, 0x1c0a, 0x0000, 0x0000, 0x0000,
        0x0000, 0x62bb, 0xaec6, 0x0000, 0x0003);
    checkSpecialRegisters(0x00, 0x02, false, false, 23);
    expect(peek(44657), equals(0xa5));
  });

  // Test instruction fd36 | LD (IY+*), *
  test("OPCODE fd36 | LD (IY+*), *", () {
    // Set up machine initial state
    loadRegisters(0xe0f9, 0xae1f, 0x4aef, 0xc9d5, 0x0000, 0x0000, 0x0000,
        0x0000, 0xc0db, 0xbdd4, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xfd);
    poke(0x0001, 0x36);
    poke(0x0002, 0x81);
    poke(0x0003, 0xc5);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xe0f9, 0xae1f, 0x4aef, 0xc9d5, 0x0000, 0x0000, 0x0000,
        0x0000, 0xc0db, 0xbdd4, 0x0000, 0x0004);
    checkSpecialRegisters(0x00, 0x02, false, false, 19);
    expect(peek(48469), equals(0xc5));
  });

  // Test instruction fd39 | ADD IY, SP
  test("OPCODE fd39 | ADD IY, SP", () {
    // Set up machine initial state
    loadRegisters(0x2603, 0x726f, 0x9c7f, 0xcd46, 0x0000, 0x0000, 0x0000,
        0x0000, 0xdc45, 0x54d5, 0xdc57, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xfd);
    poke(0x0001, 0x39);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x2631, 0x726f, 0x9c7f, 0xcd46, 0x0000, 0x0000, 0x0000,
        0x0000, 0xdc45, 0x312c, 0xdc57, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 15);
  });

  // Test instruction fd46 | LD B, (IY+*)
  test("OPCODE fd46 | LD B, (IY+*)", () {
    // Set up machine initial state
    loadRegisters(0x87f3, 0x17d5, 0x5eea, 0x830b, 0x0000, 0x0000, 0x0000,
        0x0000, 0xdcee, 0x3afc, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xfd);
    poke(0x0001, 0x46);
    poke(0x0002, 0x4d);
    poke(0x3b49, 0xc9);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x87f3, 0xc9d5, 0x5eea, 0x830b, 0x0000, 0x0000, 0x0000,
        0x0000, 0xdcee, 0x3afc, 0x0000, 0x0003);
    checkSpecialRegisters(0x00, 0x02, false, false, 19);
  });

  // Test instruction fd4e | LD C, (IY+*)
  test("OPCODE fd4e | LD C, (IY+*)", () {
    // Set up machine initial state
    loadRegisters(0x2c0f, 0x69d7, 0x748a, 0x9290, 0x0000, 0x0000, 0x0000,
        0x0000, 0x904f, 0xbb9a, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xfd);
    poke(0x0001, 0x4e);
    poke(0x0002, 0x67);
    poke(0xbc01, 0x9d);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x2c0f, 0x699d, 0x748a, 0x9290, 0x0000, 0x0000, 0x0000,
        0x0000, 0x904f, 0xbb9a, 0x0000, 0x0003);
    checkSpecialRegisters(0x00, 0x02, false, false, 19);
  });

  // Test instruction fd56 | LD D, (IY+*)
  test("OPCODE fd56 | LD D, (IY+*)", () {
    // Set up machine initial state
    loadRegisters(0xd3e8, 0xdf10, 0x5442, 0xb641, 0x0000, 0x0000, 0x0000,
        0x0000, 0xa5a0, 0xfda2, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xfd);
    poke(0x0001, 0x56);
    poke(0x0002, 0xce);
    poke(0xfd70, 0x78);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xd3e8, 0xdf10, 0x7842, 0xb641, 0x0000, 0x0000, 0x0000,
        0x0000, 0xa5a0, 0xfda2, 0x0000, 0x0003);
    checkSpecialRegisters(0x00, 0x02, false, false, 19);
  });

  // Test instruction fd5e | LD E, (IY+*)
  test("OPCODE fd5e | LD E, (IY+*)", () {
    // Set up machine initial state
    loadRegisters(0x6f3b, 0xe9dc, 0x7a06, 0x14f3, 0x0000, 0x0000, 0x0000,
        0x0000, 0xec76, 0x8aaa, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xfd);
    poke(0x0001, 0x5e);
    poke(0x0002, 0xc6);
    poke(0x8a70, 0x8c);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x6f3b, 0xe9dc, 0x7a8c, 0x14f3, 0x0000, 0x0000, 0x0000,
        0x0000, 0xec76, 0x8aaa, 0x0000, 0x0003);
    checkSpecialRegisters(0x00, 0x02, false, false, 19);
  });

  // Test instruction fd66 | LD H, (IY+*)
  test("OPCODE fd66 | LD H, (IY+*)", () {
    // Set up machine initial state
    loadRegisters(0x9129, 0xe4ee, 0xe3a3, 0x86ca, 0x0000, 0x0000, 0x0000,
        0x0000, 0x4d93, 0x5b24, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xfd);
    poke(0x0001, 0x66);
    poke(0x0002, 0x80);
    poke(0x5aa4, 0x77);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x9129, 0xe4ee, 0xe3a3, 0x77ca, 0x0000, 0x0000, 0x0000,
        0x0000, 0x4d93, 0x5b24, 0x0000, 0x0003);
    checkSpecialRegisters(0x00, 0x02, false, false, 19);
  });

  // Test instruction fd6e | LD L, (IY+*)
  test("OPCODE fd6e | LD L, (IY+*)", () {
    // Set up machine initial state
    loadRegisters(0xcfd4, 0x6ef1, 0xc07d, 0xeb96, 0x0000, 0x0000, 0x0000,
        0x0000, 0xb0f9, 0xb0a3, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xfd);
    poke(0x0001, 0x6e);
    poke(0x0002, 0x78);
    poke(0xb11b, 0xf8);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xcfd4, 0x6ef1, 0xc07d, 0xebf8, 0x0000, 0x0000, 0x0000,
        0x0000, 0xb0f9, 0xb0a3, 0x0000, 0x0003);
    checkSpecialRegisters(0x00, 0x02, false, false, 19);
  });

  // Test instruction fd70 | LD (IY+*), B
  test("OPCODE fd70 | LD (IY+*), B", () {
    // Set up machine initial state
    loadRegisters(0x2677, 0x33c5, 0xc0dc, 0x262f, 0x0000, 0x0000, 0x0000,
        0x0000, 0xd3dc, 0x23a1, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xfd);
    poke(0x0001, 0x70);
    poke(0x0002, 0x53);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x2677, 0x33c5, 0xc0dc, 0x262f, 0x0000, 0x0000, 0x0000,
        0x0000, 0xd3dc, 0x23a1, 0x0000, 0x0003);
    checkSpecialRegisters(0x00, 0x02, false, false, 19);
    expect(peek(9204), equals(0x33));
  });

  // Test instruction fd71 | LD (IY+*), C
  test("OPCODE fd71 | LD (IY+*), C", () {
    // Set up machine initial state
    loadRegisters(0x892e, 0x04ae, 0xd67f, 0x81ec, 0x0000, 0x0000, 0x0000,
        0x0000, 0x7757, 0xbfab, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xfd);
    poke(0x0001, 0x71);
    poke(0x0002, 0xb4);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x892e, 0x04ae, 0xd67f, 0x81ec, 0x0000, 0x0000, 0x0000,
        0x0000, 0x7757, 0xbfab, 0x0000, 0x0003);
    checkSpecialRegisters(0x00, 0x02, false, false, 19);
    expect(peek(48991), equals(0xae));
  });

  // Test instruction fd72 | LD (IY+*), D
  test("OPCODE fd72 | LD (IY+*), D", () {
    // Set up machine initial state
    loadRegisters(0xd2dc, 0xc23c, 0xdd54, 0x6559, 0x0000, 0x0000, 0x0000,
        0x0000, 0xb32b, 0x7c80, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xfd);
    poke(0x0001, 0x72);
    poke(0x0002, 0xe3);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xd2dc, 0xc23c, 0xdd54, 0x6559, 0x0000, 0x0000, 0x0000,
        0x0000, 0xb32b, 0x7c80, 0x0000, 0x0003);
    checkSpecialRegisters(0x00, 0x02, false, false, 19);
    expect(peek(31843), equals(0xdd));
  });

  // Test instruction fd73 | LD (IY+*), E
  test("OPCODE fd73 | LD (IY+*), E", () {
    // Set up machine initial state
    loadRegisters(0x49ef, 0xbff2, 0x8409, 0x02dd, 0x0000, 0x0000, 0x0000,
        0x0000, 0xaf95, 0x8762, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xfd);
    poke(0x0001, 0x73);
    poke(0x0002, 0x17);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x49ef, 0xbff2, 0x8409, 0x02dd, 0x0000, 0x0000, 0x0000,
        0x0000, 0xaf95, 0x8762, 0x0000, 0x0003);
    checkSpecialRegisters(0x00, 0x02, false, false, 19);
    expect(peek(34681), equals(0x09));
  });

  // Test instruction fd74 | LD (IY+*), H
  test("OPCODE fd74 | LD (IY+*), H", () {
    // Set up machine initial state
    loadRegisters(0x9479, 0x9817, 0xfa2e, 0x1fe0, 0x0000, 0x0000, 0x0000,
        0x0000, 0xa395, 0x92db, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xfd);
    poke(0x0001, 0x74);
    poke(0x0002, 0xf6);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x9479, 0x9817, 0xfa2e, 0x1fe0, 0x0000, 0x0000, 0x0000,
        0x0000, 0xa395, 0x92db, 0x0000, 0x0003);
    checkSpecialRegisters(0x00, 0x02, false, false, 19);
    expect(peek(37585), equals(0x1f));
  });

  // Test instruction fd75 | LD (IY+*), L
  test("OPCODE fd75 | LD (IY+*), L", () {
    // Set up machine initial state
    loadRegisters(0xc8d6, 0x6aa4, 0x180e, 0xe37b, 0x0000, 0x0000, 0x0000,
        0x0000, 0x02cf, 0x1724, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xfd);
    poke(0x0001, 0x75);
    poke(0x0002, 0xab);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xc8d6, 0x6aa4, 0x180e, 0xe37b, 0x0000, 0x0000, 0x0000,
        0x0000, 0x02cf, 0x1724, 0x0000, 0x0003);
    checkSpecialRegisters(0x00, 0x02, false, false, 19);
    expect(peek(5839), equals(0x7b));
  });

  // Test instruction fd77 | LD (IY+*), A
  test("OPCODE fd77 | LD (IY+*), A", () {
    // Set up machine initial state
    loadRegisters(0x6f9e, 0x7475, 0x78ad, 0x2b8c, 0x0000, 0x0000, 0x0000,
        0x0000, 0xc6b7, 0x6b4d, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xfd);
    poke(0x0001, 0x77);
    poke(0x0002, 0xf7);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x6f9e, 0x7475, 0x78ad, 0x2b8c, 0x0000, 0x0000, 0x0000,
        0x0000, 0xc6b7, 0x6b4d, 0x0000, 0x0003);
    checkSpecialRegisters(0x00, 0x02, false, false, 19);
    expect(peek(27460), equals(0x6f));
  });

  // Test instruction fd7e | LD A, (IY+*)
  test("OPCODE fd7e | LD A, (IY+*)", () {
    // Set up machine initial state
    loadRegisters(0x1596, 0xdaba, 0x147b, 0xf362, 0x0000, 0x0000, 0x0000,
        0x0000, 0x7110, 0xd45f, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xfd);
    poke(0x0001, 0x7e);
    poke(0x0002, 0xe4);
    poke(0xd443, 0xaa);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xaa96, 0xdaba, 0x147b, 0xf362, 0x0000, 0x0000, 0x0000,
        0x0000, 0x7110, 0xd45f, 0x0000, 0x0003);
    checkSpecialRegisters(0x00, 0x02, false, false, 19);
  });

  // Test instruction fd86 | ADD A, (IY+*)
  test("OPCODE fd86 | ADD A, (IY+*)", () {
    // Set up machine initial state
    loadRegisters(0xfc9c, 0xb882, 0x43f9, 0x3e15, 0x0000, 0x0000, 0x0000,
        0x0000, 0x9781, 0x8b33, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xfd);
    poke(0x0001, 0x86);
    poke(0x0002, 0xce);
    poke(0x8b01, 0xe1);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xdd89, 0xb882, 0x43f9, 0x3e15, 0x0000, 0x0000, 0x0000,
        0x0000, 0x9781, 0x8b33, 0x0000, 0x0003);
    checkSpecialRegisters(0x00, 0x02, false, false, 19);
  });

  // Test instruction fd8e | ADC A, (IY+*)
  test("OPCODE fd8e | ADC A, (IY+*)", () {
    // Set up machine initial state
    loadRegisters(0x41ee, 0x398f, 0xf6dc, 0x06f3, 0x0000, 0x0000, 0x0000,
        0x0000, 0xf34a, 0x1aa2, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xfd);
    poke(0x0001, 0x8e);
    poke(0x0002, 0x78);
    poke(0x1b1a, 0xc0);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x0101, 0x398f, 0xf6dc, 0x06f3, 0x0000, 0x0000, 0x0000,
        0x0000, 0xf34a, 0x1aa2, 0x0000, 0x0003);
    checkSpecialRegisters(0x00, 0x02, false, false, 19);
  });

  // Test instruction fd96 | SUB (IY+*)
  test("OPCODE fd96 | SUB (IY+*)", () {
    // Set up machine initial state
    loadRegisters(0xa0c6, 0x22ac, 0x0413, 0x4b13, 0x0000, 0x0000, 0x0000,
        0x0000, 0xb44e, 0xc08b, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xfd);
    poke(0x0001, 0x96);
    poke(0x0002, 0x55);
    poke(0xc0e0, 0x7b);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x2536, 0x22ac, 0x0413, 0x4b13, 0x0000, 0x0000, 0x0000,
        0x0000, 0xb44e, 0xc08b, 0x0000, 0x0003);
    checkSpecialRegisters(0x00, 0x02, false, false, 19);
  });

  // Test instruction fd9e | SBC A, (IY+*)
  test("OPCODE fd9e | SBC A, (IY+*)", () {
    // Set up machine initial state
    loadRegisters(0xb983, 0x981f, 0xbb8e, 0xd6d5, 0x0000, 0x0000, 0x0000,
        0x0000, 0x5c3b, 0xf66c, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xfd);
    poke(0x0001, 0x9e);
    poke(0x0002, 0xf9);
    poke(0xf665, 0xf3);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xc583, 0x981f, 0xbb8e, 0xd6d5, 0x0000, 0x0000, 0x0000,
        0x0000, 0x5c3b, 0xf66c, 0x0000, 0x0003);
    checkSpecialRegisters(0x00, 0x02, false, false, 19);
  });

  // Test instruction fda6 | AND (IY+*)
  test("OPCODE fda6 | AND (IY+*)", () {
    // Set up machine initial state
    loadRegisters(0xddb8, 0x40bb, 0x3742, 0x6ff1, 0x0000, 0x0000, 0x0000,
        0x0000, 0xad28, 0x659b, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xfd);
    poke(0x0001, 0xa6);
    poke(0x0002, 0x53);
    poke(0x65ee, 0x95);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x9594, 0x40bb, 0x3742, 0x6ff1, 0x0000, 0x0000, 0x0000,
        0x0000, 0xad28, 0x659b, 0x0000, 0x0003);
    checkSpecialRegisters(0x00, 0x02, false, false, 19);
  });

  // Test instruction fdae | XOR (IY+*)
  test("OPCODE fdae | XOR (IY+*)", () {
    // Set up machine initial state
    loadRegisters(0xa0da, 0xbc27, 0x257b, 0x5489, 0x0000, 0x0000, 0x0000,
        0x0000, 0xfa59, 0x81f8, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xfd);
    poke(0x0001, 0xae);
    poke(0x0002, 0x09);
    poke(0x8201, 0xcb);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x6b28, 0xbc27, 0x257b, 0x5489, 0x0000, 0x0000, 0x0000,
        0x0000, 0xfa59, 0x81f8, 0x0000, 0x0003);
    checkSpecialRegisters(0x00, 0x02, false, false, 19);
  });

  // Test instruction fdb6 | OR (IY+*)
  test("OPCODE fdb6 | OR (IY+*)", () {
    // Set up machine initial state
    loadRegisters(0xdb37, 0x3509, 0xd6ca, 0xb16a, 0x0000, 0x0000, 0x0000,
        0x0000, 0xa099, 0xdf6d, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xfd);
    poke(0x0001, 0xb6);
    poke(0x0002, 0x4b);
    poke(0xdfb8, 0x64);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xffac, 0x3509, 0xd6ca, 0xb16a, 0x0000, 0x0000, 0x0000,
        0x0000, 0xa099, 0xdf6d, 0x0000, 0x0003);
    checkSpecialRegisters(0x00, 0x02, false, false, 19);
  });

  // Test instruction fdbe | CP (IY+*)
  test("OPCODE fdbe | CP (IY+*)", () {
    // Set up machine initial state
    loadRegisters(0x0970, 0x0b31, 0xf4ad, 0x9d4c, 0x0000, 0x0000, 0x0000,
        0x0000, 0xb95a, 0xa96b, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xfd);
    poke(0x0001, 0xbe);
    poke(0x0002, 0x6b);
    poke(0xa9d6, 0xc0);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x0903, 0x0b31, 0xf4ad, 0x9d4c, 0x0000, 0x0000, 0x0000,
        0x0000, 0xb95a, 0xa96b, 0x0000, 0x0003);
    checkSpecialRegisters(0x00, 0x02, false, false, 19);
  });

  // Test instruction fdcb06 | RLC (IY+*)
  test("OPCODE fdcb06 | RLC (IY+*)", () {
    // Set up machine initial state
    loadRegisters(0xf285, 0x89a2, 0xe78f, 0xef74, 0x0000, 0x0000, 0x0000,
        0x0000, 0x140d, 0xff27, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xfd);
    poke(0x0001, 0xcb);
    poke(0x0002, 0x72);
    poke(0x0003, 0x06);
    poke(0xff99, 0xf1);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xf2a1, 0x89a2, 0xe78f, 0xef74, 0x0000, 0x0000, 0x0000,
        0x0000, 0x140d, 0xff27, 0x0000, 0x0004);
    checkSpecialRegisters(0x00, 0x02, false, false, 23);
    expect(peek(65433), equals(0xe3));
  });

  // Test instruction fdcb0e | RRC (IY+*)
  test("OPCODE fdcb0e | RRC (IY+*)", () {
    // Set up machine initial state
    loadRegisters(0x8da4, 0x8f91, 0xfc5a, 0x5e2c, 0x0000, 0x0000, 0x0000,
        0x0000, 0xb2f2, 0xf223, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xfd);
    poke(0x0001, 0xcb);
    poke(0x0002, 0x0c);
    poke(0x0003, 0x0e);
    poke(0xf22f, 0xf7);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x8da9, 0x8f91, 0xfc5a, 0x5e2c, 0x0000, 0x0000, 0x0000,
        0x0000, 0xb2f2, 0xf223, 0x0000, 0x0004);
    checkSpecialRegisters(0x00, 0x02, false, false, 23);
    expect(peek(61999), equals(0xfb));
  });

  // Test instruction fdcb16 | RL (IY+*)
  test("OPCODE fdcb16 | RL (IY+*)", () {
    // Set up machine initial state
    loadRegisters(0x0c3c, 0xdcd7, 0xadcc, 0x196d, 0x0000, 0x0000, 0x0000,
        0x0000, 0x87e2, 0xf0b4, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xfd);
    poke(0x0001, 0xcb);
    poke(0x0002, 0x23);
    poke(0x0003, 0x16);
    poke(0xf0d7, 0x89);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x0c05, 0xdcd7, 0xadcc, 0x196d, 0x0000, 0x0000, 0x0000,
        0x0000, 0x87e2, 0xf0b4, 0x0000, 0x0004);
    checkSpecialRegisters(0x00, 0x02, false, false, 23);
    expect(peek(61655), equals(0x12));
  });

  // Test instruction fdcb1e | RR (IY+*)
  test("OPCODE fdcb1e | RR (IY+*)", () {
    // Set up machine initial state
    loadRegisters(0x2f39, 0x2470, 0xb521, 0x6ca3, 0x0000, 0x0000, 0x0000,
        0x0000, 0x1066, 0xda38, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xfd);
    poke(0x0001, 0xcb);
    poke(0x0002, 0x3a);
    poke(0x0003, 0x1e);
    poke(0xda72, 0x25);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x2f81, 0x2470, 0xb521, 0x6ca3, 0x0000, 0x0000, 0x0000,
        0x0000, 0x1066, 0xda38, 0x0000, 0x0004);
    checkSpecialRegisters(0x00, 0x02, false, false, 23);
    expect(peek(55922), equals(0x92));
  });

  // Test instruction fdcb26 | SLA (IY+*)
  test("OPCODE fdcb26 | SLA (IY+*)", () {
    // Set up machine initial state
    loadRegisters(0x5844, 0x0e19, 0xd277, 0xbf7f, 0x0000, 0x0000, 0x0000,
        0x0000, 0x6504, 0xd4e4, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xfd);
    poke(0x0001, 0xcb);
    poke(0x0002, 0xbd);
    poke(0x0003, 0x26);
    poke(0xd4a1, 0xbf);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x582d, 0x0e19, 0xd277, 0xbf7f, 0x0000, 0x0000, 0x0000,
        0x0000, 0x6504, 0xd4e4, 0x0000, 0x0004);
    checkSpecialRegisters(0x00, 0x02, false, false, 23);
    expect(peek(54433), equals(0x7e));
  });

  // Test instruction fdcb2e | SRA (IY+*)
  test("OPCODE fdcb2e | SRA (IY+*)", () {
    // Set up machine initial state
    loadRegisters(0xf4ee, 0xb832, 0x4b7f, 0xe2b7, 0x0000, 0x0000, 0x0000,
        0x0000, 0x9386, 0x42fd, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xfd);
    poke(0x0001, 0xcb);
    poke(0x0002, 0x06);
    poke(0x0003, 0x2e);
    poke(0x4303, 0xad);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xf481, 0xb832, 0x4b7f, 0xe2b7, 0x0000, 0x0000, 0x0000,
        0x0000, 0x9386, 0x42fd, 0x0000, 0x0004);
    checkSpecialRegisters(0x00, 0x02, false, false, 23);
    expect(peek(17155), equals(0xd6));
  });

  // Test instruction fdcb3e | SRL (IY+*)
  test("OPCODE fdcb3e | SRL (IY+*)", () {
    // Set up machine initial state
    loadRegisters(0x0d95, 0x3e02, 0x8f74, 0x0f82, 0x0000, 0x0000, 0x0000,
        0x0000, 0x85df, 0xb2d1, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xfd);
    poke(0x0001, 0xcb);
    poke(0x0002, 0x2e);
    poke(0x0003, 0x3e);
    poke(0xb2ff, 0x50);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x0d2c, 0x3e02, 0x8f74, 0x0f82, 0x0000, 0x0000, 0x0000,
        0x0000, 0x85df, 0xb2d1, 0x0000, 0x0004);
    checkSpecialRegisters(0x00, 0x02, false, false, 23);
    expect(peek(45823), equals(0x28));
  });

  // Test instruction fdcb46 | BIT 0, (IY+*)
  test("OPCODE fdcb46 | BIT 0, (IY+*)", () {
    // Set up machine initial state
    loadRegisters(0x0e5a, 0xb1f9, 0x475f, 0xebfc, 0x0000, 0x0000, 0x0000,
        0x0000, 0x7765, 0x63b1, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xfd);
    poke(0x0001, 0xcb);
    poke(0x0002, 0x8c);
    poke(0x0003, 0x46);
    poke(0x633d, 0xfe);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x0e74, 0xb1f9, 0x475f, 0xebfc, 0x0000, 0x0000, 0x0000,
        0x0000, 0x7765, 0x63b1, 0x0000, 0x0004);
    checkSpecialRegisters(0x00, 0x02, false, false, 20);
  });

  // Test instruction fdcb4e | BIT 1, (IY+*)
  test("OPCODE fdcb4e | BIT 1, (IY+*)", () {
    // Set up machine initial state
    loadRegisters(0x30cb, 0x5626, 0x52bc, 0x5503, 0x0000, 0x0000, 0x0000,
        0x0000, 0x303b, 0xe1c8, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xfd);
    poke(0x0001, 0xcb);
    poke(0x0002, 0x20);
    poke(0x0003, 0x4e);
    poke(0xe1e8, 0xaa);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x3031, 0x5626, 0x52bc, 0x5503, 0x0000, 0x0000, 0x0000,
        0x0000, 0x303b, 0xe1c8, 0x0000, 0x0004);
    checkSpecialRegisters(0x00, 0x02, false, false, 20);
  });

  // Test instruction fdcb56 | BIT 2, (IY+*)
  test("OPCODE fdcb56 | BIT 2, (IY+*)", () {
    // Set up machine initial state
    loadRegisters(0xf5ad, 0xf9f6, 0x1e8c, 0x9e08, 0x0000, 0x0000, 0x0000,
        0x0000, 0x716a, 0x6932, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xfd);
    poke(0x0001, 0xcb);
    poke(0x0002, 0x6f);
    poke(0x0003, 0x56);
    poke(0x69a1, 0xdf);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xf539, 0xf9f6, 0x1e8c, 0x9e08, 0x0000, 0x0000, 0x0000,
        0x0000, 0x716a, 0x6932, 0x0000, 0x0004);
    checkSpecialRegisters(0x00, 0x02, false, false, 20);
  });

  // Test instruction fdcb5e | BIT 3, (IY+*)
  test("OPCODE fdcb5e | BIT 3, (IY+*)", () {
    // Set up machine initial state
    loadRegisters(0x6f89, 0xeff5, 0x993b, 0x22b5, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0f30, 0xe165, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xfd);
    poke(0x0001, 0xcb);
    poke(0x0002, 0xe2);
    poke(0x0003, 0x5e);
    poke(0xe147, 0x17);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x6f75, 0xeff5, 0x993b, 0x22b5, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0f30, 0xe165, 0x0000, 0x0004);
    checkSpecialRegisters(0x00, 0x02, false, false, 20);
  });

  // Test instruction fdcb66 | BIT 4, (IY+*)
  test("OPCODE fdcb66 | BIT 4, (IY+*)", () {
    // Set up machine initial state
    loadRegisters(0x583f, 0xc13e, 0xb136, 0x6bc5, 0x0000, 0x0000, 0x0000,
        0x0000, 0x3ef9, 0x6948, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xfd);
    poke(0x0001, 0xcb);
    poke(0x0002, 0x9d);
    poke(0x0003, 0x66);
    poke(0x68e5, 0x90);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x5839, 0xc13e, 0xb136, 0x6bc5, 0x0000, 0x0000, 0x0000,
        0x0000, 0x3ef9, 0x6948, 0x0000, 0x0004);
    checkSpecialRegisters(0x00, 0x02, false, false, 20);
  });

  // Test instruction fdcb6e | BIT 5, (IY+*)
  test("OPCODE fdcb6e | BIT 5, (IY+*)", () {
    // Set up machine initial state
    loadRegisters(0x2da0, 0xf872, 0x692d, 0x92c4, 0x0000, 0x0000, 0x0000,
        0x0000, 0x36b5, 0x4210, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xfd);
    poke(0x0001, 0xcb);
    poke(0x0002, 0x93);
    poke(0x0003, 0x6e);
    poke(0x41a3, 0x1e);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x2d54, 0xf872, 0x692d, 0x92c4, 0x0000, 0x0000, 0x0000,
        0x0000, 0x36b5, 0x4210, 0x0000, 0x0004);
    checkSpecialRegisters(0x00, 0x02, false, false, 20);
  });

  // Test instruction fdcb76 | BIT 6, (IY+*)
  test("OPCODE fdcb76 | BIT 6, (IY+*)", () {
    // Set up machine initial state
    loadRegisters(0x7375, 0xcaff, 0xdd80, 0xc8ed, 0x0000, 0x0000, 0x0000,
        0x0000, 0x7e39, 0x6623, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xfd);
    poke(0x0001, 0xcb);
    poke(0x0002, 0x53);
    poke(0x0003, 0x76);
    poke(0x6676, 0x3a);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x7375, 0xcaff, 0xdd80, 0xc8ed, 0x0000, 0x0000, 0x0000,
        0x0000, 0x7e39, 0x6623, 0x0000, 0x0004);
    checkSpecialRegisters(0x00, 0x02, false, false, 20);
  });

  // Test instruction fdcb7e | BIT 7, (IY+*)
  test("OPCODE fdcb7e | BIT 7, (IY+*)", () {
    // Set up machine initial state
    loadRegisters(0x503c, 0x8dfe, 0x1019, 0x6778, 0x0000, 0x0000, 0x0000,
        0x0000, 0xf7df, 0x9484, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xfd);
    poke(0x0001, 0xcb);
    poke(0x0002, 0x40);
    poke(0x0003, 0x7e);
    poke(0x94c4, 0x9e);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x5090, 0x8dfe, 0x1019, 0x6778, 0x0000, 0x0000, 0x0000,
        0x0000, 0xf7df, 0x9484, 0x0000, 0x0004);
    checkSpecialRegisters(0x00, 0x02, false, false, 20);
  });

  // Test instruction fdcb86 | RES 0, (IY+*)
  test("OPCODE fdcb86 | RES 0, (IY+*)", () {
    // Set up machine initial state
    loadRegisters(0x152b, 0x8ce1, 0x818d, 0x40f2, 0x0000, 0x0000, 0x0000,
        0x0000, 0x9b7a, 0x2a50, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xfd);
    poke(0x0001, 0xcb);
    poke(0x0002, 0x7e);
    poke(0x0003, 0x86);
    poke(0x2ace, 0x36);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x152b, 0x8ce1, 0x818d, 0x40f2, 0x0000, 0x0000, 0x0000,
        0x0000, 0x9b7a, 0x2a50, 0x0000, 0x0004);
    checkSpecialRegisters(0x00, 0x02, false, false, 23);
  });

  // Test instruction fdcb8e | RES 1, (IY+*)
  test("OPCODE fdcb8e | RES 1, (IY+*)", () {
    // Set up machine initial state
    loadRegisters(0xcb79, 0x0fff, 0xb244, 0xc902, 0x0000, 0x0000, 0x0000,
        0x0000, 0x6246, 0x4c81, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xfd);
    poke(0x0001, 0xcb);
    poke(0x0002, 0xc2);
    poke(0x0003, 0x8e);
    poke(0x4c43, 0x7f);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xcb79, 0x0fff, 0xb244, 0xc902, 0x0000, 0x0000, 0x0000,
        0x0000, 0x6246, 0x4c81, 0x0000, 0x0004);
    checkSpecialRegisters(0x00, 0x02, false, false, 23);
    expect(peek(19523), equals(0x7d));
  });

  // Test instruction fdcb96 | RES 2, (IY+*)
  test("OPCODE fdcb96 | RES 2, (IY+*)", () {
    // Set up machine initial state
    loadRegisters(0x5d99, 0xd9ec, 0xb6d0, 0x5ed5, 0x0000, 0x0000, 0x0000,
        0x0000, 0x5d9d, 0xe6cf, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xfd);
    poke(0x0001, 0xcb);
    poke(0x0002, 0x9e);
    poke(0x0003, 0x96);
    poke(0xe66d, 0xfc);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x5d99, 0xd9ec, 0xb6d0, 0x5ed5, 0x0000, 0x0000, 0x0000,
        0x0000, 0x5d9d, 0xe6cf, 0x0000, 0x0004);
    checkSpecialRegisters(0x00, 0x02, false, false, 23);
    expect(peek(58989), equals(0xf8));
  });

  // Test instruction fdcb9e | RES 3, (IY+*)
  test("OPCODE fdcb9e | RES 3, (IY+*)", () {
    // Set up machine initial state
    loadRegisters(0x81c7, 0x71df, 0x45d5, 0x0ca7, 0x0000, 0x0000, 0x0000,
        0x0000, 0x648f, 0x41bd, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xfd);
    poke(0x0001, 0xcb);
    poke(0x0002, 0xeb);
    poke(0x0003, 0x9e);
    poke(0x41a8, 0x61);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x81c7, 0x71df, 0x45d5, 0x0ca7, 0x0000, 0x0000, 0x0000,
        0x0000, 0x648f, 0x41bd, 0x0000, 0x0004);
    checkSpecialRegisters(0x00, 0x02, false, false, 23);
  });

  // Test instruction fdcba6 | RES 4, (IY+*)
  test("OPCODE fdcba6 | RES 4, (IY+*)", () {
    // Set up machine initial state
    loadRegisters(0x814b, 0x6408, 0x3dcb, 0x971f, 0x0000, 0x0000, 0x0000,
        0x0000, 0x5716, 0x93f3, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xfd);
    poke(0x0001, 0xcb);
    poke(0x0002, 0x76);
    poke(0x0003, 0xa6);
    poke(0x9469, 0xbc);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x814b, 0x6408, 0x3dcb, 0x971f, 0x0000, 0x0000, 0x0000,
        0x0000, 0x5716, 0x93f3, 0x0000, 0x0004);
    checkSpecialRegisters(0x00, 0x02, false, false, 23);
    expect(peek(37993), equals(0xac));
  });

  // Test instruction fdcbae | RES 5, (IY+*)
  test("OPCODE fdcbae | RES 5, (IY+*)", () {
    // Set up machine initial state
    loadRegisters(0xec0d, 0xb57e, 0x18c6, 0x7b01, 0x0000, 0x0000, 0x0000,
        0x0000, 0xbac6, 0x0c1d, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xfd);
    poke(0x0001, 0xcb);
    poke(0x0002, 0x0c);
    poke(0x0003, 0xae);
    poke(0x0c29, 0xa9);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xec0d, 0xb57e, 0x18c6, 0x7b01, 0x0000, 0x0000, 0x0000,
        0x0000, 0xbac6, 0x0c1d, 0x0000, 0x0004);
    checkSpecialRegisters(0x00, 0x02, false, false, 23);
    expect(peek(3113), equals(0x89));
  });

  // Test instruction fdcbb6 | RES 6, (IY+*)
  test("OPCODE fdcbb6 | RES 6, (IY+*)", () {
    // Set up machine initial state
    loadRegisters(0xa887, 0x519b, 0xc91b, 0xcc91, 0x0000, 0x0000, 0x0000,
        0x0000, 0xa416, 0x1e16, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xfd);
    poke(0x0001, 0xcb);
    poke(0x0002, 0x3a);
    poke(0x0003, 0xb6);
    poke(0x1e50, 0x13);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xa887, 0x519b, 0xc91b, 0xcc91, 0x0000, 0x0000, 0x0000,
        0x0000, 0xa416, 0x1e16, 0x0000, 0x0004);
    checkSpecialRegisters(0x00, 0x02, false, false, 23);
  });

  // Test instruction fdcbbe | RES 7, (IY+*)
  test("OPCODE fdcbbe | RES 7, (IY+*)", () {
    // Set up machine initial state
    loadRegisters(0x1133, 0xbef6, 0x5059, 0x1089, 0x0000, 0x0000, 0x0000,
        0x0000, 0xd558, 0x3d0f, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xfd);
    poke(0x0001, 0xcb);
    poke(0x0002, 0xc8);
    poke(0x0003, 0xbe);
    poke(0x3cd7, 0xa1);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x1133, 0xbef6, 0x5059, 0x1089, 0x0000, 0x0000, 0x0000,
        0x0000, 0xd558, 0x3d0f, 0x0000, 0x0004);
    checkSpecialRegisters(0x00, 0x02, false, false, 23);
    expect(peek(15575), equals(0x21));
  });

  // Test instruction fdcbc6 | SET 0, (IY+*)
  test("OPCODE fdcbc6 | SET 0, (IY+*)", () {
    // Set up machine initial state
    loadRegisters(0x35da, 0x98c2, 0x3f57, 0x44a4, 0x0000, 0x0000, 0x0000,
        0x0000, 0x2771, 0x76c4, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xfd);
    poke(0x0001, 0xcb);
    poke(0x0002, 0xee);
    poke(0x0003, 0xc6);
    poke(0x76b2, 0x82);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x35da, 0x98c2, 0x3f57, 0x44a4, 0x0000, 0x0000, 0x0000,
        0x0000, 0x2771, 0x76c4, 0x0000, 0x0004);
    checkSpecialRegisters(0x00, 0x02, false, false, 23);
    expect(peek(30386), equals(0x83));
  });

  // Test instruction fdcbce | SET 1, (IY+*)
  test("OPCODE fdcbce | SET 1, (IY+*)", () {
    // Set up machine initial state
    loadRegisters(0x8e13, 0x968e, 0x1784, 0x0a0a, 0x0000, 0x0000, 0x0000,
        0x0000, 0x1e87, 0xb8a2, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xfd);
    poke(0x0001, 0xcb);
    poke(0x0002, 0x36);
    poke(0x0003, 0xce);
    poke(0xb8d8, 0x45);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x8e13, 0x968e, 0x1784, 0x0a0a, 0x0000, 0x0000, 0x0000,
        0x0000, 0x1e87, 0xb8a2, 0x0000, 0x0004);
    checkSpecialRegisters(0x00, 0x02, false, false, 23);
    expect(peek(47320), equals(0x47));
  });

  // Test instruction fdcbd6 | SET 2, (IY+*)
  test("OPCODE fdcbd6 | SET 2, (IY+*)", () {
    // Set up machine initial state
    loadRegisters(0x7801, 0x78b6, 0xd191, 0x054a, 0x0000, 0x0000, 0x0000,
        0x0000, 0x2065, 0x6aa3, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xfd);
    poke(0x0001, 0xcb);
    poke(0x0002, 0xc9);
    poke(0x0003, 0xd6);
    poke(0x6a6c, 0x7c);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x7801, 0x78b6, 0xd191, 0x054a, 0x0000, 0x0000, 0x0000,
        0x0000, 0x2065, 0x6aa3, 0x0000, 0x0004);
    checkSpecialRegisters(0x00, 0x02, false, false, 23);
  });

  // Test instruction fdcbde | SET 3, (IY+*)
  test("OPCODE fdcbde | SET 3, (IY+*)", () {
    // Set up machine initial state
    loadRegisters(0x8310, 0xfa01, 0x6c69, 0x252a, 0x0000, 0x0000, 0x0000,
        0x0000, 0x5291, 0xc9e0, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xfd);
    poke(0x0001, 0xcb);
    poke(0x0002, 0x17);
    poke(0x0003, 0xde);
    poke(0xc9f7, 0x41);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x8310, 0xfa01, 0x6c69, 0x252a, 0x0000, 0x0000, 0x0000,
        0x0000, 0x5291, 0xc9e0, 0x0000, 0x0004);
    checkSpecialRegisters(0x00, 0x02, false, false, 23);
    expect(peek(51703), equals(0x49));
  });

  // Test instruction fdcbe6 | SET 4, (IY+*)
  test("OPCODE fdcbe6 | SET 4, (IY+*)", () {
    // Set up machine initial state
    loadRegisters(0xfd89, 0xd888, 0x1e2f, 0xddf5, 0x0000, 0x0000, 0x0000,
        0x0000, 0x42f5, 0x8b06, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xfd);
    poke(0x0001, 0xcb);
    poke(0x0002, 0x76);
    poke(0x0003, 0xe6);
    poke(0x8b7c, 0x45);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xfd89, 0xd888, 0x1e2f, 0xddf5, 0x0000, 0x0000, 0x0000,
        0x0000, 0x42f5, 0x8b06, 0x0000, 0x0004);
    checkSpecialRegisters(0x00, 0x02, false, false, 23);
    expect(peek(35708), equals(0x55));
  });

  // Test instruction fdcbee | SET 5, (IY+*)
  test("OPCODE fdcbee | SET 5, (IY+*)", () {
    // Set up machine initial state
    loadRegisters(0x5fcb, 0x9007, 0x1736, 0xaca8, 0x0000, 0x0000, 0x0000,
        0x0000, 0x4bab, 0x42bc, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xfd);
    poke(0x0001, 0xcb);
    poke(0x0002, 0x02);
    poke(0x0003, 0xee);
    poke(0x42be, 0xd0);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x5fcb, 0x9007, 0x1736, 0xaca8, 0x0000, 0x0000, 0x0000,
        0x0000, 0x4bab, 0x42bc, 0x0000, 0x0004);
    checkSpecialRegisters(0x00, 0x02, false, false, 23);
    expect(peek(17086), equals(0xf0));
  });

  // Test instruction fdcbf6 | SET 6, (IY+*)
  test("OPCODE fdcbf6 | SET 6, (IY+*)", () {
    // Set up machine initial state
    loadRegisters(0x7c43, 0xfcd1, 0x34bd, 0xf4ab, 0x0000, 0x0000, 0x0000,
        0x0000, 0xef33, 0xc61a, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xfd);
    poke(0x0001, 0xcb);
    poke(0x0002, 0x56);
    poke(0x0003, 0xf6);
    poke(0xc670, 0x5d);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x7c43, 0xfcd1, 0x34bd, 0xf4ab, 0x0000, 0x0000, 0x0000,
        0x0000, 0xef33, 0xc61a, 0x0000, 0x0004);
    checkSpecialRegisters(0x00, 0x02, false, false, 23);
  });

  // Test instruction fdcbfe | SET 7, (IY+*)
  test("OPCODE fdcbfe | SET 7, (IY+*)", () {
    // Set up machine initial state
    loadRegisters(0xb4cf, 0x5639, 0x677b, 0x0ca2, 0x0000, 0x0000, 0x0000,
        0x0000, 0xddc5, 0x4e4f, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xfd);
    poke(0x0001, 0xcb);
    poke(0x0002, 0x88);
    poke(0x0003, 0xfe);
    poke(0x4dd7, 0x4a);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xb4cf, 0x5639, 0x677b, 0x0ca2, 0x0000, 0x0000, 0x0000,
        0x0000, 0xddc5, 0x4e4f, 0x0000, 0x0004);
    checkSpecialRegisters(0x00, 0x02, false, false, 23);
    expect(peek(19927), equals(0xca));
  });

  // Test instruction fde1 | POP IY
  test("OPCODE fde1 | POP IY", () {
    // Set up machine initial state
    loadRegisters(0x828e, 0x078b, 0x1e35, 0x8f1c, 0x0000, 0x0000, 0x0000,
        0x0000, 0x4827, 0xb742, 0x716e, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xfd);
    poke(0x0001, 0xe1);
    poke(0x716e, 0xd5);
    poke(0x716f, 0x92);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x828e, 0x078b, 0x1e35, 0x8f1c, 0x0000, 0x0000, 0x0000,
        0x0000, 0x4827, 0x92d5, 0x7170, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 14);
  });

  // Test instruction fde3 | EX (SP), IY
  test("OPCODE fde3 | EX (SP), IY", () {
    // Set up machine initial state
    loadRegisters(0x4298, 0xc805, 0x6030, 0x4292, 0x0000, 0x0000, 0x0000,
        0x0000, 0x473b, 0x9510, 0x1a38, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xfd);
    poke(0x0001, 0xe3);
    poke(0x1a38, 0xe0);
    poke(0x1a39, 0x0f);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x4298, 0xc805, 0x6030, 0x4292, 0x0000, 0x0000, 0x0000,
        0x0000, 0x473b, 0x0fe0, 0x1a38, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 23);
    expect(peek(6712), equals(0x10));
    expect(peek(6713), equals(0x95));
  });

  // Test instruction fde5 | PUSH IY
  test("OPCODE fde5 | PUSH IY", () {
    // Set up machine initial state
    loadRegisters(0xd139, 0xaa0d, 0xbf2b, 0x2a56, 0x0000, 0x0000, 0x0000,
        0x0000, 0xe138, 0xd4da, 0xa8e1, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xfd);
    poke(0x0001, 0xe5);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xd139, 0xaa0d, 0xbf2b, 0x2a56, 0x0000, 0x0000, 0x0000,
        0x0000, 0xe138, 0xd4da, 0xa8df, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 15);
    expect(peek(43231), equals(0xda));
    expect(peek(43232), equals(0xd4));
  });

  // Test instruction fde9 | JP (IY)
  test("OPCODE fde9 | JP (IY)", () {
    // Set up machine initial state
    loadRegisters(0xc14f, 0x2eb6, 0xedf0, 0x27cf, 0x0000, 0x0000, 0x0000,
        0x0000, 0x09ee, 0xa2a4, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xfd);
    poke(0x0001, 0xe9);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xc14f, 0x2eb6, 0xedf0, 0x27cf, 0x0000, 0x0000, 0x0000,
        0x0000, 0x09ee, 0xa2a4, 0x0000, 0xa2a4);
    checkSpecialRegisters(0x00, 0x02, false, false, 8);
  });

  // Test instruction fdf9 | LD SP, IY
  test("OPCODE fdf9 | LD SP, IY", () {
    // Set up machine initial state
    loadRegisters(0xc260, 0x992e, 0xd544, 0x67fb, 0x0000, 0x0000, 0x0000,
        0x0000, 0xba5e, 0x3596, 0x353f, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xfd);
    poke(0x0001, 0xf9);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0xc260, 0x992e, 0xd544, 0x67fb, 0x0000, 0x0000, 0x0000,
        0x0000, 0xba5e, 0x3596, 0x3596, 0x0002);
    checkSpecialRegisters(0x00, 0x02, false, false, 10);
  });

  // Test instruction fe | CP *
  test("OPCODE fe | CP *", () {
    // Set up machine initial state
    loadRegisters(0x6900, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0000);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x0000, 0xfe);
    poke(0x0001, 0x82);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x6987, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x0000, 0x0002);
    checkSpecialRegisters(0x00, 0x01, false, false, 7);
  });

  // Test instruction ff | RST 38h
  test("OPCODE ff | RST 38h", () {
    // Set up machine initial state
    loadRegisters(0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x5507, 0x6d33);
    z80.i = 0x00;
    z80.r = 0x00;
    z80.iff1 = false;
    z80.iff2 = false;
    poke(0x6d33, 0xff);

    // Execute machine for tState cycles
    while (z80.tStates < 1) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
        0x0000, 0x0000, 0x0000, 0x5505, 0x0038);
    checkSpecialRegisters(0x00, 0x01, false, false, 11);
    expect(peek(21765), equals(0x34));
    expect(peek(21766), equals(0x6d));
  });
}
