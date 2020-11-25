import 'dart:io';

import 'package:spectrum/core/disassembler.dart';
import 'package:spectrum/core/utility.dart';

void main(List<String> args) {
  if (args.length < 3) {
    print("dart dasm.dart filename [start-hex] [end-hex]");
    exit(1);
  }

  final file = File(args[0]);
  file.open(mode: FileMode.read);

  final rom = file.readAsBytesSync();

  final start = int.parse(args[1]);
  final end = int.parse(args[2]);

  var pc = start;

  while (pc < end) {
    final dasm = Disassembler.disassembleInstruction(
        [rom[pc], rom[pc + 1], rom[pc + 2], rom[pc + 3]]);

    print('[${toHex32(pc)}]  ${dasm.byteCode}  ${dasm.disassembly}');
    pc += dasm.length;
  }
}
