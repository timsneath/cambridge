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
        public bool cpuSuspended { get; set; }
        public long tStates { get; set; }

        public Z80(Memory memory, ushort startAddr = 0)
        {
            this.memory = memory;
            Reset();
            pc = startAddr;
        }

        public void Reset()
        {
            // Initial register states are set per section 2.4 of 
            //    http://www.myquest.nl/z80undocumented/z80-documented-v0.91.pdf
            af = 0xFFFF;
            bc = 0xFFFF;
            de = 0xFFFF;
            hl = 0xFFFF;
            ix = 0xFFFF;
            iy = 0xFFFF;
            sp = 0xFFFF;
            pc = 0x0000;
            iff1 = false;
            iff2 = false;
            im = 0;

            tStates = 0;
            cpuSuspended = false;
        }

        // Algorithm for counting set bits taken from LLVM optimization proposal at: 
        //    https://llvm.org/bugs/show_bug.cgi?id=1488
        private bool IsParity(int value)
        {
            int count = 0;

            for (; value != 0; count++)
            {
                value &= value - 1; // clear the least significant bit set
            }
            return (count % 2 == 0);
        }

        private bool IsBitSet(int value, int bit) => (value & (1 << bit)) == 1 << bit;

        private byte SetBit(int value, int bit) => (byte)(value | (1 << bit));

        private byte ResetBit(int value, int bit) => (byte)(value & ~(1 << bit));

        private bool IsSign8(byte value) => (value & 0x80) == 0x80;

        private bool IsSign16(ushort value) => (value & 0x8000) == 0x8000;

        private bool IsZero(ushort value) => (value == 0);

        private void LDI()
        {
            var byteRead = memory.ReadByte(hl);
            memory.WriteByte(de, byteRead);

            de++;
            hl++;
            bc--;

            fH = false;
            fN = false;
            fPV = (bc != 0);
            f5 = IsBitSet(byteRead, 5);
            f3 = IsBitSet(byteRead, 3);

            tStates += 16;
        }

        private void LDD()
        {
            var byteRead = memory.ReadByte(hl);
            memory.WriteByte(de, byteRead);

            de--;
            hl--;
            bc--;
            fH = false;
            fN = false;
            fPV = (bc != 0);
            f5 = IsBitSet(byteRead, 5);
            f3 = IsBitSet(byteRead, 3);

            tStates += 16;
        }

        private void LDIR()
        {
            var byteRead = memory.ReadByte(hl);
            memory.WriteByte(de, byteRead);

            de++;
            hl++;
            bc--;

            if (bc != 0)
            {
                pc -= 2;
                tStates += 21;
            }
            else
            {
                f5 = IsBitSet(byteRead, 5);
                f3 = IsBitSet(byteRead, 3);
                fH = false;
                fPV = false;
                fN = false;

                tStates += 16;
            }
        }

        private void LDDR()
        {
            var byteRead = memory.ReadByte(hl);
            memory.WriteByte(de, byteRead);
            de--;
            hl--;
            bc--;
            if (bc > 0)
            {
                pc -= 2;
                tStates += 21;
            }
            else
            {
                f5 = IsBitSet(byteRead, 5);
                f3 = IsBitSet(byteRead, 3);
                fH = false;
                fPV = false;
                fN = false;

                tStates += 16;
            }
        }

        #region Arithmetic operations
        private byte INC(byte reg)
        {
            var oldReg = reg;
            fPV = (reg == 0x7F);
            reg++;
            fH = IsBitSet(reg, 4) != IsBitSet(oldReg, 4);
            fZ = IsZero(reg);
            fS = IsSign8(reg);
            f5 = IsBitSet(reg, 5);
            f3 = IsBitSet(reg, 3);
            fN = false;

            tStates += 4;

            return reg;
        }

        private byte DEC(byte reg)
        {
            var oldReg = reg;
            fPV = (reg == 0x80);
            reg--;
            fH = IsBitSet(reg, 4) != IsBitSet(oldReg, 4);
            fZ = IsZero(reg);
            fS = IsSign8(reg);
            f5 = IsBitSet(reg, 5);
            f3 = IsBitSet(reg, 3);
            fN = true;

            tStates += 4;

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

            // overflow in add only occurs when operand polarities are the same
            bool overflowCheck = (IsSign16(a) == IsSign16(b));

            a = ADD(a, b);

            // if polarity is now different then add caused an overflow
            if (overflowCheck)
            {
                fPV = (IsSign16(a) != IsSign16(b));
            }
            else
            {
                fPV = false;
            }
            fS = IsSign16(a);
            fZ = IsZero(a);
            return a;
        }

        private byte ADD(byte a, byte b)
        {
            fH = (((a & 0x0F) + (b & 0x0F)) & 0x10) == 0x10;

            // overflow in add only occurs when operand polarities are the same
            bool overflowCheck = (IsSign8(a) == IsSign8(b));

            fC = a + b > 0xFF;
            a += b;
            fS = IsSign8(a);

            // if polarity is now different then add caused an overflow
            if (overflowCheck)
            {
                fPV = (fS != IsSign8(b));
            }
            else
            {
                fPV = false;
            }

            f5 = IsBitSet(a, 5);
            f3 = IsBitSet(a, 3);
            fZ = IsZero(a);
            fN = false;

            tStates += 4;

            return a;
        }

        private ushort ADD(ushort a, ushort b)
        {
            fH = (((a & 0xFFF) + (b & 0xFFF)) & 0x1000) == 0x1000;
            fC = a + b > 0xFFFF;
            a += b;
            f5 = IsBitSet(a, 13);
            f3 = IsBitSet(a, 11);
            fN = false;

            tStates += 11;

            return a;
        }

        private byte SBC(byte x, byte y)
        {
            if (fC) y++;
            return SUB(x, y);
        }

        private ushort SBC(ushort x, ushort y)
        {
            if (fC) y++;
            fC = x < y;
            fH = (x & 0xFFF) < (y & 0xFFF);

            // overflow in subtract only occurs when operand signs are different
            bool overflowCheck = (IsSign16(x) != IsSign16(y));

            x -= y;
            f5 = IsBitSet(x, 13);
            f3 = IsBitSet(x, 11);
            fS = IsSign16(x);
            fZ = IsZero(x);
            fN = true;

            // if x changed polarity then subtract caused an overflow
            if (overflowCheck)
            {
                fPV = (fS != IsSign16(x));
            }
            else
            {
                fPV = false;
            }

            tStates += 15;

            return x;
        }

        // TODO: Consistent parameter names
        private byte SUB(byte x, byte y)
        {
            fC = x < y;
            fH = (x & 0x0F) < (y & 0x0F);

            fS = IsSign8(x);

            // overflow in subtract only occurs when operand signs are different
            bool overflowCheck = (IsSign8(x) != IsSign8(y));

            x -= y;
            f5 = IsBitSet(x, 5);
            f3 = IsBitSet(x, 3);

            // if x changed polarity then subtract caused an overflow
            if (overflowCheck)
            {
                fPV = (fS != IsSign8(x));
            }
            else
            {
                fPV = false;
            }

            fS = IsSign8(x);
            fZ = IsZero(x);
            fN = true;

            tStates += 4;

            return x;
        }

        private void CP(byte x)
        {
            SUB(a, x);
            f5 = IsBitSet(x, 5);
            f3 = IsBitSet(x, 3);
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
            f5 = IsBitSet(a, 5);
            f3 = IsBitSet(a, 3);

            fS = IsSign8(a);
            fZ = IsZero(a);
            fPV = IsParity(a);

            tStates += 4;
        }
        #endregion

        #region Flow operations
        private void CALL()
        {
            var callAddr = GetNextWord();

            PUSH(pc);

            pc = callAddr;

            tStates += 17;
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
            }

            tStates += 12;
        }

        private void DJNZ(sbyte relativeAddress)
        {
            b--;
            if (b != 0)
            {
                JR(relativeAddress);
                tStates++;
            }
            else
            {
                pc++;
                tStates += 8;
            }
        }

        private void RST(byte addr)
        {
            PUSH(pc);
            pc = addr;
            tStates += 11;
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

        private void EX_AFAFPrime()
        {
            byte temp;

            temp = a;
            a = a_;
            a_ = temp;

            temp = f;
            f = f_;
            f_ = temp;


            tStates += 4;
        }
        #endregion

        #region Logic operations


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

            tStates += 16;
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
                tStates += 21;
            }
            else
            {
                tStates += 16;
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

            tStates += 16;
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
                tStates += 21;
            }
            else
            {
                tStates += 16;
            }
        }

        private byte OR(byte a, byte reg)
        {
            a |= reg;
            fS = IsSign8(a);
            fZ = IsZero(a);
            fH = false;
            f5 = IsBitSet(a, 5);
            f3 = IsBitSet(a, 3);

            fPV = IsParity(a);
            fN = false;
            fC = false;

            tStates += 4;

            return a;
        }

        private byte XOR(byte a, byte reg)
        {
            a ^= reg;
            fS = IsSign8(a);
            fZ = IsZero(a);
            fH = false;
            f5 = IsBitSet(a, 5);
            f3 = IsBitSet(a, 3);

            fPV = IsParity(a);
            fN = false;
            fC = false;

            tStates += 4;

            return a;
        }

        private byte AND(byte a, byte reg)
        {
            a &= reg;
            fS = IsSign8(a);
            fZ = IsZero(a);
            fH = true;
            f5 = IsBitSet(a, 5);
            f3 = IsBitSet(a, 3);
            fPV = IsParity(a);
            fN = false;
            fC = false;

            tStates += 4;

            return a;
        }

        private byte NEG(byte a)
        {
            // returns two's complement of a
            fPV = (a == 0x80);
            fC = (a != 0x00);

            a = (byte)~a;
            a++;

            f5 = IsBitSet(a, 5);
            f3 = IsBitSet(a, 3);

            fS = IsSign8(a);
            fZ = IsZero(a);
            fH = true;
            fN = true;

            tStates += 8;

            return a;
        }

        // TODO: Organize these into the same groups as the Z80 manual
        private void CPL()
        {
            a = (byte)~a;
            f5 = IsBitSet(a, 5);
            f3 = IsBitSet(a, 3);
            fH = true;
            fN = true;

            tStates += 4;
        }

        private void SCF()
        {
            f5 = IsBitSet(a, 5);
            f3 = IsBitSet(a, 3);
            fH = false;
            fN = false;
            fC = true;
        }

        private void CCF()
        {
            f5 = IsBitSet(a, 5);
            f3 = IsBitSet(a, 3);
            fH = fC;
            fN = false;
            fC = !fC;

            tStates += 4;
        }

        private byte RLC(byte reg)
        {
            // rotates register r to the left
            // bit 7 is copied to carry and to bit 0
            fC = IsSign8(reg);
            reg <<= 1;
            if (fC) reg = (byte)SetBit(reg, 0);

            f5 = IsBitSet(reg, 5);
            f3 = IsBitSet(reg, 3);
            fS = IsSign8(reg);
            fZ = IsZero(reg);
            fH = false;
            fPV = IsParity(reg);
            fN = false;

            return reg;
        }

        private void RLCA()
        {
            // rotates register A to the left
            // bit 7 is copied to carry and to bit 0
            fC = IsSign8(a);
            a <<= 1;
            if (fC) a = (byte)SetBit(a, 0);
            f5 = IsBitSet(a, 5);
            f3 = IsBitSet(a, 3);

            fH = false;
            fN = false;

            tStates += 4;
        }

        private byte RRC(byte reg)
        {
            fC = IsBitSet(reg, 0);
            reg >>= 1;
            if (fC) reg = (byte)SetBit(reg, 7);

            f5 = IsBitSet(reg, 5);
            f3 = IsBitSet(reg, 3);
            fS = IsSign8(reg);
            fZ = IsZero(reg);
            fH = false;
            fPV = IsParity(reg);
            fN = false;

            return reg;

        }

        private void RRCA()
        {
            fC = IsBitSet(a, 0);
            a >>= 1;
            if (fC) a = (byte)SetBit(a, 7);

            f5 = IsBitSet(a, 5);
            f3 = IsBitSet(a, 3);

            fH = false;
            fN = false;

            tStates += 4;
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
            f5 = IsBitSet(reg, 5);
            f3 = IsBitSet(reg, 3);
            fPV = IsParity(reg);
            fN = false;

            if (bit0) reg = (byte)SetBit(reg, 0);

            return reg;
        }

        private void RLA()
        {
            // rotates register r to the left, through carry. 
            // carry becomes the LSB of the new r
            bool bit0 = fC;

            fC = IsSign8(a);
            a <<= 1;

            f5 = IsBitSet(a, 5);
            f3 = IsBitSet(a, 3);

            fH = false;
            fN = false;

            if (bit0) a = (byte)SetBit(a, 0);

            tStates += 4;
        }

        private byte RR(byte reg)
        {
            bool bit7 = fC;

            fC = IsBitSet(reg, 0);
            reg >>= 1;

            fS = IsSign8(reg);
            fZ = IsZero(reg);
            fH = false;
            f5 = IsBitSet(reg, 5);
            f3 = IsBitSet(reg, 3);
            fPV = IsParity(reg);
            fN = false;

            if (bit7) reg = (byte)SetBit(reg, 7);

            return reg;
        }

        private void RRA()
        {
            bool bit7 = fC;

            fC = IsBitSet(a, 0);
            a >>= 1;

            f5 = IsBitSet(a, 5);
            f3 = IsBitSet(a, 3);

            fH = false;
            fN = false;

            if (bit7) { a = SetBit(a, 7); }

            tStates += 4;
        }

        private byte SLA(byte reg)
        {
            fC = IsSign8(reg);
            reg <<= 1;

            f5 = IsBitSet(reg, 5);
            f3 = IsBitSet(reg, 3);

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

            if (bit7) reg = SetBit(reg, 7);

            f5 = IsBitSet(reg, 5);
            f3 = IsBitSet(reg, 3);

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
            reg = SetBit(reg, 0);

            f5 = IsBitSet(reg, 5);
            f3 = IsBitSet(reg, 3);

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
            reg = ResetBit(reg, 7);

            f5 = IsBitSet(reg, 5);
            f3 = IsBitSet(reg, 3);

            fS = IsSign8(reg);
            fZ = IsZero(reg);
            fH = false;
            fPV = IsParity(reg);
            fN = false;

            return reg;
        }

        private void RLD()
        {
            byte pHL = memory.ReadByte(hl);
            byte new_pHL = (byte)((pHL & 0x0F) << 4);
            new_pHL += (byte)(a & 0x0F);
            a = (byte)(a & 0xF0);
            a += (byte)((pHL & 0xF0) >> 4);
            memory.WriteByte(hl, new_pHL);

            tStates += 18;
        }

        private void RRD()
        {
            byte pHL = memory.ReadByte(hl);
            byte new_pHL = (byte)((a & 0x0F) << 4);
            new_pHL += (byte)((pHL & 0xF0) >> 4);
            a = (byte)(a & 0xF0);
            a += (byte)(pHL & 0x0F);
            memory.WriteByte(hl, new_pHL);

            tStates += 18;
        }
        #endregion

        #region Bitwise operations
        private void BIT(int bitToTest, int reg)
        {
            switch (reg)
            {
                case 0x0: fZ = !IsBitSet(b, bitToTest); f3 = IsBitSet(b, 3); f5 = IsBitSet(b, 5); fPV = fZ; break;
                case 0x1: fZ = !IsBitSet(c, bitToTest); f3 = IsBitSet(c, 3); f5 = IsBitSet(c, 5); fPV = fZ; break;
                case 0x2: fZ = !IsBitSet(d, bitToTest); f3 = IsBitSet(d, 3); f5 = IsBitSet(d, 5); fPV = fZ; break;
                case 0x3: fZ = !IsBitSet(e, bitToTest); f3 = IsBitSet(e, 3); f5 = IsBitSet(e, 5); fPV = fZ; break;
                case 0x4: fZ = !IsBitSet(h, bitToTest); f3 = IsBitSet(h, 3); f5 = IsBitSet(h, 5); fPV = fZ; break;
                case 0x5: fZ = !IsBitSet(l, bitToTest); f3 = IsBitSet(l, 3); f5 = IsBitSet(l, 5); fPV = fZ; break;
                case 0x6: var val = memory.ReadByte(hl); fZ = !IsBitSet(val, bitToTest); f3 = IsBitSet(val, 3); f5 = IsBitSet(val, 5); fPV = fZ; break;
                case 0x7: fZ = !IsBitSet(a, bitToTest); f3 = IsBitSet(a, 3); f5 = IsBitSet(a, 5); fPV = fZ; break;
                default:
                    throw new ArgumentOutOfRangeException("register", reg, "Field register must map to a valid Z80 register.");
            }

            // undocumented behavior from http://worldofspectrum.org/faq/reference/z80reference.htm
            fS = ((bitToTest == 7) && (!fZ));
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

        #region Port operations and interrupts
        private byte IN(byte portNumber)
        {

            // TODO: check tstates
            var readByte = portRead(bc);

            fS = IsSign8(portNumber);
            fZ = IsZero(portNumber);
            fH = false;
            fPV = IsParity(portNumber);
            fN = false;
            f5 = IsBitSet(portNumber, 5);
            f3 = IsBitSet(portNumber, 3);

            return readByte;
        }

        private void OUT(byte portNumber, byte value)
        {
            // TODO: write value to portNumber
            tStates += 11;
        }


        private void INIR()
        {
            memory.WriteByte(hl, portRead(bc));
            hl++;
            b--;
            if (b != 0)
            {
                pc -= 2;
                tStates += 21;
            }
            else
            {
                fN = true;
                fZ = true;
                tStates += 16;
            }
        }

        // TODO: this is wrong or INDR is wrong - they are clones of one another
        private void OTIR()
        {
            portWrite(bc, memory.ReadByte(hl));
            hl++;
            b--;
            if (b != 0)
            {
                pc -= 2;
                tStates += 21;
            }
            else
            {
                fN = true;
                fZ = true;
                tStates += 16;
            }
        }

        private void INDR()
        {
            memory.WriteByte(hl, portRead(bc));
            hl--;
            b--;
            if (b != 0)
            {
                pc -= 2;
                tStates += 21;
            }
            else
            {
                fN = true;
                fZ = true;
                tStates += 16;
            }
        }

        // TODO: this is wrong or INDR is wrong - they are clones of one another
        private void OTDR()
        {
            portWrite(bc, memory.ReadByte(hl));
            hl--;
            b--;
            if (b != 0)
            {
                pc -= 2;
                tStates += 21;
            }
            else
            {
                fN = true;
                fZ = true;
                tStates += 16;
            }
        }

        // TODO: These settings seem to be ZX Spectrum-specific? If so, move to Spectrum class
        public void Interrupt()
        {
            switch(im)
            {
                case 0:
                    // Not used on a ZX Spectrum
                    break;

                case 1:
                    pc = 0x0038;
                    break;

                case 2:
                    var interruptVectorTableAddress = (ushort)(i << 8);

                    // TODO: use data bus to subselect IM 2 location

                    pc = memory.ReadWord(interruptVectorTableAddress);

                    break;

                default:
                    throw new IndexOutOfRangeException("Interrupt mode out of range. Can be value 0, 1, or 2.");
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
