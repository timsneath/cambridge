using System;
using Microsoft.VisualStudio.TestPlatform.UnitTestFramework;
using ProjectCambridge.EmulatorCore;

namespace ProjectCambridge.EmulatorTests
{
    [TestClass]
    public class Z80Tests
    {
        Memory memory;
        Z80 z80;

        public Z80Tests()
        {
            memory = new Memory(ROMProtected: false);
            z80 = new Z80(memory, 0xA000);
        }

        [TestInitialize]
        public void TestClean()
        {
            z80.Reset();
            memory.Reset(IncludeROMArea: true);
        }

        private void Poke(ushort addr, byte val) => memory.WriteByte(addr, val);

        private void PokeInstructions(byte[] instructions)
        {
            ushort addr = 0xA000;

            foreach (var instruction in instructions)
            {
                memory.WriteByte(addr++, instruction);
            }
            memory.WriteByte(addr, 0x76); // HALT instruction
        }

        private void PokeAndRun(params byte[] instructions)
        {
            PokeInstructions(instructions);
            z80.pc = 0xA000;
            while (z80.ExecuteNextInstruction()) { }
        }

        [TestMethod]
        public void TestNOPInstruction()
        {
            PokeAndRun(0x00, 0x00, 0x00, 0x00);

            Assert.IsTrue(z80.af == 0);
            Assert.IsTrue(z80.bc == 0);
            Assert.IsTrue(z80.de == 0);
            Assert.IsTrue(z80.hl == 0);
            Assert.IsTrue(z80.ix == 0);
            Assert.IsTrue(z80.iy == 0);

            Assert.IsTrue(z80.pc == 0xA005);
        }

        [TestMethod]
        public void TestLD_H_E()
        {
            z80.h = 0x8A;
            z80.e = 0x10;
            PokeAndRun(0x63);
            Assert.IsTrue(z80.h == 0x10);
            Assert.IsTrue(z80.e == 0x10);
        }

        [TestMethod]
        public void TestLD_R_N() // LD r, r'
        {
            PokeAndRun(0x1E, 0xA5);
            Assert.IsTrue(z80.e == 0xA5);
        }

        [TestMethod]
        public void TestLD_R_HL() // LD r, (HL)
        {
            Poke(0x75A1, 0x58);
            z80.hl = 0x75A1;
            PokeAndRun(0x4E);
            Assert.IsTrue(z80.c == 0x58);
        }

        [TestMethod]
        public void TestLD_R_IXd() // LD r, (IX+d)
        {
            z80.ix = 0x25AF;
            Poke(0x25C8, 0x39);
            PokeAndRun(0xDD, 0x46, 0x19);
            Assert.IsTrue(z80.b == 0x39);
        }

        [TestMethod]
        public void TestLD_R_IYd() // LD r, (IY+d)
        {
            z80.iy = 0x25AF;
            Poke(0x25C8, 0x39);
            PokeAndRun(0xFD, 0x46, 0x19);
            Assert.IsTrue(z80.b == 0x39);
        }

        [TestMethod]
        public void TestLD_HL_R() // LD (HL), r
        {
            z80.hl = 0x2146;
            z80.b = 0x29;
            PokeAndRun(0x70);
            Assert.IsTrue(memory.ReadByte(0x2146) == 0x29);
        }

        [TestMethod]
        public void TestLD_IXd_r() // LD (IX+d), r
        {
            z80.c = 0x1C;
            z80.ix = 0x3100;
            PokeAndRun(0xDD, 0x70, 0x06);
            Assert.IsTrue(memory.ReadByte(0x3106) == 0x1C);
        }

        [TestMethod]
        public void TestLD_IYd_r() // LD (IY+d), r
        {
            z80.c = 0x48;
            z80.iy = 0x2A11;
            PokeAndRun(0xFD, 0x70, 0x04);
            Assert.IsTrue(memory.ReadByte(0x2A15) == 0x48);
        }

        [TestMethod]
        public void TestLD_HL_N() // LD (HL), n
        {
            z80.hl = 0x4444;
            PokeAndRun(0x36, 0x28);
            Assert.IsTrue(memory.ReadByte(0x4444) == 0x28);
        }

        [TestMethod]
        public void TestLD_IXd_N() // LD (IX+d), n
        {
            z80.ix = 0x219A;
            PokeAndRun(0xDD, 0x36, 0x05, 0x5A);
            Assert.IsTrue(memory.ReadByte(0x219F) == 0x05);
        }

        [TestMethod]
        public void TestLD_IYd_N() // LD (IY+d), n
        {
            z80.iy = 0xA940;
            PokeAndRun(0xFD, 0x36, 0x10, 0x97);
            Assert.IsTrue(memory.ReadByte(0xA950) == 0x97);
        }

        [TestMethod]
        public void TestLD_A_BC() // LD A, (BC)
        {
            z80.bc = 0x4747;
            Poke(0x4747, 0x12);
            PokeAndRun(0x0A);
            Assert.IsTrue(z80.a == 0x12);
        }

        [TestMethod]
        public void TestLD_A_DE() // LD A, (DE)
        {
            z80.de = 0x30A2;
            Poke(0x30A2, 0x22);
            PokeAndRun(0x1A);
            Assert.IsTrue(z80.a == 0x22);
        }

