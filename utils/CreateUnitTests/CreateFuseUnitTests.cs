using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ProjectCambridge.Utilities
{
    class CreateFuseUnitTests
    {
        static void Main(string[] args)
        {

            var outputClass = new StringWriter();

            outputClass.Write(@"using System;
using Microsoft.VisualStudio.TestPlatform.UnitTestFramework;
using ProjectCambridge.EmulatorCore;

namespace ProjectCambridge.EmulatorTests
{
    [TestClass]
    public class FuseTests
    {
        // TODO: Adjust earlier test cases for consistency of naming

        Memory memory;
        Z80 z80;

        public FuseTests()
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
        }");
            outputClass.WriteLine();
            outputClass.WriteLine();

            var input = File.ReadAllLines(@"c:\code\fuse\z80\tests\tests.in").ToList();
            var expected = File.ReadAllLines(@"c:\code\fuse\z80\tests\tests.expected").ToList();

            var inputLine = 0;
            var expectedLine = 0;

            while (inputLine < input.Count)
            {
                var testName = input[inputLine];
                outputClass.Write(@"        [TestMethod]
        [TestCategory(""Fuse Tests"")]
        public void Test_");
                outputClass.Write(testName + "()\n");
                inputLine++;

                outputClass.Write("        {\n");

                var registers = input[inputLine].Split(new[] { ' ' }, StringSplitOptions.RemoveEmptyEntries);
                outputClass.Write("                z80.af = 0x" + registers[0] + ";\n");
                outputClass.Write("                z80.bc = 0x" + registers[1] + ";\n");
                outputClass.Write("                z80.de = 0x" + registers[2] + ";\n");
                outputClass.Write("                z80.hl = 0x" + registers[3] + ";\n");
                outputClass.Write("                z80.af_ = 0x" + registers[4] + ";\n");
                outputClass.Write("                z80.bc_ = 0x" + registers[5] + ";\n");
                outputClass.Write("                z80.de_ = 0x" + registers[6] + ";\n");
                outputClass.Write("                z80.hl_ = 0x" + registers[7] + ";\n");
                outputClass.Write("                z80.ix = 0x" + registers[8] + ";\n");
                outputClass.Write("                z80.iy = 0x" + registers[9] + ";\n");
                outputClass.Write("                z80.sp = 0x" + registers[10] + ";\n");
                outputClass.Write("                z80.pc = 0x" + registers[11] + ";\n\n");
                inputLine++;

                var special = input[inputLine].Split(' ');
                outputClass.Write("                z80.i = 0x" + special[0] + ";\n");
                outputClass.Write("                z80.r = 0x" + special[1] + ";\n");
                outputClass.Write("                z80.iff1 = " + ((special[2] == "1") ? "true" : "false") + ";\n");
                outputClass.Write("                z80.iff2 = " + ((special[3] == "1") ? "true" : "false") + ";\n\n");
                // TODO: Take care of IM, Halted, T-States status
                inputLine++;

                while (!input[inputLine].StartsWith("-1"))
                {
                    var pokes = input[inputLine].Split(' ');
                    var addr = ushort.Parse(pokes[0], System.Globalization.NumberStyles.HexNumber);
                    var idx = 1;
                    while (pokes[idx] != "-1")
                    {
                        outputClass.Write("                Poke(0x" + string.Format($"{addr:X4}") + ", 0x" + pokes[idx] + ");\n");
                        idx++;
                        addr++;
                    }
                    outputClass.Write("                Poke(0x" + string.Format($"{addr:X4}") + ", 0x76);\n\n"); // HALT
                    inputLine++;
                }
                inputLine++; // ignore blank line
                inputLine++;

                outputClass.Write("                while (z80.ExecuteNextInstruction()) { }\n\n");
                outputClass.Write("                z80.pc--; // rewind HALT instruction\n");

                if (expected[expectedLine] != testName)
                {
                    throw new Exception("Mismatch of input and output lines");
                }
                expectedLine++;

                // TODO: Check T-States
                while (expected[expectedLine].StartsWith(" "))
                    expectedLine++;

                var expectedRegisters = expected[expectedLine].Split(new[] { ' ' }, StringSplitOptions.RemoveEmptyEntries);
                outputClass.Write("                Assert.IsTrue(z80.af == 0x" + expectedRegisters[0] + ");\n");
                outputClass.Write("                Assert.IsTrue(z80.bc == 0x" + expectedRegisters[1] + ");\n");
                outputClass.Write("                Assert.IsTrue(z80.de == 0x" + expectedRegisters[2] + ");\n");
                outputClass.Write("                Assert.IsTrue(z80.hl == 0x" + expectedRegisters[3] + ");\n");
                outputClass.Write("                Assert.IsTrue(z80.af_ == 0x" + expectedRegisters[4] + ");\n");
                outputClass.Write("                Assert.IsTrue(z80.bc_ == 0x" + expectedRegisters[5] + ");\n");
                outputClass.Write("                Assert.IsTrue(z80.de_ == 0x" + expectedRegisters[6] + ");\n");
                outputClass.Write("                Assert.IsTrue(z80.hl_ == 0x" + expectedRegisters[7] + ");\n");
                outputClass.Write("                Assert.IsTrue(z80.ix == 0x" + expectedRegisters[8] + ");\n");
                outputClass.Write("                Assert.IsTrue(z80.iy == 0x" + expectedRegisters[9] + ");\n");
                outputClass.Write("                Assert.IsTrue(z80.sp == 0x" + expectedRegisters[10] + ");\n");
                outputClass.Write("                Assert.IsTrue(z80.pc == 0x" + expectedRegisters[11] + ");\n");
                expectedLine++;

                // for now, ignore special flags
                expectedLine++;

                // for now, ignore memory state
                while (expected[expectedLine].Length > 0 &&
                    ((expected[expectedLine][0] >= '0' && expected[expectedLine][0] <= '9') ||
                    (expected[expectedLine][0] >= 'a' && expected[expectedLine][0] <= 'f')))
                {
                    expectedLine++;
                }

                // ignore blank line
                expectedLine++;

                outputClass.Write("        }\n\n");
            }

            outputClass.Write("    }\n");
            outputClass.Write("}\n");

            string fusePath = @"C:\scratch\CreateFuseUnitTests.cs";
            File.WriteAllText(fusePath, outputClass.ToString());
        }
    }
}
