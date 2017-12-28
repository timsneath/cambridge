import 'package:test/test.dart';
import '../memory.dart';

void main() {
  test("basic memory test", () {
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
}
