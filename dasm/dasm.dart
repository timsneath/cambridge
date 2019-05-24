import 'dart:io';

import '../spectrum/lib/spectrum/opcodes.dart';
import '../spectrum/lib/spectrum/utility.dart';

void main(List<String> args) {
  if (args.length == 0) {
    args.add("0x0041");
    args.add("0x0053");
  }

  final file = new File('../spectrum/roms/48.rom');
  file.open(mode: FileMode.read);

  final rom = file.readAsBytesSync();

  final start = int.parse(args[0]);
  final end = int.parse(args[1]);

  int pc = start;

  while (pc < end) {
    final length = OpcodeDecoder.getInstructionLength(
        rom[pc], rom[pc + 1], rom[pc + 2], rom[pc + 3]);
    final instruction =
        OpcodeDecoder.decode(rom[pc], rom[pc + 1], rom[pc + 2], rom[pc + 3]);

    var instructionByteCode = '';
    for (var i = 0; i < 4; i++) {
      if (i < length) {
        instructionByteCode += toHex16(rom[pc + i]) + ' ';
      } else {
        instructionByteCode += '   ';
      }
    }

    print('[${toHex32(pc)}]  $instructionByteCode  $instruction');
    pc += length;
  }
}
