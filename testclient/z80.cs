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

        public Z80(Memory memory)
        {
            this.memory = memory;
            this.Reset();
        }

        // operations
        private byte INC(byte reg)
        {
            fP = (reg == 0x7F);
            fH = (reg & 0xF) == 0xF;
            reg++;
            fZ = IsZero(reg);
            fS = IsSign(reg);
            fN = false;

            return reg;
        }

        private byte DEC(byte reg)
        {
            fP = (reg == 0x80);
            fH = false; // TODO: set if borrow from bit 4
            reg--;
            fZ = IsZero(reg);
            fS = IsSign(reg);
            fN = true;

            return reg;
        }

        private void SUB(byte reg)
        {
            a -= reg;
            fS = IsSign(reg);
            fZ = IsZero(reg);
        }

        private void CALL()
        {
            var callAddr = GetNextWord();

            pc += 2;
            PUSH(pc);

            pc = callAddr;
        }

        private void RST(byte addr)
        {
            PUSH(pc);
            pc = addr;
        }

        private void PUSH(ushort val)
        {
            memory.WriteByte(--sp, HighByte(val));
            memory.WriteByte(--sp, LowByte(val));
        }

        private ushort POP()
        {
            var lo = memory.ReadByte(sp++);
            var hi = memory.ReadByte(sp++);
            return (ushort)((hi << 8) + lo);
        }

        private byte RLC(byte reg)
        {
            // rotates register r to the left
            // bit 7 is copied to carry and to bit 0
            fC = IsSign(reg);
            reg <<= 1;
            if (fC) reg = (byte)SetBit(reg, 0);

            fS = IsSign(reg);
            fZ = IsZero(reg);
            fH = false;
            fP = IsParity(reg);
            fN = false;

            return reg;
        }

        private byte RRC(byte reg)
        {
            fC = IsBitSet(reg, 0);
            reg >>= 1;
            if (fC) reg = (byte)SetBit(reg, 7);

            fS = IsSign(reg);
            fZ = IsZero(reg);
            fH = false;
            fP = IsParity(reg);
            fN = false;

            return reg;

        }

        private byte RL(byte reg)
        {
            // rotates register r to the left, through carry. 
            // carry becomes the LSB of the new r
            bool bit0 = fC;

            fC = IsSign(reg);
            reg <<= 1;

            fS = IsSign(reg);
            fZ = IsZero(reg);
            fH = false;
            fP = IsParity(reg);
            fN = false;

            if (bit0) reg = (byte)SetBit(reg, 0);

            return reg;
        }

        private byte RR(byte reg)
        {
            bool bit7 = fC;

            fC = IsBitSet(reg, 0);
            reg >>= 1;

            fS = IsSign(reg);
            fZ = IsZero(reg);
            fH = false;
            fP = IsParity(reg);
            fN = false;

            if (bit7) reg = (byte)SetBit(reg, 7);

            return reg;
        }

        private byte SLA(byte reg)
        {
            fC = IsSign(reg);
            reg <<= 1;

            fS = IsSign(reg);
            fZ = IsZero(reg);
            fH = false;
            fP = IsParity(reg);
            fN = false;

            return reg;
        }

        private byte SRA(byte reg)
        {
            bool bit7 = IsSign(reg);

            fC = IsBitSet(reg, 0);
            reg >>= 1;

            if (bit7) SetBit(reg, 7);

            fS = IsSign(reg);
            fZ = IsZero(reg);
            fH = false;
            fP = IsParity(reg);
            fN = false;

            return reg;
        }

        private byte SLL(byte reg)
        {
            // technically, SLL is undocumented
            fC = IsBitSet(reg, 7);
            reg <<= 1;
            SetBit(reg, 1);

            fS = IsSign(reg);
            fZ = IsZero(reg);
            fH = false;
            fP = IsParity(reg);
            fN = false;

            return reg;
        }

        private byte SRL(byte reg)
        {
            fC = IsBitSet(reg, 0);
            reg >>= 1;
            ResetBit(reg, 7);

            fS = IsSign(reg);
            fZ = IsZero(reg);
            fH = false;
            fP = IsParity(reg);
            fN = false;

            return reg;
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
    }
}
