import 'package:test/test.dart';

import 'dart:typed_data';

import '../display.dart';
import '../z80.dart';
import '../memory.dart';

main() {
  test('Basic display test', () {
    var memory = new Memory();
    var z80 = new Z80(memory, startAddress: 0xA000);
    z80.reset();
    
    var display = new Display();
    var buffer = display.imageBuffer(memory);
    expect(buffer.lengthInBytes, equals(256 * 192));
  });
} 