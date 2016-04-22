using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace testclient
{
    public partial class Z80
    {
        /* 
         * explanations of each command: http://clrhome.org/table/
         * helpful decoder shortcuts: http://z80.info/decoding.htm
         * and http://z80.info/z80code.txt
         */
        public void Decode()
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
                case 0x04: b++; break;

                // DEC B
                case 0x05: b--; break;

                // LD B, *
                case 0x06: b = GetNextByte(); break;

                // RLCA
                case 0x07: throw new NotImplementedException(); break;

                // EX AF, AF'
                case 0x08: af_ = af; af = af_; break;

                // ADD HL, BC
                case 0x09: hl += bc; break;

                // LD A, (BC)
                case 0x0A: break;

                // DEC BC
                case 0x0B: break;

                // INC C
                case 0x0C: break;

                // DEC C
                case 0x0D: c--; break;

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
                case 0x14: d++; break;

                // DEC D
                case 0x15: d--; break;

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
                case 0x1C: e++; break;

                // DEC E
                case 0x1D: e--; break;

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
                case 0x24: h++; break;

                // DEC H
                case 0x25: h--; break;

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
                case 0x2C: l++; break;

                // DEC L
                case 0x2D: l--; break;

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
                case 0x3C: a++; break;

                // DEC A
                case 0x3D: a--; break;

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
                case 0x90: a -= b; break;

                // SUB C
                case 0x91: a -= c; break;

                // SUB D
                case 0x92: a -= d; break;

                // SUB E
                case 0x93: a -= e; break;

                // SUB H
                case 0x94: a -= h; break;

                // SUB L
                case 0x95: a -= l; break;

                // SUB (HL)
                case 0x96: a -= memory.ReadByte(hl); break;

                // SUB A
                case 0x97: a -= a; break;

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



                default: break;
            }
        }
    }
}
