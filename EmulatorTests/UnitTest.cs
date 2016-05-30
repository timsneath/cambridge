﻿using System;
using Microsoft.VisualStudio.TestPlatform.UnitTestFramework;
using ProjectCambridge.EmulatorCore;

namespace ProjectCambridge.EmulatorTests
{
    [TestClass]
    public class Z80InstructionTests
    {
        // TODO: Adjust earlier test cases for consistency of naming

        Memory memory;
        Z80 z80;

        public Z80InstructionTests()
        {
            memory = new Memory(ROMProtected: false);
            z80 = new Z80(memory, 0xA000);
        }

        [TestInitialize]
        public void Initialize()
        {
            z80.Reset();
            memory.Reset(IncludeROMArea: true);
        }

        private void Poke(ushort addr, byte val) => memory.WriteByte(addr, val);
        private byte Peek(ushort addr) => memory.ReadByte(addr);

        private void LoadInstructions(byte[] instructions)
        {
            // we pick this as a 'safe' location that doesn't clash with other instructions
            // TODO: randomize this, perhaps? 
            ushort addr = 0xA000;

            foreach (var instruction in instructions)
            {
                memory.WriteByte(addr++, instruction);
            }
            memory.WriteByte(addr, 0x76); // HALT instruction
        }

        private void Execute(params byte[] instructions)
        {
            LoadInstructions(instructions);
            z80.pc = 0xA000;
            while (z80.ExecuteNextInstruction()) { }
        }

        [TestMethod]
        public void NOP()
        {
            Execute(0x00, 0x00, 0x00, 0x00);

            Assert.IsTrue(z80.af == 0);
            Assert.IsTrue(z80.bc == 0);
            Assert.IsTrue(z80.de == 0);
            Assert.IsTrue(z80.hl == 0);
            Assert.IsTrue(z80.ix == 0);
            Assert.IsTrue(z80.iy == 0);

            Assert.IsTrue(z80.pc == 0xA005);
        }

        [TestMethod]
        public void LD_H_E()
        {
            z80.h = 0x8A;
            z80.e = 0x10;
            Execute(0x63);
            Assert.IsTrue(z80.h == 0x10);
            Assert.IsTrue(z80.e == 0x10);
        }

        [TestMethod]
        public void LD_R_N() // LD r, r'
        {
            Execute(0x1E, 0xA5);
            Assert.IsTrue(z80.e == 0xA5);
        }

        [TestMethod]
        public void LD_R_HL() // LD r, (HL)
        {
            Poke(0x75A1, 0x58);
            z80.hl = 0x75A1;
            Execute(0x4E);
            Assert.IsTrue(z80.c == 0x58);
        }

        [TestMethod]
        public void LD_R_IXd() // LD r, (IX+d)
        {
            z80.ix = 0x25AF;
            Poke(0x25C8, 0x39);
            Execute(0xDD, 0x46, 0x19);
            Assert.IsTrue(z80.b == 0x39);
        }

        [TestMethod]
        public void LD_R_IYd() // LD r, (IY+d)
        {
            z80.iy = 0x25AF;
            Poke(0x25C8, 0x39);
            Execute(0xFD, 0x46, 0x19);
            Assert.IsTrue(z80.b == 0x39);
        }

        [TestMethod]
        public void LD_HL_R() // LD (HL), r
        {
            z80.hl = 0x2146;
            z80.b = 0x29;
            Execute(0x70);
            Assert.IsTrue(Peek(0x2146) == 0x29);
        }

        [TestMethod]
        public void LD_IXd_r() // LD (IX+d), r
        {
            z80.c = 0x1C;
            z80.ix = 0x3100;
            Execute(0xDD, 0x71, 0x06);
            Assert.IsTrue(Peek(0x3106) == 0x1C);
        }

        [TestMethod]
        public void LD_IYd_r() // LD (IY+d), r
        {
            z80.c = 0x48;
            z80.iy = 0x2A11;
            Execute(0xFD, 0x71, 0x04);
            Assert.IsTrue(Peek(0x2A15) == 0x48);
        }

        [TestMethod]
        public void LD_HL_N() // LD (HL), n
        {
            z80.hl = 0x4444;
            Execute(0x36, 0x28);
            Assert.IsTrue(Peek(0x4444) == 0x28);
        }

