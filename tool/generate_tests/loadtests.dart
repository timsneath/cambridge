//

import 'dart:io';

import 'model.dart';

// ignore_for_file: non_constant_identifier_names
// This stops complaints about our convention of naming registers like AF' as
// af_

const String testsFile = 'tool/generate_tests/fuse_tests/tests.in';
const String expectedResultsFile =
    'tool/generate_tests/fuse_tests/tests.expected';

List<String> listUndocumentedOpcodeTests() {
  String toHex16(int value) => value.toRadixString(16).padLeft(2, '0');

  // These unit tests stress undocumented Z80 opcodes
  final undocumentedOpcodeTests = [
    "4c", "4e", "54", "5c", "63", "64", "6b", "6c", "6e",
    "70", "71", "74", "7c", // base opcodes

    "cb30", "cb31", "cb32", "cb33", "cb34", "cb35", "cb36",
    "cb37", // CB opcodes

    "dd24", "dd25", "dd26", "dd2c", "dd2d", "dd2e", "dd44", "dd45", "dd4c",
    "dd4d", "dd54", "dd55", "dd5c", "dd5d", "dd60", "dd61", "dd62", "dd63",
    "dd64", "dd65", "dd67", "dd68", "dd69", "dd6a", "dd6b", "dd6c", "dd6d",
    "dd6f", "dd7c", "dd7d", "dd84", "dd85", "dd8c", "dd8d", "dd94", "dd95",
    "dd9c", "dd9d", "dda4", "dda5", "ddac", "ddad", "ddb4", "ddb5", "ddbc",
    "ddbd", "ddcb36", "ddfd00", // DD opcodes

    "fd24", "fd25", "fd26", "fd2c", "fd2d", "fd2e", "fd44", "fd45", "fd4c",
    "fd4d", "fd54", "fd55", "fd5c", "fd5d", "fd60", "fd61", "fd62", "fd63",
    "fd64", "fd65", "fd67", "fd68", "fd69", "fd6a", "fd6b", "fd6c", "fd6d",
    "fd6f", "fd7c", "fd7d", "fd84", "fd85", "fd8c", "fd8d", "fd94", "fd95",
    "fd9c", "fd9d", "fda4", "fda5", "fdac", "fdad", "fdb4", "fdb5", "fdbc",
    "fdbd", "fdcb36", // FD opcodes
  ];

  // These too...
  for (var opCode = 0; opCode < 256; opCode++) {
    if ((opCode & 0x7) != 0x6) {
      undocumentedOpcodeTests.add("ddcb${toHex16(opCode)}");
      undocumentedOpcodeTests.add("fdcb${toHex16(opCode)}");
    }
  }

  return undocumentedOpcodeTests;
}

List<FuseTest> loadTests() {
  final undocumentedOpcodeTests = listUndocumentedOpcodeTests();

  final tests = <FuseTest>[];

  final inputs = loadTestInput();
  final results = loadExpectedResults();

  for (final testName in inputs.keys) {
    tests.add(FuseTest(testName, inputs[testName]!, results[testName]!,
        isUndocumented: undocumentedOpcodeTests.contains(testName)));
  }
  print(tests.length);
  return tests;
}

Map<String, FuseTestInput> loadTestInput() {
  final inputs = <String, FuseTestInput>{};

  final input = File(testsFile).readAsLinesSync();
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
          tStates: int.parse(specialRaw[6])); // parse as decimal, not hex

      final map = <int, List<int>>{};

      while (!input[inputLine].startsWith('-1')) {
        final pokes = input[inputLine].split(' ')..removeLast();
        final addr = int.parse(pokes[0], radix: 16);
        final values =
            pokes.sublist(1).map((poke) => int.parse(poke, radix: 16)).toList();
        map[addr] = values;
        inputLine++;
      }

      inputLine += 2;

      final test = FuseTestInput(registers, specialRegisters, map);
      inputs[testName] = test;
    }
    print('Loaded ${inputs.length} tests.');
    return inputs;
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

Map<String, FuseTestResult> loadExpectedResults() {
  final results = <String, FuseTestResult>{};

  final expected = File(expectedResultsFile).readAsLinesSync();

  var expectedLine = 0;

  while (expectedLine < expected.length) {
    final testName = expected[expectedLine++];

    // Uninterested in intermediate states -- at least, for now.
    while (expected[expectedLine].startsWith(' ')) {
      expectedLine++;
    }

    final registersRaw = expected[expectedLine++].trimRight().split(' ');
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

    final specialRaw = expected[expectedLine++].trimRight().split(' ');
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
        tStates: int.parse(specialRaw[6])); // parse as decimal, not hex

    final expectedMemory = <int, String>{};
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
        expectedMemory[addr] = peeks[idx];
        idx++;
        addr++;
      }
      expectedLine++;
    }
    final result = FuseTestResult(registers, specialRegisters, expectedMemory);
    results[testName] = result;
    expectedLine++;
  }
  print('Loaded ${results.length} results.');
  return results;
}
