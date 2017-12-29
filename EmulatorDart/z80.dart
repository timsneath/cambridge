// z80.dart -- implements the Zilog Z80 processor core
//
// Reference notes:
// The Z80 microprocessor user manual can be downloaded from Zilog:
//    http://tinyurl.com/z80manual
//
// Other useful details of the Z80 architecture can be found here:
//    http://landley.net/history/mirror/cpm/z80.html
// and here:
//    http://z80.info/z80code.htm

import 'memory.dart';
import 'utility.dart';

class Z80 {
  Memory memory;
  bool cpuSuspended;
  int tStates;

  Z80(this.memory, {int startAddress = 0}) {
    reset();
    pc = startAddress;
  }

  void reset() {
    // Initial register states are set per section 2.4 of
    //  http://www.myquest.nl/z80undocumented/z80-documented-v0.91.pdf
    af = 0xFFFF;
    bc = 0xFFFF;
    de = 0xFFFF;
    hl = 0xFFFF;
    ix = 0xFFFF;
    iy = 0xFFFF;
    sp = 0xFFFF;
    pc = 0x0000;
    iff1 = false;
    iff2 = false;
    im = 0;

    tStates = 0;
    cpuSuspended = false;
  }

  // *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** ***
  // REGISTERS
  // *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** ***

  final flags = const {
    'C': 0x01, // carry flag (bit 0)
    'N': 0x02, // add/subtract flag (bit 1)
    'P': 0x04, // parity/overflow flag (bit 2)
    'F3': 0x08, // undocumented flag
    'H': 0x10, // half carry flag (bit 4)
    'F5': 0x20, // undocumented flag
    'Z': 0x40, // zero flag (bit 6)
    'S': 0x80 // sign flag (bit 7)
  };

  // Core registers
  int a, f, b, c, d, e, h, l;
  int ix, iy;

  // The alternate register set (A', F', B', C', D', E', H', L')
  int a_, f_, b_, c_, d_, e_, h_, l_;

  int i; // Interrupt Page Address register
  int r; // Memory Refresh register

  int pc; // Program Counter
  int sp; // Stack pointer

  bool iff1;
  bool iff2;

  int im; // Interrupt Mode

  int get af => a * 256 + f;
  set af(num value) {
    a = highByte(value);
    f = lowByte(value);
  }

  int get bc => b * 256 + c;
  set bc(num value) {
    b = highByte(value);
    c = lowByte(value);
  }

  int get de => d * 256 + e;
  set de(num value) {
    d = highByte(value);
    e = lowByte(value);
  }

  int get hl => h * 256 + l;
  set hl(num value) {
    h = highByte(value);
    l = lowByte(value);
  }

  int get ixh => ix & 0xFF00 >> 8;
  int get ixl => ix & 0x00FF;

  int get iyh => iy & 0xFF00 >> 8;
  int get iyl => iy & 0x00FF;

  bool get fC => f & flags['C'] == flags['C'];
  bool get fN => f & flags['N'] == flags['N'];
  bool get fPV => f & flags['P'] == flags['P'];
  bool get f3 => f & flags['F3'] == flags['F3'];
  bool get fH => f & flags['H'] == flags['H'];
  bool get f5 => f & flags['F5'] == flags['F5'];
  bool get fZ => f & flags['Z'] == flags['Z'];
  bool get fS => f & flags['S'] == flags['S'];

  set fC(bool value) => f = value ? f & flags['C'] : f & ~flags['C'];
  set fN(bool value) => f = value ? f & flags['N'] : f & ~flags['N'];
  set fPV(bool value) => f = value ? f & flags['P'] : f & ~flags['P'];
  set f3(bool value) => f = value ? f & flags['F3'] : f & ~flags['F3'];
  set fH(bool value) => f = value ? f & flags['H'] : f & ~flags['H'];
  set f5(bool value) => f = value ? f & flags['F5'] : f & ~flags['F5'];
  set fZ(bool value) => f = value ? f & flags['Z'] : f & ~flags['Z'];
  set fS(bool value) => f = value ? f & flags['S'] : f & ~flags['S'];

  // *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** ***
  // INSTRUCTIONS
  // *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** ***

  void LDI() {
    var byteRead = memory.readByte(hl);
    memory.writeByte(de, byteRead);

    de++;
    hl++;
    bc--;

    fH = false;
    fN = false;
    fPV = (bc != 0);
    f5 = isBitSet(byteRead, 5);
    f3 = isBitSet(byteRead, 3);

    tStates += 16;
  }

