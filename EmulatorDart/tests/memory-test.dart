import 'dart:typed_data';
import 'package:test/test.dart';

import '../memory.dart';

void main() {
  test("Basic memory test", () {
    var mem = new Memory();
    mem.isRomProtected = true;
    mem.WriteByte(0xFFFF, 255);
    expect(mem.ReadByte(0xFFFF), equals(0xFF));
  });

  test("ROM is protected from writes", () {
    var mem = new Memory();
    mem.isRomProtected = true;
    mem.WriteByte(0x0FFF, 255);
    expect(mem.ReadByte(0x0FFF), equals(0x00));
  });

  test("ROM write protection can be disabled", () {
    var mem = new Memory();
    mem.isRomProtected = false;
    mem.WriteByte(0x0FFF, 255);
    expect(mem.ReadByte(0x0FFF), equals(0xFF));
  });

  test("ReadWord observes appropriate endianness", () {
    var mem = new Memory();
    mem.WriteByte(0xF000, 0xCD);
    mem.WriteByte(0xF001, 0xAB);
    expect(mem.ReadWord(0xF000), equals(0xABCD));
  });

  test("WriteWord observes appropriate endianness", () {
    var mem = new Memory();
    mem.WriteWord(0xABCD, 0xDEAD);
    expect(mem.ReadByte(0xABCD), equals(0xAD));
    expect(mem.ReadByte(0xABCE), equals(0xDE));
  });

  test("Load memory appropriately", () {
    var mem = new Memory();
    mem.Load(
        0xA000, new List<int>.generate(0x1000, (int index) => index % 0x100));
    expect(mem.ReadByte(0xA000), equals(0x00));
    expect(mem.ReadByte(0xA030), equals(0x30));
    expect(mem.ReadByte(0xA105), equals(0x05));
  });
}