        [TestMethod]
        public void LD_IXd_N() // LD (IX+d), n
        {
            z80.ix = 0x219A;
            Execute(0xDD, 0x36, 0x05, 0x5A);
            Assert.IsTrue(Peek(0x219F) == 0x5A);
        }

        [TestMethod]
        public void LD_IYd_N() // LD (IY+d), n
        {
            z80.iy = 0xA940;
            Execute(0xFD, 0x36, 0x10, 0x97);
            Assert.IsTrue(Peek(0xA950) == 0x97);
        }

        [TestMethod]
        public void LD_A_BC() // LD A, (BC)
        {
            z80.bc = 0x4747;
            Poke(0x4747, 0x12);
            Execute(0x0A);
            Assert.IsTrue(z80.a == 0x12);
        }

        [TestMethod]
        public void LD_A_DE() // LD A, (DE)
        {
            z80.de = 0x30A2;
            Poke(0x30A2, 0x22);
            Execute(0x1A);
            Assert.IsTrue(z80.a == 0x22);
        }

        [TestMethod]
        public void LD_A_NN() // LD A, (nn)
        {
            Poke(0x8832, 0x04);
            Execute(0x3A, 0x32, 0x88);
            Assert.IsTrue(z80.a == 0x04);
        }

        [TestMethod]
        public void LD_BC_A() // LD (BC), A
        {
            z80.a = 0x7A;
            z80.bc = 0x1212;
            Execute(0x02);
            Assert.IsTrue(Peek(0x1212) == 0x7A);
        }

        [TestMethod]
        public void LD_DE_A() // LD (DE), A
        {
            z80.de = 0x1128;
            z80.a = 0xA0;
            Execute(0x12);
            Assert.IsTrue(Peek(0x1128) == 0xA0);
        }

        [TestMethod]
        public void LD_NN_A() // LD (NN), A
        {
            z80.a = 0xD7;
            Execute(0x32, 0x41, 0x31);
            Assert.IsTrue(Peek(0x3141) == 0xD7);
        }

        [TestMethod]
        public void LD_A_I() // LD A, I
        {
            var oldCarry = z80.fC;
            z80.i = 0xFE;
            Execute(0xED, 0x57);
            Assert.IsTrue(z80.a == 0xFE);
            Assert.IsTrue(z80.i == 0xFE);
            Assert.IsTrue(z80.fS);
            Assert.IsFalse(z80.fZ);
            Assert.IsFalse(z80.fH);
            Assert.IsTrue(z80.fPV == z80.iff2);
            Assert.IsFalse(z80.fN);
            Assert.IsTrue(z80.fC == oldCarry);
            // TODO: If an interrupt occurs during the execution of 
            // this instruction, the Parity flag contains a 0.
        }

        [TestMethod]
        public void LD_A_R() // LD A, R
        {
            var oldCarry = z80.fC;
            z80.r = 0x07;
            Execute(0xED, 0x5F);
            Assert.IsTrue(z80.a == 0x07);
            Assert.IsTrue(z80.r == 0x07);
            Assert.IsFalse(z80.fS);
            Assert.IsFalse(z80.fZ);
            Assert.IsFalse(z80.fH);
            Assert.IsTrue(z80.fPV == z80.iff2);
            Assert.IsFalse(z80.fN);
            Assert.IsTrue(z80.fC == oldCarry);
            // TODO: If an interrupt occurs during the execution of 
            // this instruction, the Parity flag contains a 0.
        }

        [TestMethod]
        public void LD_I_A() // LD I, A
        {
            z80.a = 0x5C;
            Execute(0xED, 0x47);
            Assert.IsTrue(z80.i == 0x5C);
            Assert.IsTrue(z80.a == 0x5C);
        }

        [TestMethod]
        public void LD_R_A() // LD R, A
        {
            z80.a = 0xDE;
            Execute(0xED, 0x4F);
            Assert.IsTrue(z80.r == 0xDE);
            Assert.IsTrue(z80.a == 0xDE);
        }

        [TestMethod]
        public void LD_DD_NN() // LD dd, nn
        {
            Execute(0x21, 0x00, 0x50);
            Assert.IsTrue(z80.hl == 0x5000);
            Assert.IsTrue(z80.h == 0x50);
            Assert.IsTrue(z80.l == 0x00);
        }

        [TestMethod]
        public void LD_IX_NN() // LD IX, nn
        {
            Execute(0xDD, 0x21, 0xA2, 0x45);
            Assert.IsTrue(z80.ix == 0x45A2);
        }

