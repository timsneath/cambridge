import 'dart:convert';
import 'dart:typed_data';

String toHex8(int value) => '0x${value.toRadixString(16).padLeft(1, '0')}';
String toHex16(int value) => '0x${value.toRadixString(16).padLeft(2, '0')}';
String toHex32(int value) => '0x${value.toRadixString(16).padLeft(4, '0')}';

class DataFileReader {
  int idx = 0;
  late ByteData data;

  int get lengthInBytes => data.lengthInBytes;

  int consumeByte() => data.getUint8(idx++);
  int consumeWord() {
    final word = data.getUint16(idx, Endian.little);
    idx += 2;
    return word;
  }

  String consumeString(int length) {
    final rawString = <int>[];
    for (var i = 0; i < length; i++) {
      rawString.add(consumeByte());
    }

    final stringResult = utf8.decode(rawString);

    return stringResult;
  }

  List<int> consumeData(int length) {
    final result = data.buffer.asUint8List(idx, length);
    idx += length;
    return result;
  }

  DataFileReader(this.data);
}
