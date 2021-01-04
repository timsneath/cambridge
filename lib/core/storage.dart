// storage.dart -- handles load/save of data

import 'dart:typed_data';

import 'storage/tap_file.dart';
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

  void loadBASICProgram(List<int> data, int startLine, int variablesOffset) {
    const NEWPPC = 0x5C42; // [WORD] Line to be jumped to
    const NSPPC = 0x5C44; //  [BYTE] Statement number in line to be jumped to
    const VARS = 0x5C4B; //   [WORD] Address of variables
    const PROG = 0x5C53; //   [WORD] Address of BASIC program
    const E_LINE = 0x5C59; // [WORD] Address of command being typed in
    const WORKSP = 0x5C61; // [WORD] Address of temporary work space
    const STKBOT = 0x5C63; // [WORD] Address of bottom of calculator stack
    const STKEND = 0x5C65; // [WORD] Address of start of spare space

    final oldLineContent = z80.memory.readWord(E_LINE);
    final progStartAddress = z80.memory.readWord(PROG);
    final progEndAddress = progStartAddress + data.length;

    z80.memory.load(progStartAddress, data);

    // Update system variables
    // From https://softspectrum48.weebly.com/notes/category/tape-loading
    z80.memory.writeWord(VARS, variablesOffset + progStartAddress);
    z80.memory.writeWord(E_LINE, progEndAddress + 1);
    z80.memory.writeByte(z80.memory.readByte(E_LINE - 1), 0x80);
    z80.memory.writeWord(z80.memory.readByte(E_LINE), oldLineContent);
    z80.memory.writeByte(E_LINE + 2, 0x0D);
    z80.memory.writeByte(E_LINE + 3, 0x80);

    z80.memory.writeWord(WORKSP, progEndAddress + 5);
    z80.memory.writeWord(STKBOT, progEndAddress + 5);
    z80.memory.writeWord(STKEND, progEndAddress + 5);

    if (startLine < 32768) {
      z80.memory.writeWord(NEWPPC, startLine);
      z80.memory.writeByte(NSPPC, 0);
    } else {
      z80.memory.writeWord(NEWPPC, 32768);
    }

    z80.ix = progEndAddress;
  }

  void loadTAPSnapshot(ByteData snapshot) {
    final blocks = TAPFile(snapshot).blocks;

    for (var idx = 0; idx < blocks.length; idx++) {
      if (blocks[idx].isHeader) {
        final header = blocks[idx] as TAPHeaderBlock;
        final program = blocks[++idx] as TAPDataBlock;
        switch (header.blockType) {
          case 0x00:
            // We have a BASIC program
            loadBASICProgram(program.data, header.param1, header.param2);
            break;
          case 0x03:
            // A straightforward data block
            final program = blocks[++idx] as TAPDataBlock;
            z80.memory.load(header.param1, program.data);
            break;
          default:
            throw Exception('Unhandled TAP header type');
        }
      } else {
        throw Exception('Headerless TAP data block');
      }
    }
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
