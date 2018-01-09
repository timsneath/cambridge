// memory_test.dart -- test display system

// Run tests with 
//   pub run test test/memory_test.dart --no-color > test/results_memory_test.txt

import 'package:test/test.dart';
import 'package:spectrum/spectrum.dart';

main() {
  test("Basic memory test", () {
    var mem = new Memory(true);
    mem.writeByte(0xFFFF, 255);
    expect(mem.readByte(0xFFFF), equals(0xFF));
  });

  test("ROM is protected from writes", () {
    var mem = new Memory(true);
    mem.writeByte(0x0FFF, 255);
    expect(mem.readByte(0x0FFF), equals(0x00));
  });

  test("ROM write protection can be disabled", () {
    var mem = new Memory(false);
    mem.writeByte(0x0FFF, 255);
    expect(mem.readByte(0x0FFF), equals(0xFF));
  });

  test("ReadWord observes appropriate endianness", () {
    var mem = new Memory(true);
    mem.writeByte(0xF000, 0xCD);
    mem.writeByte(0xF001, 0xAB);
    expect(mem.readWord(0xF000), equals(0xABCD));
  });

  test("WriteWord observes appropriate endianness", () {
    var mem = new Memory(true);
    mem.writeWord(0xABCD, 0xDEAD);
    expect(mem.readByte(0xABCD), equals(0xAD));
    expect(mem.readByte(0xABCE), equals(0xDE));
  });

  // test("ReadByte fails on attempt to read beyond ramTop", () {
  //   var mem = new Memory(true);
  //   expect(() => mem.readByte(0xFFFF + 1), throwsA("IndexError"));
  // });

  test("Load memory appropriately", () {
    var mem = new Memory(true);
    mem.load(
        0xA000, new List<int>.generate(0x1000, (int index) => index % 0x100));
    expect(mem.readByte(0xA000), equals(0x00));
    expect(mem.readByte(0xA030), equals(0x30));
    expect(mem.readByte(0xA105), equals(0x05));
  });
}
