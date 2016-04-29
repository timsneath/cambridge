 using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ProjectCambridge
{
    public partial class Z80
    {
        /* 
         * explanations of each command: http://clrhome.org/table/
         * helpful decoder shortcuts: http://z80.info/decoding.htm
         * and http://z80.info/z80code.txt
         */
        public void DecodeOpcode()
        {
            byte opCode = GetNextByte();
            switch (opCode)
            {
                // NOP
                case 0x00: break;

                // LD BC, **
                case 0x01: b = GetNextByte(); c = GetNextByte(); break;

                // LD (BC), A
                case 0x02: memory.WriteByte(bc, a); break;

                // INC BC
                case 0x03: bc++; break;

                // INC B
                case 0x04: b = INC(b); break;

                // DEC B
                case 0x05: b = DEC(b); break;

                // LD B, *
                case 0x06: b = GetNextByte(); break;

                // RLCA
                case 0x07: fC = IsSign(a); a <<= 1; fH = false; fN = false; if (fC) a = (byte)SetBit(a, 0); break;

                // EX AF, AF'
                case 0x08: Swap(ref a, ref a_); Swap(ref f, ref f_); break;

                // ADD HL, BC
                case 0x09: hl += bc; break;

                // LD A, (BC)
                case 0x0A: a = memory.ReadByte(bc); break;

                // DEC BC
                case 0x0B: bc--; break;

                // INC C
                case 0x0C: c = INC(c); break;

                // DEC C
                case 0x0D: c = DEC(c); break;

                // LD C, *
                case 0x0E: c = GetNextByte(); break;

                // RRCA
                case 0x0F: break;

                // DJNZ *
                case 0x10: GetNextByte(); break;

                // LD DE, **
                case 0x11: d = GetNextByte(); e = GetNextByte(); break;

                // LD (DE), A
                case 0x12: memory.WriteByte(de, a); break;

                // INC DE
                case 0x13: de++; break;

                // INC D
                case 0x14: d = INC(d); break;

                // DEC D
                case 0x15: d = DEC(d); break;

                // LD D, *
                case 0x16: d = GetNextByte(); break;

                // RLA
                case 0x17: break;

                // JR *
                case 0x18: break;

                // ADD HL, DE
                case 0x19: hl += de; break;

                // LD A, (DE)
                case 0x1A: a = memory.ReadByte(de); break;

                // DEC DE
                case 0x1B: de--; break;

                // INC E
                case 0x1C: e = INC(e); break;

                // DEC E
                case 0x1D: e = DEC(e); break;

                // LD E, *
                case 0x1E: e = GetNextByte(); break;

                // RRA
                case 0x1F: break;

                // JR NZ, *
                case 0x20: break;

                // LD HL, **
                case 0x21: h = GetNextByte(); l = GetNextByte(); break;

                // LD (**), HL
                case 0x22: memory.WriteWord(hl, GetNextWord()); break;

                // INC HL
                case 0x23: hl++; break;

                // INC H
                case 0x24: h = INC(h); break;

                // DEC H
                case 0x25: h = DEC(h); break;

                // LD H, *
                case 0x26: h = GetNextByte(); break;

                // DAA
                case 0x27: break;

                // JR Z, *
                case 0x28: break;

                // ADD HL, HL
                case 0x29: hl += hl; break;

                // LD HL, (**)
                case 0x2A: hl = memory.ReadWord(GetNextWord()); break;

                // DEC HL
                case 0x2B: hl--; break;

                // INC L
                case 0x2C: l = INC(l); break;

                // DEC L
                case 0x2D: l = DEC(l); break;

                // LD L, *
                case 0x2E: break;

                // CPL
                case 0x2F: break;

                // JR NC, *
                case 0x30: break;

                // LD SP, **
                case 0x31: sp = GetNextWord(); break;

                // LD (**), A
                case 0x32: memory.WriteByte(GetNextWord(), a); break;

                // INC SP
                case 0x33: sp++; break;

                // INC (HL)
                case 0x34: var incValue = memory.ReadByte(hl) + 1;  memory.WriteByte(hl, (byte)incValue); break;

                // DEC (HL)
                case 0x35: var decValue = memory.ReadByte(hl) - 1; memory.WriteByte(hl, (byte)decValue); break;

                // LD (HL), *
                case 0x36: memory.WriteWord(hl, GetNextByte()); break;

                // SCF
                case 0x37: break;

                // JR C, *
                case 0x38: break;

                // ADD HL, SP
                case 0x39: hl += sp; break;

                // LD A, (**)
                case 0x3A: a = memory.ReadByte(GetNextWord()); break;

                // DEC SP
                case 0x3B: sp--; break;

                // INC A
                case 0x3C: a = INC(a); break;

                // DEC A
                case 0x3D: a = DEC(a); break;

                // LD A, *
                case 0x3E: a = GetNextByte(); break;

                // CCF
                case 0x3F: break;

                // LD B, B
                case 0x40: break;

                // LD B, C
                case 0x41: b = c; break;

                // LD B, D
                case 0x42: b = d; break;

                // LD B, E
                case 0x43: b = e; break;

                // LD B, H
                case 0x44: b = h; break;

                // LD B, L
                case 0x45: b = l; break;

                // LD B, (HL)
                case 0x46: b = memory.ReadByte(hl); break;

                // LD B, A
                case 0x47: b = a; break;

                // LD C, B
                case 0x48: c = b; break;

                // LD C, C
                case 0x49: break;

                // LD C, D
                case 0x4A: c = d; break;

                // LD C, E
                case 0x4B: c = e; break;

                // LD C, H
                case 0x4C: c = h; break;

                // LD C, L
                case 0x4D: c = l; break;

                // LD C, (HL)
                case 0x4E: c = memory.ReadByte(hl); break;

                // LD C, A
                case 0x4F: c = a; break;

                // LD D, B
                case 0x50: d = b; break;

                // LD D, C
                case 0x51: d = c; break;

                // LD D, D
                case 0x52: break;

                // LD D, E
                case 0x53: d = e; break;

                // LD D, H
                case 0x54: d = h; break;

                // LD D, L
                case 0x55: d = l; break;

                // LD D, (HL)
                case 0x56: d = memory.ReadByte(hl); break;

                // LD D, A
                case 0x57: d = a; break;

                // LD E, B
                case 0x58: e = b; break;

                // LD E, C
                case 0x59: e = c; break;

                // LD E, D
                case 0x5A: e = d; break;

                // LD E, E
                case 0x5B: break;

                // LD E, H
                case 0x5C: e = h; break;

                // LD E, L
                case 0x5D: e = l; break;

                // LD E, (HL)
                case 0x5E: e = memory.ReadByte(hl); break;

                // LD E, A
                case 0x5F: e = a; break;

                // LD H, B
                case 0x60: h = b; break;

                // LD H, C
                case 0x61: h = c; break;

                // LD H, D
                case 0x62: h = d; break;

                // LD H, E
                case 0x63: h = e; break;

                // LD H, H
                case 0x64: break;

                // LD H, L
                case 0x65: h = l; break;

                // LD H, (HL)
                case 0x66: h = memory.ReadByte(hl); break;

                // LD H, A
                case 0x67: h = a; break;

                // LD L, B
                case 0x68: l = b; break;

                // LD L, C
                case 0x69: l = c; break;

                // LD L, D
                case 0x6A: l = d; break;

                // LD L, E
                case 0x6B: l = e; break;

                // LD L, H
                case 0x6C: l = h; break;

                // LD L, L
                case 0x6D: break;

                // LD L, (HL)
                case 0x6E: l = memory.ReadByte(hl); break;

                // LD L, A
                case 0x6F: l = a; break;

                // LD (HL), B
                case 0x70: memory.WriteByte(hl, b); break;

                // LD (HL), C
                case 0x71: memory.WriteByte(hl, c); break;

                // LD (HL), D
                case 0x72: memory.WriteByte(hl, d); break;

                // LD (HL), E
                case 0x73: memory.WriteByte(hl, e); break;

                // LD (HL), H
                case 0x74: memory.WriteByte(hl, h); break;

                // LD (HL), L
                case 0x75: memory.WriteByte(hl, l); break;

                // HALT
                case 0x76: break;

                // LD (HL), A
                case 0x77: memory.WriteByte(hl, a); break;

                // LD A, B
                case 0x78: a = b; break;

                // LD A, C
                case 0x79: a = c; break;

                // LD A, D
                case 0x7A: a = d; break;

                // LD A, E
                case 0x7B: a = e; break;

                // LD A, H
                case 0x7C: a = h; break;

                // LD A, L
                case 0x7D: a = l; break;

                // LD A, (HL)
                case 0x7E: a = memory.ReadByte(hl); break;

                // LD A, A
                case 0x7F: break;

                // ADD A, B
                case 0x80: a += b; break;

                // ADD A, C
                case 0x81: a += c; break;

                // ADD A, D
                case 0x82: a += d; break;

                // ADD A, E
                case 0x83: a += e; break;

                // ADD A, H
                case 0x84: a += h; break;

                // ADD A, L
                case 0x85: a += l; break;

                // ADD A, (HL)
                case 0x86: a += memory.ReadByte(hl); break;

                // ADD A, A
                case 0x87: a += a; break;

                // ADC A, B
                case 0x88: a += b; break;

                // ADC A, C
                case 0x89: a += c; break;

                // ADC A, D
                case 0x8A: a += d; break;

                // ADC A, E
                case 0x8B: a += e; break;

                // ADC A, H
                case 0x8C: a += h; break;

                // ADC A, L
                case 0x8D: a += l; break;

                // ADC A, (HL)
                case 0x8E: a += memory.ReadByte(hl); break;

                // ADC A, A
                case 0x8F: a += a; break;

                // SUB B
                case 0x90: SUB(b); break;

                // SUB C
                case 0x91: SUB(c); break;

                // SUB D
                case 0x92: SUB(d); break;

                // SUB E
                case 0x93: SUB(e); break;

                // SUB H
                case 0x94: SUB(h); break;

                // SUB L
                case 0x95: SUB(l); break;

                // SUB (HL)
                case 0x96: SUB(memory.ReadByte(hl)); break;

                // SUB A
                case 0x97: SUB(a); break;

                // SBC A, B
                case 0x98: a -= b; break;

                // SBC A, C
                case 0x99: a -= c; break;

                // SBC A, D
                case 0x9A: a -= d; break;

                // SBC A, E
                case 0x9B: a -= e; break;

                // SBC A, H
                case 0x9C: a -= h; break;

                // SBC A, L
                case 0x9D: a -= l; break;

                // SBC A, (HL)
                case 0x9E: a -= memory.ReadByte(hl); break;

                // SBC A, A
                case 0x9F: a -= a; break;

                // AND B
                case 0xA0: a &= b; break;

                // AND C
                case 0xA1: a &= c; break;

                // AND D
                case 0xA2: a &= d; break;

                // AND E
                case 0xA3: a &= e; break;

                // AND H
                case 0xA4: a &= h; break;

                // AND L
                case 0xA5: a &= l; break;

                // AND (HL)
                case 0xA6: a &= memory.ReadByte(hl); break;

                // AND A
                case 0xA7: a &= a; break;

                // XOR B
                case 0xA8: a ^= b; break;

                // XOR C
                case 0xA9: a ^= c; break;

                // XOR D
                case 0xAA: a ^= d; break;

                // XOR E
                case 0xAB: a ^= e; break;

                // XOR H
                case 0xAC: a ^= h; break;

                // XOR L
                case 0xAD: a ^= l; break;

                // XOR (HL)
                case 0xAE: a ^= memory.ReadByte(hl); break;

                // XOR A
                case 0xAF: a ^= a; break;

                // OR B
                case 0xB0: a |= b; break;

                // OR C
                case 0xB1: a |= c; break;

                // OR D
                case 0xB2: a |= d; break;

                // OR E
                case 0xB3: a |= e; break;

                // OR H
                case 0xB4: a |= h; break;

                // OR L
                case 0xB5: a |= l; break;

                // OR (HL)
                case 0xB6: a |= memory.ReadByte(hl); break;

                // OR A
                case 0xB7: a |= a; break;

                // CP B
                case 0xB8: cp(b); break;

                // CP C
                case 0xB9: cp(c); break;

                // CP D
                case 0xBA: cp(d); break;

                // CP E
                case 0xBB: cp(e); break;

                // CP H
                case 0xBC: cp(h); break;

                // CP L
                case 0xBD: cp(l); break;

                // CP (HL)
                case 0xBE: cp(memory.ReadByte(hl)); break;

                // CP A
                case 0xBF: cp(a); break;

                // RET NZ
                case 0xC0: break;

                // POP BC
                case 0xC1: bc = POP16(); break;

                // JP NZ, **
                case 0xC2: break;

                // JP **
                case 0xC3: pc = GetNextWord(); break;

                // CALL NZ, **
                case 0xC4: if (!fZ) { CALL(); }; break;

                // PUSH BC
                case 0xC5: PUSH16(bc); break;

                // ADD A, *
                case 0xC6: break;

                // RST 00h
                case 0xC7: RST(0x00); break;

                // RET Z
                case 0xC8: if (fZ) pc = POP16(); break;

                // RET
                case 0xC9: pc = POP16(); break;

                // JP Z, **
                case 0xCA: if (fZ) pc = GetNextWord(); break;

                // BITWISE INSTRUCTIONS
                case 0xCB: DecodeCBOpcode(); break;

                // CALL Z, **
                case 0xCC: if (fZ) CALL(); break;

                // CALL **
                case 0xCD: CALL(); break;

                // ADC A, *
                case 0xCE: GetNextByte(); break;

                // RST 08h
                case 0xCF: RST(0x08); break;

                // RET NC
                case 0xD0: if (!fC) pc = POP16(); break;

                // POP DE
                case 0xD1: de = POP16(); break;

                // JP NC, **
                case 0xD2: if (!fC) pc = GetNextWord(); break;

                // OUT (*), A
                case 0xD3: GetNextByte(); break;

                // CALL NC, **
                case 0xD4: if (!fC) CALL(); break;

                // PUSH DE
                case 0xD5: PUSH16(de); break;

                // SUB *
                case 0xD6: GetNextByte(); break;

                // RST 10h
                case 0xD7: RST(0x10); break;

                // RET C
                case 0xD8: if (fC) pc = POP16(); break;

                // EXX
                case 0xD9: Swap(ref b, ref b_); Swap(ref c, ref c_); Swap(ref d, ref d_); Swap(ref e, ref e_); Swap(ref h, ref h_); Swap(ref l, ref l_); break;

                // JP C, **
                case 0xDA: if (fC) pc = GetNextWord(); break;

                // IN A, (**)
                case 0xDB: break;

                // CALL C, **
                case 0xDC: if (fC) CALL(); break;

                // IX OPERATIONS
                case 0xDD: break;

                // SBC A, *
                case 0xDE: break;

                // RST 18h
                case 0xDF: RST(0x18); break;

                // RET PO
                case 0xE0: break;

                // POP HL
                case 0xE1: hl = POP16(); break;

                // JP PO, **
                case 0xE2: break;

                // EX (SP), HL
                case 0xE3: break;

                // CALL PO, **
                case 0xE4: break;

                // PUSH HL
                case 0xE5: PUSH16(hl); break;

                // AND *
                case 0xE6: break;

                // RST 20h
                case 0xE7: RST(0x20); break;

                // RET PE
                case 0xE8: break;

                // JP (HL)
                case 0xE9: pc = memory.ReadWord(hl); break;

                // JP PE, **
                case 0xEA: break;

                // EX DE, HL
                case 0xEB: Swap(ref d, ref h); Swap(ref e, ref l); break;

                // CALL PE, **
                case 0xEC: break;

                // EXTD INSTRUCTIONS
                case 0xED: break;

                // XOR *
                case 0xEE: break;

                // RST 28h
                case 0xEF: RST(0x28); break;

                // RET P
                case 0xF0: break;

                // POP AF
                case 0xF1: af = POP16(); break;

                // JP P, **
                case 0xF2: break;

                // DI
                case 0xF3: break;

                // CALL P, **
                case 0xF4: break;

                // PUSH AF
                case 0xF5: PUSH16(af); break;

                // OR *
                case 0xF6: break;

                // RST 30h
                case 0xF7: RST(0x30); break;

                // RET M
                case 0xF8: break;

                // LD SP, HL
                case 0xF9: sp = hl; break;

                // JP M, **
                case 0xFA: break;

                // EI
                case 0xFB: break;

                // CALL M, **
                case 0xFC: break;

                // IY INSTRUCTIONS
                case 0xFD: break;

                // CP *
                case 0xFE: break;

                // RST 38h
                case 0xFF: RST(0x38); break; 
            }   
        }

        private void DecodeCBOpcode()
        {
            byte opCode = GetNextByte();
            
            // first two bits of opCode determine function:
            switch (opCode >> 6)
            {
                // 00 = rot [y], r[z]
                case 0: rot(opCode & 0x38, opCode & 0x07); break;

                // 01 = BIT y, r[z]
                case 1: bit(opCode & 0x38, opCode & 0x07); break;

                // 02 = RES y, r[z]
                case 2: res(opCode & 0x38, opCode & 0x07); break;

                // 03 = SET y, r[z]
                case 3: set(opCode & 0x38, opCode & 0x07); break;
            }
        }

        private void rot(int operation, int register)
        {
            Func<byte, byte> rotFunction;
            
            switch(operation)
            {
                case 0x00: rotFunction = RLC; break;
                case 0x01: rotFunction = RRC; break;
                case 0x02: rotFunction = RL; break;
                case 0x03: rotFunction = RR; break;
                case 0x04: rotFunction = SLA; break;
                case 0x05: rotFunction = SRA; break;
                case 0x06: rotFunction = SLL; break;
                case 0x07: rotFunction = SRL; break;
                default:
                    throw new ArgumentOutOfRangeException("operation", operation, "Operation must map to a valid rotation operation.");
            }

            switch (register)
            {
                case 0x00: b = rotFunction(b); break;
                case 0x01: c = rotFunction(c); break;
                case 0x02: d = rotFunction(d); break;
                case 0x03: e = rotFunction(e); break;
                case 0x04: h = rotFunction(h); break;
                case 0x05: l = rotFunction(l); break;
                case 0x06: memory.WriteByte(hl, rotFunction(memory.ReadByte(hl))); break;
                case 0x07: a = rotFunction(a); break;
                default:
                    throw new ArgumentOutOfRangeException("register", register, "Field register must map to a valid Z80 register.");
            }
        }



        private bool IsParity(byte reg)
        {
            int bits1 = 0;
            for(var i=0; i < 8; i++)
            {
                if (IsBitSet(reg, i)) { bits1++; }
            }

            return (bits1 % 2 == 0);
        }


        private void bit(int bitToTest, int reg)
        { 
            switch(reg)
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

        private void res(int bitToReset, int reg)
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

        private void set(int bitToSet, int reg)
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

        private void cp(byte reg)
        { 
            var res = (byte)(a - reg);
            fS = IsSign(reg);
            fZ = (res == 0);
            fH = false; // TODO: set if borrow from bit 4
            fP = IsSign(res) != IsSign(a); // overflow
            fN = true;
            fC = false; // TODO; set if borrow

        }

        private bool IsBitSet(int x, int index)
        {
            return (x & (1 << index)) == 1 << index;
        }

        private byte SetBit(int x, int index)
        {
            return (byte)(x | (1 << index));
        }

        private byte ResetBit(int x, int index)
        {
            return (byte)(x & ~(1 << index));
        }

        private bool IsSign(byte x)
        {
            return (x & 0x80) == 0x80;
        }

        private bool IsZero(byte x)
        {
            return (x == 0);
        }

        private void Swap<T>(ref T x, ref T y)
        {
            var temp = y;
            y = x;
            x = temp;
        }
    }
}