  void LDD() {
    var byteRead = memory.readByte(hl);
    memory.writeByte(de, byteRead);

    de--;
    hl--;
    bc--;
    fH = false;
    fN = false;
    fPV = (bc != 0);
    f5 = isBitSet(byteRead, 5);
    f3 = isBitSet(byteRead, 3);

    tStates += 16;
  }

  void LDIR() {
    var byteRead = memory.readByte(hl);
    memory.writeByte(de, byteRead);

    de++;
    hl++;
    bc--;

    if (bc != 0) {
      pc -= 2;
      tStates += 21;
    } else {
      f5 = isBitSet(byteRead, 5);
      f3 = isBitSet(byteRead, 3);
      fH = false;
      fPV = false;
      fN = false;

      tStates += 16;
    }
  }

  void LDDR() {
    var byteRead = memory.readByte(hl);
    memory.writeByte(de, byteRead);
    de--;
    hl--;
    bc--;
    if (bc > 0) {
      pc -= 2;
      tStates += 21;
    } else {
      f5 = isBitSet(byteRead, 5);
      f3 = isBitSet(byteRead, 3);
      fH = false;
      fPV = false;
      fN = false;

      tStates += 16;
    }
  }

  // Arithmetic operations
  int INC(int reg) {
    var oldReg = reg;
    fPV = (reg == 0x7F);
    reg++;
    fH = isBitSet(reg, 4) != isBitSet(oldReg, 4);
    fZ = isZero(reg);
    fS = isSign8(reg);
    f5 = isBitSet(reg, 5);
    f3 = isBitSet(reg, 3);
    fN = false;

    tStates += 4;

    return reg;
  }

  int DEC(int reg) {
    var oldReg = reg;
    fPV = (reg == 0x80);
    reg--;
    fH = isBitSet(reg, 4) != isBitSet(oldReg, 4);
    fZ = isZero(reg);
    fS = isSign8(reg);
    f5 = isBitSet(reg, 5);
    f3 = isBitSet(reg, 3);
    fN = true;

    tStates += 4;

    return reg;
  }

  int ADC8(int a, int b) {
    if (fC) b++;
    return ADD8(a, b);
  }

  int ADC16(int a, int b) {
    if (fC) b++;

    // overflow in add only occurs when operand polarities are the same
    bool overflowCheck = (isSign16(a) == isSign16(b));

    a = ADD16(a, b);

    // if polarity is now different then add caused an overflow
    if (overflowCheck) {
      fPV = (isSign16(a) != isSign16(b));
    } else {
      fPV = false;
    }
    fS = isSign16(a);
    fZ = isZero(a);
    return a;
  }

  int ADD8(int a, int b) {
    fH = (((a & 0x0F) + (b & 0x0F)) & 0x10) == 0x10;

    // overflow in add only occurs when operand polarities are the same
    bool overflowCheck = (isSign8(a) == isSign8(b));

    fC = a + b > 0xFF;
    a += b;
    fS = isSign8(a);

    // if polarity is now different then add caused an overflow
    if (overflowCheck) {
      fPV = (fS != isSign8(b));
    } else {
      fPV = false;
    }

    f5 = isBitSet(a, 5);
    f3 = isBitSet(a, 3);
    fZ = isZero(a);
    fN = false;

    tStates += 4;

    return a;
  }

  int ADD16(int a, int b) {
    fH = (((a & 0xFFF) + (b & 0xFFF)) & 0x1000) == 0x1000;
    fC = a + b > 0xFFFF;
    a += b;
    f5 = isBitSet(a, 13);
    f3 = isBitSet(a, 11);
    fN = false;

    tStates += 11;

    return a;
  }

  int SBC8(int x, int y) {
    if (fC) y++;
    return SUB8(x, y);
  }

  int SBC16(int x, int y) {
    if (fC) y++;
    fC = x < y;
    fH = (x & 0xFFF) < (y & 0xFFF);

    // overflow in subtract only occurs when operand signs are different
    bool overflowCheck = (isSign16(x) != isSign16(y));

    x -= y;
    f5 = isBitSet(x, 13);
    f3 = isBitSet(x, 11);
    fS = isSign16(x);
    fZ = isZero(x);
    fN = true;

    // if x changed polarity then subtract caused an overflow
    if (overflowCheck) {
      fPV = (fS != isSign16(x));
    } else {
      fPV = false;
    }

    tStates += 15;

    return x;
  }

