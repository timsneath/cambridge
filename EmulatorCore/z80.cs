using System;
using System.Collections.Generic;
using System.Collections.Specialized;

namespace ProjectCambridge.EmulatorCore
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

        private Memory memory;

        public Z80(Memory memory, ushort startAddr)
        {
            this.memory = memory;
            this.Reset();
            this.pc = startAddr;
        }

        public void Reset()
        {
            a = b = c = d = e = h = l = 0;
            f = 0;
            ix = iy = pc = sp = 0;
            iff1 = iff2 = false;
        }

        #region Arithmetic operations
        private byte INC(byte reg)
        {
            fPV = (reg == 0x7F);
            fH = (reg & 0xF) == 0xF;
            reg++;
            fZ = IsZero(reg);
            fS = IsSign(reg);
            fN = false;

            return reg;
        }

        private byte DEC(byte reg)
        {
            fPV = (reg == 0x80);
            fH = false; // TODO: set if borrow from bit 4
            reg--;
            fZ = IsZero(reg);
            fS = IsSign(reg);
            fN = true;

            return reg;
        }

        private byte ADC(byte a, byte b)
        {
            if (fC) b++;
            return ADD(a, b);
        }

        private ushort ADC(ushort a, ushort b)
        {
            if (fC) b++;
            return ADD(a, b);
        }

        private byte ADD(byte a, byte b)
        {
            fH = (((a & 0x0F) + (b & 0x0F)) & 0x10) == 0x10;
            fPV = a + b > 0xFF;
            fC = a + b > 0xFF;
            a += b;
            fS = IsSign(a);
            fZ = IsZero(a);
            fN = false;
            return a;
        }

        private ushort ADD(ushort a, ushort b)
        {
            fH = (((a & 0xFFF) + (b & 0xFFF)) & 0x1000) == 0x1000;
            fC = a + b > 0xFFFF;
            a += b;
            fN = false;
            return a;
        }

        private byte SBC(byte a, byte b)
        {
            if (fC) b++;
            return SUB(a, b);
        }

        private byte SUB(byte a, byte b)
        {
            fH = (a & 0x0F) < (b & 0x0F);
            fC = a - b < 0;
            fPV = a - b < 0;
            a -= b;
            fS = IsSign(a);
            fZ = IsZero(a);
            fN = true;
            return a;
        }
        #endregion

        #region Flow operations
        private void CALL()
        {
            var callAddr = GetNextWord();

            pc += 2;
            PUSH(pc);

            pc = callAddr;
        }

        private void JR(sbyte jump)
        {
            if (jump >= 0)
            {
                pc += (ushort)jump;
            }
            else
            {
                pc -= (ushort)-jump;

                // if we're going backwards, we also automatically allow for 
                // the twice-incremented PC
                pc -= 2;
            }
        }

        private void RST(byte addr)
        {
            PUSH(pc);
            pc = addr;
        }
        #endregion

        #region Stack operations
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
        #endregion

        #region Logic operations
        private byte CP(byte v)
        {
            var res = (byte)(a - v);
            fS = IsSign(v);
            fZ = (res == 0);
            fH = false; // TODO: set if borrow from bit 4
            fPV = IsSign(res) != IsSign(a); // overflow
            fN = true;
            fC = a < v;

            return res;
        }

        private void CPD()
        {
            byte val = memory.ReadByte(hl);
            fH = (a & 0x0F) < (val & 0x0F);
            fS = (a - val < 0);
            fZ = (a == val);
            fN = true;
            fPV = (bc - 1 != 0);
            hl--;
            bc--;
        }

        private void CPDR()
        {
            byte val = memory.ReadByte(hl);
            fH = (a & 0x0F) < (val & 0x0F);
            fS = (a - val < 0);
            fZ = (a == val);
            fN = true;
            fPV = (bc - 1 != 0);
            hl--;
            bc--;

            if ((bc != 0) && (a != val))
            {
                pc -= 2;
            }
        }

        private void CPI()
        {
            byte val = memory.ReadByte(hl);
            fH = (a & 0x0F) < (val & 0x0F);
            fS = (a - val < 0);
            fZ = (a == val);
            fN = true;
            fPV = (bc - 1 != 0);
            hl++;
            bc--;
        }

        private void CPIR()
        {
            byte val = memory.ReadByte(hl);
            fH = (a & 0x0F) < (val & 0x0F);
            fS = (a - val < 0);
            fZ = (a == val);
            fN = true;
            fPV = (bc - 1 != 0);
            hl++;
            bc--;

            if ((bc != 0) && (a != val))
            {
                pc -= 2;
            }
        }

        private byte OR(byte a, byte reg)
        {
            a |= reg;
            return a;
        }

        private byte XOR(byte a, byte reg)
        {
            a ^= reg;
            return a;
        }

        private byte AND(byte a, byte reg)
        {
            a &= reg;
            return a;
        }

        private byte NEG(byte a)
        {
            // returns two's complement of a
            fPV = (a == 0x80);
            fC = (a != 0x00);

            a = (byte)~a;
            a++;

            fS = IsSign(a);
            fZ = IsZero(a);
            fH = false; // TODO: fix this
            fN = true;

            return a;
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
            fPV = IsParity(reg);
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
            fPV = IsParity(reg);
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
            fPV = IsParity(reg);
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
            fPV = IsParity(reg);
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
            fPV = IsParity(reg);
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
            fPV = IsParity(reg);
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
            fPV = IsParity(reg);
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
            fPV = IsParity(reg);
            fN = false;

            return reg;
        }
        #endregion


        #region Diagnostics and debugging
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
            if (fPV) state += "P";
            if (fH) state += "H";
            if (fZ) state += "Z";
            if (fS) state += "S";

            return state;
        }
        #endregion
    }
}
