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

        private void PokeAndRun(byte[] instructions)
        {
            PokeInstructions(instructions);
            z80.pc = 0xA000;
            while (z80.ExecuteNextInstruction()) { }
        }

        private void PokeAndRun(byte instruction)
        {
            PokeAndRun(new byte[] { instruction });
        }

        [TestMethod]
        public void TestNOPInstruction()
        {
            PokeAndRun(new byte[] { 0x00, 0x00, 0x00, 0x00 });

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
            PokeAndRun(new byte[] { 0x1E, 0xA5 });
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
            PokeAndRun(new byte[] { 0xDD, 0x46, 0x19 });
            Assert.IsTrue(z80.b == 0x39);
        }

        [TestMethod]
        public void TestLD_R_IYd() // LD r, (IY+d)
        {
            z80.iy = 0x25AF;
            Poke(0x25C8, 0x39);
            PokeAndRun(new byte[] { 0xFD, 0x46, 0x19 });
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
            PokeAndRun(new byte[] { 0xDD, 0x70, 0x06 });
            Assert.IsTrue(memory.ReadByte(0x3106) == 0x1C);
        }

        [TestMethod]
        public void TestLD_IYd_r() // LD (IY+d), r
        {
            z80.c = 0x48;
            z80.iy = 0x2A11;
            PokeAndRun(new byte[] { 0xFD, 0x70, 0x04 });
            Assert.IsTrue(memory.ReadByte(0x2A15) == 0x48);
        }

        [TestMethod]
        public void TestLD_HL_N() // LD (HL), n
        {
            z80.hl = 0x4444;
            PokeAndRun(new byte[] { 0x36, 0x28 });
            Assert.IsTrue(memory.ReadByte(0x4444) == 0x28);
        }

        [TestMethod]
        public void TestLD_IXd_N() // LD (IX+d), n
        {
            z80.ix = 0x219A;
            PokeAndRun(new byte[] { 0xDD, 0x36, 0x05, 0x5A });
            Assert.IsTrue(memory.ReadByte(0x219F) == 0x05);
        }

        [TestMethod]
        public void TestLD_IYd_N() // LD (IY+d), n
        {
            z80.iy = 0xA940;
            PokeAndRun(new byte[] { 0xFD, 0x36, 0x10, 0x97 });
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
            PokeAndRun(new byte[] { 0x3A, 0x32, 0x88 });
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
            PokeAndRun(new byte[] { 0x32, 0x41, 0x31 });
            Assert.IsTrue(memory.ReadByte(0x3141) == 0xD7);
        }
    }
}