  // TODO: Consistent parameter names
  int SUB8(int x, int y) {
    fC = x < y;
    fH = (x & 0x0F) < (y & 0x0F);

    fS = isSign8(x);

    // overflow in subtract only occurs when operand signs are different
    bool overflowCheck = (isSign8(x) != isSign8(y));

    x -= y;
    f5 = isBitSet(x, 5);
    f3 = isBitSet(x, 3);

    // if x changed polarity then subtract caused an overflow
    if (overflowCheck) {
      fPV = (fS != isSign8(x));
    } else {
      fPV = false;
    }

    fS = isSign8(x);
    fZ = isZero(x);
    fN = true;

    tStates += 4;

    return x;
  }

  void CP(int x) {
    SUB8(a, x);
    f5 = isBitSet(x, 5);
    f3 = isBitSet(x, 3);
  }

  // algorithm from http://worldofspectrum.org/faq/reference/z80reference.htm
  void DAA() {
    int correctionFactor = 0;
    int oldA = a;

    if ((a > 0x99) || fC) {
      correctionFactor |= 0x60;
      fC = true;
    } else {
      fC = false;
    }

    if (((a & 0x0F) > 0x09) || fH) {
      correctionFactor |= 0x06;
    }

    if (!fN) {
      a += correctionFactor;
    } else {
      a -= correctionFactor;
    }

    fH = ((oldA & 0x10) ^ (a & 0x10)) == 0x10;
    f5 = isBitSet(a, 5);
    f3 = isBitSet(a, 3);

    fS = isSign8(a);
    fZ = isZero(a);
    fPV = isParity(a);

    tStates += 4;
  }

  // Flow operations
  void CALL() {
    var callAddr = getNextWord();

    PUSH(pc);

    pc = callAddr;

    tStates += 17;
  }

  void JR(int jump) {
    if (jump >= 0) {
      pc += jump;
    } else {
      pc -= -jump;
    }

    tStates += 12;
  }

  void DJNZ(int relativeAddress) {
    b--;
    if (b != 0) {
      JR(relativeAddress);
      tStates++;
    } else {
      pc++;
      tStates += 8;
    }
  }

  void RST(int addr) {
    PUSH(pc);
    pc = addr;
    tStates += 11;
  }

  // Stack operations
  void PUSH(int val) {
    memory.writeByte(--sp, highByte(val));
    memory.writeByte(--sp, lowByte(val));
  }

  int POP() {
    var lo = memory.readByte(sp++);
    var hi = memory.readByte(sp++);
    return ((hi << 8) + lo);
  }

  void EX_AFAFPrime() {
    int temp;

    temp = a;
    a = a_;
    a_ = temp;

    temp = f;
    f = f_;
    f_ = temp;

    tStates += 4;
  }

  // Logic operations

  void CPD() {
    int val = memory.readByte(hl);
    fH = (a & 0x0F) < (val & 0x0F);
    fS = (a - val < 0);
    fZ = (a == val);
    fN = true;
    fPV = (bc - 1 != 0);
    hl--;
    bc--;

    tStates += 16;
  }

  void CPDR() {
    int val = memory.readByte(hl);
    fH = (a & 0x0F) < (val & 0x0F);
    fS = (a - val < 0);
    fZ = (a == val);
    fN = true;
    fPV = (bc - 1 != 0);
    hl--;
    bc--;

    if ((bc != 0) && (a != val)) {
      pc -= 2;
      tStates += 21;
    } else {
      tStates += 16;
    }
  }

  void CPI() {
    int val = memory.readByte(hl);
    fH = (a & 0x0F) < (val & 0x0F);
    fS = (a - val < 0);
    fZ = (a == val);
    fN = true;
    fPV = (bc - 1 != 0);
    hl++;
    bc--;

    tStates += 16;
  }

  void CPIR() {
    int val = memory.readByte(hl);
    fH = (a & 0x0F) < (val & 0x0F);
    fS = (a - val < 0);
    fZ = (a == val);
    fN = true;
    fPV = (bc - 1 != 0);
    hl++;
    bc--;

    if ((bc != 0) && (a != val)) {
      pc -= 2;
      tStates += 21;
    } else {
      tStates += 16;
    }
  }

  int OR(int a, int reg) {
    a |= reg;
    fS = isSign8(a);
    fZ = isZero(a);
    fH = false;
    f5 = isBitSet(a, 5);
    f3 = isBitSet(a, 3);

    fPV = isParity(a);
    fN = false;
    fC = false;

    tStates += 4;

    return a;
  }

