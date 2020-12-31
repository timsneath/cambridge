import 'dart:io';
import 'package:spectrum/core/disassembler.dart';

// ignore_for_file: non_constant_identifier_names
// This stops complaints about our convention of naming registers like AF' as
// af_

const bool includeUndocumentedOpcodeUnitTests = false;

String toHex16(int value) => value.toRadixString(16).padLeft(2, '0');
String toHex32(int value) => value.toRadixString(16).padLeft(4, '0');
String toBin16(int value) => value.toRadixString(2).padLeft(16, '0');
String toBin32(int value) => value.toRadixString(2).padLeft(32, '0');

void main2() {
  final file = File('test/fuse_z80_opcode_test.dart');
  final sink = file.openWrite();

  String testName;

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
          "Register F: expected ${toBin8(lowByte(af))}, actual ${toBin8(lowByte(z80.af))}");
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

""");

  // These unit tests stress undocumented Z80 opcodes
  final undocumentedOpcodeTests = [
    "4c", "4e", "54", "5c", "63", "64", "6b", "6c",
    "6e", "70", "71", "74", "7c", // main

    "cb30", "cb31", "cb32", "cb33", "cb34", "cb35", "cb36", "cb37", //cb

    "dd24", "dd25", "dd26", "dd2c", "dd2d", "dd2e",
    "dd44", "dd45", "dd4c", "dd4d",
    "dd54", "dd55", "dd5c", "dd5d",
    "dd60", "dd61", "dd62", "dd63", "dd64", "dd65", "dd67", "dd68",
    "dd69", "dd6a", "dd6b", "dd6c", "dd6d", "dd6f",
    "dd7c", "dd7d",
    "dd84", "dd85", "dd8c", "dd8d",
    "dd94", "dd95", "dd9c", "dd9d",
    "dda4", "dda5", "ddac", "ddad",
    "ddb4", "ddb5", "ddbc", "ddbd",
    "ddcb36", "ddfd00", // dd

    "fd24", "fd25", "fd26", "fd2c", "fd2d", "fd2e",
    "fd44", "fd45", "fd4c", "fd4d",
    "fd54", "fd55", "fd5c", "fd5d",
    "fd60", "fd61", "fd62", "fd63", "fd64", "fd65", "fd67", "fd68",
    "fd69", "fd6a", "fd6b", "fd6c", "fd6d", "fd6f",
    "fd7c", "fd7d",
    "fd84", "fd85", "fd8c", "fd8d",
    "fd94", "fd95", "fd9c", "fd9d",
    "fda4", "fda5", "fdac", "fdad",
    "fdb4", "fdb5", "fdbc", "fdbd",
    "fdcb36" // fd
  ];

  // These too...
  for (var opCode = 0; opCode < 256; opCode++) {
    if ((opCode & 0x7) != 0x6) {
      undocumentedOpcodeTests.add("ddcb${toHex16(opCode)}");
      undocumentedOpcodeTests.add("fdcb${toHex16(opCode)}");
    }
  }

  final input =
      File('tool/generate_tests/fuse_tests/tests.in').readAsLinesSync();
  final expected =
      File('tool/generate_tests/fuse_tests/tests.expected').readAsLinesSync();

  try {
    var inputLine = 0;
    var expectedLine = 0;

    while (inputLine < input.length) {
      testName = input[inputLine++];
      final instr = Disassembler.z80Opcodes[testName];
      sink.write("\n  // Test instruction $testName | "
          "${instr ?? '<UNKNOWN>'}\n");
      sink.write('  test("');
      if (undocumentedOpcodeTests.contains(testName)) {
        sink.write('UNDOCUMENTED ');
      } else {
        sink.write('OPCODE ');
      }
      sink.write(testName);
      if (instr != null) {
        sink.write(" | $instr");
      }
      sink.write('", () {\n');

      sink.write("    // Set up machine initial state\n");
      final registers = input[inputLine++].split(' ');
      sink.write("    loadRegisters(");
      sink.write("0x${registers[0]}, ");
      sink.write("0x${registers[1]}, ");
      sink.write("0x${registers[2]}, ");
      sink.write("0x${registers[3]}, ");
      sink.write("0x${registers[4]}, ");
      sink.write("0x${registers[5]}, ");
      sink.write("0x${registers[6]}, ");
      sink.write("0x${registers[7]}, ");
      sink.write("0x${registers[8]}, ");
      sink.write("0x${registers[9]}, ");
      sink.write("0x${registers[10]}, ");
      sink.write("0x${registers[11]});\n");

      final special = input[inputLine++].split(' ');
      special.removeWhere((item) => item.isEmpty);

      sink.write("    z80.i = 0x${special[0]};\n");
      sink.write("    z80.r = 0x${special[1]};\n");
      sink.write("    z80.iff1 = ${special[2] == '1' ? 'true' : 'false'};\n");
      sink.write("    z80.iff2 = ${special[3] == '1' ? 'true' : 'false'};\n");
      final testRunLength = int.parse(special[6]);

      while (!input[inputLine].startsWith('-1')) {
        final pokes = input[inputLine].split(' ');
        var addr = int.parse(pokes[0], radix: 16);
        var idx = 1;
        while (pokes[idx] != '-1') {
          sink.write("    poke(0x${toHex32(addr)}, 0x${pokes[idx]});\n");
          idx++;
          addr++;
        }
        inputLine++;
      }
      inputLine++;
      inputLine++;

      sink.write("\n    // Execute machine for tState cycles\n");
      sink.write("    while (z80.tStates < $testRunLength) {\n");
      sink.write("      z80.executeNextInstruction();\n");
      sink.write("    }\n");

      if (expected[expectedLine++] != testName) {
        throw Exception("Mismatch of input and output lines: $testName and "
            "${expected[expectedLine - 1]}");
      }

      while (expected[expectedLine].startsWith(' ')) {
        expectedLine++;
      }

      sink.write("\n    // Test machine state is as expected\n");
      final expectedRegisters = expected[expectedLine].split(' ');
      expectedRegisters.removeWhere((item) => item.isEmpty);
      sink.write("    checkRegisters(");
      sink.write("0x${expectedRegisters[0]}, ");
      sink.write("0x${expectedRegisters[1]}, ");
      sink.write("0x${expectedRegisters[2]}, ");
      sink.write("0x${expectedRegisters[3]}, ");
      sink.write("0x${expectedRegisters[4]}, ");
      sink.write("0x${expectedRegisters[5]}, ");
      sink.write("0x${expectedRegisters[6]}, ");
      sink.write("0x${expectedRegisters[7]}, ");
      sink.write("0x${expectedRegisters[8]}, ");
      sink.write("0x${expectedRegisters[9]}, ");
      sink.write("0x${expectedRegisters[10]}, ");
      sink.write("0x${expectedRegisters[11]});\n");
      expectedLine++;

      final expectedSpecial = expected[expectedLine].split(' ');
      expectedSpecial.removeWhere((item) => item.isEmpty);
      sink.write("    checkSpecialRegisters(");
      sink.write("0x${expectedSpecial[0]}, ");
      sink.write("0x${expectedSpecial[1]}, ");
      sink.write("${expectedSpecial[2] == '1' ? 'true' : 'false'}, ");
      sink.write("${expectedSpecial[3] == '1' ? 'true' : 'false'}, ");
      sink.write("${expectedSpecial[6]});\n");
      expectedLine++;

      while (expected[expectedLine].isNotEmpty &&
          ((expected[expectedLine].codeUnitAt(0) >= '0'.codeUnits[0] &&
                  expected[expectedLine].codeUnitAt(0) <= '9'.codeUnits[0]) ||
              (expected[expectedLine].codeUnitAt(0) >= 'a'.codeUnits[0] &&
                  expected[expectedLine].codeUnitAt(0) <= 'f'.codeUnits[0]))) {
        final peeks = expected[expectedLine].split(' ');
        peeks.removeWhere((item) => item.isEmpty);
        var addr = int.parse(peeks[0], radix: 16);
        var idx = 1;
        while (peeks[idx] != "-1") {
          sink.write("    expect(peek($addr), equals(0x${peeks[idx]}));\n");
          idx++;
          addr++;
        }
        expectedLine++;
      }
      expectedLine++;

      sink.write("  }");

      if (undocumentedOpcodeTests.contains(testName)) {
        if (!includeUndocumentedOpcodeUnitTests) {
          sink.write(", skip: 'undocumented'");
        } else {
          sink.write(", tags: 'undocumented'");
        }
      }

      sink.write(");\n\n");
    }

    sink.write("""
}
  """);
  } finally {
    sink.close();
  }
}

class Registers {
  final int af;
  final int bc;
  final int de;
  final int hl;
  final int af_;
  final int bc_;
  final int de_;
  final int hl_;
  final int ix;
  final int iy;
  final int sp;
  final int pc;

  Registers(
      {this.af = 0,
      this.bc = 0,
      this.de = 0,
      this.hl = 0,
      this.af_ = 0,
      this.bc_ = 0,
      this.de_ = 0,
      this.hl_ = 0,
      this.ix = 0,
      this.iy = 0,
      this.sp = 0,
      this.pc = 0});
}

class SpecialRegisters {
  final int i;
  final int r;
  final int iff1;
  final int iff2;
  final int im;
  final bool halted;
  final int tStates;

  SpecialRegisters(
      {this.i = 0,
      this.r = 0,
      this.iff1 = 0,
      this.iff2 = 0,
      this.im = 0,
      this.halted = false,
      this.tStates = 0});
}

class FuseTest {
  final String testName;
  final Registers registers;
  final SpecialRegisters specialRegisters;
  final Map<int, List<int>> memorySetup;

  FuseTest(
      this.testName, this.registers, this.specialRegisters, this.memorySetup);
}

final tests = <FuseTest>[];

void loadTests() {
  final input =
      File('tool/generate_tests/fuse_tests/tests.in').readAsLinesSync();
  var inputLine = 0;

  try {
    while (inputLine < input.length) {
      final testName = input[inputLine++];

      final registersRaw = input[inputLine++].trimRight().split(' ');
      assert(registersRaw.length == 13); // we discard MEMPTR

      final reg = registersRaw.map((val) => int.parse(val, radix: 16)).toList();
      final registers = Registers(
          af: reg[0],
          bc: reg[1],
          de: reg[2],
          hl: reg[3],
          af_: reg[4],
          bc_: reg[5],
          de_: reg[6],
          hl_: reg[7],
          ix: reg[8],
          iy: reg[9],
          sp: reg[10],
          pc: reg[11]);

      final specialRaw = input[inputLine++].trimRight().split(' ');
      specialRaw.removeWhere((item) => item.isEmpty);
      final spec = specialRaw.map((val) => int.parse(val, radix: 16)).toList();
      assert(spec.length == 7);

      final specialRegisters = SpecialRegisters(
          i: spec[0],
          r: spec[1],
          iff1: spec[2],
          iff2: spec[3],
          im: spec[4],
          halted: spec[5] == 1,
          tStates: spec[6]);

      final map = <int, List<int>>{};

      while (!input[inputLine].startsWith('-1')) {
        final pokes = input[inputLine].split(' ');
        final addr = int.parse(pokes[0], radix: 16);
        final values =
            pokes.sublist(1).map((poke) => int.parse(poke, radix: 16)).toList();
        map[addr] = values;
        inputLine++;
      }

      inputLine += 2;
      final test = FuseTest(testName, registers, specialRegisters, map);
      tests.add(test);
    }
    print('Loaded ${tests.length} tests.');
  } catch (id) {
    print('Line $inputLine: ');
    print('  ${input[inputLine - 2]}');
    print('  ${input[inputLine - 1]}');
    print('> ${input[inputLine]}');
    print('  ${input[inputLine + 1]}');
    print('  ${input[inputLine + 2]}');
    rethrow;
  }
}

void main() {
  loadTests();
}