        [TestMethod]
        public void LD_IY_NN() // LD IY, nn
        {
            Execute(0xFD, 0x21, 0x33, 0x77);
            Assert.IsTrue(z80.iy == 0x7733);
        }

        [TestMethod]
        public void LD_HL_NN1() // LD HL, (nn)
        {
            Poke(0x4545, 0x37);
            Poke(0x4546, 0xA1);
            Execute(0x2A, 0x45, 0x45);
            Assert.IsTrue(z80.hl == 0xA137);

        }

        [TestMethod]
        public void LD_HL_NN2()
        {
            Poke(0x8ABC, 0x84);
            Poke(0x8ABD, 0x89);
            Execute(0x2A, 0xBC, 0x8A);
            Assert.IsTrue(z80.hl == 0x8984);
        }

        [TestMethod]
        public void LD_DD_pNN() // LD dd, (nn)
        {
            Poke(0x2130, 0x65);
            Poke(0x2131, 0x78);
            Execute(0xED, 0x4B, 0x30, 0x21);
            Assert.IsTrue(z80.bc == 0x7865);
        }

        [TestMethod]
        public void LD_IX_pNN() // LD IX, (nn)
        {
            Poke(0x6666, 0x92);
            Poke(0x6667, 0xDA);
            Execute(0xDD, 0x2A, 0x66, 0x66);
            Assert.IsTrue(z80.ix == 0xDA92);
        }

        [TestMethod]
        public void LD_IY_pNN() // LD IY, (nn)
        {
            Poke(0xF532, 0x11);
            Poke(0xF533, 0x22);
            Execute(0xFD, 0x2A, 0x32, 0xF5);
            Assert.IsTrue(z80.iy == 0x2211);
        }

        [TestMethod]
        public void LD_pNN_HL() // LD (nn), HL
        {
            z80.hl = 0x483A;
            Execute(0x22, 0x29, 0xB2);
            Assert.IsTrue(Peek(0xB229) == 0x3A);
            Assert.IsTrue(Peek(0xB22A) == 0x48);
        }

        [TestMethod]
        public void LD_pNN_DD() // LD (nn), DD
        {
            z80.bc = 0x4644;
            Execute(0xED, 0x43, 0x00, 0x10);
            Assert.IsTrue(Peek(0x1000) == 0x44);
            Assert.IsTrue(Peek(0x1001) == 0x46);
        }

        [TestMethod]
        public void LD_pNN_IX() // LD (nn), IX
        {
            z80.ix = 0x5A30;
            Execute(0xDD, 0x22, 0x92, 0x43);
            Assert.IsTrue(Peek(0x4392) == 0x30);
            Assert.IsTrue(Peek(0x4393) == 0x5A);
        }

        [TestMethod]
        public void LD_pNN_IY() // LD (nn), IY
        {
            z80.iy = 0x4174;
            Execute(0xFD, 0x22, 0x38, 0x88);
            Assert.IsTrue(Peek(0x8838) == 0x74);
            Assert.IsTrue(Peek(0x8839) == 0x41);
        }

        [TestMethod]
        public void LD_SP_HL() // LD SP, HL
        {
            z80.hl = 0x442E;
            Execute(0xF9);
            Assert.IsTrue(z80.sp == 0x442E);
        }

        [TestMethod]
        public void LD_SP_IX() // LD SP, IX
        {
            z80.ix = 0x98DA;
            Execute(0xDD, 0xF9);
            Assert.IsTrue(z80.sp == 0x98DA);
        }

        [TestMethod]
        public void LD_SP_IY() // LD SP, IY
        {
            z80.iy = 0xA227;
            Execute(0xFD, 0xF9);
            Assert.IsTrue(z80.sp == 0xA227);
        }

        [TestMethod]
        public void PUSH_qq() // PUSH qq
        {
            z80.af = 0x2233;
            z80.sp = 0x1007;
            Execute(0xF5);
            Assert.IsTrue(Peek(0x1006) == 0x22);
            Assert.IsTrue(Peek(0x1005) == 0x33);
            Assert.IsTrue(z80.sp == 0x1005);
        }

        [TestMethod]
        public void PUSH_IX() // PUSH IX
        {
            z80.ix = 0x2233;
            z80.sp = 0x1007;
            Execute(0xDD, 0xE5);
            Assert.IsTrue(Peek(0x1006) == 0x22);
            Assert.IsTrue(Peek(0x1005) == 0x33);
            Assert.IsTrue(z80.sp == 0x1005);
        }