  int XOR(int a, int reg) {
    a ^= reg;
    fS = isSign8(a);
    fZ = isZero(a);
    fH = false;
    f5 = isBitSet(a, 5);
    f3 = isBitSet(a, 3);

    fPV = isParity(a);
    fN = false;
    fC = false;

    tStates += 4;

    return a;
  }

  int AND(int a, int reg) {
    a &= reg;
    fS = isSign8(a);
    fZ = isZero(a);
    fH = true;
    f5 = isBitSet(a, 5);
    f3 = isBitSet(a, 3);
    fPV = isParity(a);
    fN = false;
    fC = false;

    tStates += 4;

    return a;
  }

  int NEG(int a) {
    // returns two's complement of a
    fPV = (a == 0x80);
    fC = (a != 0x00);

    a = ~a;
    a++;

    f5 = isBitSet(a, 5);
    f3 = isBitSet(a, 3);

    fS = isSign8(a);
    fZ = isZero(a);
    fH = true;
    fN = true;

    tStates += 8;

    return a;
  }

  // TODO: Organize these into the same groups as the Z80 manual
  void CPL() {
    a = ~a;
    f5 = isBitSet(a, 5);
    f3 = isBitSet(a, 3);
    fH = true;
    fN = true;

    tStates += 4;
  }

  void SCF() {
    f5 = isBitSet(a, 5);
    f3 = isBitSet(a, 3);
    fH = false;
    fN = false;
    fC = true;
  }

  void CCF() {
    f5 = isBitSet(a, 5);
    f3 = isBitSet(a, 3);
    fH = fC;
    fN = false;
    fC = !fC;

    tStates += 4;
  }

  int RLC(int reg) {
    // rotates register r to the left
    // bit 7 is copied to carry and to bit 0
    fC = isSign8(reg);
    reg <<= 1;
    if (fC) reg = setBit(reg, 0);

    f5 = isBitSet(reg, 5);
    f3 = isBitSet(reg, 3);
    fS = isSign8(reg);
    fZ = isZero(reg);
    fH = false;
    fPV = isParity(reg);
    fN = false;

    return reg;
  }

  void RLCA() {
    // rotates register A to the left
    // bit 7 is copied to carry and to bit 0
    fC = isSign8(a);
    a <<= 1;
    if (fC) a = setBit(a, 0);
    f5 = isBitSet(a, 5);
    f3 = isBitSet(a, 3);

    fH = false;
    fN = false;

    tStates += 4;
  }

  int RRC(int reg) {
    fC = isBitSet(reg, 0);
    reg >>= 1;
    if (fC) reg = setBit(reg, 7);

    f5 = isBitSet(reg, 5);
    f3 = isBitSet(reg, 3);
    fS = isSign8(reg);
    fZ = isZero(reg);
    fH = false;
    fPV = isParity(reg);
    fN = false;

    return reg;
  }

  void RRCA() {
    fC = isBitSet(a, 0);
    a >>= 1;
    if (fC) a = setBit(a, 7);

    f5 = isBitSet(a, 5);
    f3 = isBitSet(a, 3);

    fH = false;
    fN = false;

    tStates += 4;
  }

  int RL(int reg) {
    // rotates register r to the left, through carry.
    // carry becomes the LSB of the new r
    bool bit0 = fC;

    fC = isSign8(reg);
    reg <<= 1;

    if (bit0) reg = setBit(reg, 0);

    fS = isSign8(reg);
    fZ = isZero(reg);
    fH = false;
    f5 = isBitSet(reg, 5);
    f3 = isBitSet(reg, 3);
    fPV = isParity(reg);
    fN = false;

    return reg;
  }

  void RLA() {
    // rotates register r to the left, through carry.
    // carry becomes the LSB of the new r
    bool bit0 = fC;

    fC = isSign8(a);
    a <<= 1;

    if (bit0) a = setBit(a, 0);

    f5 = isBitSet(a, 5);
    f3 = isBitSet(a, 3);

    fH = false;
    fN = false;

    tStates += 4;
  }

  int RR(int reg) {
    bool bit7 = fC;

    fC = isBitSet(reg, 0);
    reg >>= 1;

    if (bit7) reg = setBit(reg, 7);

    fS = isSign8(reg);
    fZ = isZero(reg);
    fH = false;
    f5 = isBitSet(reg, 5);
    f3 = isBitSet(reg, 3);
    fPV = isParity(reg);
    fN = false;

    return reg;
  }

