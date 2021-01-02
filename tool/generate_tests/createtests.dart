import 'dart:io';
import 'package:spectrum/core/disassembler.dart';

import 'loadtests.dart';

const bool includeUndocumentedOpcodeUnitTests = false;
String toHex32(int value) => '0x${value.toRadixString(16).padLeft(4, '0')}';
String toHex16(int value) => '0x${value.toRadixString(16).padLeft(2, '0')}';

void main() {
  final tests = loadTests();

  if (!includeUndocumentedOpcodeUnitTests) {
    tests.removeWhere((test) => test.isUndocumented);
  }

  final file = File('test/fuse_z80_opcode_test.dart');
  final sink = file.openWrite();
  try {
    sink.write(r"""
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

void loadRegisters({int af = 0, int bc = 0, int de = 0, int hl = 0, 
                    int af_ = 0, int bc_ = 0, int de_ = 0, int hl_ = 0, 
                    int ix = 0, int iy = 0, int sp = 0, int pc = 0}) {
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

void checkRegisters({int af = 0, int bc = 0, int de = 0, int hl = 0, 
                    int af_ = 0, int bc_ = 0, int de_ = 0, int hl_ = 0, 
                    int ix = 0, int iy = 0, int sp = 0, int pc = 0}) {
  expect(highByte(z80.af), equals(highByte(af)),
      reason:
          "Register A: expected ${toHex8(highByte(af))}, "
          "actual ${toHex8(highByte(z80.af))}");
  expect(lowByte(z80.af), equals(lowByte(af)),
      reason:
          "Register F [SZ5H3PNC]: expected ${toBin8(lowByte(af))}, "
          "actual ${toBin8(lowByte(z80.af))}");
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
void checkSpecialRegisters({int i = 0, int r = 0, bool iff1 = false, 
                            bool iff2 = false, int tStates = 0}) {
  expect(z80.i, equals(i), reason: "Register I mismatch");

  // TODO: r is "magic" and we haven't finished doing magic yet
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
""");

    for (final test in tests) {
      final testName = test.testName;
      var rootTestName = testName;
      if (test.testName.contains('_')) {
        final idx = test.testName.indexOf('_');
        rootTestName = testName.substring(0, idx);
      }
      final instr = Disassembler.z80Opcodes[rootTestName];

      sink.write("""

  // Test instruction $testName | ${instr ?? '<UNKNOWN>'}
  test("${test.isUndocumented ? 'UNDOCUMENTED' : 'OPCODE'} "
       "$testName${instr != null ? ' | $instr' : ''}", () {
    // Set up machine initial state
    loadRegisters(af: ${toHex32(test.input.reg.af)}, 
                  bc: ${toHex32(test.input.reg.bc)}, 
                  de: ${toHex32(test.input.reg.de)}, 
                  hl: ${toHex32(test.input.reg.hl)}, 
                  af_: ${toHex32(test.input.reg.af_)}, 
                  bc_: ${toHex32(test.input.reg.bc_)}, 
                  de_: ${toHex32(test.input.reg.de_)},
                  hl_: ${toHex32(test.input.reg.hl_)}, 
                  ix: ${toHex32(test.input.reg.ix)}, 
                  iy: ${toHex32(test.input.reg.iy)}, 
                  sp: ${toHex32(test.input.reg.sp)}, 
                  pc: ${toHex32(test.input.reg.pc)});
    z80.i = ${toHex16(test.input.spec.i)};
    z80.r = ${toHex16(test.input.spec.r)};
    z80.iff1 = ${test.input.spec.iff1 == 1 ? 'true' : 'false'};
    z80.iff2 = ${test.input.spec.iff2 == 1 ? 'true' : 'false'};
""");

      for (final startAddress in test.input.initialMemorySetup.keys) {
        var addr = startAddress;
        for (final poke in test.input.initialMemorySetup[addr]!) {
          sink.write("""
    poke(${toHex32(addr++)}, ${toHex16(poke)});
""");
        }
      }

      sink.write("""

    // Execute machine for tState cycles
    while (z80.tStates < ${test.input.spec.tStates}) {
      z80.executeNextInstruction();
    }

    // Test machine state is as expected
    checkRegisters(af: ${toHex32(test.results.reg.af)},
                   bc: ${toHex32(test.results.reg.bc)},
                   de: ${toHex32(test.results.reg.de)},
                   hl: ${toHex32(test.results.reg.hl)},
                   af_: ${toHex32(test.results.reg.af_)},
                   bc_: ${toHex32(test.results.reg.bc_)},
                   de_: ${toHex32(test.results.reg.de_)},
                   hl_: ${toHex32(test.results.reg.hl_)},
                   ix: ${toHex32(test.results.reg.ix)},
                   iy: ${toHex32(test.results.reg.iy)},
                   sp: ${toHex32(test.results.reg.sp)},
                   pc: ${toHex32(test.results.reg.pc)});
    checkSpecialRegisters(i: ${toHex16(test.results.spec.i)},
                          r: ${toHex16(test.results.spec.r)},
                          iff1: ${test.results.spec.iff1 == 1 ? 'true' : 'false'},
                          iff2: ${test.results.spec.iff2 == 1 ? 'true' : 'false'},
                          tStates: ${test.results.spec.tStates});
""");
      for (final addr in test.results.expectedMemory.keys) {
        sink.write("""
    expect(peek($addr), equals(0x${test.results.expectedMemory[addr]!}));
""");
      }
      sink.write("""
  }${test.isUndocumented ? ", skip: 'undocumented'" : ''});
""");
    }
    sink.write('}\n');
    print('Generated ${file.uri}.');
  } finally {
    sink.close();
  }
}
