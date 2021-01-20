import 'dart:io';
import 'dart:typed_data';

import 'file_reader.dart';

// Documented at https://sinclair.wiki.zxnet.co.uk/wiki/TAP_format
class TAPFile {
  final blocks = <TAPBlock>[];
  late final int lengthInBytes;

  TAPFile(ByteData snapshot) {
    final file = DataFileReader(snapshot);
    lengthInBytes = file.lengthInBytes;
    // Keep going until we've exhausted the number of blocks
    while (file.idx < lengthInBytes) {
      final blockOffset = file.idx;
      final blockSize = file.consumeWord();
      final flag = file.consumeByte();
      switch (flag) {
        case 0x00:
          // Read header block
          final blockType = file.consumeByte();
          final fileName = file.consumeString(10).trimRight();
          final dataBlockLength = file.consumeWord();
          final param1 = file.consumeWord();
          final param2 = file.consumeWord();
          final headerChecksum = file.consumeByte();

          final header = TAPHeaderBlock(blockOffset, blockType, fileName,
              dataBlockLength, param1, param2, headerChecksum);

          blocks.add(header);
          break;
        case 0xFF:
          // Read code block
          final data = file.consumeData(blockSize - 2);
          final dataChecksum = file.consumeByte();

          final dataBlock = TAPDataBlock(blockOffset, data, dataChecksum);
          blocks.add(dataBlock);

          break;
      }
    }
  }

  factory TAPFile.fromFile(String filename) {
    final buffer = File(filename).readAsBytesSync().buffer;
    return TAPFile(buffer.asByteData());
  }

  @override
  String toString() => 'TAP Format File ($lengthInBytes bytes)\n  '
      '${blocks.map((block) => block.toString().replaceAll('\n', '\n  ')).join('\n  ')}';
}

abstract class TAPBlock {
  final int offset;
  final bool isHeader;

  const TAPBlock({required this.offset, required this.isHeader});
}

class TAPHeaderBlock extends TAPBlock {
  final int blockType;
  final String fileName;
  final int dataBlockLength;
  final int param1;
  final int param2;
  final int headerChecksum;

  const TAPHeaderBlock(int offset, this.blockType, this.fileName,
      this.dataBlockLength, this.param1, this.param2, this.headerChecksum)
      : super(offset: offset, isHeader: true);

  @override
  String toString() {
    final buffer = StringBuffer();
    buffer.writeln('TAP Header Block [Offset: ${toHex32(offset)}]');
    buffer.write('  Block type: ');
    switch (blockType) {
      case 0x00:
        buffer.writeln('Program');
        break;
      case 0x01:
        buffer.writeln('Number array');
        break;
      case 0x02:
        buffer.writeln('Character array');
        break;
      case 0x03:
        buffer.writeln('Code file');
        break;
      default:
        buffer.writeln('Unknown');
    }

    buffer.writeln('  Filename: $fileName');
    buffer.writeln('  Data block length: $dataBlockLength');
    buffer.write('  Params: (${toHex16(param1)}, ${toHex16(param2)})');
    return buffer.toString();
  }
}

class TAPDataBlock extends TAPBlock {
  final List<int> data;
  final int dataChecksum;

  const TAPDataBlock(int offset, this.data, this.dataChecksum)
      : super(offset: offset, isHeader: false);

  @override
  String toString() => 'TAP Data Block [Offset: ${toHex32(offset)}]\n'
      '  Length: ${data.length} bytes';
}