  void RRA() {
    bool bit7 = fC;

    fC = isBitSet(a, 0);
    a >>= 1;

    if (bit7) {
      a = setBit(a, 7);
    }

    f5 = isBitSet(a, 5);
    f3 = isBitSet(a, 3);

    fH = false;
    fN = false;

    tStates += 4;
  }

  int SLA(int reg) {
    fC = isSign8(reg);
    reg <<= 1;

    f5 = isBitSet(reg, 5);
    f3 = isBitSet(reg, 3);

    fS = isSign8(reg);
    fZ = isZero(reg);
    fH = false;
    fPV = isParity(reg);
    fN = false;

    return reg;
  }

  int SRA(int reg) {
    bool bit7 = isSign8(reg);

    fC = isBitSet(reg, 0);
    reg >>= 1;

    if (bit7) reg = setBit(reg, 7);

    f5 = isBitSet(reg, 5);
    f3 = isBitSet(reg, 3);

    fS = isSign8(reg);
    fZ = isZero(reg);
    fH = false;
    fPV = isParity(reg);
    fN = false;

    return reg;
  }

  int SLL(int reg) {
    // technically, SLL is undocumented
    fC = isBitSet(reg, 7);
    reg <<= 1;
    reg = setBit(reg, 0);

    f5 = isBitSet(reg, 5);
    f3 = isBitSet(reg, 3);

    fS = isSign8(reg);
    fZ = isZero(reg);
    fH = false;
    fPV = isParity(reg);
    fN = false;

    return reg;
  }

  int SRL(int reg) {
    fC = isBitSet(reg, 0);
    reg >>= 1;
    reg = resetBit(reg, 7);

    f5 = isBitSet(reg, 5);
    f3 = isBitSet(reg, 3);

    fS = isSign8(reg);
    fZ = isZero(reg);
    fH = false;
    fPV = isParity(reg);
    fN = false;

    return reg;
  }

  void RLD() {
    int old_pHL = memory.readByte(hl);

    int new_pHL = ((old_pHL & 0x0F) << 4);
    new_pHL += (a & 0x0F);

    a = (a & 0xF0);
    a += ((old_pHL & 0xF0) >> 4);

    memory.writeByte(hl, new_pHL);

    f5 = isBitSet(a, 5);
    f3 = isBitSet(a, 3);

    fS = isSign8(a);
    fZ = isZero(a);
    fH = false;
    fPV = isParity(a);
    fN = false;

    tStates += 18;
  }

  void RRD() {
    int old_pHL = memory.readByte(hl);

    int new_pHL = ((a & 0x0F) << 4);
    new_pHL += (old_pHL & 0xF0) >> 4;

    a = (a & 0xF0);
    a += (old_pHL & 0x0F);

    memory.writeByte(hl, new_pHL);

    f5 = isBitSet(a, 5);
    f3 = isBitSet(a, 3);

    fS = isSign8(a);
    fZ = isZero(a);
    fH = false;
    fPV = isParity(a);
    fN = false;

    tStates += 18;
  }

  // Bitwise operations
  void BIT(int bitToTest, int reg) {
    switch (reg) {
      case 0x0:
        fZ = !isBitSet(b, bitToTest);
        f3 = isBitSet(b, 3);
        f5 = isBitSet(b, 5);
        fPV = fZ;
        break;
      case 0x1:
        fZ = !isBitSet(c, bitToTest);
        f3 = isBitSet(c, 3);
        f5 = isBitSet(c, 5);
        fPV = fZ;
        break;
      case 0x2:
        fZ = !isBitSet(d, bitToTest);
        f3 = isBitSet(d, 3);
        f5 = isBitSet(d, 5);
        fPV = fZ;
        break;
      case 0x3:
        fZ = !isBitSet(e, bitToTest);
        f3 = isBitSet(e, 3);
        f5 = isBitSet(e, 5);
        fPV = fZ;
        break;
      case 0x4:
        fZ = !isBitSet(h, bitToTest);
        f3 = isBitSet(h, 3);
        f5 = isBitSet(h, 5);
        fPV = fZ;
        break;
      case 0x5:
        fZ = !isBitSet(l, bitToTest);
        f3 = isBitSet(l, 3);
        f5 = isBitSet(l, 5);
        fPV = fZ;
        break;
      case 0x6:
        var val = memory.readByte(hl);
        fZ = !isBitSet(val, bitToTest);
        f3 = isBitSet(val, 3);
        f5 = isBitSet(val, 5);
        fPV = fZ;
        break;
      case 0x7:
        fZ = !isBitSet(a, bitToTest);
        f3 = isBitSet(a, 3);
        f5 = isBitSet(a, 5);
        fPV = fZ;
        break;
      default:
        throw new Exception(
            "Field register $reg must map to a valid Z80 register.");
    }

    // undocumented behavior from http://worldofspectrum.org/faq/reference/z80reference.htm
    fS = ((bitToTest == 7) && (!fZ));
    fH = true;
    fN = false;
  }