        [TestMethod]
        public void PUSH_IY() // PUSH IY
        {
            z80.iy = 0x2233;
            z80.sp = 0x1007;
            Execute(0xFD, 0xE5);
            Assert.IsTrue(Peek(0x1006) == 0x22);
            Assert.IsTrue(Peek(0x1005) == 0x33);
            Assert.IsTrue(z80.sp == 0x1005);
        }

        [TestMethod]
        public void POP_qq() // POP qq
        {
            z80.sp = 0x1000;
            Poke(0x1000, 0x55);
            Poke(0x1001, 0x33);
            Execute(0xE1);
            Assert.IsTrue(z80.hl == 0x3355);
            Assert.IsTrue(z80.sp == 0x1002);
        }

        [TestMethod]
        public void POP_IX() // POP IX
        {
            z80.sp = 0x1000;
            Poke(0x1000, 0x55);
            Poke(0x1001, 0x33);
            Execute(0xDD, 0xE1);
            Assert.IsTrue(z80.ix == 0x3355);
            Assert.IsTrue(z80.sp == 0x1002);
        }

        [TestMethod]
        public void POP_IY() // POP IY
        {
            z80.sp = 0x8FFF;
            Poke(0x8FFF, 0xFF);
            Poke(0x9000, 0x11);
            Execute(0xFD, 0xE1);
            Assert.IsTrue(z80.iy == 0x11FF);
            Assert.IsTrue(z80.sp == 0x9001);
        }

        [TestMethod]
        public void EX_DE_HL() // EX DE, HL
        {
            z80.de = 0x2822;
            z80.hl = 0x499A;
            Execute(0xEB);
            Assert.IsTrue(z80.hl == 0x2822);
            Assert.IsTrue(z80.de == 0x499A);
        }

        [TestMethod]
        public void EX_AF_AF() // EX AF, AF'
        {
            z80.af = 0x9900;
            z80.af_ = 0x5944;
            Execute(0x08);
            Assert.IsTrue(z80.af_ == 0x9900);
            Assert.IsTrue(z80.af == 0x5944);
        }

        [TestMethod]
        public void EXX() // EXX
        {
            z80.af = 0x1234; z80.af_ = 0x4321;
            z80.bc = 0x445A; z80.de = 0x3DA2; z80.hl = 0x8859;
            z80.bc_ = 0x0988; z80.de_ = 0x9300; z80.hl_ = 0x00E7;
            Execute(0xD9);
            Assert.IsTrue(z80.bc == 0x0988);
            Assert.IsTrue(z80.de == 0x9300);
            Assert.IsTrue(z80.hl == 0x00E7);
            Assert.IsTrue(z80.bc_ == 0x445A);
            Assert.IsTrue(z80.de_ == 0x3DA2);
            Assert.IsTrue(z80.hl_ == 0x8859);
            Assert.IsTrue(z80.af == 0x1234); // unchanged
            Assert.IsTrue(z80.af_ == 0x4321); // unchanged
        }

        [TestMethod]
        public void EX_SP_HL() // EX (SP), HL
        {
            z80.hl = 0x7012;
            z80.sp = 0x8856;
            Poke(0x8856, 0x11);
            Poke(0x8857, 0x22);
            Execute(0xE3);
            Assert.IsTrue(z80.hl == 0x2211);
            Assert.IsTrue(Peek(0x8856) == 0x12);
            Assert.IsTrue(Peek(0x8857) == 0x70);
            Assert.IsTrue(z80.sp == 0x8856);
        }

        [TestMethod]
        public void EX_SP_IX() // EX (SP), IX
        {
            z80.ix = 0x3988;
            z80.sp = 0x0100;
            Poke(0x0100, 0x90);
            Poke(0x0101, 0x48);
            Execute(0xDD, 0xE3);
            Assert.IsTrue(z80.ix == 0x4890);
            Assert.IsTrue(Peek(0x0100) == 0x88);
            Assert.IsTrue(Peek(0x0101) == 0x39);
            Assert.IsTrue(z80.sp == 0x0100);
        }

