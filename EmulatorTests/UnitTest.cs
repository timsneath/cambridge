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

        public void Poke(ushort addr, byte val) => memory.WriteByte(addr, val);

        public void PokeInstructions(byte[] instructions)
        {
            ushort addr = 0xA000;

            foreach (var instruction in instructions)
            {
                memory.WriteByte(addr++, instruction);
            }
            memory.WriteByte(addr, 0x76); // HALT instruction
        }

        public void PokeAndRun(byte[] instructions)
        {
            PokeInstructions(instructions);
            z80.pc = 0xA000;
            while (z80.ExecuteNextInstruction()) { }
        }

        public void PokeAndRun(byte instruction)
        {
            PokeAndRun(new byte[] { instruction });
        }

        [TestMethod]
        public void TestTest()
        {
            Assert.AreEqual(true, true);
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

            Assert.AreEqual(z80.pc, 0xA005);
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

        [TestInitialize]
        public void TestClean()
        {
            z80.Reset();
            memory.Reset(IncludeROMArea: true);
        }
    }
}
