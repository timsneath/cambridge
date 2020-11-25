import 'dart:io';

const bool includeUndocumentedOpcodeUnitTests = false;

String toHex16(int value) => value.toRadixString(16).padLeft(2, '0');
String toHex32(int value) => value.toRadixString(16).padLeft(4, '0');
String toBin16(int value) => value.toRadixString(2).padLeft(16, '0');
String toBin32(int value) => value.toRadixString(2).padLeft(32, '0');

main() {
  var file = File('../fuse_z80_opcode_test.dart');
  var sink = file.openWrite();

  String testName;

  sink.write(r"""
// fuse_unit_test.dart -- translated Z80 unit tests from FUSE Z80 emulator
// 
// The FUSE emulator contains a large unit test suite of over 1,300 tests,
// which cover both documented and undocumented opcodes:
//   http://fuse-emulator.sourceforge.net/ 

// Run tests with `flutter test --plain-name=OPCODE` (for documented tests)

import 'package:flutter_test/flutter_test.dart';
import 'package:spectrum/spectrum/z80.dart';
import 'package:spectrum/spectrum/memory.dart';
import 'package:spectrum/spectrum/utility.dart';

Memory memory = Memory(false);
Z80 z80 = Z80(memory, startAddress: 0xA000);

void poke(int addr, int val) => memory.writeByte(addr, val);
int peek(int addr) => memory.readByte(addr);

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

void checkSpecialRegisters(int i, int r, bool iff1, bool iff2, int tStates) {
  expect(z80.i, equals(i), reason: "Register I mismatch");

  // TODO: r is magic and we haven't done magic yet
  // expect(z80.r, equals(r));

  expect(z80.iff1, equals(iff1), reason: "Register IFF1 mismatch");
  expect(z80.iff2, equals(iff2), reason: "Register IFF2 mismatch");
  expect(z80.tStates, equals(tStates), reason: "tStates mismatch");
}

main() {
  setUp(() {
    z80.reset();
    memory.reset();
  });
  tearDown(() {});

""");

  // These unit tests stress undocumented Z80 opcodes
  var undocumentedOpcodeTests = [
    "4c",
    "4e",
    "54",
    "5c",
    "63",
    "64",
    "6b",
    "6c",
    "6e",
    "70",
    "71",
    "74",
    "7c",
    "cb30",
    "cb31",
    "cb32",
    "cb33",
    "cb34",
    "cb35",
    "cb36",
    "cb37",
    "dd24",
    "dd25",
    "dd26",
    "dd2c",
    "dd2d",
    "dd2e",
    "dd44",
    "dd45",
    "dd4c",
    "dd4d",
    "dd54",
    "dd55",
    "dd5c",
    "dd5d",
    "dd60",
    "dd61",
    "dd62",
    "dd63",
    "dd64",
    "dd65",
    "dd67",
    "dd68",
    "dd69",
    "dd6a",
    "dd6b",
    "dd6c",
    "dd6d",
    "dd6f",
    "dd7c",
    "dd7d",
    "dd84",
    "dd85",
    "dd8c",
    "dd8d",
    "dd94",
    "dd95",
    "dd9c",
    "dd9d",
    "dda4",
    "dda5",
    "ddac",
    "ddad",
    "ddb4",
    "ddb5",
    "ddbc",
    "ddbd",
    "ddfd00",
    "fd24",
    "fd25",
    "fd26",
    "fd2c",
    "fd2d",
    "fd2e",
    "fd44",
    "fd45",
    "fd4c",
    "fd4d",
    "fd54",
    "fd55",
    "fd5c",
    "fd5d",
    "fd60",
    "fd61",
    "fd62",
    "fd63",
    "fd64",
    "fd65",
    "fd67",
    "fd68",
    "fd69",
    "fd6a",
    "fd6b",
    "fd6c",
    "fd6d",
    "fd6f",
    "fd7c",
    "fd7d",
    "fd84",
    "fd85",
    "fd8c",
    "fd8d",
    "fd94",
    "fd95",
    "fd9c",
    "fd9d",
    "fda4",
    "fda5",
    "fdac",
    "fdad",
    "fdb4",
    "fdb5",
    "fdbc",
    "fdbd",
    "ddcb36",
    "fdcb36"
  ];

  // These too...
  for (int opCode = 0; opCode < 256; opCode++) {
    if ((opCode & 0x7) != 0x6) {
      undocumentedOpcodeTests.add("ddcb${toHex16(opCode)}");
      undocumentedOpcodeTests.add("fdcb${toHex16(opCode)}");
    }
  }

  List<String> input = File('tests.in').readAsLinesSync();
  List<String> expected = File('tests.expected').readAsLinesSync();

  try {
    int inputLine = 0;
    int expectedLine = 0;

    while (inputLine < input.length) {
      testName = input[inputLine++];
      sink.write("\n  // Test instruction $testName\n");
      sink.write("  test('");
      if (undocumentedOpcodeTests.contains(testName)) {
        sink.write('UNDOCUMENTED ');
      } else {
        sink.write('OPCODE ');
      }
      sink.write("$testName', () {\n");

      sink.write("    // Set up machine initial state\n");
      var registers = input[inputLine++].split(' ');
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

      var special = input[inputLine++].split(' ');
      special.removeWhere((item) => item.length == 0);

      sink.write("    z80.i = 0x${special[0]};\n");
      sink.write("    z80.r = 0x${special[1]};\n");
      sink.write("    z80.iff1 = ${special[2] == '1' ? 'true' : 'false'};\n");
      sink.write("    z80.iff2 = ${special[3] == '1' ? 'true' : 'false'};\n");
      int testRunLength = int.parse(special[6]);

      while (!input[inputLine].startsWith('-1')) {
        var pokes = input[inputLine].split(' ');
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
      sink.write("    while (z80.tStates < ${testRunLength}) {\n");
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
      var expectedRegisters = expected[expectedLine].split(' ');
      expectedRegisters.removeWhere((item) => item.length == 0);
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

      var expectedSpecial = expected[expectedLine].split(' ');
      expectedSpecial.removeWhere((item) => item.length == 0);
      sink.write("    checkSpecialRegisters(");
      sink.write("0x${expectedSpecial[0]}, ");
      sink.write("0x${expectedSpecial[1]}, ");
      sink.write("${expectedSpecial[2] == '1' ? 'true' : 'false'}, ");
      sink.write("${expectedSpecial[3] == '1' ? 'true' : 'false'}, ");
      sink.write("${expectedSpecial[6]});\n");
      expectedLine++;

      while (expected[expectedLine].length > 0 &&
          ((expected[expectedLine].codeUnitAt(0) >= '0'.codeUnits[0] &&
                  expected[expectedLine].codeUnitAt(0) <= '9'.codeUnits[0]) ||
              (expected[expectedLine].codeUnitAt(0) >= 'a'.codeUnits[0] &&
                  expected[expectedLine].codeUnitAt(0) <= 'f'.codeUnits[0]))) {
        var peeks = expected[expectedLine].split(' ');
        peeks.removeWhere((item) => item.length == 0);
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
        sink.write(", tags: 'undocumented'");
      }

      sink.write(");\n\n");
    }

    sink.write(r"""
}
  """);
  } finally {
    sink.close();
  }
}