        [TestMethod]
        public void EX_SP_IY() // EX (SP), IY
        {
            z80.iy = 0x3988;
            z80.sp = 0x0100;
            Poke(0x0100, 0x90);
            Poke(0x0101, 0x48);
            Execute(0xFD, 0xE3);
            Assert.IsTrue(z80.iy == 0x4890);
            Assert.IsTrue(Peek(0x0100) == 0x88);
            Assert.IsTrue(Peek(0x0101) == 0x39);
            Assert.IsTrue(z80.sp == 0x0100);
        }

        [TestMethod]
        public void LDI() // LDI
        {
            z80.hl = 0x1111;
            Poke(0x1111, 0x88);
            z80.de = 0x2222;
            Poke(0x2222, 0x66);
            z80.bc = 0x07;
            Execute(0xED, 0xA0);
            Assert.IsTrue(z80.hl == 0x1112);
            Assert.IsTrue(Peek(0x1111) == 0x88);
            Assert.IsTrue(z80.de == 0x2223);
            Assert.IsTrue(Peek(0x2222) == 0x88);
            Assert.IsTrue(z80.bc == 0x06);
            Assert.IsFalse(z80.fH | z80.fN);
            Assert.IsTrue(z80.fPV);
        }

        [TestMethod]
        public void LDIR() // LDIR
        {
            z80.hl = 0x1111;
            z80.de = 0x2222;
            z80.bc = 0x0003;
            Poke(0x1111, 0x88);
            Poke(0x1112, 0x36);
            Poke(0x1113, 0xA5);
            Poke(0x2222, 0x66);
            Poke(0x2223, 0x59);
            Poke(0x2224, 0xC5);
            Execute(0xED, 0xB0);
            Assert.IsTrue(z80.hl == 0x1114);
            Assert.IsTrue(z80.de == 0x2225);
            Assert.IsTrue(z80.bc == 0x0000);
            Assert.IsTrue(Peek(0x1111) == 0x88);
            Assert.IsTrue(Peek(0x1112) == 0x36);
            Assert.IsTrue(Peek(0x1113) == 0xA5);
            Assert.IsTrue(Peek(0x2222) == 0x88);
            Assert.IsTrue(Peek(0x2223) == 0x36);
            Assert.IsTrue(Peek(0x2224) == 0xA5);
            Assert.IsFalse(z80.fH | z80.fPV | z80.fN);
        }

        [TestMethod]
        public void LDD() // LDD
        {
            z80.hl = 0x1111;
            Poke(0x1111, 0x88);
            z80.de = 0x2222;
            Poke(0x2222, 0x66);
            z80.bc = 0x07;
            Execute(0xED, 0xA8);
            Assert.IsTrue(z80.hl == 0x1110);
            Assert.IsTrue(Peek(0x1111) == 0x88);
            Assert.IsTrue(z80.de == 0x2221);
            Assert.IsTrue(Peek(0x2222) == 0x88);
            Assert.IsTrue(z80.bc == 0x06);
            Assert.IsFalse(z80.fH | z80.fN);
            Assert.IsTrue(z80.fPV);
        }

        [TestMethod]
        public void LDDR() // LDDR
        {
            z80.hl = 0x1114;
            z80.de = 0x2225;
            z80.bc = 0x0003;
            Poke(0x1114, 0xA5);
            Poke(0x1113, 0x36);
            Poke(0x1112, 0x88);
            Poke(0x2225, 0xC5);
            Poke(0x2224, 0x59);
            Poke(0x2223, 0x66);
            Execute(0xED, 0xB8);
            Assert.IsTrue(z80.hl == 0x1111);
            Assert.IsTrue(z80.de == 0x2222);
            Assert.IsTrue(z80.bc == 0x0000);
            Assert.IsTrue(Peek(0x1114) == 0xA5);
            Assert.IsTrue(Peek(0x1113) == 0x36);
            Assert.IsTrue(Peek(0x1112) == 0x88);
            Assert.IsTrue(Peek(0x2225) == 0xA5);
            Assert.IsTrue(Peek(0x2224) == 0x36);
            Assert.IsTrue(Peek(0x2223) == 0x88);
            Assert.IsFalse(z80.fH | z80.fPV | z80.fN);
        }

        [TestMethod]
        public void CPI() // CPI
        {
            z80.hl = 0x1111;
            Poke(0x1111, 0x3B);
            z80.a = 0x3B;
            z80.bc = 0x0001;
            Execute(0xED, 0xA1);
            Assert.IsTrue(z80.bc == 0x0000);
            Assert.IsTrue(z80.hl == 0x1112);
            Assert.IsTrue(z80.fZ);
            Assert.IsFalse(z80.fPV);
            Assert.IsTrue(z80.a == 0x3B);
            Assert.IsTrue(Peek(0x1111) == 0x3B);
        }

