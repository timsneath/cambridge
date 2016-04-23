using System;
using System.Collections.Generic;
using System.Collections.Specialized;

namespace ProjectCambridge
{
    public partial class Z80
    {
        // The Z80 microprocessor user manual can be downloaded from Zilog directly, here:
        //    http://tinyurl.com/z80manual
        // 
        // Other useful details of the Z80 architecture can be found here:
        //    http://landley.net/history/mirror/cpm/z80.html
        // and here: 
        //    http://z80.info/z80code.htm

        // Memory and clock
        private Memory memory;

        public Z80()
        {
            memory = new Memory();
            this.Reset();
        }

        // 
        private byte GetNextByte()
        {
            var byteRead = memory.ReadByte(pc);
            pc++;
            return byteRead;
        }

        private ushort GetNextWord()
        {
            var wordRead = memory.ReadWord(pc);
            pc += 2;
            return wordRead;
        }

        // interrupts

        public void Reset()
        {
            a = b = c = d = e = h = l = 0;
            f = 0;
            ix = iy = pc = sp = 0;
            memory.Reset();
        }

        public string GetState()
        {
            // AF BC DE HL AF' BC' DE' HL' IX IY SP PC
            // I R IFF1 IFF2 IM < halted > < tstates >

            var state = $"A  {a:X2} | BC  {bc:X4} | DE  {de:X4} | HL  {hl:X4}\n";
            state += $"A' {a_:X2} | BC' {bc_:X4} | DE' {de_:X4} | HL' {hl_:X4}\n";
            state += $"IX {ix:X4} | IY {iy:X4} | SP {sp:X4} | PC {pc:X4}\n";

            state += "Flags: ";
            if (fC) state += "C";
            if (fN) state += "N";
            if (fP) state += "P";
            if (fH) state += "H";
            if (fZ) state += "Z";
            if (fS) state += "S";

            return state;
        }

        public void LoadMemory(ushort start, byte[] contents)
        {
            foreach (byte c in contents)
            {
                memory.WriteByte(start++, c);
            }
        }
    }
}
