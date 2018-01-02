// display_test.dart -- test display system

// Run tests with 
//   pub run test test/display_test.dart --no-color > test/results_display_test.txt

import 'package:test/test.dart';

import '../display.dart';
import '../z80.dart';
import '../memory.dart';

main() {
  test('Basic display test', () {
    var memory = new Memory(false);
    var z80 = new Z80(memory, startAddress: 0xA000);
    z80.reset();
    
    var display = new Display();
    var buffer = display.imageBuffer(memory);
    expect(buffer.lengthInBytes, equals(256 * 192));
  });
} 