        [TestMethod]
        public void CPIR() // CPIR
        {
            z80.hl = 0x1111;
            z80.a = 0xF3;
            z80.bc = 0x0007;
            Poke(0x1111, 0x52);
            Poke(0x1112, 0x00);
            Poke(0x1113, 0xF3);
            Execute(0xED, 0xB1);
            Assert.IsTrue(z80.hl == 0x1114);
            Assert.IsTrue(z80.bc == 0x0004);
            Assert.IsTrue(z80.fPV & z80.fZ);
        }

        [TestMethod]
        public void CPD() // CPD
        {
            z80.hl = 0x1111;
            Poke(0x1111, 0x3B);
            z80.a = 0x3B;
            z80.bc = 0x0001;
            Execute(0xED, 0xA9);
            Assert.IsTrue(z80.hl == 0x1110);
            Assert.IsTrue(z80.fZ);
            Assert.IsFalse(z80.fPV);
            Assert.IsTrue(z80.a == 0x3B);
            Assert.IsTrue(Peek(0x1111) == 0x3B);
        }

        [TestMethod]
        public void CPDR() // CPDR
        {
            z80.hl = 0x1118;
            z80.a = 0xF3;
            z80.bc = 0x0007;
            Poke(0x1118, 0x52);
            Poke(0x1117, 0x00);
            Poke(0x1116, 0xF3);
            Execute(0xED, 0xB9);
            Assert.IsTrue(z80.hl == 0x1115);
            Assert.IsTrue(z80.bc == 0x0004);
            Assert.IsTrue(z80.fPV & z80.fZ);
        }

        [TestMethod]
        public void ADD_A_r() // ADD A, r
        {
            z80.a = 0x44;
            z80.c = 0x11;
            Execute(0x81);
            Assert.IsFalse(z80.fH);
            Assert.IsFalse(z80.fS | z80.fZ | z80.fPV | z80.fN | z80.fC);
        }

        [TestMethod]
        public void ADD_A_n() // ADD A, n
        {
            z80.a = 0x23;
            Execute(0xC6, 0x33);
            Assert.IsTrue(z80.a == 0x56);
            Assert.IsFalse(z80.fH);
            Assert.IsFalse(z80.fS | z80.fZ | z80.fN | z80.fPV | z80.fC);
        }

        [TestMethod]
        public void ADD_A_pHL() // ADD A, (HL)
        {
            z80.a = 0xA0;
            z80.hl = 0x2323;
            Poke(0x2323, 0x08);
            Execute(0x86);
            Assert.IsTrue(z80.a == 0xA8);
            Assert.IsTrue(z80.fS);
            Assert.IsFalse(z80.fZ | z80.fC | z80.fPV | z80.fN | z80.fH);
        }

        [TestMethod]
        public void ADD_A_IXd() // ADD A, (IX + d)
        {
            z80.a = 0x11;
            z80.ix = 0x1000;
            Poke(0x1005, 0x22);
            Execute(0xDD, 0x86, 0x05);
            Assert.IsTrue(z80.a == 0x33);
            Assert.IsFalse(z80.fS | z80.fZ | z80.fH | z80.fPV | z80.fN | z80.fC);
        }

        [TestMethod]
        public void ADD_A_IYd() // ADD A, (IY + d)
        {
            z80.a = 0x11;
            z80.iy = 0x1000;
            Poke(0x1005, 0x22);
            Execute(0xFD, 0x86, 0x05);
            Assert.IsTrue(z80.a == 0x33);
            Assert.IsFalse(z80.fS | z80.fZ | z80.fH | z80.fPV | z80.fN | z80.fC);
        }

        [TestMethod]
        public void ADC_A_pHL() // ADC A, (HL)
        {
            z80.a = 0x16;
            z80.fC = true;
            z80.hl = 0x6666;
            Poke(0x6666, 0x10);
            Execute(0x8E);
            Assert.IsTrue(z80.a == 0x27);
            Assert.IsFalse(z80.fS | z80.fZ | z80.fH | z80.fPV | z80.fN | z80.fC);
        }