        [TestMethod]
        public void TestLD_A_NN() // LD A, (nn)
        {
            Poke(0x8832, 0x04);
            PokeAndRun(0x3A, 0x32, 0x88);
            Assert.IsTrue(z80.a == 0x04);
        }

        [TestMethod]
        public void TestLD_BC_A() // LD (BC), A
        {
            z80.a = 0x7A;
            z80.bc = 0x1212;
            PokeAndRun(0x02);
            Assert.IsTrue(memory.ReadByte(0x1212) == 0x7A);
        }

        [TestMethod]
        public void TestLD_DE_A() // LD (DE), A
        {
            z80.de = 0x1128;
            z80.a = 0xA0;
            PokeAndRun(0x12);
            Assert.IsTrue(memory.ReadByte(0x1128) == 0xA0);
        }

        [TestMethod]
        public void TestLD_NN_A() // LD (NN), A
        {
            z80.a = 0xD7;
            PokeAndRun(0x32, 0x41, 0x31);
            Assert.IsTrue(memory.ReadByte(0x3141) == 0xD7);
        }

        [TestMethod]
        public void TestLD_A_I() // LD A, I
        {
            var oldCarry = z80.fC;
            z80.i = 0xFE;
            PokeAndRun(0xED, 0x57);
            Assert.IsTrue(z80.a == 0xFE);
            Assert.IsTrue(z80.i == 0xFE);
            Assert.IsTrue(z80.fS);
            Assert.IsFalse(z80.fZ);
            Assert.IsFalse(z80.fH);
            Assert.IsTrue(z80.fP == z80.iff2);
            Assert.IsFalse(z80.fN);
            Assert.IsTrue(z80.fC = oldCarry);
            // TODO: If an interrupt occurs during the execution of 
            // this instruction, the Parity flag contains a 0.
        }

        [TestMethod]
        public void TestLD_A_R() // LD A, R
        {
            var oldCarry = z80.fC;
            z80.r = 0x07;
            PokeAndRun(0xED, 0x5F);
            Assert.IsTrue(z80.a == 0x07);
            Assert.IsTrue(z80.r == 0x07);
            Assert.IsFalse(z80.fS);
            Assert.IsFalse(z80.fZ);
            Assert.IsFalse(z80.fH);
            Assert.IsTrue(z80.fP == z80.iff2);
            Assert.IsFalse(z80.fN);
            Assert.IsTrue(z80.fC = oldCarry);
            // TODO: If an interrupt occurs during the execution of 
            // this instruction, the Parity flag contains a 0.
        }

        [TestMethod]
        public void TestLD_I_A() // LD I, A
        {
            z80.a = 0x5C;
            PokeAndRun(0xED, 0x47);
            Assert.IsTrue(z80.i == 0x5C);
            Assert.IsTrue(z80.a == 0x5C);
        }

        [TestMethod]
        public void TestLD_R_A() // LD R, A
        {
            z80.a = 0xDE;
            PokeAndRun(0xED, 0x4F);
            Assert.IsTrue(z80.r == 0xDE);
            Assert.IsTrue(z80.a == 0xDE);
        }

        [TestMethod]
        public void TestLD_DD_NN() // LD dd, nn
        {
            PokeAndRun(0x21, 0x00, 0x50);
            Assert.IsTrue(z80.hl == 0x5000);
            Assert.IsTrue(z80.h == 0x50);
            Assert.IsTrue(z80.l == 0x00);
        }

        [TestMethod]
        public void TestLD_IX_NN() // LD IX, nn
        {
            PokeAndRun(0xDD, 0x21, 0xA2, 0x45);
            Assert.IsTrue(z80.ix == 0x45A2);
        }

        [TestMethod]
        public void TestLD_IY_NN() // LD IY, nn
        {
            PokeAndRun(0xFD, 0x21, 0x33, 0x77);
            Assert.IsTrue(z80.iy == 0x7733);
        }

        [TestMethod]
        public void TestLD_HL_NN1() // LD HL, (nn)
        {
            Poke(0x4545, 0x37);
            Poke(0x4546, 0xA1);
            PokeAndRun(0x2A, 0x45, 0x45);
            Assert.IsTrue(z80.hl == 0xA137);

        }

        [TestMethod]
        public void TestLD_HL_NN2()
        {
            Poke(0x8ABC, 0x84);
            Poke(0x8ABD, 0x89);
            PokeAndRun(0x2A, 0xBC, 0x8A);
            Assert.IsTrue(z80.hl == 0x8984);
        }

        [TestMethod]
        public void TestLD_DD_pNN() // LD dd, (nn)
        {
            Poke(0x2130, 0x65);
            Poke(0x2131, 0x78);
            PokeAndRun(0xED, 0x4B, 0x30, 0x21);
            Assert.IsTrue(z80.bc == 0x7865);
        }

        [TestMethod]
        public void TestLD_IX_pNN() // LD IX, (nn)
        {
            Poke(0x6666, 0x92);
            Poke(0x6667, 0xDA);
            PokeAndRun(0xDD, 0x2A, 0x66, 0x66);
            Assert.IsTrue(z80.ix == 0xDA92);
        }

        [TestMethod]
        public void TestLD_IY_pNN() // LD IY, (nn)
        {
            Poke(0xF532, 0x11);
            Poke(0xF533, 0x22);
            PokeAndRun(0xFD, 0x2A, 0x32, 0xF5);
            Assert.IsTrue(z80.iy == 0x2211);
        }
    }
}
