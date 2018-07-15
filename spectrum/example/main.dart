import 'dart:io';

import 'package:spectrum/spectrum.dart';

main() {
  Memory memory = Memory(true);
  Z80 z80 = Z80(memory);

  print(Directory.current);
  var rom = File('../ui/roms/48.rom').readAsBytesSync();
  memory.load(0x0000, rom);

  int instructionsExecuted = 0;

  while (!z80.cpuSuspended) {
    // assert(z80.b != null);

    z80.executeNextInstruction();

    if (instructionsExecuted++ % 0x1000 == 0) {
      print("Program Counter: ${toHex16(z80.pc)}");
    }

    // assert(z80.b != null);
  }
}
