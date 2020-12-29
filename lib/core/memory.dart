// memory.dart -- implements the ZX Spectrum memory Map

// ZX Spectrum memory map, from:
//    http://www.animatez.co.uk/computers/zx-spectrum/memory-map/
//
// 0x0000-0x3FFF   ROM
// 0x4000-0x57FF   Screen memory
// 0x5800-0x5AFF   Screen memory (color data)
// 0x5B00-0x5BFF   Printer buffer
// 0x5C00-0x5CBF   System variables
// 0x5CC0-0x5CCA   Reserved
// 0x5CCB-0xFF57   Available memory
// 0xFF58-0xFFFF   Reserved
//
// The block of RAM between &4000 and &7FFF is contended, that is access
// to the RAM is shared between the processor and the ULA. The ULA has
// priority access when the screen is being drawn.

import 'dart:typed_data';

import 'utility.dart';

class Memory {
  static const romTop = 0x3FFF;
  static const ramTop = 0xFFFF;

  bool isRomProtected;

  /// The raw memory in the ZX Spectrum
  ///
  /// We treat the memory space as a list of unsigned bytes from 0x0000 to
  /// ramTop. For convenience, we treat the typed data format as an internal
  /// implementation detail, and all external interfaces are as int.
  Uint8List memory = Uint8List(ramTop + 1);

  Memory({this.isRomProtected = false});

  void reset() {
    if (isRomProtected) {
      memory.fillRange(romTop + 1, ramTop - romTop, 0);
    } else {
      memory.fillRange(0, ramTop + 1, 0);
    }
  }

  void load(int start, List<int> loadData, {bool ignoreRomProtection = false}) {
    // TODO: honor ignoreRomProtection flag
    final loadData8 = Uint8List.fromList(loadData);

    memory.setRange(start, start + loadData8.length, loadData8);
  }

  ByteData get displayBuffer => memory.buffer.asByteData(0x4000, 0x1AFF);

  int readByte(int address) => memory[address] & 0xFF;
  int readWord(int address) => (memory[address + 1] << 8) + memory[address];

  // As with a real device, no exception thrown if an attempt is made to
  // write to ROM - the request is just ignored
  void writeByte(int address, int value) {
    if (address > romTop || !isRomProtected) {
      // coerce to 8-bit, just in case
      memory[address] = value & 0xFF;
    }
  }

  void writeWord(int address, int value) {
    if (address > romTop || !isRomProtected) {
      memory[address] = lowByte(value);
      memory[address + 1] = highByte(value);
    }
  }
}
