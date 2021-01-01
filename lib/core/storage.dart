// storage.dart -- handles load/save of data

import 'dart:typed_data';

import 'ula.dart';
import 'utility.dart';
import 'z80.dart';

// ignore: avoid_classes_with_only_static_members
class Storage {
  final Z80 z80;

  const Storage({required this.z80});

  void loadBinaryData(ByteData snapshot,
      {int startLocation = 0x4000, int pc = 0x4000}) {
    z80.memory.load(startLocation, snapshot.buffer.asUint8List());
    z80.pc = pc;
    // z80.sp = pc;
  }

  void loadRom(ByteData snapshot) {
    loadBinaryData(snapshot, startLocation: 0x0000, pc: 0x0000);
  }

  // Documented at https://sinclair.wiki.zxnet.co.uk/wiki/TAP_format
  void loadTAPSnapshot(ByteData snapshot) {
    // TODO: implement
  }

  // Per https://faqwiki.zxnet.co.uk/wiki/SNA_format
  // the snapshot format has a 27 byte header containing the Z80 registers
  void loadSNASnapshot(ByteData snapshot) {
    final r = snapshot.buffer.asUint8List(0, 27);

    z80.i = r[0];
    z80.hl_ = createWord(r[1], r[2]);
    z80.de_ = createWord(r[3], r[4]);
    z80.bc_ = createWord(r[5], r[6]);
    z80.af_ = createWord(r[7], r[8]);
    z80.hl = createWord(r[9], r[10]);
    z80.de = createWord(r[11], r[12]);
    z80.bc = createWord(r[13], r[14]);
    z80.iy = createWord(r[15], r[16]);
    z80.ix = createWord(r[17], r[18]);
    z80.iff2 = z80.iff1 = isBitSet(r[19], 2);
    z80.r = r[20];
    z80.af = createWord(r[21], r[22]);
    z80.sp = createWord(r[23], r[24]);
    z80.im = r[25];
    ULA.screenBorder = r[26];

    z80.memory.load(0x4000, snapshot.buffer.asUint8List(27));

    // The program counter is pushed onto the stack, and since SP points to
    // the stack, we can simply POP it off.
    z80.pc = z80.POP();
  }

  // Per http://rk.nvg.ntnu.no/sinclair/formats/z80-format.html
  // the snapshot format has a 30 byte header containing the Z80 registers
  void loadZ80Snapshot(ByteData snapshot) {
    final r = snapshot.buffer.asUint8List(0, 30);

    var fileFormatVersion = 145;
    var isDataBlockCompressed = false;

    if (createWord(r[6], r[7]) == 0) {
      if (createWord(r[30], r[31]) == 54) {
        fileFormatVersion = 300;
      } else if (createWord(r[30], r[31]) == 23) {
        fileFormatVersion = 201;
      } else {
        throw Exception('Unrecognized Z80 file format.');
      }
    }

    z80.af = createWord(r[0], r[1]);
    z80.bc = createWord(r[2], r[3]);
    z80.hl = createWord(r[4], r[5]);
    if (fileFormatVersion <= 145) {
      z80.pc = createWord(r[6], r[7]);
    } else {
      z80.pc = createWord(r[32], r[33]);
    }
    z80.sp = createWord(r[8], r[9]);
    z80.i = r[10];
    z80.r = r[11];
    ULA.screenBorder = (r[12] << 1) & 0x03;
    if (isBitSet(r[12], 5)) {
      isDataBlockCompressed = true;
    }
    z80.de = createWord(r[13], r[14]);
    z80.bc_ = createWord(r[15], r[16]);
    z80.de_ = createWord(r[17], r[18]);
    z80.hl_ = createWord(r[19], r[20]);
    z80.af_ = createWord(r[21], r[22]);
    z80.iy = createWord(r[23], r[24]);
    z80.ix = createWord(r[25], r[26]);
    z80.iff1 = z80.iff2 = r[27] == 0;
    if ((r[29] & 0x03) == 0x00) {
      z80.im = 0;
    } else if ((r[29] & 0x03) == 0x01) {
      z80.im = 1;
    } else if ((r[29] & 0x03) == 0x02) {
      z80.im = 2;
    }

    if (!isDataBlockCompressed && (fileFormatVersion == 145)) {
      z80.memory.load(0x4000, snapshot.buffer.asUint8List(30));
    } else {
      throw Exception('Unsupported -- compressed v1.45 Z80 file.');
    }
  }
}
