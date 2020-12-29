// z80instruction_test.dart -- test a common set of Z80 instructions against Zilog spec

// Run tests with
//   pub run test test/z80instruction_test.dart --no-color > test/results_z80instruction_test.txt

import 'package:flutter_test/flutter_test.dart';
import 'package:spectrum/core/z80.dart';
import 'package:spectrum/core/memory.dart';

Memory memory = Memory(isRomProtected: false);
Z80 z80 = Z80(memory, startAddress: 0xA000);

void poke(int addr, int val) => memory.writeByte(addr, val);
int peek(int addr) => memory.readByte(addr);

void loadInstructions(List<int> instructions) {
  // we pick this as a 'safe' location that doesn't clash with other instructions
  // TODO: randomize this, perhaps?
  const addr = 0xA000;

  memory.load(addr, instructions);
  memory.writeByte(addr + instructions.length, 0x76); // HALT instruction
}

void execute(List<int> instructions) {
  loadInstructions(instructions);
  z80.pc = 0xA000;
  while (!z80.cpuSuspended) {
    z80.executeNextInstruction();
  }
}

void main() {
  setUp(() {
    z80.reset();
    memory.reset();
  });

  test('NOP', () {
    var beforeAF = z80.af;
    var beforeBC = z80.bc;
    var beforeDE = z80.de;
    var beforeHL = z80.hl;
    var beforeIX = z80.ix;
    var beforeIY = z80.iy;

    execute([0x00, 0x00, 0x00, 0x00]);

    expect(z80.af, equals(beforeAF));
    expect(z80.bc, equals(beforeBC));
    expect(z80.de, equals(beforeDE));
    expect(z80.hl, equals(beforeHL));
    expect(z80.ix, equals(beforeIX));
    expect(z80.iy, equals(beforeIY));

    expect(z80.pc, equals(0xA004));
  });

  test('LD_H_E', () {
    z80.h = 0x8A;
    z80.e = 0x10;
    execute([0x63]);
    expect(z80.h, equals(0x10));
    expect(z80.e, equals(0x10));
  });

  test('LD_R_N', () // LD r, r'
      {
    execute([0x1E, 0xA5]);
    expect(z80.e, equals(0xA5));
  });

  test('LD_R_HL', () // LD r, (HL)
      {
    poke(0x75A1, 0x58);
    z80.hl = 0x75A1;
    execute([0x4E]);
    expect(z80.c, equals(0x58));
  });

  test('LD_R_IXd', () // LD r, (IX+d)
      {
    z80.ix = 0x25AF;
    poke(0x25C8, 0x39);
    execute([0xDD, 0x46, 0x19]);
    expect(z80.b, equals(0x39));
  });

  test('LD_R_IYd', () // LD r, (IY+d)
      {
    z80.iy = 0x25AF;
    poke(0x25C8, 0x39);
    execute([0xFD, 0x46, 0x19]);
    expect(z80.b, equals(0x39));
  });

  test('LD_HL_R', () // LD (HL), r
      {
    z80.hl = 0x2146;
    z80.b = 0x29;
    execute([0x70]);
    expect(peek(0x2146), equals(0x29));
  });

  test('LD_IXd_r', () // LD (IX+d), r
      {
    z80.c = 0x1C;
    z80.ix = 0x3100;
    execute([0xDD, 0x71, 0x06]);
    expect(peek(0x3106), equals(0x1C));
  });

  test('LD_IYd_r', () // LD (IY+d), r
      {
    z80.c = 0x48;
    z80.iy = 0x2A11;
    execute([0xFD, 0x71, 0x04]);
    expect(peek(0x2A15), equals(0x48));
  });

  test('LD_HL_N', () // LD (HL), n
      {
    z80.hl = 0x4444;
    execute([0x36, 0x28]);
    expect(peek(0x4444), equals(0x28));
  });

  test('LD_IXd_N', () // LD (IX+d), n
      {
    z80.ix = 0x219A;
    execute([0xDD, 0x36, 0x05, 0x5A]);
    expect(peek(0x219F), equals(0x5A));
  });

  test('LD_IYd_N', () // LD (IY+d), n
      {
    z80.iy = 0xA940;
    execute([0xFD, 0x36, 0x10, 0x97]);
    expect(peek(0xA950), equals(0x97));
  });

  test('LD_A_BC', () // LD A, (BC)
      {
    z80.bc = 0x4747;
    poke(0x4747, 0x12);
    execute([0x0A]);
    expect(z80.a, equals(0x12));
  });

  test('LD_A_DE', () // LD A, (DE)
      {
    z80.de = 0x30A2;
    poke(0x30A2, 0x22);
    execute([0x1A]);
    expect(z80.a, equals(0x22));
  });

  test('LD_A_NN', () // LD A, (nn)
      {
    poke(0x8832, 0x04);
    execute([0x3A, 0x32, 0x88]);
    expect(z80.a, equals(0x04));
  });

  test('LD_BC_A', () // LD (BC), A
      {
    z80.a = 0x7A;
    z80.bc = 0x1212;
    execute([0x02]);
    expect(peek(0x1212), equals(0x7A));
  });

  test('LD_DE_A', () // LD (DE), A
      {
    z80.de = 0x1128;
    z80.a = 0xA0;
    execute([0x12]);
    expect(peek(0x1128), equals(0xA0));
  });

  test('LD_NN_A', () // LD (NN), A
      {
    z80.a = 0xD7;
    execute([0x32, 0x41, 0x31]);
    expect(peek(0x3141), equals(0xD7));
  });

  test('LD_A_I', () // LD A, I
      {
    var oldCarry = z80.fC;
    z80.i = 0xFE;
    execute([0xED, 0x57]);
    expect(z80.a, equals(0xFE));
    expect(z80.i, equals(0xFE));
    expect(z80.fS, equals(true));
    expect(z80.fZ, equals(false));
    expect(z80.fH, equals(false));
    expect(z80.fPV, equals(z80.iff2));
    expect(z80.fN, equals(false));
    expect(z80.fC, equals(oldCarry));
    // TODO: If an interrupt occurs during the execution of
    // this instruction, the Parity flag contains a 0.
  });

  test('LD_A_R', () // LD A, R
      {
    var oldCarry = z80.fC;
    z80.r = 0x07;
    execute([0xED, 0x5F]);
    expect(z80.a, equals(z80.r));
    // TODO: some confusion whether this should result in 8 or 9
    // expect(z80.r, equals(0x08));
    expect(z80.fS, equals(false));
    expect(z80.fZ, equals(false));
    expect(z80.fH, equals(false));
    expect(z80.fPV, equals(z80.iff2));
    expect(z80.fN, equals(false));
    expect(z80.fC, equals(oldCarry));
    // TODO: If an interrupt occurs during the execution of
    // this instruction, the Parity flag contains a 0.
  });

  test('LD_I_A', () // LD I, A
      {
    z80.a = 0x5C;
    execute([0xED, 0x47]);
    expect(z80.i, equals(0x5C));
    expect(z80.a, equals(0x5C));
  });

  test('LD_R_A', () // LD R, A
      {
    z80.a = 0xDE;
    execute([0xED, 0x4F]);
    expect(z80.r, equals(0xDF));
    expect(z80.a, equals(0xDE));
  });

  test('LD_DD_NN', () // LD dd, nn
      {
    execute([0x21, 0x00, 0x50]);
    expect(z80.hl, equals(0x5000));
    expect(z80.h, equals(0x50));
    expect(z80.l, equals(0x00));
  });

  test('LD_IX_NN', () // LD IX, nn
      {
    execute([0xDD, 0x21, 0xA2, 0x45]);
    expect(z80.ix, equals(0x45A2));
  });

  test('LD_IY_NN', () // LD IY, nn
      {
    execute([0xFD, 0x21, 0x33, 0x77]);
    expect(z80.iy, equals(0x7733));
  });

  test('LD_HL_NN1', () // LD HL, (nn)
      {
    poke(0x4545, 0x37);
    poke(0x4546, 0xA1);
    execute([0x2A, 0x45, 0x45]);
    expect(z80.hl, equals(0xA137));
  });

  test('LD_HL_NN2', () {
    poke(0x8ABC, 0x84);
    poke(0x8ABD, 0x89);
    execute([0x2A, 0xBC, 0x8A]);
    expect(z80.hl, equals(0x8984));
  });

  test('LD_DD_pNN', () // LD dd, (nn)
      {
    poke(0x2130, 0x65);
    poke(0x2131, 0x78);
    execute([0xED, 0x4B, 0x30, 0x21]);
    expect(z80.bc, equals(0x7865));
  });

  test('LD_IX_pNN', () // LD IX, (nn)
      {
    poke(0x6666, 0x92);
    poke(0x6667, 0xDA);
    execute([0xDD, 0x2A, 0x66, 0x66]);
    expect(z80.ix, equals(0xDA92));
  });

  test('LD_IY_pNN', () // LD IY, (nn)
      {
    poke(0xF532, 0x11);
    poke(0xF533, 0x22);
    execute([0xFD, 0x2A, 0x32, 0xF5]);
    expect(z80.iy, equals(0x2211));
  });

  test('LD_pNN_HL', () // LD (nn), HL
      {
    z80.hl = 0x483A;
    execute([0x22, 0x29, 0xB2]);
    expect(peek(0xB229), equals(0x3A));
    expect(peek(0xB22A), equals(0x48));
  });

  test('LD_pNN_DD', () // LD (nn), DD
      {
    z80.bc = 0x4644;
    execute([0xED, 0x43, 0x00, 0x10]);
    expect(peek(0x1000), equals(0x44));
    expect(peek(0x1001), equals(0x46));
  });

  test('LD_pNN_IX', () // LD (nn), IX
      {
    z80.ix = 0x5A30;
    execute([0xDD, 0x22, 0x92, 0x43]);
    expect(peek(0x4392), equals(0x30));
    expect(peek(0x4393), equals(0x5A));
  });

  test('LD_pNN_IY', () // LD (nn), IY
      {
    z80.iy = 0x4174;
    execute([0xFD, 0x22, 0x38, 0x88]);
    expect(peek(0x8838), equals(0x74));
    expect(peek(0x8839), equals(0x41));
  });

  test('LD_SP_HL', () // LD SP, HL
      {
    z80.hl = 0x442E;
    execute([0xF9]);
    expect(z80.sp, equals(0x442E));
  });

  test('LD_SP_IX', () // LD SP, IX
      {
    z80.ix = 0x98DA;
    execute([0xDD, 0xF9]);
    expect(z80.sp, equals(0x98DA));
  });

  test('LD_SP_IY', () // LD SP, IY
      {
    z80.iy = 0xA227;
    execute([0xFD, 0xF9]);
    expect(z80.sp, equals(0xA227));
  });

  test('PUSH_qq', () // PUSH qq
      {
    z80.af = 0x2233;
    z80.sp = 0x1007;
    execute([0xF5]);
    expect(peek(0x1006), equals(0x22));
    expect(peek(0x1005), equals(0x33));
    expect(z80.sp, equals(0x1005));
  });

  test('PUSH_IX', () // PUSH IX
      {
    z80.ix = 0x2233;
    z80.sp = 0x1007;
    execute([0xDD, 0xE5]);
    expect(peek(0x1006), equals(0x22));
    expect(peek(0x1005), equals(0x33));
    expect(z80.sp, equals(0x1005));
  });

  test('PUSH_IY', () // PUSH IY
      {
    z80.iy = 0x2233;
    z80.sp = 0x1007;
    execute([0xFD, 0xE5]);
    expect(peek(0x1006), equals(0x22));
    expect(peek(0x1005), equals(0x33));
    expect(z80.sp, equals(0x1005));
  });

  test('POP_qq', () // POP qq
      {
    z80.sp = 0x1000;
    poke(0x1000, 0x55);
    poke(0x1001, 0x33);
    execute([0xE1]);
    expect(z80.hl, equals(0x3355));
    expect(z80.sp, equals(0x1002));
  });

  test('POP_IX', () // POP IX
      {
    z80.sp = 0x1000;
    poke(0x1000, 0x55);
    poke(0x1001, 0x33);
    execute([0xDD, 0xE1]);
    expect(z80.ix, equals(0x3355));
    expect(z80.sp, equals(0x1002));
  });

  test('POP_IY', () // POP IY
      {
    z80.sp = 0x8FFF;
    poke(0x8FFF, 0xFF);
    poke(0x9000, 0x11);
    execute([0xFD, 0xE1]);
    expect(z80.iy, equals(0x11FF));
    expect(z80.sp, equals(0x9001));
  });

  test('EX_DE_HL', () // EX DE, HL
      {
    z80.de = 0x2822;
    z80.hl = 0x499A;
    execute([0xEB]);
    expect(z80.hl, equals(0x2822));
    expect(z80.de, equals(0x499A));
  });

  test('EX_AF_AF', () // EX AF, AF'
      {
    z80.af = 0x9900;
    z80.af_ = 0x5944;
    execute([0x08]);
    expect(z80.af_, equals(0x9900));
    expect(z80.af, equals(0x5944));
  });

  test('EXX', () // EXX
      {
    z80.af = 0x1234;
    z80.af_ = 0x4321;
    z80.bc = 0x445A;
    z80.de = 0x3DA2;
    z80.hl = 0x8859;
    z80.bc_ = 0x0988;
    z80.de_ = 0x9300;
    z80.hl_ = 0x00E7;
    execute([0xD9]);
    expect(z80.bc, equals(0x0988));
    expect(z80.de, equals(0x9300));
    expect(z80.hl, equals(0x00E7));
    expect(z80.bc_, equals(0x445A));
    expect(z80.de_, equals(0x3DA2));
    expect(z80.hl_, equals(0x8859));
    expect(z80.af, equals(0x1234)); // unchanged
    expect(z80.af_, equals(0x4321)); // unchanged
  });

  test('EX_SP_HL', () // EX (SP), HL
      {
    z80.hl = 0x7012;
    z80.sp = 0x8856;
    poke(0x8856, 0x11);
    poke(0x8857, 0x22);
    execute([0xE3]);
    expect(z80.hl, equals(0x2211));
    expect(peek(0x8856), equals(0x12));
    expect(peek(0x8857), equals(0x70));
    expect(z80.sp, equals(0x8856));
  });

  test('EX_SP_IX', () // EX (SP), IX
      {
    z80.ix = 0x3988;
    z80.sp = 0x0100;
    poke(0x0100, 0x90);
    poke(0x0101, 0x48);
    execute([0xDD, 0xE3]);
    expect(z80.ix, equals(0x4890));
    expect(peek(0x0100), equals(0x88));
    expect(peek(0x0101), equals(0x39));
    expect(z80.sp, equals(0x0100));
  });

  test('EX_SP_IY', () // EX (SP), IY
      {
    z80.iy = 0x3988;
    z80.sp = 0x0100;
    poke(0x0100, 0x90);
    poke(0x0101, 0x48);
    execute([0xFD, 0xE3]);
    expect(z80.iy, equals(0x4890));
    expect(peek(0x0100), equals(0x88));
    expect(peek(0x0101), equals(0x39));
    expect(z80.sp, equals(0x0100));
  });

  test('LDI', () // LDI
      {
    z80.hl = 0x1111;
    poke(0x1111, 0x88);
    z80.de = 0x2222;
    poke(0x2222, 0x66);
    z80.bc = 0x07;
    execute([0xED, 0xA0]);
    expect(z80.hl, equals(0x1112));
    expect(peek(0x1111), equals(0x88));
    expect(z80.de, equals(0x2223));
    expect(peek(0x2222), equals(0x88));
    expect(z80.bc, equals(0x06));
    expect(z80.fH || z80.fN, equals(false));
    expect(z80.fPV, equals(true));
  });

  test('LDIR', () // LDIR
      {
    z80.hl = 0x1111;
    z80.de = 0x2222;
    z80.bc = 0x0003;
    poke(0x1111, 0x88);
    poke(0x1112, 0x36);
    poke(0x1113, 0xA5);
    poke(0x2222, 0x66);
    poke(0x2223, 0x59);
    poke(0x2224, 0xC5);
    execute([0xED, 0xB0]);
    expect(z80.hl, equals(0x1114));
    expect(z80.de, equals(0x2225));
    expect(z80.bc, equals(0x0000));
    expect(peek(0x1111), equals(0x88));
    expect(peek(0x1112), equals(0x36));
    expect(peek(0x1113), equals(0xA5));
    expect(peek(0x2222), equals(0x88));
    expect(peek(0x2223), equals(0x36));
    expect(peek(0x2224), equals(0xA5));
    expect(z80.fH || z80.fPV || z80.fN, equals(false));
  });

  test('LDD', () // LDD
      {
    z80.hl = 0x1111;
    poke(0x1111, 0x88);
    z80.de = 0x2222;
    poke(0x2222, 0x66);
    z80.bc = 0x07;
    execute([0xED, 0xA8]);
    expect(z80.hl, equals(0x1110));
    expect(peek(0x1111), equals(0x88));
    expect(z80.de, equals(0x2221));
    expect(peek(0x2222), equals(0x88));
    expect(z80.bc, equals(0x06));
    expect(z80.fH || z80.fN, equals(false));
    expect(z80.fPV, equals(true));
  });

  test('LDDR', () // LDDR
      {
    z80.hl = 0x1114;
    z80.de = 0x2225;
    z80.bc = 0x0003;
    poke(0x1114, 0xA5);
    poke(0x1113, 0x36);
    poke(0x1112, 0x88);
    poke(0x2225, 0xC5);
    poke(0x2224, 0x59);
    poke(0x2223, 0x66);
    execute([0xED, 0xB8]);
    expect(z80.hl, equals(0x1111));
    expect(z80.de, equals(0x2222));
    expect(z80.bc, equals(0x0000));
    expect(peek(0x1114), equals(0xA5));
    expect(peek(0x1113), equals(0x36));
    expect(peek(0x1112), equals(0x88));
    expect(peek(0x2225), equals(0xA5));
    expect(peek(0x2224), equals(0x36));
    expect(peek(0x2223), equals(0x88));
    expect(z80.fH || z80.fPV || z80.fN, equals(false));
  });

  test('CPI', () // CPI
      {
    z80.hl = 0x1111;
    poke(0x1111, 0x3B);
    z80.a = 0x3B;
    z80.bc = 0x0001;
    execute([0xED, 0xA1]);
    expect(z80.bc, equals(0x0000));
    expect(z80.hl, equals(0x1112));
    expect(z80.fZ, equals(true));
    expect(z80.fPV, equals(false));
    expect(z80.a, equals(0x3B));
    expect(peek(0x1111), equals(0x3B));
  });

  test('CPIR', () // CPIR
      {
    z80.hl = 0x1111;
    z80.a = 0xF3;
    z80.bc = 0x0007;
    poke(0x1111, 0x52);
    poke(0x1112, 0x00);
    poke(0x1113, 0xF3);
    execute([0xED, 0xB1]);
    expect(z80.hl, equals(0x1114));
    expect(z80.bc, equals(0x0004));
    expect(z80.fPV && z80.fZ, equals(true));
  });

  test('CPD', () // CPD
      {
    z80.hl = 0x1111;
    poke(0x1111, 0x3B);
    z80.a = 0x3B;
    z80.bc = 0x0001;
    execute([0xED, 0xA9]);
    expect(z80.hl, equals(0x1110));
    expect(z80.fZ, equals(true));
    expect(z80.fPV, equals(false));
    expect(z80.a, equals(0x3B));
    expect(peek(0x1111), equals(0x3B));
  });

  test('CPDR', () // CPDR
      {
    z80.hl = 0x1118;
    z80.a = 0xF3;
    z80.bc = 0x0007;
    poke(0x1118, 0x52);
    poke(0x1117, 0x00);
    poke(0x1116, 0xF3);
    execute([0xED, 0xB9]);
    expect(z80.hl, equals(0x1115));
    expect(z80.bc, equals(0x0004));
    expect(z80.fPV && z80.fZ, equals(true));
  });

  test('ADD_A_r', () // ADD A, r
      {
    z80.a = 0x44;
    z80.c = 0x11;
    execute([0x81]);
    expect(z80.fH, equals(false));
    expect(z80.fS || z80.fZ || z80.fPV || z80.fN || z80.fC, equals(false));
  });

  test('ADD_A_n', () // ADD A, n
      {
    z80.a = 0x23;
    execute([0xC6, 0x33]);
    expect(z80.a, equals(0x56));
    expect(z80.fH, equals(false));
    expect(z80.fS || z80.fZ || z80.fN || z80.fPV || z80.fC, equals(false));
  });

  test('ADD_A_pHL', () // ADD A, (HL)
      {
    z80.a = 0xA0;
    z80.hl = 0x2323;
    poke(0x2323, 0x08);
    execute([0x86]);
    expect(z80.a, equals(0xA8));
    expect(z80.fS, equals(true));
    expect(z80.fZ || z80.fC || z80.fPV || z80.fN || z80.fH, equals(false));
  });

  test('ADD_A_IXd', () // ADD A, (IX + d)
      {
    z80.a = 0x11;
    z80.ix = 0x1000;
    poke(0x1005, 0x22);
    execute([0xDD, 0x86, 0x05]);
    expect(z80.a, equals(0x33));
    expect(z80.fS || z80.fZ || z80.fH || z80.fPV || z80.fN || z80.fC,
        equals(false));
  });

  test('ADD_A_IYd', () // ADD A, (IY + d)
      {
    z80.a = 0x11;
    z80.iy = 0x1000;
    poke(0x1005, 0x22);
    execute([0xFD, 0x86, 0x05]);
    expect(z80.a, equals(0x33));
    expect(z80.fS || z80.fZ || z80.fH || z80.fPV || z80.fN || z80.fC,
        equals(false));
  });

  test('ADC_A_pHL', () // ADC A, (HL)
      {
    z80.a = 0x16;
    z80.fC = true;
    z80.hl = 0x6666;
    poke(0x6666, 0x10);
    execute([0x8E]);
    expect(z80.a, equals(0x27));
    expect(z80.fS || z80.fZ || z80.fH || z80.fPV || z80.fN || z80.fC,
        equals(false));
  });

  test('SUB_D', () // SUB D
      {
    z80.a = 0x29;
    z80.d = 0x11;
    execute([0x92]);
    expect(z80.a, equals(0x18));
    expect(z80.fN, equals(true));
    expect(z80.fS || z80.fZ || z80.fH || z80.fPV || z80.fC, equals(false));
  });

  test('SBC_pHL', () // SBC A, (HL)
      {
    z80.a = 0x16;
    z80.fC = true;
    z80.hl = 0x3433;
    poke(0x3433, 0x05);
    execute([0x9E]);
    expect(z80.a, equals(0x10));
    expect(z80.fN, equals(true));
    expect(z80.fS || z80.fZ || z80.fH || z80.fPV || z80.fC, equals(false));
  });

  test('AND_s', () // AND s
      {
    z80.b = 0x7B;
    z80.a = 0xC3;
    execute([0xA0]);
    expect(z80.a, equals(0x43));
    expect(z80.fH, equals(true));
    expect(z80.fS || z80.fZ || z80.fPV || z80.fN || z80.fC, equals(false));
  });

  test('OR_s', () // OR s
      {
    z80.h = 0x48;
    z80.a = 0x12;
    execute([0xB4]);
    expect(z80.a, equals(0x5A));
    expect(z80.fPV, equals(true));
    expect(z80.fS || z80.fZ || z80.fH || z80.fN || z80.fC, equals(false));
  });

  test('XOR_s', () // XOR s
      {
    z80.a = 0x96;
    execute([0xEE, 0x5D]);
    expect(z80.a, equals(0xCB));
    expect(z80.fS, equals(true));
    expect(z80.fZ || z80.fH || z80.fPV || z80.fN || z80.fC, equals(false));
  });

  test('CP_s', () // CP s
      {
    z80.a = 0x63;
    z80.hl = 0x6000;
    poke(0x6000, 0x60);
    execute([0xBE]);
    expect(z80.fN, equals(true));
    expect(z80.fS || z80.fZ || z80.fH || z80.fPV || z80.fC, equals(false));
  });

  test('INC_s', () // INC s
      {
    bool oldC = z80.fC;
    z80.d = 0x28;
    execute([0x14]);
    expect(z80.d, equals(0x29));
    expect(z80.fS || z80.fZ || z80.fH || z80.fPV || z80.fN, equals(false));
    expect(z80.fC, equals(oldC));
  });

  test('INC_pHL', () // INC (HL)
      {
    bool oldC = z80.fC;
    z80.hl = 0x3434;
    poke(0x3434, 0x7F);
    execute([0x34]);
    expect(peek(0x3434), equals(0x80));
    expect(z80.fPV && z80.fS && z80.fH, equals(true));
    expect(z80.fZ || z80.fN, equals(false));
    expect(z80.fC, equals(oldC));
  });

  test('INC_pIXd', () // INC (IX+d)
      {
    bool oldC = z80.fC;
    z80.ix = 0x2020;
    poke(0x2030, 0x34);
    execute([0xDD, 0x34, 0x10]);
    expect(peek(0x2030), equals(0x35));
    expect(z80.fS || z80.fZ || z80.fH || z80.fPV || z80.fN, equals(false));
    expect(z80.fC, equals(oldC));
  });

  test('INC_pIYd', () // INC (IY+d)
      {
    bool oldC = z80.fC;
    z80.iy = 0x2020;
    poke(0x2030, 0x34);
    execute([0xFD, 0x34, 0x10]);
    expect(peek(0x2030), equals(0x35));
    expect(z80.fS || z80.fZ || z80.fH || z80.fPV || z80.fN, equals(false));
    expect(z80.fC, equals(oldC));
  });

  test('DEC_m', () // DEC m
      {
    bool oldC = z80.fC;
    z80.d = 0x2A;
    execute([0x15]);
    expect(z80.fN, equals(true));
    expect(z80.fS || z80.fZ || z80.fH || z80.fPV, equals(false));
    expect(z80.fC, equals(oldC));
  });

  test('DAA', () // DAA
      {
    z80.a = 0x0E;
    z80.b = 0x0F;
    z80.c = 0x90;
    z80.d = 0x40;

    // AND 0x0F; ADD A, 0x90; DAA; ADC A 0x40; DAA
    execute([0xA0, 0x81, 0x27, 0x8A, 0x27]);

    expect(z80.a, equals(0x45));
    // TODO: Add asserts for flags
  });

  test('CPL', () // CPL
      {
    z80.a = 0xB4;
    execute([0x2F]);
    expect(z80.a, equals(0x4B));
    expect(z80.fH && z80.fN, equals(true));
  });

  test('NEG', () // NEG
      {
    z80.a = 0x98;
    execute([0xED, 0x44]);
    expect(z80.a, equals(0x68));
    expect(z80.fS || z80.fZ || z80.fPV, equals(false));
    expect(z80.fN && z80.fC && z80.fH, equals(true));
  });

  test('CCF', () // CCF
      {
    z80.fN = true;
    z80.fC = true;
    execute([0x3F]);
    expect(z80.fC || z80.fN, equals(false));
  });

  test('SCF', () // SCF
      {
    z80.fC = false;
    z80.fH = true;
    z80.fN = true;
    execute([0x37]);
    expect(z80.fC, equals(true));
    expect(z80.fH || z80.fN, equals(false));
  });

  test('HALT', () // HALT
      {
    // TODO: Replace temporary HALT assert with real logic
    // when HALT isn't used to end emulation
    // expect(true);
  });

  test('DI', () // DI
      {
    z80.iff1 = true;
    z80.iff2 = true;
    execute([0xF3]);
    expect(z80.iff1 || z80.iff2, equals(false));
  });

  test('EI', () // DI
      {
    z80.iff1 = true;
    z80.iff2 = true;
    execute([0xF3]);
    expect(z80.iff1 || z80.iff2, equals(false));
  });

  test('IM0', () // IM 0
      {
    // TODO: Come up with a test case for this
    // expect(true);
  });

  test('IM1', () // IM 1
      {
    // TODO: Come up with a test case for this
    // expect(true);
  });

  test('IM2', () // IM 2
      {
    // TODO: Come up with a test case for this
    // expect(true);
  });

  test('ADD_HL_ss', () // ADD HL, ss
      {
    z80.hl = 0x4242;
    z80.de = 0x1111;
    execute([0x19]);
    expect(z80.hl, equals(0x5353));
  });

  test('ADC_HL_ss', () // ADD HL, ss
      {
    z80.bc = 0x2222;
    z80.hl = 0x5437;
    z80.fC = true;
    execute([0xED, 0x4A]);
    expect(z80.hl, equals(0x765A));
  });

  test('SBC_HL_ss', () // SBC HL, ss
      {
    z80.hl = 0x9999;
    z80.de = 0x1111;
    z80.fC = true;
    execute([0xED, 0x52]);
    expect(z80.hl, equals(0x8887));
  });

  test('ADD_IX_pp', () // ADD IX, pp
      {
    z80.ix = 0x3333;
    z80.bc = 0x5555;
    execute([0xDD, 0x09]);
    expect(z80.ix, equals(0x8888));
  });

  test('ADD_IY_pp', () // ADD IY, rr
      {
    z80.iy = 0x3333;
    z80.bc = 0x5555;
    execute([0xFD, 0x09]);
    expect(z80.iy, equals(0x8888));
  });

  test('INC_ss', () // INC ss
      {
    z80.hl = 0x1000;
    execute([0x23]);
    expect(z80.hl, equals(0x1001));
  });

  test('INC_IX', () // INC IX
      {
    z80.ix = 0x3300;
    execute([0xDD, 0x23]);
    expect(z80.ix, equals(0x3301));
  });

  test('INC_IY', () // INC IY
      {
    z80.iy = 0x2977;
    execute([0xFD, 0x23]);
    expect(z80.iy, equals(0x2978));
  });

  test('DEC_ss', () // DEC ss
      {
    z80.hl = 0x1001;
    execute([0x2B]);
    expect(z80.hl, equals(0x1000));
  });

  test('DEC_IX', () // DEC IX
      {
    z80.ix = 0x2006;
    execute([0xDD, 0x2B]);
    expect(z80.ix, equals(0x2005));
  });

  test('DEC_IY', () // DEC IY
      {
    z80.iy = 0x7649;
    execute([0xFD, 0x2B]);
    expect(z80.iy, equals(0x7648));
  }

// TODO: Go back and check some of these flags

      );

  test('RLCA', () // RLCA
      {
    z80.a = 0x88;
    execute([0x07]);
    expect(z80.fC, equals(true));
    expect(z80.a, equals(0x11));
  });

  test('RLA', () // RLA
      {
    z80.fC = true;
    z80.a = 0x76;
    execute([0x17]);
    expect(z80.fC, equals(false));
    expect(z80.a, equals(0xED));
  });

  test('RRCA', () // RRCA
      {
    z80.a = 0x11;
    execute([0x0F]);
    expect(z80.a, equals(0x88));
    expect(z80.fC, equals(true));
  });

  test('RRA', () // RRA
      {
    z80.fH = true;
    z80.fN = true;
    z80.a = 0xE1;
    z80.fC = false;
    execute([0x1F]);
    expect(z80.a, equals(0x70));
    expect(z80.fC, equals(true));
    expect(z80.fH || z80.fN, equals(false));
  });

  test('RLC_r', () // RLC r
      {
    z80.fH = true;
    z80.fN = true;
    z80.l = 0x88;
    execute([0xCB, 0x05]);
    expect(z80.fC, equals(true));
    expect(z80.l, equals(0x11));
    expect(z80.fH || z80.fN, equals(false));
  });

  test('RLC_pHL', () // RLC (HL)
      {
    z80.fH = true;
    z80.fN = true;
    z80.hl = 0x2828;
    poke(0x2828, 0x88);
    execute([0xCB, 0x06]);
    expect(z80.fC, equals(true));
    expect(peek(0x2828), equals(0x11));
    expect(z80.fH || z80.fN, equals(false));
  });

  test('RLC_pIXd', () // RLC (IX+d)
      {
    z80.ix = 0x1000;
    poke(0x1002, 0x88);
    execute([0xDD, 0xCB, 0x02, 0x06]);
    expect(z80.fC, equals(true));
    expect(peek(0x1002), equals(0x11));
  });

  test('RLC_pIYd', () // RLC (IY+d)
      {
    z80.iy = 0x1000;
    poke(0x1002, 0x88);
    execute([0xFD, 0xCB, 0x02, 0x06]);
    expect(z80.fC, equals(true));
    expect(peek(0x1002), equals(0x11));
  });

  test('RL_m', () // RL m
      {
    z80.d = 0x8F;
    z80.fC = false;
    execute([0xCB, 0x12]);
    expect(z80.fC, equals(true));
    expect(z80.d, equals(0x1E));
  });

  test('RRC_m', () // RRC m
      {
    z80.a = 0x31;
    execute([0xCB, 0x0F]);
    expect(z80.fC, equals(true));
    expect(z80.a, equals(0x98));
  });

  test('RR_m', () // RR m
      {
    z80.hl = 0x4343;
    poke(0x4343, 0xDD);
    z80.fC = false;
    execute([0xCB, 0x1E]);
    expect(peek(0x4343), equals(0x6E));
    expect(z80.fC, equals(true));
  });

  test('SLA_m', () // SLA m
      {
    z80.l = 0xB1;
    execute([0xCB, 0x25]);
    expect(z80.fC, equals(true));
    expect(z80.l, equals(0x62));
  });

  test('SRA_m', () // SRA m
      {
    z80.ix = 0x1000;
    poke(0x1003, 0xB8);
    execute([0xDD, 0xCB, 0x03, 0x2E]);
    expect(z80.fC, equals(false));
    expect(peek(0x1003), equals(0xDC));
  });

  test('SRL_m', () // SRL m
      {
    z80.b = 0x8F;
    poke(0x1003, 0xB8);
    execute([0xCB, 0x38]);
    expect(z80.fC, equals(true));
    expect(z80.b, equals(0x47));
  });

  test('RLD', () // RLD
      {
    z80.hl = 0x5000;
    z80.a = 0x7A;
    poke(0x5000, 0x31);
    execute([0xED, 0x6F]);
    expect(z80.a, equals(0x73));
    expect(peek(0x5000), equals(0x1A));
  });

  test('RRD', () // RRD
      {
    z80.hl = 0x5000;
    z80.a = 0x84;
    poke(0x5000, 0x20);
    execute([0xED, 0x67]);
    expect(z80.a, equals(0x80));
    expect(peek(0x5000), equals(0x42));
  });

  test('BIT_b_r', () // BIT b, r
      {
    z80.b = 0;
    execute([0xCB, 0x50]);
    expect(z80.b, equals(0));
    expect(z80.fZ, equals(true));
  });

  test('BIT_b_pHL', () // BIT b, (HL)
      {
    z80.fZ = true;
    z80.hl = 0x4444;
    poke(0x4444, 0x10);
    execute([0xCB, 0x66]);
    expect(z80.fZ, equals(false));
    expect(peek(0x4444), equals(0x10));
  });

  test('BIT_b_pIXd', () // BIT b, (IX+d)
      {
    z80.fZ = true;
    z80.ix = 0x2000;
    poke(0x2004, 0xD2);
    execute([0xDD, 0xCB, 0x04, 0x76]);
    expect(z80.fZ, equals(false));
    expect(peek(0x2004), equals(0xD2));
  });

  test('BIT_b_pIYd', () // BIT b, (IY+d)
      {
    z80.fZ = true;
    z80.iy = 0x2000;
    poke(0x2004, 0xD2);
    execute([0xFD, 0xCB, 0x04, 0x76]);
    expect(z80.fZ, equals(false));
    expect(peek(0x2004), equals(0xD2));
  });

  test('SET_b_r', () // SET b, r
      {
    z80.a = 0;
    execute([0xCB, 0xE7]);
    expect(z80.a, equals(0x10));
  });

  test('SET_b_pHL', () // SET b, (HL)
      {
    z80.hl = 0x3000;
    poke(0x3000, 0x2F);
    execute([0xCB, 0xE6]);
    expect(peek(0x3000), equals(0x3F));
  });

  test('SET_b_pIXd', () // SET b, (IX+d)
      {
    z80.ix = 0x2000;
    poke(0x2003, 0xF0);
    execute([0xDD, 0xCB, 0x03, 0xC6]);
    expect(peek(0x2003), equals(0xF1));
  });

  test('SET_b_pIYd', () // SET b, (IY+d)
      {
    z80.iy = 0x2000;
    poke(0x2003, 0x38);
    execute([0xFD, 0xCB, 0x03, 0xC6]);
    expect(peek(0x2003), equals(0x39));
  });

  test('RES_b_m', () // RES b, m
      {
    z80.d = 0xFF;
    execute([0xCB, 0xB2]);
    expect(z80.d, equals(0xBF));
  });
}
