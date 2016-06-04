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
            var outputTest = new StringWriter();
            string testName = "";

            outputClass.Write(@"using System;
using Microsoft.VisualStudio.TestPlatform.UnitTestFramework;
using ProjectCambridge.EmulatorCore;

namespace ProjectCambridge.EmulatorTests
{
    [TestClass]
    public class FuseTests
    {
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

        private void LoadRegisters(ushort af, ushort bc, ushort de, ushort hl, 
                                   ushort af_, ushort bc_, ushort de_, ushort hl_,
                                   ushort ix, ushort iy, ushort sp, ushort pc)
        {
            z80.af = af; z80.bc = bc; z80.de = de; z80.hl = hl;
            z80.af_ = af_; z80.bc_ = bc_; z80.de_ = de_; z80.hl_ = hl_;
            z80.ix = ix; z80.iy = iy; z80.sp = sp; z80.pc = pc;
        }

        private void AssertRegisters(ushort af, ushort bc, ushort de, ushort hl, 
                                   ushort af_, ushort bc_, ushort de_, ushort hl_,
                                   ushort ix, ushort iy, ushort sp, ushort pc)
        {
            Assert.IsTrue(z80.af == af);
            Assert.IsTrue(z80.bc == bc);
            Assert.IsTrue(z80.de == de);
            Assert.IsTrue(z80.hl == hl);
            Assert.IsTrue(z80.af_ == af_);
            Assert.IsTrue(z80.bc_ == bc_);
            Assert.IsTrue(z80.de_ == de_);
            Assert.IsTrue(z80.hl_ == hl_);
            Assert.IsTrue(z80.ix == ix);
            Assert.IsTrue(z80.iy == iy);
            Assert.IsTrue(z80.sp == sp);
            Assert.IsTrue(z80.pc == pc);
        }

        private void AssertSpecial(byte i, byte r, bool iff1, bool iff2, long tStates)
        {
            Assert.IsTrue(z80.i == i);
            //Assert.IsTrue(z80.r == r); // TODO: r is magic and we haven't done magic yet
            Assert.IsTrue(z80.iff1 == iff1);
            Assert.IsTrue(z80.iff2 == iff2);
            Assert.IsTrue(z80.tStates == tStates);
        }
");
            outputClass.WriteLine();
            outputClass.WriteLine();

            var input = File.ReadAllLines(@"c:\code\fuse\z80\tests\tests.in").ToList();
            var expected = File.ReadAllLines(@"c:\code\fuse\z80\tests\tests.expected").ToList();

            var inputLine = 0;
            var expectedLine = 0;

            while (inputLine < input.Count)
            {
                testName = input[inputLine];
                outputTest.Write(@"        [TestMethod]
        [TestCategory(""Fuse Tests"")]
        public void Test_");
                outputTest.WriteLine(testName + "()");
                inputLine++;

                outputTest.WriteLine("        {");

                var registers = input[inputLine].Split(new[] { ' ' }, StringSplitOptions.RemoveEmptyEntries);
                outputTest.Write("                LoadRegisters(");
                outputTest.Write("0x" + registers[0] + ", ");
                outputTest.Write("0x" + registers[1] + ", ");
                outputTest.Write("0x" + registers[2] + ", ");
                outputTest.Write("0x" + registers[3] + ", ");
                outputTest.Write("0x" + registers[4] + ", ");
                outputTest.Write("0x" + registers[5] + ", ");
                outputTest.Write("0x" + registers[6] + ", ");
                outputTest.Write("0x" + registers[7] + ", ");
                outputTest.Write("0x" + registers[8] + ", ");
                outputTest.Write("0x" + registers[9] + ", ");
                outputTest.Write("0x" + registers[10] + ", ");
                outputTest.Write("0x" + registers[11] + ");");
                outputTest.WriteLine();
                inputLine++;

                var special = input[inputLine].Split(new[] { ' ' }, StringSplitOptions.RemoveEmptyEntries);
                outputTest.WriteLine("                z80.i = 0x" + special[0] + ";");
                outputTest.WriteLine("                z80.r = 0x" + special[1] + ";");
                outputTest.WriteLine("                z80.iff1 = " + ((special[2] == "1") ? "true" : "false") + ";");
                outputTest.WriteLine("                z80.iff2 = " + ((special[3] == "1") ? "true" : "false") + ";");
                outputTest.WriteLine();

                // TODO: Take care of IM, Halted states

                long testRunLength = long.Parse(special[6]); // measured in T-States

                inputLine++;

                while (!input[inputLine].StartsWith("-1"))
                {
                    var pokes = input[inputLine].Split(' ');
                    var addr = ushort.Parse(pokes[0], System.Globalization.NumberStyles.HexNumber);
                    var idx = 1;
                    while (pokes[idx] != "-1")
                    {
                        outputTest.WriteLine("                Poke(0x" + string.Format($"{addr:X4}") + ", 0x" + pokes[idx] + ");");
                        idx++;
                        addr++;
                    }
                    inputLine++;
                }
                outputTest.WriteLine();
                inputLine++; // ignore blank line
                inputLine++;

                outputTest.WriteLine("                while (z80.tStates < 0x" + string.Format($"{testRunLength:X4}") + ")");
                outputTest.WriteLine("                {");
                outputTest.WriteLine("                    z80.ExecuteNextInstruction();");
                outputTest.WriteLine("                }");
                outputTest.WriteLine();

                if (expected[expectedLine] != testName)
                {
                    throw new Exception("Mismatch of input and output lines");
                }
                expectedLine++;

                // TODO: Check T-States
                while (expected[expectedLine].StartsWith(" "))
                    expectedLine++;

                var expectedRegisters = expected[expectedLine].Split(new[] { ' ' }, StringSplitOptions.RemoveEmptyEntries);
                outputTest.Write("                AssertRegisters(");
                outputTest.Write("0x" + expectedRegisters[0] + ", ");
                outputTest.Write("0x" + expectedRegisters[1] + ", ");
                outputTest.Write("0x" + expectedRegisters[2] + ", ");
                outputTest.Write("0x" + expectedRegisters[3] + ", ");
                outputTest.Write("0x" + expectedRegisters[4] + ", ");
                outputTest.Write("0x" + expectedRegisters[5] + ", ");
                outputTest.Write("0x" + expectedRegisters[6] + ", ");
                outputTest.Write("0x" + expectedRegisters[7] + ", ");
                outputTest.Write("0x" + expectedRegisters[8] + ", ");
                outputTest.Write("0x" + expectedRegisters[9] + ", ");
                outputTest.Write("0x" + expectedRegisters[10] + ", ");
                outputTest.Write("0x" + expectedRegisters[11] + ");");
                outputTest.WriteLine();
                expectedLine++;

                // TODO: Take care of IM, Halted states
                var expectedSpecial = expected[expectedLine].Split(new[] { ' ' }, StringSplitOptions.RemoveEmptyEntries);
                outputTest.Write("                AssertSpecial(");
                outputTest.Write("0x" + expectedSpecial[0] + ", "); // I register
                outputTest.Write("0x" + expectedSpecial[1] + ", "); // R register
                outputTest.Write(((expectedSpecial[2] == "1") ? "true" : "false") + ", "); // IFF1
                outputTest.Write(((expectedSpecial[3] == "1") ? "true" : "false") + ", "); // IFF2
                outputTest.Write(expectedSpecial[6] + ");"); // measured in T-States
                outputTest.WriteLine();
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

                outputTest.Write("        }");
                outputTest.WriteLine();
                outputTest.WriteLine();


                //// we ignore certain FUSE tests that are incompatible with our test harness
                //// specifically, we're using HALT right now to end, rather than some number
                //// of pre-defined T-states

                //// TODO: are these hanging because of HALT or because of infinite loop bugs?
                //var hangingTests = new string[] {"02", "0a", "18", "20_1", "28_2", "2e", "30_1", "38_2", "c0_1",
                //    "c2_1", "c3", "c4_1", "c8_2", "ca_2", "cc_1", "cd", "cf", "d0_1", "d2_1", "d4_1", "d7",
                //    "d8_2", "da_1", "db", "db_1", "db_2", "db_3", "dc_1", "dde9", "df",
                //    "e0_1", "e2_1", "e4_1", "e7", "e8_2", "e9",
                //    "ea_1", "ec_1", "ed45", "ed55", "ed65", "ef",
                //    "f0_1", "f2_1", "f4_1", "f7",
                //    "f8_2", "fa_1", "fc_1", "fde9", "ff",
                //    "c9", // RET: this test passes, but it doesn't HALT at the right PC
                //    "c7" // RST 00h: this test passes, but only after the stack overwrites the instruction
                //};

                //if (!hangingTests.Contains(testName))
                //{
                //    outputClass.Write(outputTest.ToString());
                //}

                outputClass.Write(outputTest.ToString());
                outputTest = new StringWriter();
            }

            outputClass.WriteLine("    }");
            outputClass.WriteLine("}");

            string fusePath = @"C:\scratch\FuseUnitTests.cs";
            File.WriteAllText(fusePath, outputClass.ToString());
        }
    }
}
