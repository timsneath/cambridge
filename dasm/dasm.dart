import 'dart:io';

import '../spectrum/lib/spectrum/opcodes.dart';
import '../spectrum/lib/spectrum/utility.dart';

main(List<String> arguments) {
  final file = new File('../spectrum/roms/48.rom');
  file.open(mode: FileMode.read);

  final rom = file.readAsBytesSync();

  final start = int.parse(arguments[0]);
  final end = int.parse(arguments[1]);

  int pc = start;

  while (pc < end) {
    final length = OpcodeDecoder.getInstructionLength(
        rom[pc], rom[pc + 1], rom[pc + 2], rom[pc + 3]);
    final instruction =
        OpcodeDecoder.decode(rom[pc], rom[pc + 1], rom[pc + 2], rom[pc + 3]);
    print('${toHex32(pc)}: $instruction');
    pc += length;
  }
}
