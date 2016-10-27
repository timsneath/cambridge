using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ProjectCambridge.EmulatorCore
{
    public partial class Z80
    {
        /* 
         * explanations of each command: http://clrhome.org/table/
         * helpful decoder shortcuts: http://z80.info/decoding.htm
         */
        public bool ExecuteNextInstruction()
        {
            byte opCode = GetNextByte();
            switch (opCode)
            {
                // NOP
                case 0x00: tStates += 4; break;

                // LD BC, **
                case 0x01: bc = GetNextWord(); tStates += 10;  break;

                // LD (BC), A
                case 0x02: memory.WriteByte(bc, a); tStates += 7;  break;

                // INC BC
                case 0x03: bc++; tStates += 6;  break;

                // INC B
                case 0x04: b = INC(b); break;

                // DEC B
                case 0x05: b = DEC(b); break;

                // LD B, *
                case 0x06: b = GetNextByte(); tStates += 7; break;

                // RLCA
                case 0x07: RLCA(); break;

                // EX AF, AF'
                case 0x08: EX_AFAFPrime(); break;

                // ADD HL, BC
                case 0x09: hl = ADD(hl, bc); break;

                // LD A, (BC)
                case 0x0A: a = memory.ReadByte(bc); tStates += 7; break;

                // DEC BC
                case 0x0B: bc--; tStates += 6; break;

                // INC C
                case 0x0C: c = INC(c); break;

                // DEC C
                case 0x0D: c = DEC(c); break;

                // LD C, *
                case 0x0E: c = GetNextByte(); tStates += 7; break;

                // RRCA
                case 0x0F: RRCA(); break;

                // DJNZ *
                case 0x10: DJNZ((sbyte)GetNextByte()); break;

                // LD DE, **
                case 0x11: de = GetNextWord(); tStates += 10; break;

                // LD (DE), A
                case 0x12: memory.WriteByte(de, a); tStates += 7; break;

                // INC DE
                case 0x13: de++; tStates += 6; break;

                // INC D
                case 0x14: d = INC(d); break;

                // DEC D
                case 0x15: d = DEC(d); break;

                // LD D, *
                case 0x16: d = GetNextByte(); tStates += 7; break;

                // RLA
                case 0x17: RLA(); break;

                // JR *
                case 0x18: JR((sbyte)GetNextByte()); break;

                // ADD HL, DE
                case 0x19: hl = ADD(hl, de); break;

                // LD A, (DE)
                case 0x1A: a = memory.ReadByte(de); tStates += 7; break;

                // DEC DE
                case 0x1B: de--; tStates += 6; break;

                // INC E
                case 0x1C: e = INC(e); break;

                // DEC E
                case 0x1D: e = DEC(e); break;

                // LD E, *
                case 0x1E: e = GetNextByte(); tStates += 7; break;

                // RRA
                case 0x1F: RRA(); break;

                // JR NZ, *
                case 0x20: if (!fZ) { JR((sbyte)GetNextByte()); } else { pc++; tStates += 7; } break;

                // LD HL, **
                case 0x21: hl = GetNextWord(); tStates += 10; break;

                // LD (**), HL
                case 0x22: memory.WriteWord(GetNextWord(), hl); tStates += 16; break;

                // INC HL
                case 0x23: hl++; tStates += 6; break;

                // INC H
                case 0x24: h = INC(h); break;

                // DEC H
                case 0x25: h = DEC(h); break;

                // LD H, *
                case 0x26: h = GetNextByte(); tStates += 7; break;

                // DAA
                case 0x27: DAA(); break;

                // JR Z, *
                case 0x28: if (fZ) { JR((sbyte)GetNextByte()); } else { pc++; tStates += 7; } break;

                // ADD HL, HL
                case 0x29: hl = ADD(hl, hl); break;

                // LD HL, (**)
                case 0x2A: hl = memory.ReadWord(GetNextWord()); tStates += 16; break;

                // DEC HL
                case 0x2B: hl--; tStates += 6; break;

                // INC L
                case 0x2C: l = INC(l); break;

                // DEC L
                case 0x2D: l = DEC(l); break;

                // LD L, *
                case 0x2E: l = GetNextByte(); tStates += 7; break;

                // CPL
                case 0x2F: CPL(); break;

                // JR NC, *
                case 0x30: if (!fC) { JR((sbyte)GetNextByte()); } else { pc++; tStates += 7; } break;

                // LD SP, **
                case 0x31: sp = GetNextWord(); tStates += 10; break;

                // LD (**), A
                case 0x32: memory.WriteByte(GetNextWord(), a); tStates += 13; break;

                // INC SP
                case 0x33: sp++; tStates += 6; break;

                // INC (HL)
                case 0x34: memory.WriteByte(hl, INC(memory.ReadByte(hl))); tStates += 7; break;

                // DEC (HL)
                case 0x35: memory.WriteByte(hl, DEC(memory.ReadByte(hl))); tStates += 7; break;

                // LD (HL), *
                case 0x36: memory.WriteByte(hl, GetNextByte()); tStates += 10; break;

                // SCF
                case 0x37: SCF(); tStates += 4; break;

                // JR C, *
                case 0x38: if (fC) { JR((sbyte)GetNextByte()); } else { pc++; tStates += 7; } break;

                // ADD HL, SP
                case 0x39: hl = ADD(hl, sp); tStates += 11; break;

                // LD A, (**)
                case 0x3A: a = memory.ReadByte(GetNextWord()); tStates += 13; break;

                // DEC SP
                case 0x3B: sp--; tStates += 6; break;

                // INC A
                case 0x3C: a = INC(a); break;

                // DEC A
                case 0x3D: a = DEC(a); break;

                // LD A, *
                case 0x3E: a = GetNextByte(); tStates += 7; break;

                // CCF
                case 0x3F: CCF(); break;

                // LD B, B
                case 0x40: tStates += 4; break;

                // LD B, C
                case 0x41: b = c; tStates += 4; break;

                // LD B, D
                case 0x42: b = d; tStates += 4; break;

                // LD B, E
                case 0x43: b = e; tStates += 4; break;

                // LD B, H
                case 0x44: b = h; tStates += 4; break;

                // LD B, L
                case 0x45: b = l; tStates += 4; break;

                // LD B, (HL)
                case 0x46: b = memory.ReadByte(hl); tStates += 7; break;

                // LD B, A
                case 0x47: b = a; tStates += 4; break;

                // LD C, B
                case 0x48: c = b; tStates += 4; break;

                // LD C, C
                case 0x49: tStates += 4; break;

                // LD C, D
                case 0x4A: c = d; tStates += 4; break;

                // LD C, E
                case 0x4B: c = e; tStates += 4; break;

                // LD C, H
                case 0x4C: c = h; tStates += 4; break;

                // LD C, L
                case 0x4D: c = l; tStates += 4; break;

                // LD C, (HL)
                case 0x4E: c = memory.ReadByte(hl); tStates += 7; break;

                // LD C, A
                case 0x4F: c = a; tStates += 4; break;

                // LD D, B
                case 0x50: d = b; tStates += 4; break;

                // LD D, C
                case 0x51: d = c; tStates += 4; break;

                // LD D, D
                case 0x52: tStates += 4; break;

                // LD D, E
                case 0x53: d = e; tStates += 4; break;

                // LD D, H
                case 0x54: d = h; tStates += 4; break;

                // LD D, L
                case 0x55: d = l; tStates += 4; break;

                // LD D, (HL)
                case 0x56: d = memory.ReadByte(hl); tStates += 7; break;

                // LD D, A
                case 0x57: d = a; tStates += 4; break;

                // LD E, B
                case 0x58: e = b; tStates += 4; break;

                // LD E, C
                case 0x59: e = c; tStates += 4; break;

                // LD E, D
                case 0x5A: e = d; tStates += 4; break;

                // LD E, E
                case 0x5B: tStates += 4; break;

                // LD E, H
                case 0x5C: e = h; tStates += 4; break;

                // LD E, L
                case 0x5D: e = l; tStates += 4; break;

                // LD E, (HL)
                case 0x5E: e = memory.ReadByte(hl); tStates += 7; break;

                // LD E, A
                case 0x5F: e = a; tStates += 4; break;

                // LD H, B
                case 0x60: h = b; tStates += 4; break;

                // LD H, C
                case 0x61: h = c; tStates += 4; break;

                // LD H, D
                case 0x62: h = d; tStates += 4; break;

                // LD H, E
                case 0x63: h = e; tStates += 4; break;

                // LD H, H
                case 0x64: tStates += 4; break;

                // LD H, L
                case 0x65: h = l; tStates += 4; break;

                // LD H, (HL)
                case 0x66: h = memory.ReadByte(hl); tStates += 7; break;

                // LD H, A
                case 0x67: h = a; tStates += 4; break;

                // LD L, B
                case 0x68: l = b; tStates += 4; break;

                // LD L, C
                case 0x69: l = c; tStates += 4; break;

                // LD L, D
                case 0x6A: l = d; tStates += 4; break;

                // LD L, E
                case 0x6B: l = e; tStates += 4; break;

                // LD L, H
                case 0x6C: l = h; tStates += 4; break;

                // LD L, L
                case 0x6D: tStates += 4; break;

                // LD L, (HL)
                case 0x6E: l = memory.ReadByte(hl); tStates += 7; break;

                // LD L, A
                case 0x6F: l = a; tStates += 4; break;

                // LD (HL), B
                case 0x70: memory.WriteByte(hl, b); tStates += 7; break;

                // LD (HL), C
                case 0x71: memory.WriteByte(hl, c); tStates += 7; break;

                // LD (HL), D
                case 0x72: memory.WriteByte(hl, d); tStates += 7; break;

                // LD (HL), E
                case 0x73: memory.WriteByte(hl, e); tStates += 7; break;

                // LD (HL), H
                case 0x74: memory.WriteByte(hl, h); tStates += 7; break;

                // LD (HL), L
                case 0x75: memory.WriteByte(hl, l); tStates += 7; break;

                // HALT
                case 0x76: tStates += 4; pc--; cpuSuspended = true; break;

                // LD (HL), A
                case 0x77: memory.WriteByte(hl, a); tStates += 7; break;

                // LD A, B
                case 0x78: a = b; tStates += 4; break;

                // LD A, C
                case 0x79: a = c; tStates += 4; break;

                // LD A, D
                case 0x7A: a = d; tStates += 4; break;

                // LD A, E
                case 0x7B: a = e; tStates += 4; break;

                // LD A, H
                case 0x7C: a = h; tStates += 4; break;

                // LD A, L
                case 0x7D: a = l; tStates += 4; break;

                // LD A, (HL)
                case 0x7E: a = memory.ReadByte(hl); tStates += 7; break;

                // LD A, A
                case 0x7F: tStates += 4; break;

                // ADD A, B
                case 0x80: a = ADD(a, b); break;

                // ADD A, C
                case 0x81: a = ADD(a, c); break;

                // ADD A, D
                case 0x82: a = ADD(a, d); break;

                // ADD A, E
                case 0x83: a = ADD(a, e); break;

                // ADD A, H
                case 0x84: a = ADD(a, h); break;

                // ADD A, L
                case 0x85: a = ADD(a, l); break;

                // ADD A, (HL)
                case 0x86: a = ADD(a, memory.ReadByte(hl)); tStates += 3; break;

                // ADD A, A
                case 0x87: a = ADD(a, a); break;

                // ADC A, B
                case 0x88: a = ADC(a, b); break;

                // ADC A, C
                case 0x89: a = ADC(a, c); break;

                // ADC A, D
                case 0x8A: a = ADC(a, d); break;

                // ADC A, E
                case 0x8B: a = ADC(a, e); break;

                // ADC A, H
                case 0x8C: a = ADC(a, h); break;

                // ADC A, L
                case 0x8D: a = ADC(a, l); break;

                // ADC A, (HL)
                case 0x8E: a = ADC(a, memory.ReadByte(hl)); tStates += 3; break;

                // ADC A, A
                case 0x8F: a = ADC(a, a); break;

                // SUB B
                case 0x90: a = SUB(a, b); break;

                // SUB C
                case 0x91: a = SUB(a, c); break;

                // SUB D
                case 0x92: a = SUB(a, d); break;

                // SUB E
                case 0x93: a = SUB(a, e); break;

                // SUB H
                case 0x94: a = SUB(a, h); break;

                // SUB L
                case 0x95: a = SUB(a, l); break;

                // SUB (HL)
                case 0x96: a = SUB(a, memory.ReadByte(hl)); tStates += 3; break;

                // SUB A
                case 0x97: a = SUB(a, a); break;

                // SBC A, B
                case 0x98: a = SBC(a, b); break;

                // SBC A, C
                case 0x99: a = SBC(a, c); break;

                // SBC A, D
                case 0x9A: a = SBC(a, d); break;

                // SBC A, E
                case 0x9B: a = SBC(a, e); break;

                // SBC A, H
                case 0x9C: a = SBC(a, h); break;

                // SBC A, L
                case 0x9D: a = SBC(a, l); break;

                // SBC A, (HL)
                case 0x9E: a = SBC(a, memory.ReadByte(hl)); tStates += 3; break;

                // SBC A, A
                case 0x9F: a = SBC(a, a); break;

                // AND B
                case 0xA0: a = AND(a, b); break;

                // AND C
                case 0xA1: a = AND(a, c); break;

                // AND D
                case 0xA2: a = AND(a, d); break;

                // AND E
                case 0xA3: a = AND(a, e); break;

                // AND H
                case 0xA4: a = AND(a, h); break;

                // AND L
                case 0xA5: a = AND(a, l); break;

                // AND (HL)
                case 0xA6: a = AND(a, memory.ReadByte(hl)); tStates += 3; break;

                // AND A
                case 0xA7: a = AND(a, a); break;

                // XOR B
                case 0xA8: a = XOR(a, b); break;

                // XOR C
                case 0xA9: a = XOR(a, c); break;

                // XOR D
                case 0xAA: a = XOR(a, d); break;

                // XOR E
                case 0xAB: a = XOR(a, e); break;

                // XOR H
                case 0xAC: a = XOR(a, h); break;

                // XOR L
                case 0xAD: a = XOR(a, l); break;

                // XOR (HL)
                case 0xAE: a = XOR(a, memory.ReadByte(hl)); tStates += 3; break;

                // XOR A
                case 0xAF: a = XOR(a, a); break;

                // OR B
                case 0xB0: a = OR(a, b); break;

                // OR C
                case 0xB1: a = OR(a, c); break;

                // OR D
                case 0xB2: a = OR(a, d); break;

                // OR E
                case 0xB3: a = OR(a, e); break;

                // OR H
                case 0xB4: a = OR(a, h); break;

                // OR L
                case 0xB5: a = OR(a, l); break;

                // OR (HL)
                case 0xB6: a = OR(a, memory.ReadByte(hl)); tStates += 3; break;

                // OR A
                case 0xB7: a = OR(a, a); break;

                // CP B
                case 0xB8: CP(b); break;

                // CP C
                case 0xB9: CP(c); break;

                // CP D
                case 0xBA: CP(d); break;

                // CP E
                case 0xBB: CP(e); break;

                // CP H
                case 0xBC: CP(h); break;

                // CP L
                case 0xBD: CP(l); break;

                // CP (HL)
                case 0xBE: CP(memory.ReadByte(hl)); tStates += 3; break;

                // CP A
                case 0xBF: CP(a); break;

                // RET NZ
                case 0xC0: if (!fZ) { pc = POP(); tStates += 11; } else { tStates += 5; } break;

                // POP BC
                case 0xC1: bc = POP(); tStates += 10; break;

                // JP NZ, **
                case 0xC2: if (!fZ) { pc = GetNextWord(); } else { pc += 2; } tStates += 10; break;

                // JP **
                case 0xC3: pc = GetNextWord(); tStates += 10; break;

                // CALL NZ, **
                case 0xC4: if (!fZ) { CALL(); } else { pc += 2; tStates += 10; } break;

                // PUSH BC
                case 0xC5: PUSH(bc); tStates += 11; break;

                // ADD A, *
                case 0xC6: a = ADD(a, GetNextByte()); tStates += 3; break;

                // RST 00h
                case 0xC7: RST(0x00); break;

                // RET Z
                case 0xC8: if (fZ) { pc = POP(); tStates += 11; } else { tStates += 5; } break;

                // RET
                case 0xC9: pc = POP(); tStates += 10; break;

                // JP Z, **
                case 0xCA: if (fZ) pc = GetNextWord(); else { pc += 2; } tStates += 10; break;

                // BITWISE INSTRUCTIONS
                case 0xCB: DecodeCBOpcode(); break;

                // CALL Z, **
                case 0xCC: if (fZ) { CALL(); } else { pc += 2; tStates += 10; } break;

                // CALL **
                case 0xCD: CALL(); break;

                // ADC A, *
                case 0xCE: a = ADC(a, GetNextByte()); tStates += 3; break;

                // RST 08h
                case 0xCF: RST(0x08); break;

                // RET NC
                case 0xD0: if (!fC) { pc = POP(); tStates += 11; } else { tStates += 5; } break;

                // POP DE
                case 0xD1: de = POP(); tStates += 10; break;

                // JP NC, **
                case 0xD2: if (!fC) { pc = GetNextWord(); } else { pc += 2; } tStates += 10; break;

                // OUT (*), A
                case 0xD3: OUT(GetNextByte(), a); break;

                // CALL NC, **
                case 0xD4: if (!fC) { CALL(); } else { pc += 2; tStates += 10; } break;

                // PUSH DE
                case 0xD5: PUSH(de); tStates += 11; break;

                // SUB *
                case 0xD6: a = SUB(a, GetNextByte()); tStates += 3; break;

                // RST 10h
                case 0xD7: RST(0x10); break;

                // RET C
                case 0xD8: if (fC) { pc = POP(); tStates += 11; } else { tStates += 5; } break;

                // EXX
                case 0xD9: Swap(ref b, ref b_); Swap(ref c, ref c_); Swap(ref d, ref d_); Swap(ref e, ref e_); Swap(ref h, ref h_); Swap(ref l, ref l_); tStates += 4; break;

                // JP C, **
                case 0xDA: if (fC) { pc = GetNextWord(); } else { pc += 2; } tStates += 10; break;

                // IN A, (*)
                case 0xDB: a = IN(GetNextByte()); tStates += 11; break;

                // CALL C, **
                case 0xDC: if (fC) { CALL(); } else { pc += 2; tStates += 10; } break;

                // IX OPERATIONS
                case 0xDD: DecodeDDOpcode(); break;

                // SBC A, *
                case 0xDE: a = SBC(a, GetNextByte()); tStates += 3; break;

                // RST 18h
                case 0xDF: RST(0x18); break;

                // RET PO
                case 0xE0: if (!fPV) { pc = POP(); tStates += 11; } else { tStates += 5; } break;

                // POP HL
                case 0xE1: hl = POP(); tStates += 10; break;

                // JP PO, **
                case 0xE2: if (!fPV) { pc = GetNextWord(); } else { pc += 2; } tStates += 10; break;

                // EX (SP), HL
                case 0xE3: var temp = hl; hl = memory.ReadWord(sp); memory.WriteWord(sp, temp); tStates += 19; break;

                // CALL PO, **
                case 0xE4: if (!fPV) { CALL(); } else { pc += 2; tStates += 10; } break;

                // PUSH HL
                case 0xE5: PUSH(hl); tStates += 11; break;

                // AND *
                case 0xE6: a = AND(a, GetNextByte()); tStates += 3; break;

                // RST 20h
                case 0xE7: RST(0x20); break;

                // RET PE
                case 0xE8: if (fPV) { pc = POP(); tStates += 11; } else { tStates += 5; } break;

                // JP (HL)
                // note that the brackets in the instruction are an eccentricity, the result 
                // should be hl rather than the contents of addr(hl)
                case 0xE9: pc = hl; tStates += 4; break;

                // JP PE, **
                case 0xEA: if (fPV) { pc = GetNextWord(); } else { pc += 2; } tStates += 10; break;

                // EX DE, HL
                case 0xEB: Swap(ref d, ref h); Swap(ref e, ref l); tStates += 4; break;

                // CALL PE, **
                case 0xEC: if (fPV) { CALL(); } else { pc += 2; tStates += 10; } break;

                // EXTD INSTRUCTIONS
                case 0xED: DecodeEDOpcode(); break;

                // XOR *
                case 0xEE: a = XOR(a, GetNextByte()); tStates += 3; break;

                // RST 28h
                case 0xEF: RST(0x28); break;

                // RET P
                case 0xF0: if (!fS) { pc = POP(); tStates += 11; } else { tStates += 5; } break;

                // POP AF
                case 0xF1: af = POP(); tStates += 10; break;

                // JP P, **
                case 0xF2: if (!fS) { pc = GetNextWord(); } else { pc += 2; } tStates += 10; break;

                // DI
                case 0xF3: iff1 = false; iff2 = false; tStates += 4; break;

                // CALL P, **
                case 0xF4: if (!fS) { CALL(); } else { pc += 2; tStates += 10; } break;

                // PUSH AF
                case 0xF5: PUSH(af); tStates += 11; break;

                // OR *
                case 0xF6: a = OR(a, GetNextByte()); tStates += 3; break;

                // RST 30h
                case 0xF7: RST(0x30); break;

                // RET M
                case 0xF8: if (fS) { pc = POP(); tStates += 11; } else { tStates += 5; } break;

                // LD SP, HL
                case 0xF9: sp = hl; tStates += 6; break;

                // JP M, **
                case 0xFA: if (fS) { pc = GetNextWord(); } else { pc += 2; } tStates += 10; break;

                // EI
                case 0xFB: iff1 = true; iff2 = true; tStates += 4; break;

                // CALL M, **
                case 0xFC: if (fS) { CALL(); } else { pc += 2; tStates += 10; } break;

                // IY INSTRUCTIONS
                case 0xFD: DecodeFDOpcode(); break;

                // CP *
                case 0xFE: CP(GetNextByte()); tStates += 3; break;

                // RST 38h
                case 0xFF: RST(0x38); break;
            }

            return true;
        }

        private void DecodeCBOpcode()
        {
            byte opCode = GetNextByte();

            // first two bits of opCode determine function:
            switch (opCode >> 6)
            {
                // 00 = rot [y], r[z]
                case 0: rot((opCode & 0x38) >> 3, opCode & 0x07); break;

                // 01 = BIT y, r[z]
                case 1: BIT((opCode & 0x38) >> 3, opCode & 0x07); break;

                // 02 = RES y, r[z]
                case 2: RES((opCode & 0x38) >> 3, opCode & 0x07); break;

                // 03 = SET y, r[z]
                case 3: SET((opCode & 0x38) >> 3, opCode & 0x07); break;
            }

            // Set T-States
            if ((opCode & 0x7) == 0x6)
            {
                if ((opCode > 0x40) && (opCode < 0x7F))
                {
                    // BIT n, (HL)
                    tStates += 12;
                }
                else
                {
                    // all the other instructions involving (HL)
                    tStates += 15;
                }
            }
            else
            {
                // straight register bitwise operation
                tStates += 8;
            }
        }

        private void DecodeEDOpcode()
        {
            byte opCode = GetNextByte();

            switch (opCode)
            {
                // IN B, (C)
                case 0x40: b = IN(c); tStates += 11; break;

                // OUT (C), B
                case 0x41: OUT(c, b); tStates += 12; break;

                // SBC HL, BC
                case 0x42: hl = SBC(hl, bc); break;

                // LD (**), BC
                case 0x43: memory.WriteWord(GetNextWord(), bc); tStates += 20; break;

                // NEG
                case 0x44:
                case 0x4C:
                case 0x54:
                case 0x5C:
                case 0x64:
                case 0x6C:
                case 0x74:
                case 0x7C:
                    a = NEG(a); break;

                // RETN
                case 0x45:
                case 0x55:
                case 0x5D:
                case 0x65:
                case 0x6D:
                case 0x75:
                case 0x7D:
                    pc = POP(); iff1 = iff2; tStates += 14; break;

                // IM 0
                case 0x46:
                case 0x66:
                    tStates += 8; break;

                // LD I, A
                case 0x47: i = a; tStates += 9; break;

                // IN C, (C)
                case 0x48: c = IN(c); break;

                // OUT C, (C)
                case 0x49: OUT(c, c); tStates += 12; break;

                // ADC HL, BC
                case 0x4A: hl = ADC(hl, bc); tStates += 4; break;

                // LD BC, (**)
                case 0x4B: bc = memory.ReadWord(GetNextWord()); tStates += 20; break;

                // RETI
                case 0x4D: tStates += 14; break;

                // LD R, A
                case 0x4F: r = a; tStates += 9; break;

                // IN D, (C)
                case 0x50: d = IN(c); break;

                // OUT (C), D
                case 0x51: OUT(c, d); tStates += 12; break;

                // SBC HL, DE
                case 0x52: hl = SBC(hl, de); break;

                // LD (**), DE
                case 0x53: memory.WriteWord(GetNextWord(), de); tStates += 20; break;

                // IM 1
                case 0x4E:
                case 0x56:
                case 0x6E:
                case 0x76:
                    tStates += 8; break;

                // LD A, I
                case 0x57: a = i; fS = IsSign8(i); fZ = IsZero(i); fH = false; fPV = iff2; fN = false; tStates += 9; break;

                // IN E, (C)
                case 0x58: e = IN(c); break;

                // OUT (C), E
                case 0x59: OUT(c, e); tStates += 12; break;

                // ADC HL, DE
                case 0x5A: hl = ADC(hl, de); tStates += 4; break;

                // LD DE, (**)
                case 0x5B: de = memory.ReadWord(GetNextWord()); tStates += 20; break;

                // IM 2
                case 0x5E:
                case 0x7E:
                    tStates += 8;
                    break;

                // LD A, R
                case 0x5F: a = r; fS = IsSign8(r); fZ = IsZero(r); fH = false; fPV = iff2; fN = false; tStates += 9; break;

                // IN H, (C)
                case 0x60: h = IN(c); break;

                // OUT (C), H
                case 0x61: OUT(c, h); tStates += 12; break;

                // SBC HL, HL
                case 0x62: hl = SBC(hl, hl); break;

                // LD (**), HL
                case 0x63: memory.WriteWord(GetNextWord(), hl); tStates += 20; break;

                // RRD
                case 0x67: RRD(); break;

                // IN L, (C)
                case 0x68: l = IN(c); break;

                // OUT (C), L
                case 0x69: OUT(c, l); tStates += 12; break;

                // ADC HL, HL
                case 0x6A: hl = ADC(hl, hl); tStates += 4; break;

                // LD HL, (**)
                case 0x6B: hl = memory.ReadWord(GetNextWord()); tStates += 20; break;

                // RLD
                case 0x6F: RLD(); break;

                // SBC HL, SP
                case 0x72: hl = SBC(hl, sp); break;

                // LD (**), SP
                case 0x73: memory.WriteWord(GetNextWord(), sp); tStates += 20; break;

                // IN A, (C)
                case 0x78: a = IN(c); tStates += 11; break;

                // OUT (C), A
                case 0x79: OUT(c, a); tStates += 12; break;

                // ADC HL, SP
                case 0x7A: hl = ADC(hl, sp); tStates += 4; break;

                // LD SP, (**)
                case 0x7B: sp = memory.ReadWord(GetNextWord()); tStates += 20; break;

                // LDI
                case 0xA0: LDI(); break;

                // CPI
                case 0xA1: CPI(); break;

                // INI
                case 0xA2: tStates += 16; break;

                // OUTI
                case 0xA3: tStates += 16; break;

                // LDD
                case 0xA8: LDD(); break;

                // CPD
                case 0xA9: CPD(); break;

                // IND
                case 0xAA: tStates += 16; break;

                // OUTD
                case 0xAB: tStates += 16; break;

                // LDIR
                case 0xB0: LDIR(); break;

                // CPIR
                case 0xB1: CPIR(); break;

                // INIR
                case 0xB2: INIR(); break;

                // OTIR
                case 0xB3: OTIR(); break;

                // LDDR
                case 0xB8: LDDR(); break;

                // CPDR
                case 0xB9: CPDR(); break;

                // INDR
                case 0xBA: INDR(); break;

                // OTDR
                case 0xBB: OTDR(); break;

                default:
                    throw new InvalidOperationException($"Opcode ED{opCode:X2} not understood. ");
            }
        }


        private void DecodeDDOpcode()
        {
            byte opCode = GetNextByte();
            ushort addr;

            switch (opCode)
            {
                // NOP
                case 0x00: tStates += 8; break;

                // ADD IX, BC
                case 0x09: ix = ADD(ix, bc); tStates += 4; break;

                // ADD IX, DE
                case 0x19: ix = ADD(ix, de); tStates += 4; break;

                // LD IX, **
                case 0x21: ix = GetNextWord(); tStates += 14; break;

                // LD (**), IX
                case 0x22: memory.WriteWord(GetNextWord(), ix); tStates += 20; break;

                // INC IX
                case 0x23: ix++; tStates += 10; break;

                // INC IXH
                case 0x24: ixh = INC(ixh); tStates += 4; break;

                // DEC IXH
                case 0x25: ixh = DEC(ixh); tStates += 4; break;

                // LD IXH, *
                case 0x26: ixh = GetNextByte(); tStates += 11; break;

                // ADD IX, IX
                case 0x29: ix = ADD(ix, ix); tStates += 4; break;

                // LD IX, (**)
                case 0x2A: ix = memory.ReadWord(GetNextWord()); tStates += 20; break;

                // DEC IX
                case 0x2B: ix--; tStates += 10; break;

                // INC IXH
                case 0x2C: ixl = INC(ixl); tStates += 4; break;

                // DEC IXH
                case 0x2D: ixl = DEC(ixl); tStates += 4; break;

                // LD IXH, *
                case 0x2E: ixl = GetNextByte(); tStates += 11; break;

                // INC (IX+*)
                case 0x34:
                    addr = DisplacedIX;
                    memory.WriteByte(addr, INC(memory.ReadByte(addr)));
                    tStates += 19;
                    break;

                // DEC (IX+*)
                case 0x35:
                    addr = DisplacedIX;
                    memory.WriteByte(addr, DEC(memory.ReadByte(addr)));
                    tStates += 19;
                    break;

                // LD (IX+*), *
                case 0x36: memory.WriteByte(DisplacedIX, GetNextByte()); tStates += 19; break;

                // ADD IX, SP
                case 0x39: ix = ADD(ix, sp); tStates += 4; break;

                // LD B, IXH
                case 0x44: b = ixh; tStates += 8; break;

                // LD B, IXL
                case 0x45: b = ixl; tStates += 8; break;

                // LD B, (IX+*)
                case 0x46: b = memory.ReadByte(DisplacedIX); tStates += 19; break;

                // LD C, IXH
                case 0x4C: c = ixh; tStates += 8; break;

                // LD C, IXL
                case 0x4D: c = ixl; tStates += 8; break;

                // LD C, (IX+*)
                case 0x4E: c = memory.ReadByte(DisplacedIX); tStates += 19; break;

                // LD D, IXH
                case 0x54: d = ixh; tStates += 8; break;

                // LD D, IXL
                case 0x55: d = ixl; tStates += 8; break;

                // LD D, (IX+*)
                case 0x56: d = memory.ReadByte(DisplacedIX); tStates += 19; break;

                // LD E, IXH
                case 0x5C: e = ixh; tStates += 8; break;

                // LD E, IXL
                case 0x5D: e = ixl; tStates += 8; break;

                // LD E, (IX+*)
                case 0x5E: e = memory.ReadByte(DisplacedIX); tStates += 19; break;

                // LD IXH, B
                case 0x60: ixh = b; tStates += 8; break;

                // LD IXH, C
                case 0x61: ixh = c; tStates += 8; break;

                // LD IXH, D
                case 0x62: ixh = d; tStates += 8; break;

                // LD IXH, E
                case 0x63: ixh = e; tStates += 8; break;

                // LD IXH, IXH
                case 0x64: tStates += 8; break;

                // LD IXH, IXL
                case 0x65: ixh = ixl; tStates += 8; break;

                // LD H, (IX+*)
                case 0x66: h = memory.ReadByte(DisplacedIX); tStates += 19; break;

                // LD IXH, A
                case 0x67: ixh = a; tStates += 8; break;

                // LD IXL, B
                case 0x68: ixl = b; tStates += 8; break;

                // LD IXL, C
                case 0x69: ixl = c; tStates += 8; break;

                // LD IXL, D
                case 0x6A: ixl = d; tStates += 8; break;

                // LD IXL, E
                case 0x6B: ixl = e; tStates += 8; break;

                // LD IXL, IXH
                case 0x6C: ixl = ixh; tStates += 8; break;

                // LD IXL, IXL
                case 0x6D: tStates += 8; break;

                // LD L, (IX+*)
                case 0x6E: l = memory.ReadByte(DisplacedIX); tStates += 19; break;

                // LD IXL, A
                case 0x6F: ixl = a; tStates += 8; break;

                // LD (IX+*), B
                case 0x70: memory.WriteByte(DisplacedIX, b); tStates += 19; break;

                // LD (IX+*), C
                case 0x71: memory.WriteByte(DisplacedIX, c); tStates += 19; break;

                // LD (IX+*), D
                case 0x72: memory.WriteByte(DisplacedIX, d); tStates += 19; break;

                // LD (IX+*), E
                case 0x73: memory.WriteByte(DisplacedIX, e); tStates += 19; break;

                // LD (IX+*), H
                case 0x74: memory.WriteByte(DisplacedIX, h); tStates += 19; break;

                // LD (IX+*), L
                case 0x75: memory.WriteByte(DisplacedIX, l); tStates += 19; break;

                // LD (IX+*), A
                case 0x77: memory.WriteByte(DisplacedIX, a); tStates += 19; break;

                // LD A, IXH
                case 0x7C: a = ixh; tStates += 8; break;

                // LD A, IXL
                case 0x7D: a = ixl; tStates += 8; break;

                // LD A, (IX+*)
                case 0x7E: a = memory.ReadByte(DisplacedIX); tStates += 19; break;

                // ADD A, IXH
                case 0x84: a = ADD(a, ixh); tStates += 4; break;

                // ADD A, IXL
                case 0x85: a = ADD(a, ixl); tStates += 4; break;

                // ADD A, (IX+*)
                case 0x86: a = ADD(a, memory.ReadByte(DisplacedIX)); tStates += 15; break;

                // ADC A, IXH
                case 0x8C: a = ADC(a, ixh); tStates += 4; break;

                // ADC A, IXL
                case 0x8D: a = ADC(a, ixl); tStates += 4; break;

                // ADC A, (IX+*)
                case 0x8E: a = ADC(a, memory.ReadByte(DisplacedIX)); tStates += 15; break;

                // SUB IXH
                case 0x94: a = SUB(a, ixh); tStates += 4; break;

                // SUB IXL
                case 0x95: a = SUB(a, ixl); tStates += 4; break;

                // SUB (IX+*)
                case 0x96: a = SUB(a, memory.ReadByte(DisplacedIX)); tStates += 15; break;

                // SBC A, IXH
                case 0x9C: a = SBC(a, ixh); tStates += 4; break;

                // SBC A, IXL
                case 0x9D: a = SBC(a, ixl); tStates += 4; break;

                // SBC A, (IX+*)
                case 0x9E: a = SBC(a, memory.ReadByte(DisplacedIX)); tStates += 15; break;

                // AND IXH
                case 0xA4: a = AND(a, ixh); tStates += 4; break;

                // AND IXL
                case 0xA5: a = AND(a, ixl); tStates += 4; break;

                // AND (IX+*)
                case 0xA6: a = AND(a, memory.ReadByte(DisplacedIX)); tStates += 15; break;

                // XOR (IX+*)
                case 0xAE: a = XOR(a, memory.ReadByte(DisplacedIX)); tStates += 15; break;

                // XOR IXH
                case 0xAC: a = XOR(a, ixh); tStates += 4; break;

                // XOR IXL
                case 0xAD: a = XOR(a, ixl); tStates += 4; break;

                // OR IXH
                case 0xB4: a = OR(a, ixh); tStates += 4; break;

                // OR IXL
                case 0xB5: a = OR(a, ixl); tStates += 4; break;

                // OR (IX+*)
                case 0xB6: a = OR(a, memory.ReadByte(DisplacedIX)); tStates += 15; break;

                // CP IXH
                case 0xBC: CP(ixh); tStates += 4; break;

                // CP IXL
                case 0xBD: CP(ixl); tStates += 4; break;

                // CP (IX+*)
                case 0xBE: CP(memory.ReadByte(DisplacedIX)); tStates += 15; break;

                // bitwise instructions
                case 0xCB: DecodeDDCBOpCode(); break;

                // POP IX
                case 0xE1: ix = POP(); tStates += 14; break;

                // EX (SP), IX
                case 0xE3: var temp = memory.ReadWord(sp); memory.WriteWord(sp, ix); ix = temp; tStates += 23; break;

                // PUSH IX
                case 0xE5: PUSH(ix); tStates += 15; break;

                // JP (IX)
                // note that the brackets in the instruction are an eccentricity, the result 
                // should be ix rather than the contents of addr(ix)
                case 0xE9: pc = ix; tStates += 8; break;

                // LD SP, IX
                case 0xF9: sp = ix; tStates += 10; break;

                default:
                    throw new InvalidOperationException($"Opcode DD{opCode:X2} not understood. ");

            }
        }

        private void DecodeDDCBOpCode()
        {
            // format is DDCB[addr][opcode]
            ushort addr = DisplacedIX;
            var opCode = GetNextByte();

            // BIT
            if ((opCode >= 0x40) && (opCode <= 0x7F))
            {
                var val = memory.ReadByte(addr);
                fZ = !IsBitSet(val, (opCode & 0x38) >> 3);
                fH = true;
                fN = false;
                f5 = IsBitSet(val, 5);
                f3 = IsBitSet(val, 3);
                tStates += 20;
                return;
            }

            else
            {
                switch (opCode)
                {
                    // RLC (IX+*)
                    case 0x06: memory.WriteByte(addr, RLC(memory.ReadByte(addr))); break;

                    // RRC (IX+*)
                    case 0x0E: memory.WriteByte(addr, RRC(memory.ReadByte(addr))); break;

                    // RL (IX+*)
                    case 0x16: memory.WriteByte(addr, RL(memory.ReadByte(addr))); break;

                    // RR (IX+*)
                    case 0x1E: memory.WriteByte(addr, RR(memory.ReadByte(addr))); break;

                    // SLA (IX+*)
                    case 0x26: memory.WriteByte(addr, SLA(memory.ReadByte(addr))); break;

                    // SRA (IX+*)
                    case 0x2E: memory.WriteByte(addr, SRA(memory.ReadByte(addr))); break;

                    // SLL (IX+*)
                    case 0x36: memory.WriteByte(addr, SLL(memory.ReadByte(addr))); break;

                    // SRL (IX+*)
                    case 0x3E: memory.WriteByte(addr, SRL(memory.ReadByte(addr))); break;

                    // RES n, (IX+*)
                    case 0x86:
                    case 0x8E:
                    case 0x96:
                    case 0x9E:
                    case 0xA6:
                    case 0xAE:
                    case 0xB6:
                    case 0xBE:
                        memory.WriteByte(addr, ResetBit(memory.ReadByte(addr), (opCode & 0x38) >> 3)); break;

                    // SET n, (IX+*)
                    case 0xC6:
                    case 0xCE:
                    case 0xD6:
                    case 0xDE:
                    case 0xE6:
                    case 0xEE:
                    case 0xF6:
                    case 0xFE:
                        memory.WriteByte(addr, SetBit(memory.ReadByte(addr), (opCode & 0x38) >> 3)); break;

                    default:
                        throw new InvalidOperationException($"Opcode DDCB**{opCode:X2} not understood. ");
                };

                tStates += 23;
            }
        }

        private void DecodeFDCBOpCode()
        {
            // format is FDCB[addr][opcode]
            ushort addr = DisplacedIY;
            var opCode = GetNextByte();

            // BIT
            if ((opCode >= 0x40) && (opCode <= 0x7F))
            {
                var val = memory.ReadByte(addr);
                fZ = !IsBitSet(val, (opCode & 0x38) >> 3);
                fH = true;
                fN = false;
                f5 = IsBitSet(val, 5);
                f3 = IsBitSet(val, 3);
                tStates += 20;
                return;
            }
            else
            {

                switch (opCode)
                {
                    // RLC (IY+*)
                    case 0x06: memory.WriteByte(addr, RLC(memory.ReadByte(addr))); break;

                    // RRC (IY+*)
                    case 0x0E: memory.WriteByte(addr, RRC(memory.ReadByte(addr))); break;

                    // RL (IY+*)
                    case 0x16: memory.WriteByte(addr, RL(memory.ReadByte(addr))); break;

                    // RR (IY+*)
                    case 0x1E: memory.WriteByte(addr, RR(memory.ReadByte(addr))); break;

                    // SLA (IY+*)
                    case 0x26: memory.WriteByte(addr, SLA(memory.ReadByte(addr))); break;

                    // SRA (IY+*)
                    case 0x2E: memory.WriteByte(addr, SRA(memory.ReadByte(addr))); break;

                    // SLL (IY+*)
                    case 0x36: memory.WriteByte(addr, SLL(memory.ReadByte(addr))); break;

                    // SRL (IY+*)
                    case 0x3E: memory.WriteByte(addr, SRL(memory.ReadByte(addr))); break;

                    // RES n, (IY+*)
                    case 0x86:
                    case 0x8E:
                    case 0x96:
                    case 0x9E:
                    case 0xA6:
                    case 0xAE:
                    case 0xB6:
                    case 0xBE:
                        memory.WriteByte(addr, ResetBit(memory.ReadByte(addr), (opCode & 0x38) >> 3)); break;

                    // SET n, (IY+*)
                    case 0xC6:
                    case 0xCE:
                    case 0xD6:
                    case 0xDE:
                    case 0xE6:
                    case 0xEE:
                    case 0xF6:
                    case 0xFE:
                        memory.WriteByte(addr, SetBit(memory.ReadByte(addr), (opCode & 0x38) >> 3)); break;

                    default:
                        throw new InvalidOperationException($"Opcode FDCB**{opCode:X2} not understood. ");
                };

                tStates += 23;
            }
        }

        private void DecodeFDOpcode()
        {
            byte opCode = GetNextByte();
            ushort addr;

            switch (opCode)
            {
                // NOP
                case 0x00: tStates += 8; break; // T-State is a guess - I can't find this documented

                // ADD IY, BC
                case 0x09: iy = ADD(iy, bc); tStates += 4; break;

                // ADD IY, DE
                case 0x19: iy = ADD(iy, de); tStates += 4; break;

                // LD IY, **
                case 0x21: iy = GetNextWord(); tStates += 14; break;

                // LD (**), IY
                case 0x22: memory.WriteWord(GetNextWord(), iy); tStates += 20; break;

                // INC IY
                case 0x23: iy++; tStates += 10; break;

                // INC IYH
                case 0x24: iyh = INC(iyh); tStates += 4; break;

                // DEC IYH
                case 0x25: iyh = DEC(iyh); tStates += 4; break;

                // LD IYH, *
                case 0x26: iyh = GetNextByte(); tStates += 11; break;

                // ADD IY, IY
                case 0x29: iy = ADD(iy, iy); tStates += 4; break;

                // LD IY, (**)
                case 0x2A: iy = memory.ReadWord(GetNextWord()); tStates += 20; break;

                // DEC IY
                case 0x2B: iy--; tStates += 10; break;

                // INC IYH
                case 0x2C: iyl = INC(iyl); tStates += 4; break;

                // DEC IYH
                case 0x2D: iyl = DEC(iyl); tStates += 4; break;

                // LD IYH, *
                case 0x2E: iyl = GetNextByte(); tStates += 11; break;

                // INC (IY+*)
                case 0x34:
                    addr = DisplacedIY;
                    memory.WriteByte(addr, INC(memory.ReadByte(addr)));
                    tStates += 19;
                    break;

                // DEC (IY+*)
                case 0x35:
                    addr = DisplacedIY;
                    memory.WriteByte(addr, DEC(memory.ReadByte(addr)));
                    tStates += 19;
                    break;

                // LD (IY+*), *
                case 0x36: memory.WriteByte(DisplacedIY, GetNextByte()); tStates += 19; break;

                // ADD IY, SP
                case 0x39: iy = ADD(iy, sp); tStates += 4; break;

                // LD B, IYH
                case 0x44: b = iyh; tStates += 8; break;

                // LD B, IYL
                case 0x45: b = iyl; tStates += 8; break;

                // LD B, (IY+*)
                case 0x46: b = memory.ReadByte(DisplacedIY); tStates += 19; break;

                // LD C, IYH
                case 0x4C: c = iyh; tStates += 8; break;

                // LD C, IYL
                case 0x4D: c = iyl; tStates += 8; break;

                // LD C, (IY+*)
                case 0x4E: c = memory.ReadByte(DisplacedIY); tStates += 19; break;

                // LD D, IYH
                case 0x54: d = iyh; tStates += 8; break;

                // LD D, IYL
                case 0x55: d = iyl; tStates += 8; break;

                // LD D, (IY+*)
                case 0x56: d = memory.ReadByte(DisplacedIY); tStates += 19; break;

                // LD E, IYH
                case 0x5C: e = iyh; tStates += 8; break;

                // LD E, IYL
                case 0x5D: e = iyl; tStates += 8; break;

                // LD E, (IY+*)
                case 0x5E: e = memory.ReadByte(DisplacedIY); tStates += 19; break;

                // LD IYH, B
                case 0x60: iyh = b; tStates += 8; break;

                // LD IYH, C
                case 0x61: iyh = c; tStates += 8; break;

                // LD IYH, D
                case 0x62: iyh = d; tStates += 8; break;

                // LD IYH, E
                case 0x63: iyh = e; tStates += 8; break;

                // LD IYH, IYH
                case 0x64: tStates += 8; break;

                // LD IYH, IYL
                case 0x65: iyh = iyl; tStates += 8; break;

                // LD H, (IY+*)
                case 0x66: h = memory.ReadByte(DisplacedIY); tStates += 19; break;

                // LD IYH, A
                case 0x67: iyh = a; tStates += 8; break;

                // LD IYL, B
                case 0x68: iyl = b; tStates += 8; break;

                // LD IYL, C
                case 0x69: iyl = c; tStates += 8; break;

                // LD IYL, D
                case 0x6A: iyl = d; tStates += 8; break;

                // LD IYL, E
                case 0x6B: iyl = e; tStates += 8; break;

                // LD IYL, IYH
                case 0x6C: iyl = iyh; tStates += 8; break;

                // LD IYL, IYL
                case 0x6D: tStates += 8; break;

                // LD L, (IY+*)
                case 0x6E: l = memory.ReadByte(DisplacedIY); tStates += 19; break;

                // LD IYL, A
                case 0x6F: iyl = a; tStates += 8; break;

                // LD (IY+*), B
                case 0x70: memory.WriteByte(DisplacedIY, b); tStates += 19; break;

                // LD (IY+*), C
                case 0x71: memory.WriteByte(DisplacedIY, c); tStates += 19; break;

                // LD (IY+*), D
                case 0x72: memory.WriteByte(DisplacedIY, d); tStates += 19; break;

                // LD (IY+*), E
                case 0x73: memory.WriteByte(DisplacedIY, e); tStates += 19; break;

                // LD (IY+*), H
                case 0x74: memory.WriteByte(DisplacedIY, h); tStates += 19; break;

                // LD (IY+*), L
                case 0x75: memory.WriteByte(DisplacedIY, l); tStates += 19; break;

                // LD (IY+*), A
                case 0x77: memory.WriteByte(DisplacedIY, a); tStates += 19; break;

                // LD A, IYH
                case 0x7C: a = iyh; tStates += 8; break;

                // LD A, IYL
                case 0x7D: a = iyl; tStates += 8; break;

                // LD A, (IY+*)
                case 0x7E: a = memory.ReadByte(DisplacedIY); tStates += 19; break;

                // ADD A, IYH
                case 0x84: a = ADD(a, iyh); tStates += 4; break;

                // ADD A, IYL
                case 0x85: a = ADD(a, iyl); tStates += 4; break;

                // ADD A, (IY+*)
                case 0x86: a = ADD(a, memory.ReadByte(DisplacedIY)); tStates += 15; break;

                // ADC A, IYH
                case 0x8C: a = ADC(a, iyh); tStates += 4; break;

                // ADC A, IYL
                case 0x8D: a = ADC(a, iyl); tStates += 4; break;

                // ADC A, (IY+*)
                case 0x8E: a = ADC(a, memory.ReadByte(DisplacedIY)); tStates += 15; break;

                // SUB IYH
                case 0x94: a = SUB(a, iyh); tStates += 4; break;

                // SUB IYL
                case 0x95: a = SUB(a, iyl); tStates += 4; break;

                // SUB (IY+*)
                case 0x96: a = SUB(a, memory.ReadByte(DisplacedIY)); tStates += 15; break;

                // SBC A, IYH
                case 0x9C: a = SBC(a, iyh); tStates += 4; break;

                // SBC A, IYL
                case 0x9D: a = SBC(a, iyl); tStates += 4; break;

                // SBC A, (IY+*)
                case 0x9E: a = SBC(a, memory.ReadByte(DisplacedIY)); tStates += 15; break;

                // AND IYH
                case 0xA4: a = AND(a, iyh); tStates += 4; break;

                // AND IYL
                case 0xA5: a = AND(a, iyl); tStates += 4; break;

                // AND (IY+*)
                case 0xA6: a = AND(a, memory.ReadByte(DisplacedIY)); tStates += 15; break;

                // XOR (IY+*)
                case 0xAE: a = XOR(a, memory.ReadByte(DisplacedIY)); tStates += 15; break;

                // XOR IYH
                case 0xAC: a = XOR(a, iyh); tStates += 4; break;

                // XOR IYL
                case 0xAD: a = XOR(a, iyl); tStates += 4; break;

                // OR IYH
                case 0xB4: a = OR(a, iyh); tStates += 4; break;

                // OR IYL
                case 0xB5: a = OR(a, iyl); tStates += 4; break;

                // OR (IY+*)
                case 0xB6: a = OR(a, memory.ReadByte(DisplacedIY)); tStates += 15; break;

                // CP IYH
                case 0xBC: CP(iyh); tStates += 4; break;

                // CP IYL
                case 0xBD: CP(iyl); tStates += 4; break;

                // CP (IY+*)
                case 0xBE: CP(memory.ReadByte(DisplacedIY)); tStates += 15; break;

                // bitwise instructions
                case 0xCB: DecodeFDCBOpCode(); break;

                // POP IY
                case 0xE1: iy = POP(); tStates += 14; break;

                // EX (SP), IY
                case 0xE3: var temp = memory.ReadWord(sp); memory.WriteWord(sp, iy); iy = temp; tStates += 23; break;

                // PUSH IY
                case 0xE5: PUSH(iy); tStates += 15; break;

                // JP (IY)
                // note that the brackets in the instruction are an eccentricity, the result 
                // should be iy rather than the contents of addr(iy)
                case 0xE9: pc = iy; tStates += 8; break; 

                // LD SP, IY
                case 0xF9: sp = iy; tStates += 10; break;

                default:
                    throw new InvalidOperationException($"Opcode FD{opCode:X2} not understood. ");

            }
        }

        private byte GetNextByte() => memory.ReadByte(pc++);

        private ushort GetNextWord()
        {
            var wordRead = memory.ReadWord(pc);
            pc += 2;
            return wordRead;
        }


        private void rot(int operation, int register)
        {
            Func<byte, byte> rotFunction;

            switch (operation)
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
                    throw new ArgumentOutOfRangeException(nameof(operation), operation, "Operation must map to a valid rotation operation.");
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
                    throw new ArgumentOutOfRangeException(nameof(register), register, "Field register must map to a valid Z80 register.");
            }
        }

        private ushort DisplacedIX => (ushort)(ix + (ushort)((sbyte)GetNextByte()));
        private ushort DisplacedIY => (ushort)(iy + (ushort)((sbyte)GetNextByte()));

        private void Swap<T>(ref T x, ref T y)
        {
            var temp = y;
            y = x;
            x = temp;
        }
    }
}
