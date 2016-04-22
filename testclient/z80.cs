using System;
using System.Collections.Generic;
using System.Collections.Specialized;

namespace testclient
{
    public partial class Z80
    {
 

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
            a = f = b = c = d = e = h = l = 0;
            ix = iy = pc = sp = 0;
            memory.Reset();
        }


    }
}
