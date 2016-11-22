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

            const bool INCLUDE_UNDOCUMENTED_OPCODE_UNIT_TESTS = false;

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
            Assert.IsTrue(z80.af == af, $""Register pair AF is 0x{z80.af:X4}, was expected to be 0x{af:X4}."");
            Assert.IsTrue(z80.bc == bc, $""Register pair BC is 0x{z80.bc:X4}, was expected to be 0x{bc:X4}."");
            Assert.IsTrue(z80.de == de, $""Register pair DE is 0x{z80.de:X4}, was expected to be 0x{de:X4}."");
            Assert.IsTrue(z80.hl == hl, $""Register pair HL is 0x{z80.hl:X4}, was expected to be 0x{hl:X4}."");
            Assert.IsTrue(z80.af_ == af_, $""Register pair AF' is 0x{z80.af_:X4}, was expected to be 0x{af_:X4}."");
            Assert.IsTrue(z80.bc_ == bc_, $""Register pair BC' is 0x{z80.bc_:X4}, was expected to be 0x{bc_:X4}."");
            Assert.IsTrue(z80.de_ == de_, $""Register pair DE' is 0x{z80.de_:X4}, was expected to be 0x{de_:X4}."");
            Assert.IsTrue(z80.hl_ == hl_, $""Register pair HL' is 0x{z80.hl_:X4}, was expected to be 0x{hl_:X4}."");
            Assert.IsTrue(z80.ix == ix, $""Register IX is 0x{z80.ix:X4}, was expected to be 0x{ix:X4}."");
            Assert.IsTrue(z80.iy == iy, $""Register IY is 0x{z80.iy:X4}, was expected to be 0x{iy:X4}."");
            Assert.IsTrue(z80.sp == sp, $""Register SP is 0x{z80.sp:X4}, was expected to be 0x{sp:X4}."");
            Assert.IsTrue(z80.pc == pc, $""Register PC is 0x{z80.pc:X4}, was expected to be 0x{pc:X4}."");
        }                                                                                   

        private void AssertSpecial(byte i, byte r, bool iff1, bool iff2, long tStates)
        {
            Assert.IsTrue(z80.i == i, $""Register I is 0x{z80.i:X2}, was expected to be 0x{i:X2}."");
            // TODO: r is magic and we haven't done magic yet
            //Assert.IsTrue(z80.r == r, $""Register R is 0x{z80.r:X2}, was expected to be 0x{r:X2}."");

            Assert.IsTrue(z80.iff1 == iff1, $""Register IFF1 is {z80.iff1}, was expected to be {iff1}."");
            Assert.IsTrue(z80.iff2 == iff2, $""Register IFF2 is {z80.iff2}, was expected to be {iff2}."");
            Assert.IsTrue(z80.tStates == tStates, $""tstates are {z80.tStates}, was expected to be {tStates}."");
        }
");
            outputClass.WriteLine();
            outputClass.WriteLine();

            var input = File.ReadAllLines(@"c:\code\fuse\z80\tests\tests.in").ToList();
            var expected = File.ReadAllLines(@"c:\code\fuse\z80\tests\tests.expected").ToList();

            var inputLine = 0;
            var expectedLine = 0;

            // These unit tests stress undocumented Z80 opcodes. 
            var undocumentedOpcodeTests = new List<string>() {"4c", "4e", "54", "5c", "63", "64", "6b", "6c",
                "6e", "70", "71", "74", "7c", "cb30", "cb31", "cb32", "cb33", "cb34", "cb35", "cb36", "cb37",
                "dd24", "dd25", "dd26", "dd2c", "dd2d", "dd2e", "dd44", "dd45", "dd4c", "dd4d",
                "dd54", "dd55", "dd5c", "dd5d", "dd60", "dd61", "dd62", "dd63", "dd64", "dd65", "dd67",
                "dd68", "dd69", "dd6a", "dd6b", "dd6c", "dd6d", "dd6f", "dd7c", "dd7d", "dd84", "dd85",
                "dd8c", "dd8d", "dd94", "dd95", "dd9c", "dd9d", "dda4", "dda5", "ddac", "ddad", "ddb4",
                "ddb5", "ddbc", "ddbd", "ddfd00", "fd24", "fd25", "fd26", "fd2c", "fd2d", "fd2e",
                "fd44", "fd45", "fd4c", "fd4d",
                "fd54", "fd55", "fd5c", "fd5d", "fd60", "fd61", "fd62", "fd63", "fd64", "fd65", "fd67",
                "fd68", "fd69", "fd6a", "fd6b", "fd6c", "fd6d", "fd6f", "fd7c", "fd7d", "fd84", "fd85",
                "fd8c", "fd8d", "fd94", "fd95", "fd9c", "fd9d", "fda4", "fda5", "fdac", "fdad", "fdb4",
                "fdb5", "fdbc", "fdbd", "ddcb36", "fdcb36"};

            for (int opCode = 0; opCode < 256; opCode++)
            {
                if ((opCode & 0x7) != 0x6)
                {
                    undocumentedOpcodeTests.Add(String.Format($"ddcb{opCode:x2}"));
                    undocumentedOpcodeTests.Add(String.Format($"fdcb{opCode:x2}"));
                }
            }

            while (inputLine < input.Count)
            {
                testName = input[inputLine];

                if (undocumentedOpcodeTests.Contains(testName))
                {
                    outputTest.WriteLine("        [TestCategory(\"FUSE Undocumented Opcode Tests\")]");
                }
                else
                {
                    outputTest.WriteLine("        [TestCategory(\"FUSE Opcode Tests\")]");
                }

                outputTest.WriteLine("        [TestMethod]");
                outputTest.Write("        public void Test_");
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

                while (expected[expectedLine].Length > 0 &&
                    ((expected[expectedLine][0] >= '0' && expected[expectedLine][0] <= '9') ||
                    (expected[expectedLine][0] >= 'a' && expected[expectedLine][0] <= 'f')))
                {
                    var peeks = expected[expectedLine].Split(new[] { ' ' }, StringSplitOptions.RemoveEmptyEntries);
                    var addr = ushort.Parse(peeks[0], System.Globalization.NumberStyles.HexNumber);
                    var idx = 1;
                    while (peeks[idx] != "-1")
                    {
                        outputTest.WriteLine("                Assert.IsTrue(memory.ReadByte(0x" +
                            string.Format($"{addr:X4}" + ") == 0x" + peeks[idx] + ");"));
                        idx++;
                        addr++;
                    }
                    expectedLine++;
                }

                // ignore blank line
                expectedLine++;

                outputTest.Write("        }");
                outputTest.WriteLine();
                outputTest.WriteLine();

                if (!undocumentedOpcodeTests.Contains(testName) || INCLUDE_UNDOCUMENTED_OPCODE_UNIT_TESTS)
                {
                    outputClass.Write(outputTest.ToString());
                }
                outputTest = new StringWriter();
            }

            outputClass.WriteLine("    }");
            outputClass.WriteLine("}");

            string fusePath = @"C:\scratch\FuseUnitTests.cs";
            File.WriteAllText(fusePath, outputClass.ToString());
        }
    }
}
