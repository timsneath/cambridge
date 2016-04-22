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


    }
}
