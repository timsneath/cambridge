// display_test.dart -- test display system

// Run tests with
//   pub run test test/display_test.dart --no-color > test/results_display_test.txt

// @dart=2.9
import 'package:flutter_test/flutter_test.dart';
import 'package:spectrum/core/display.dart';
import 'package:spectrum/core/z80.dart';
import 'package:spectrum/core/memory.dart';

void main() {
  test('Basic display test', () {
    final memory = Memory(isRomProtected: false);
    final z80 = Z80(memory, startAddress: 0xA000);
    z80.reset();

    // final buffer = memory.displayBuffer;
    final image = Display.imageBuffer(memory);
    expect(image.lengthInBytes, equals(256 * 192));
  });
}