        [TestMethod]
        public void SUB_D() // SUB D
        {
            z80.a = 0x29;
            z80.d = 0x11;
            Execute(0x92);
            Assert.IsTrue(z80.a == 0x18);
            Assert.IsTrue(z80.fN);
            Assert.IsFalse(z80.fS | z80.fZ | z80.fH | z80.fPV | z80.fC);
        }

        [TestMethod]
        public void SBC_pHL() // SBC A, (HL)
        {
            z80.a = 0x16;
            z80.fC = true;
            z80.hl = 0x3433;
            Poke(0x3433, 0x05);
            Execute(0x9E);
            Assert.IsTrue(z80.a == 0x10);
            Assert.IsTrue(z80.fN);
            Assert.IsFalse(z80.fS | z80.fZ | z80.fH | z80.fPV | z80.fC);
        }

        [TestMethod]
        public void AND_s() // AND s
        {
            z80.b = 0x7B;
            z80.a = 0xC3;
            Execute(0xA0);
            Assert.IsTrue(z80.a == 0x43);
            Assert.IsTrue(z80.fH);
            Assert.IsFalse(z80.fS | z80.fZ | z80.fPV | z80.fN | z80.fC);
        }

        [TestMethod]
        public void OR_s() // OR s
        {
            z80.h = 0x48;
            z80.a = 0x12;
            Execute(0xB4);
            Assert.IsTrue(z80.a == 0x5A);
            Assert.IsFalse(z80.fS | z80.fZ | z80.fH | z80.fPV | z80.fN | z80.fC);
        }

        [TestMethod]
        public void XOR_s() // XOR s
        {
            z80.a = 0x96;
            Execute(0xEE, 0x5D);
            Assert.IsTrue(z80.a == 0xCB);
            Assert.IsTrue(z80.fS);
            Assert.IsFalse(z80.fZ | z80.fH | z80.fPV | z80.fN | z80.fC);
        }

        [TestMethod]
        public void CP_s() // CP s
        {
            z80.a = 0x63;
            z80.hl = 0x6000;
            Poke(0x6000, 0x60);
            Execute(0xBE);
            Assert.IsTrue(z80.fN);
            Assert.IsFalse(z80.fS | z80.fZ | z80.fH | z80.fPV | z80.fC);
        }

        [TestMethod]
        public void INC_s() // INC s
        {
            bool oldC = z80.fC;
            z80.d = 0x28;
            Execute(0x14);
            Assert.IsTrue(z80.d == 0x29);
            Assert.IsFalse(z80.fS | z80.fZ | z80.fH | z80.fPV | z80.fN);
            Assert.IsTrue(z80.fC == oldC);
        }

        [TestMethod]
        public void INC_pHL() // INC (HL)
        {
            bool oldC = z80.fC;
            z80.hl = 0x3434;
            Poke(0x3434, 0x7F);
            Execute(0x34);
            Assert.IsTrue(Peek(0x3434) == 0x80);
            Assert.IsTrue(z80.fPV & z80.fS & z80.fH);
            Assert.IsFalse(z80.fZ | z80.fN);
            Assert.IsTrue(z80.fC == oldC);
        }

        [TestMethod]
        public void INC_pIXd() // INC (IX+d)
        {
            bool oldC = z80.fC;
            z80.ix = 0x2020;
            Poke(0x2030, 0x34);
            Execute(0xDD, 0x34, 0x10);
            Assert.IsTrue(Peek(0x2030) == 0x35);
            Assert.IsFalse(z80.fS | z80.fZ | z80.fH | z80.fPV | z80.fN);
            Assert.IsTrue(z80.fC == oldC);
        }

        [TestMethod]
        public void INC_pIYd() // INC (IY+d)
        {
            bool oldC = z80.fC;
            z80.iy = 0x2020;
            Poke(0x2030, 0x34);
            Execute(0xFD, 0x34, 0x10);
            Assert.IsTrue(Peek(0x2030) == 0x35);
            Assert.IsFalse(z80.fS | z80.fZ | z80.fH | z80.fPV | z80.fN);
            Assert.IsTrue(z80.fC == oldC);
        }

        [TestMethod]
        public void DEC_m() // DEC m
        {
            bool oldC = z80.fC;
            z80.d = 0x2A;
            Execute(0x15);
            Assert.IsTrue(z80.fN);
            Assert.IsFalse(z80.fS | z80.fZ | z80.fH | z80.fPV);
            Assert.IsTrue(z80.fC == oldC);
        }

