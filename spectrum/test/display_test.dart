// display_test.dart -- test display system

// Run tests with 
//   pub run test test/display_test.dart --no-color > test/results_display_test.txt

import 'package:test/test.dart';
import 'package:spectrum/spectrum.dart';

main() {
  test('Basic display test', () {
    var memory = new Memory(false);
    var z80 = new Z80(memory, startAddress: 0xA000);
    z80.reset();
    
    var buffer = Display.imageBuffer(memory);
    expect(buffer.lengthInBytes, equals(256 * 192));
  });
} 