  void RES(int bitToReset, int reg) {
    switch (reg) {
      case 0x0:
        b = resetBit(b, bitToReset);
        break;
      case 0x1:
        c = resetBit(c, bitToReset);
        break;
      case 0x2:
        d = resetBit(d, bitToReset);
        break;
      case 0x3:
        e = resetBit(e, bitToReset);
        break;
      case 0x4:
        h = resetBit(h, bitToReset);
        break;
      case 0x5:
        l = resetBit(l, bitToReset);
        break;
      case 0x6:
        memory.writeByte(hl, resetBit(memory.readByte(hl), bitToReset));
        break;
      case 0x7:
        a = resetBit(a, bitToReset);
        break;
      default:
        throw new Exception(
            "Field register $reg must map to a valid Z80 register.");
    }
  }

  void SET(int bitToSet, int reg) {
    switch (reg) {
      case 0x0:
        b = setBit(b, bitToSet);
        break;
      case 0x1:
        c = setBit(c, bitToSet);
        break;
      case 0x2:
        d = setBit(d, bitToSet);
        break;
      case 0x3:
        e = setBit(e, bitToSet);
        break;
      case 0x4:
        h = setBit(h, bitToSet);
        break;
      case 0x5:
        l = setBit(l, bitToSet);
        break;
      case 0x6:
        memory.writeByte(hl, setBit(memory.readByte(hl), bitToSet));
        break;
      case 0x7:
        a = setBit(a, bitToSet);
        break;
      default:
        throw new Exception(
            "Field register $reg must map to a valid Z80 register.");
    }
  }

  // Port operations and interrupts
  int IN(int portNumber) {
    var readByte = portRead(bc);

    fS = isSign8(portNumber);
    fZ = isZero(portNumber);
    fH = false;
    fPV = isParity(portNumber);
    fN = false;
    f5 = isBitSet(readByte, 5);
    f3 = isBitSet(readByte, 3);

    return readByte;
  }

  void OUT(int portNumber, int value) {
    // TODO: write value to portNumber
  }

  void OUTA(int portNumber, int value) {
    // TODO: write value to portNumber
  }

  int INA(int portNumber) {
    return portNumber;
  }

  void INI() {
    memory.writeByte(hl, portRead(bc));
    hl++;
    b--;

    fN = true;

    tStates += 16;
  }

  void OUTI() {
    portWrite(c, memory.readByte(hl));
    hl++;
    b--;

    fN = true;

    tStates += 16;
  }

  void IND() {
    memory.writeByte(hl, portRead(bc));
    hl--;
    b--;

    fN = true;

    tStates += 16;
  }

  void OUTD() {
    portWrite(c, memory.readByte(hl));
    hl--;
    b--;

    fN = true;

    tStates += 16;
  }

  void INIR() {
    memory.writeByte(hl, portRead(bc));
    hl++;
    b--;
    if (b != 0) {
      pc -= 2;
      tStates += 21;
    } else {
      fN = true;
      fZ = true;
      tStates += 16;
    }
  }

  void OTIR() {
    portWrite(bc, memory.readByte(hl));
    hl++;
    b--;
    if (b != 0) {
      pc -= 2;
      tStates += 21;
    } else {
      fN = true;
      fZ = true;
      tStates += 16;
    }
  }

  void INDR() {
    memory.writeByte(hl, portRead(bc));
    hl--;
    b--;
    if (b != 0) {
      pc -= 2;
      tStates += 21;
    } else {
      fN = true;
      fZ = true;
      tStates += 16;
    }
  }

  void OTDR() {
    portWrite(bc, memory.readByte(hl));
    hl--;
    b--;
    if (b != 0) {
      pc -= 2;
      tStates += 21;
    } else {
      fN = true;
      fZ = true;
      tStates += 16;
    }
  }

  int getNextByte() => memory.readByte(pc++);

  int getNextWord() {
    var wordRead = memory.readWord(pc);
    pc += 2;
    return wordRead;
  }

  int portRead(int bc) => 0;
  void portWrite(int addr, int value) {}
}