        [TestMethod]
        public void DAA() // DAA
        {
            z80.a = 0x0E;
            z80.b = 0x0F;
            z80.c = 0x90;
            z80.d = 0x40;

            // AND 0x0F; ADD A, 0x90; DAA; ADC A 0x40; DAA
            Execute(0xA0, 0x81, 0x27, 0x8A, 0x27);

            Assert.IsTrue(z80.a == 0x45);
            // TODO: Add asserts for flags
        }

        [TestMethod]
        public void CPL() // CPL
        {
            z80.a = 0xB4;
            Execute(0x2F);
            Assert.IsTrue(z80.a == 0x4B);
            Assert.IsTrue(z80.fH & z80.fN);
        }

        [TestMethod]
        public void NEG() // NEG
        {
            z80.a = 0x98;
            Execute(0xED, 0x44);
            Assert.IsTrue(z80.a == 0x68);
            Assert.IsFalse(z80.fS | z80.fZ | z80.fPV);
            Assert.IsTrue(z80.fN & z80.fC & z80.fH);
        }

        [TestMethod]
        public void CCF() // CCF
        {
            z80.fN = true;
            z80.fC = true;
            Execute(0x3F);
            Assert.IsFalse(z80.fC | z80.fN);
        }

        [TestMethod]
        public void SCF() // SCF
        {
            z80.fC = false;
            z80.fH = true;
            z80.fN = true;
            Execute(0x37);
            Assert.IsTrue(z80.fC);
            Assert.IsFalse(z80.fH | z80.fN);
        }

        [TestMethod]
        public void HALT() // HALT
        {
            // TODO: Replace temporary HALT assert with real logic 
            // when HALT isn't used to end emulation
            Assert.IsTrue(true);
        }

        [TestMethod]
        public void DI() // DI
        {
            z80.iff1 = true;
            z80.iff2 = true;
            Execute(0xF3);
            Assert.IsFalse(z80.iff1 | z80.iff2);
        }

        [TestMethod]
        public void EI() // DI
        {
            z80.iff1 = true;
            z80.iff2 = true;
            Execute(0xF3);
            Assert.IsFalse(z80.iff1 | z80.iff2);
        }

        [TestMethod]
        public void IM0() // IM 0
        {
            // TODO: Come up with a test case for this
            Assert.IsTrue(true);
        }

        [TestMethod]
        public void IM1() // IM 1
        {
            // TODO: Come up with a test case for this
            Assert.IsTrue(true);
        }

        [TestMethod]
        public void IM2() // IM 2
        {
            // TODO: Come up with a test case for this
            Assert.IsTrue(true);
        }

        [TestMethod]
        public void ADD_HL_ss() // ADD HL, ss
        {
            z80.hl = 0x4242;
            z80.de = 0x1111;
            Execute(0x19);
            Assert.IsTrue(z80.hl == 0x5353);
        }

        [TestMethod]
        public void ADC_HL_ss() // ADD HL, ss
        {
            z80.bc = 0x2222;
            z80.hl = 0x5437;
            z80.fC = true;
            Execute(0xED, 0x4A);
            Assert.IsTrue(z80.hl == 0x765A);
        }

        [TestMethod]
        public void SBC_HL_ss() // SBC HL, ss
        {
            z80.hl = 0x9999;
            z80.de = 0x1111;
            z80.fC = true;
            Execute(0xED, 0x52);
            Assert.IsTrue(z80.hl == 0x8887);
        }

        [TestMethod]
        public void ADD_IX_pp() // ADD IX, pp
        {
            z80.ix = 0x3333;
            z80.bc = 0x5555;
            Execute(0xDD, 0x09);
            Assert.IsTrue(z80.ix == 0x8888);
        }

        [TestMethod]
        public void ADD_IY_pp() // ADD IY, rr
        {
            z80.iy = 0x3333;
            z80.bc = 0x5555;
            Execute(0xFD, 0x09);
            Assert.IsTrue(z80.iy == 0x8888);
        }

        [TestMethod]
        public void INC_ss() // INC ss
        {
            z80.hl = 0x1000;
            Execute(0x23);
            Assert.IsTrue(z80.hl == 0x1001);
        }

        [TestMethod]
        public void INC_IX() // INC IX
        {
            z80.ix = 0x3300;
            Execute(0xDD, 0x23);
            Assert.IsTrue(z80.ix == 0x3301);
        }
    }
}
