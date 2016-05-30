﻿using System;
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

        // Algorithm for counting set bits taken from LLVM optimization proposal at: 
        //    https://llvm.org/bugs/show_bug.cgi?id=1488
        private bool IsParity(int reg)
        {
            int count = 0;

            for (; reg != 0; count++)
            {
                reg &= reg - 1; // clear the least significant bit set
            }
            return (count % 2 == 0);
        }

        private bool IsBitSet(int x, int index) => (x & (1 << index)) == 1 << index;

        private byte SetBit(int x, int index) => (byte)(x | (1 << index));

        private byte ResetBit(int x, int index) => (byte)(x & ~(1 << index));

        private bool IsSign8(byte x) => (x & 0x80) == 0x80;

        private bool IsSign16(ushort x) => (x & 0x8000) == 0x8000;

        private bool IsZero(ushort x) => (x == 0);

        #region Arithmetic operations
        private byte INC(byte reg)
        {
            fPV = (reg == 0x7F);
            fH = (reg & 0xF) == 0xF;
            reg++;
            fZ = IsZero(reg);
            fS = IsSign8(reg);
            fN = false;

            return reg;
        }

        private byte DEC(byte reg)
        {
            fPV = (reg == 0x80);
            fH = false; // TODO: set if borrow from bit 4
            reg--;
            fZ = IsZero(reg);
            fS = IsSign8(reg);
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
            fS = IsSign8(a);
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

        private ushort SBC(ushort a, ushort b)
        {
            if (fC) b++;
            fC = a < b;
            fH = (a & 0xFFF) < (b & 0xFFF);
            fPV = a < b;
            a -= b;
            fS = IsSign16(a);
            fZ = IsZero(a);
            fN = true;
            return a;
        }

        private byte SUB(byte a, byte b)
        {
            fC = a - b < 0;
            fH = (a & 0x0F) < (b & 0x0F);
            fPV = a < b;
            a -= b;
            fS = IsSign8(a);
            fZ = IsZero(a);
            fN = true;
            return a;
        }

        // algorithm from http://worldofspectrum.org/faq/reference/z80reference.htm
        private void DAA()
        {
            byte correctionFactor = 0;
            byte oldA = a;

            if ((a > 0x99) | fC)
            {
                correctionFactor |= 0x60;
                fC = true;
            }
            else
            {
                fC = false;
            }

            if (((a & 0x0F) > 0x09) | fH)
            {
                correctionFactor |= 0x06;
            }

            if (!fN)
            {
                a += correctionFactor;
            }
            else
            {
                a -= correctionFactor;
            }

            fH = ((oldA & 0x10) ^ (a & 0x10)) == 0x10;

            fS = IsSign8(a);
            fZ = IsZero(a);
            fPV = IsParity(a);
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
                // pc -= 2;
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
            fS = IsSign8(v);
            fZ = (res == 0);
            fH = false; // TODO: set if borrow from bit 4
            fPV = IsSign8(res) != IsSign8(a); // overflow
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
            fS = IsSign8(a);
            fZ = IsZero(a);
            fH = false;
            fPV = false; // true if overflow - but how?
            fN = false;
            fC = false;
            return a;
        }

        private byte XOR(byte a, byte reg)
        {
            a ^= reg;
            fS = IsSign8(a);
            fZ = IsZero(a);
            fH = false;
            fPV = IsParity(a);
            fN = false;
            fC = false;
            return a;
        }

        private byte AND(byte a, byte reg)
        {
            a &= reg;
            fS = IsSign8(a);
            fZ = IsZero(a);
            fH = true;
            fPV = false; // true if overflow - but how?
            fN = false;
            fC = false;
            return a;
        }

        private byte NEG(byte a)
        {
            // returns two's complement of a
            fPV = (a == 0x80);
            fC = (a != 0x00);

            a = (byte)~a;
            a++;

            fS = IsSign8(a);
            fZ = IsZero(a);
            fH = false; // TODO: fix this
            fN = true;

            return a;
        }

        private byte RLC(byte reg)
        {
            // rotates register r to the left
            // bit 7 is copied to carry and to bit 0
            fC = IsSign8(reg);
            reg <<= 1;
            if (fC) reg = (byte)SetBit(reg, 0);

            fS = IsSign8(reg);
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

            fS = IsSign8(reg);
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

            fC = IsSign8(reg);
            reg <<= 1;

            fS = IsSign8(reg);
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

            fS = IsSign8(reg);
            fZ = IsZero(reg);
            fH = false;
            fPV = IsParity(reg);
            fN = false;

            if (bit7) reg = (byte)SetBit(reg, 7);

            return reg;
        }

        private byte SLA(byte reg)
        {
            fC = IsSign8(reg);
            reg <<= 1;

            fS = IsSign8(reg);
            fZ = IsZero(reg);
            fH = false;
            fPV = IsParity(reg);
            fN = false;

            return reg;
        }

        private byte SRA(byte reg)
        {
            bool bit7 = IsSign8(reg);

            fC = IsBitSet(reg, 0);
            reg >>= 1;

            if (bit7) SetBit(reg, 7);

            fS = IsSign8(reg);
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

            fS = IsSign8(reg);
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

            fS = IsSign8(reg);
            fZ = IsZero(reg);
            fH = false;
            fPV = IsParity(reg);
            fN = false;

            return reg;
        }
        #endregion

        #region Bitwise operations
        private void BIT(int bitToTest, int reg)
        {
            switch (reg)
            {
                case 0x0: fZ = !IsBitSet(b, bitToTest); break;
                case 0x1: fZ = !IsBitSet(c, bitToTest); break;
                case 0x2: fZ = !IsBitSet(d, bitToTest); break;
                case 0x3: fZ = !IsBitSet(e, bitToTest); break;
                case 0x4: fZ = !IsBitSet(h, bitToTest); break;
                case 0x5: fZ = !IsBitSet(l, bitToTest); break;
                case 0x6: fZ = !IsBitSet(memory.ReadByte(hl), bitToTest); break;
                case 0x7: fZ = !IsBitSet(a, bitToTest); break;
                default:
                    throw new ArgumentOutOfRangeException("register", reg, "Field register must map to a valid Z80 register.");
            }

            fH = true;
            fN = false;
        }

        private void RES(int bitToReset, int reg)
        {
            switch (reg)
            {
                case 0x0: b = ResetBit(b, bitToReset); break;
                case 0x1: c = ResetBit(c, bitToReset); break;
                case 0x2: d = ResetBit(d, bitToReset); break;
                case 0x3: e = ResetBit(e, bitToReset); break;
                case 0x4: h = ResetBit(h, bitToReset); break;
                case 0x5: l = ResetBit(l, bitToReset); break;
                case 0x6: memory.WriteByte(hl, ResetBit(memory.ReadByte(hl), bitToReset)); break;
                case 0x7: a = ResetBit(a, bitToReset); break;
                default:
                    throw new ArgumentOutOfRangeException("register", reg, "Field register must map to a valid Z80 register.");
            }

        }

        private void SET(int bitToSet, int reg)
        {
            switch (reg)
            {
                case 0x0: b = SetBit(b, bitToSet); break;
                case 0x1: c = SetBit(c, bitToSet); break;
                case 0x2: d = SetBit(d, bitToSet); break;
                case 0x3: e = SetBit(e, bitToSet); break;
                case 0x4: h = SetBit(h, bitToSet); break;
                case 0x5: l = SetBit(l, bitToSet); break;
                case 0x6: memory.WriteByte(hl, SetBit(memory.ReadByte(hl), bitToSet)); break;
                case 0x7: a = SetBit(a, bitToSet); break;
                default:
                    throw new ArgumentOutOfRangeException("register", reg, "Field register must map to a valid Z80 register.");
            }
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