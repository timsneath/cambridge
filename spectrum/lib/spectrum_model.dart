import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:scoped_model/scoped_model.dart';

import 'z80.dart';
import 'memory.dart';

class SpectrumModel extends Model {
  Z80 _z80;
  Memory _memory;
  int _instructionCounter = 0;

  Z80 get z80 => _z80;
  Memory get memory => _memory;
  int get instructionCounter => instructionCounter;

  SpectrumModel() {
    _memory = Memory(true);
    _z80 = Z80(_memory, startAddress: 0x0000);
  }

  static SpectrumModel of(BuildContext context) =>
      ScopedModel.of<SpectrumModel>(context);

  void executeInstruction() async {
    if (_instructionCounter == 0) {
      ByteData rom = await rootBundle.load('roms/48.rom');
      _memory.load(0x0000, rom.buffer.asUint8List());
      _z80.reset();
      _instructionCounter++;
      notifyListeners();
    } else {
      while (_instructionCounter++ % 0x10000 != 0) {
        z80.executeNextInstruction();
      }
      notifyListeners();
    }
  }

  void loadTestScreenshot() async {
    ByteData screen = await rootBundle.load('assets/google.scr');
    _memory.load(0x4000, screen.buffer.asUint8List());
    notifyListeners();
  }

  resetEmulator() async {
    ByteData rom = await rootBundle.load('roms/48.rom');

    _memory = Memory(true);
    _z80 = Z80(_memory, startAddress: 0x0000);
    _memory.load(0x0000, rom.buffer.asUint8List());
    notifyListeners();
  }
}
