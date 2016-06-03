using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ProjectCambridge.EmulatorCore
{
    // TODO: CP should be SUB with the result thrownaway

    public partial class Z80
    {
        /* 
         * explanations of each command: http://clrhome.org/table/
         * helpful decoder shortcuts: http://z80.info/decoding.htm
         * and http://z80.info/z80code.txt
         */
        public bool ExecuteNextInstruction()
        {
            byte opCode = GetNextByte();
            switch (opCode)
            {
                // NOP
                case 0x00: break;

                // LD BC, **
                case 0x01: bc = GetNextWord(); break;

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
                case 0x07: RLCA(); break;

                // EX AF, AF'
                case 0x08: Swap(ref a, ref a_); Swap(ref f, ref f_); break;

                // ADD HL, BC
                case 0x09: hl = ADD(hl, bc); break;

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
                case 0x0F: RRCA(); break;

                // DJNZ *
                case 0x10: b--; if (b != 0) { JR((sbyte)GetNextByte()); } else { pc++; } break;

                // LD DE, **
                case 0x11: de = GetNextWord(); break;

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
                case 0x17: RLA(); break;

                // JR *
                case 0x18: JR((sbyte)GetNextByte()); break;

                // ADD HL, DE
                case 0x19: hl = ADD(hl, de); break;

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
                case 0x1F: RRA(); break;

                // JR NZ, *
                case 0x20: if (!fZ) { JR((sbyte)GetNextByte()); } else { pc++; } break;

                // LD HL, **
                case 0x21: hl = GetNextWord(); break;

                // LD (**), HL
                case 0x22: memory.WriteWord(GetNextWord(), hl); break;

                // INC HL
                case 0x23: hl++; break;

                // INC H
                case 0x24: h = INC(h); break;

                // DEC H
                case 0x25: h = DEC(h); break;

                // LD H, *
                case 0x26: h = GetNextByte(); break;

                // DAA
                case 0x27: DAA(); break;

                // JR Z, *
                case 0x28: if (fZ) { JR((sbyte)GetNextByte()); } else { pc++; } break;

                // ADD HL, HL
                case 0x29: hl = ADD(hl, hl); break;

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
                case 0x2F: CPL(); break;

                // JR NC, *
                case 0x30: if (!fC) { JR((sbyte)GetNextByte()); } else { pc++; } break;

                // LD SP, **
                case 0x31: sp = GetNextWord(); break;

                // LD (**), A
                case 0x32: memory.WriteByte(GetNextWord(), a); break;

                // INC SP
                case 0x33: sp++; break;

                // INC (HL)
                case 0x34: memory.WriteByte(hl, INC(memory.ReadByte(hl))); break;

                // DEC (HL)
                case 0x35: memory.WriteByte(hl, DEC(memory.ReadByte(hl))); break;

                // LD (HL), *
                case 0x36: memory.WriteByte(hl, GetNextByte()); break;

                // SCF
                case 0x37: SCF(); break;

                // JR C, *
                case 0x38: if (fC) { JR((sbyte)GetNextByte()); } else { pc++; } break;

                // ADD HL, SP
                case 0x39: hl = ADD(hl, sp); break;

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
                case 0x3F: CCF(); break;

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
                case 0x76: return false;

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
                case 0x86: a = ADD(a, memory.ReadByte(hl)); break;

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
                case 0x8E: a = ADC(a, memory.ReadByte(hl)); break;

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
                case 0x96: a = SUB(a, memory.ReadByte(hl)); break;

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
                case 0x9E: a = SBC(a, memory.ReadByte(hl)); break;

                // SBC A, A
                case 0x9F: a = SBC(a, a); break;

                // AND B
                case 0xA0: a = AND(a, b); break;

                // AND C
                case 0xA1: a = AND(a, b); break;

                // AND D
                case 0xA2: a = AND(a, b); break;

                // AND E
                case 0xA3: a = AND(a, b); break;

                // AND H
                case 0xA4: a = AND(a, b); break;

                // AND L
                case 0xA5: a = AND(a, b); break;

                // AND (HL)
                case 0xA6: a = AND(a, memory.ReadByte(hl)); break;

                // AND A
                case 0xA7: a = AND(a, a); break;

                // XOR B
                case 0xA8: a = XOR(a, b); break;

                // XOR C
                case 0xA9: a = XOR(a, b); break;

                // XOR D
                case 0xAA: a = XOR(a, b); break;

                // XOR E
                case 0xAB: a = XOR(a, b); break;

                // XOR H
                case 0xAC: a = XOR(a, b); break;

                // XOR L
                case 0xAD: a = XOR(a, b); break;

                // XOR (HL)
                case 0xAE: a = XOR(a, memory.ReadByte(hl)); break;

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
                case 0xB6: a = OR(a, memory.ReadByte(hl)); break;

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
                case 0xBE: CP(memory.ReadByte(hl)); break;

                // CP A
                case 0xBF: CP(a); break;

                // RET NZ
                case 0xC0: if (!fZ) { pc = POP(); } break;

                // POP BC
                case 0xC1: bc = POP(); break;

                // JP NZ, **
                case 0xC2: if (!fZ) { pc = GetNextWord(); } else { pc += 2; } break;

                // JP **
                case 0xC3: pc = GetNextWord(); break;

                // CALL NZ, **
                case 0xC4: if (!fZ) { CALL(); } else { pc += 2; } break;

                // PUSH BC
                case 0xC5: PUSH(bc); break;

                // ADD A, *
                case 0xC6: a = ADD(a, GetNextByte()); break;

                // RST 00h
                case 0xC7: RST(0x00); break;

                // RET Z
                case 0xC8: if (fZ) { pc = POP(); } break;

                // RET
                case 0xC9: pc = POP(); break;

                // JP Z, **
                case 0xCA: if (fZ) pc = GetNextWord(); else { pc += 2; } break;

                // BITWISE INSTRUCTIONS
                case 0xCB: DecodeCBOpcode(); break;

                // CALL Z, **
                case 0xCC: if (fZ) { CALL(); } else { pc += 2; } break;

                // CALL **
                case 0xCD: CALL(); break;

                // ADC A, *
                case 0xCE: a = ADC(a, GetNextByte()); break;

                // RST 08h
                case 0xCF: RST(0x08); break;

                // RET NC
                case 0xD0: if (!fC) pc = POP(); break;

                // POP DE
                case 0xD1: de = POP(); break;

                // JP NC, **
                case 0xD2: if (!fC) { pc = GetNextWord(); } else { pc += 2; } break;

                // OUT (*), A
                case 0xD3: output[GetNextByte()] = a; break;

                // CALL NC, **
                case 0xD4: if (!fC) { CALL(); } else { pc += 2; } break;

                // PUSH DE
                case 0xD5: PUSH(de); break;

                // SUB *
                case 0xD6: a = SUB(a, GetNextByte()); break;

                // RST 10h
                case 0xD7: RST(0x10); break;

                // RET C
                case 0xD8: if (fC) pc = POP(); break;

                // EXX
                case 0xD9: Swap(ref b, ref b_); Swap(ref c, ref c_); Swap(ref d, ref d_); Swap(ref e, ref e_); Swap(ref h, ref h_); Swap(ref l, ref l_); break;

                // JP C, **
                case 0xDA: if (fC) { pc = GetNextWord(); } else { pc += 2; } break;

                // IN A, (**)
                case 0xDB: memory.ReadByte(GetNextWord()); break;

                // CALL C, **
                case 0xDC: if (fC) { CALL(); } else { pc += 2; } break;

                // IX OPERATIONS
                case 0xDD: DecodeDDOpcode(); break;

                // SBC A, *
                case 0xDE: a = SBC(a, GetNextByte()); break;

                // RST 18h
                case 0xDF: RST(0x18); break;

                // RET PO
                case 0xE0: if (!fPV) { pc = POP(); } break;

                // POP HL
                case 0xE1: hl = POP(); break;

                // JP PO, **
                case 0xE2: if (!fPV) { pc = GetNextWord(); } else { pc += 2; } break;

                // EX (SP), HL
                case 0xE3: var temp = hl; hl = memory.ReadWord(sp); memory.WriteWord(sp, temp); break;

                // CALL PO, **
                case 0xE4: if (!fPV) { CALL(); } else { pc += 2; } break;

                // PUSH HL
                case 0xE5: PUSH(hl); break;

                // AND *
                case 0xE6: a = AND(a, GetNextByte()); break;

                // RST 20h
                case 0xE7: RST(0x20); break;

                // RET PE
                case 0xE8: if (fPV) { pc = POP(); } break;

                // JP (HL)
                case 0xE9: pc = memory.ReadWord(hl); break;

                // JP PE, **
                case 0xEA: if (fPV) { pc = GetNextWord(); } else { pc += 2; } break;

                // EX DE, HL
                case 0xEB: Swap(ref d, ref h); Swap(ref e, ref l); break;

                // CALL PE, **
                case 0xEC: if (fPV) { CALL(); } else { pc += 2; } break;

                // EXTD INSTRUCTIONS
                case 0xED: DecodeEDOpcode(); break;

                // XOR *
                case 0xEE: a = XOR(a, GetNextByte()); break;

                // RST 28h
                case 0xEF: RST(0x28); break;

                // RET P
                case 0xF0: if (!fS) pc = POP(); break;

                // POP AF
                case 0xF1: af = POP(); break;

                // JP P, **
                case 0xF2: if (!fS) { pc = GetNextWord(); } else { pc += 2; } break;

                // DI
                case 0xF3: iff1 = false; iff2 = false; break;

                // CALL P, **
                case 0xF4: if (!fS) { CALL(); } else { pc += 2; } break;

                // PUSH AF
                case 0xF5: PUSH(af); break;

                // OR *
                case 0xF6: a = OR(a, GetNextByte()); break;

                // RST 30h
                case 0xF7: RST(0x30); break;

                // RET M
                case 0xF8: if (fS) { pc = POP(); } break;

                // LD SP, HL
                case 0xF9: sp = hl; break;

                // JP M, **
                case 0xFA: if (fS) { pc = GetNextWord(); } break;

                // EI
                case 0xFB: break;

                // CALL M, **
                case 0xFC: if (fS) { CALL(); } else { pc += 2; } break;

                // IY INSTRUCTIONS
                case 0xFD: DecodeFDOpcode(); break;

                // CP *
                case 0xFE: CP(GetNextByte()); break;

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
        }

        private void DecodeEDOpcode()
        {
            byte opCode = GetNextByte();

            switch (opCode)
            {
                // IN B, (C)
                case 0x40: break;

                // OUT (C), B
                case 0x41: break;

                // SBC HL, BC
                case 0x42: hl = SBC(hl, bc);  break;

                // LD (**), BC
                case 0x43: memory.WriteWord(GetNextWord(), bc); break;

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
                    pc = POP(); iff1 = iff2; break;

                // IM 0
                case 0x46: break;

                // LD I, A
                case 0x47: i = a; break;

                // IN C, (C)
                case 0x48: break;

                // OUT C, (C)
                case 0x49: break;

                // ADC HL, BC
                case 0x4A: hl = ADC(hl, bc);  break;

                // LD BC, (**)
                case 0x4B: bc = memory.ReadWord(GetNextWord()); break;

                // RETI
                case 0x4D: break;

                // LD R, A
                case 0x4F: r = a; break;

                // IN D, (C)
                case 0x50: break;

                // OUT (C), D
                case 0x51: break;

                // SBC HL, DE
                case 0x52: hl = SBC(hl, de); break;

                // LD (**), DE
                case 0x53: memory.WriteWord(GetNextWord(), de); break;

                // LD A, I
                case 0x57: a = i; fS = IsSign8(i); fZ = IsZero(i); fH = false; fPV = iff2; fN = false; break;

                // IN E, (C)
                case 0x58: break;

                // OUT (C), E
                case 0x59: break;

                // ADC HL, DE
                case 0x5A: hl = ADC(hl, de); break;

                // LD DE, (**)
                case 0x5B: de = memory.ReadWord(GetNextWord()); break;

                // IM 2
                case 0x5E:
                case 0x7E:
                    break;

                // LD A, R
                case 0x5F: a = r; fS = IsSign8(r); fZ = IsZero(r); fH = false; fPV = iff2; fN = false; break;

                // IN H, (C)
                case 0x60: break;

                // OUT (C), H
                case 0x61: break;

                // SBC HL, HL
                case 0x62: hl = SBC(hl, hl); break;

                // LD (**), HL
                case 0x63: memory.WriteWord(GetNextWord(), hl); break;

                // RRD
                case 0x67: RRD(); break;

                // IN L, (C)
                case 0x68: break;

                // OUT (C), L
                case 0x69: break;

                // ADD HL, HL
                case 0x6A: hl = ADD(hl, hl); break;

                // LD HL, (**)
                case 0x6B: hl = memory.ReadWord(GetNextWord()); break;

                // RLD
                case 0x6F: RLD(); break;

                // SBC HL, SP
                case 0x72: hl = SBC(hl, sp); break;

                // LD (**), SP
                case 0x73: memory.WriteWord(GetNextWord(), sp); break;

                // IN A, (C)
                case 0x78: break;

                // OUT (C), A
                case 0x79: break;

                // ADC HL, SP
                case 0x7A: hl = ADC(hl, sp); break;

                // LD SP, (**)
                case 0x7B: sp = GetNextWord(); break;

                // LDI
                case 0xA0: memory.WriteByte(de, memory.ReadByte(hl)); de++; hl++; bc--; fH = fN = false; fPV = (bc != 0); break;

                // CPI
                case 0xA1: CPI(); break;

                // INI
                case 0xA2: break;

                // OUTI
                case 0xA3: break;

                // LDD
                case 0xA8: memory.WriteByte(de, memory.ReadByte(hl)); de--; hl--; bc--; fH = fN = false; fPV = (bc != 0); break;

                // CPD
                case 0xA9: CPD(); break;

                // IND
                case 0xAA: break;

                // OUTD
                case 0xAB: break;

                // LDIR
                case 0xB0: memory.WriteByte(de, memory.ReadByte(hl)); de++; hl++; bc--; if (bc > 0) pc -= 2; fH = fPV = fN = false; break;

                // CPIR
                case 0xB1: CPIR(); break;

                // INIR
                case 0xB2: break;

                // OTIR
                case 0xB3: break;

                // LDDR
                case 0xB8: memory.WriteByte(de, memory.ReadByte(hl)); de--; hl--; bc--; if (bc > 0) pc -= 2; fH = fPV = fN = false; break;

                // CPDR
                case 0xB9: CPDR(); break;

                // INDR
                case 0xBA: break;

                // OTDR
                case 0xBB: break;

                default:
                    throw new InvalidOperationException($"Opcode ED{opCode:X2} not understood. ");
            }
        }

        private void DecodeDDOpcode()
        {
            byte opCode = GetNextByte();
            ushort addr = 0;

            switch (opCode)
            {
                // ADD IX, BC
                case 0x09: ix += bc; break;

                // ADD IX, DE
                case 0x19: ix += de; break;

                // LD IX, **
                case 0x21: ix = GetNextWord(); break;

                // LD (**), IX
                case 0x22: memory.WriteWord(GetNextWord(), ix); break;

                // INC IX
                case 0x23: ix++; break;

                // ADD IX, IX
                case 0x29: ix += ix; break;

                // LD IX, (**)
                case 0x2A: ix = memory.ReadWord(GetNextWord()); break;

                // DEC IX
                case 0x2B: ix--; break;

                // INC (IX+*)
                case 0x34:
                    addr = (ushort)(ix + GetNextByte());
                    memory.WriteByte(addr, INC(memory.ReadByte(addr)));
                    break;

                // DEC (IX+*)
                case 0x35:
                    addr = (ushort)(ix + GetNextByte());
                    memory.WriteByte(addr, DEC(memory.ReadByte(addr)));
                    break;

                // LD (IX+*), *
                case 0x36: addr = (ushort)(ix + GetNextByte()); memory.WriteByte(addr, GetNextByte()); break;

                // ADD IX, SP
                case 0x39: ix += sp; break;

                // LD B, (IX+*)
                case 0x46: addr = (ushort)(ix + GetNextByte()); b = memory.ReadByte(addr); break;

                // LD C, (IX+*)
                case 0x4E: addr = (ushort)(ix + GetNextByte()); c = memory.ReadByte(addr); break;

                // LD D, (IX+*)
                case 0x56: addr = (ushort)(ix + GetNextByte()); d = memory.ReadByte(addr); break;

                // LD E, (IX+*)
                case 0x5E: addr = (ushort)(ix + GetNextByte()); e = memory.ReadByte(addr); break;

                // LD H, (IX+*)
                case 0x66: addr = (ushort)(ix + GetNextByte()); h = memory.ReadByte(addr); break;

                // LD L, (IX+*)
                case 0x6E: addr = (ushort)(ix + GetNextByte()); l = memory.ReadByte(addr); break;

                // LD (IX+*), B
                case 0x70: addr = (ushort)(ix + GetNextByte()); memory.WriteByte(addr, b); break;

                // LD (IX+*), C
                case 0x71: addr = (ushort)(ix + GetNextByte()); memory.WriteByte(addr, c); break;

                // LD (IX+*), D
                case 0x72: addr = (ushort)(ix + GetNextByte()); memory.WriteByte(addr, d); break;

                // LD (IX+*), E
                case 0x73: addr = (ushort)(ix + GetNextByte()); memory.WriteByte(addr, e); break;

                // LD (IX+*), H
                case 0x74: addr = (ushort)(ix + GetNextByte()); memory.WriteByte(addr, h); break;

                // LD (IX+*), L
                case 0x75: addr = (ushort)(ix + GetNextByte()); memory.WriteByte(addr, l); break;

                // LD (IX+*), A
                case 0x77: addr = (ushort)(ix + GetNextByte()); memory.WriteByte(addr, a); break;

                // LD A, (IX+*)
                case 0x7E: addr = (ushort)(ix + GetNextByte()); a = memory.ReadByte(addr); break;

                // ADD A, (IX+*)
                case 0x86: addr = (ushort)(ix + GetNextByte()); a = ADD(a, memory.ReadByte(addr)); break;

                // ADC A, (IX+*)
                case 0x8E: addr = (ushort)(ix + GetNextByte()); a = ADC(a, memory.ReadByte(addr)); break;

                // SUB (IX+*)
                case 0x96: addr = (ushort)(ix + GetNextByte()); a = SUB(a, memory.ReadByte(addr)); break;

                // SBC A, (IX+*)
                case 0x9E: addr = (ushort)(ix + GetNextByte()); a = SBC(a, memory.ReadByte(addr)); break;

                // AND (IX+*)
                case 0xA6: addr = (ushort)(ix + GetNextByte()); a = AND(a, memory.ReadByte(addr)); break;

                // XOR (IX+*)
                case 0xAE: addr = (ushort)(ix + GetNextByte()); a = XOR(a, memory.ReadByte(addr)); break;

                // OR (IX+*)
                case 0xB6: addr = (ushort)(ix + GetNextByte()); a = OR(a, memory.ReadByte(addr)); break;

                // CP (IX+*)
                case 0xBE: addr = (ushort)(ix + GetNextByte()); a = CP(memory.ReadByte(addr)); break;

                // bitwise instructions
                case 0xCB: DecodeDDCBOpCode(); break;

                // POP IX
                case 0xE1: ix = POP(); break;

                // EX (SP), IX
                case 0xE3: var temp = memory.ReadWord(sp); memory.WriteWord(sp, ix); ix = temp; break;

                // PUSH IX
                case 0xE5: PUSH(ix); break;

                // JP (IX)
                case 0xE9: pc = ix; break;

                // LD SP, IX
                case 0xF9: sp = ix; break;

                default:
                    throw new InvalidOperationException($"Opcode DD{opCode:X2} not understood. ");

            }
        }

        private void DecodeDDCBOpCode()
        {
            // format is DDCB[addr][opcode]
            ushort addr = (ushort)(ix + GetNextByte());
            var opCode = GetNextByte();

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

                // BIT n, (IX+*)
                case 0x46:
                case 0x4E:
                case 0x56:
                case 0x5E:
                case 0x66:
                case 0x6E:
                case 0x76:
                case 0x7E:
                    fZ = !IsBitSet(memory.ReadByte(addr), (opCode & 0x38) >> 3); break;

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
        }

        private ushort DecodeFDCBOpCode()
        {
            // format is FDCB[addr][opcode]
            ushort addr = (ushort)(iy + GetNextByte());
            var opCode = GetNextByte();

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

                // BIT n, (IY+*)
                case 0x46:
                case 0x4E:
                case 0x56:
                case 0x5E:
                case 0x66:
                case 0x6E:
                case 0x76:
                case 0x7E:
                    fZ = !IsBitSet(memory.ReadByte(addr), (opCode & 0x38) >> 3); break;

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
            return addr;
        }

        private void DecodeFDOpcode()
        {
            byte opCode = GetNextByte();
            ushort addr = 0;

            switch (opCode)
            {
                // ADD IY, BC
                case 0x09: iy += bc; break;

                // ADD IY, DE
                case 0x19: iy += de; break;

                // LD IY, **
                case 0x21: iy = GetNextWord(); break;

                // LD (**), IY
                case 0x22: memory.WriteWord(GetNextWord(), iy); break;

                // INC IY
                case 0x23: iy++; break;

                // ADD IY, IY
                case 0x29: iy += iy; break;

                // LD IY, (**)
                case 0x2A: iy = memory.ReadWord(GetNextWord()); break;

                // DEC IY
                case 0x2B: iy--; break;

                // INC (IY+*)
                case 0x34:
                    addr = (ushort)(iy + GetNextByte());
                    memory.WriteByte(addr, INC(memory.ReadByte(addr)));
                    break;

                // DEC (IY+*)
                case 0x35:
                    addr = (ushort)(iy + GetNextByte());
                    memory.WriteByte(addr, DEC(memory.ReadByte(addr)));
                    break;

                // LD (IY+*), *
                case 0x36: addr = (ushort)(iy + GetNextByte()); memory.WriteByte(addr, GetNextByte()); break;

                // ADD IY, SP
                case 0x39: iy += sp; break;

                // LD B, (IY+*)
                case 0x46: addr = (ushort)(iy + GetNextByte()); b = memory.ReadByte(addr); break;

                // LD C, (IY+*)
                case 0x4E: addr = (ushort)(iy + GetNextByte()); c = memory.ReadByte(addr); break;

                // LD D, (IY+*)
                case 0x56: addr = (ushort)(iy + GetNextByte()); d = memory.ReadByte(addr); break;

                // LD E, (IY+*)
                case 0x5E: addr = (ushort)(iy + GetNextByte()); e = memory.ReadByte(addr); break;

                // LD H, (IY+*)
                case 0x66: addr = (ushort)(iy + GetNextByte()); h = memory.ReadByte(addr); break;

                // LD L, (IY+*)
                case 0x6E: addr = (ushort)(iy + GetNextByte()); l = memory.ReadByte(addr); break;

                // LD (IY+*), B
                case 0x70: addr = (ushort)(iy + GetNextByte()); memory.WriteByte(addr, b); break;

                // LD (IY+*), C
                case 0x71: addr = (ushort)(iy + GetNextByte()); memory.WriteByte(addr, c); break;

                // LD (IY+*), D
                case 0x72: addr = (ushort)(iy + GetNextByte()); memory.WriteByte(addr, d); break;

                // LD (IY+*), E
                case 0x73: addr = (ushort)(iy + GetNextByte()); memory.WriteByte(addr, e); break;

                // LD (IY+*), H
                case 0x74: addr = (ushort)(iy + GetNextByte()); memory.WriteByte(addr, h); break;

                // LD (IY+*), L
                case 0x75: addr = (ushort)(iy + GetNextByte()); memory.WriteByte(addr, l); break;

                // LD (IY+*), A
                case 0x77: addr = (ushort)(iy + GetNextByte()); memory.WriteByte(addr, a); break;

                // LD A, (IY+*)
                case 0x7E: addr = (ushort)(iy + GetNextByte()); a = memory.ReadByte(addr); break;

                // ADD A, (IY+*)
                case 0x86: addr = (ushort)(iy + GetNextByte()); a = ADD(a, memory.ReadByte(addr)); break;

                // ADC A, (IY+*)
                case 0x8E: addr = (ushort)(iy + GetNextByte()); a = ADC(a, memory.ReadByte(addr)); break;

                // SUB (IY+*)
                case 0x96: addr = (ushort)(iy + GetNextByte()); a = SUB(a, memory.ReadByte(addr)); break;

                // SBC A, (IY+*)
                case 0x9E: addr = (ushort)(iy + GetNextByte()); a = SBC(a, memory.ReadByte(addr)); break;

                // AND (IY+*)
                case 0xA6: addr = (ushort)(iy + GetNextByte()); a = AND(a, memory.ReadByte(addr)); break;

                // XOR (IY+*)
                case 0xAE: addr = (ushort)(iy + GetNextByte()); a = XOR(a, memory.ReadByte(addr)); break;

                // OR (IY+*)
                case 0xB6: addr = (ushort)(iy + GetNextByte()); a = OR(a, memory.ReadByte(addr)); break;

                // CP (IY+*)
                case 0xBE: addr = (ushort)(iy + GetNextByte()); a = CP(memory.ReadByte(addr)); break;

                // bitwise instructions
                case 0xCB: DecodeFDCBOpCode(); break;

                // POP IY
                case 0xE1: iy = POP(); break;

                // EX (SP), IY
                case 0xE3: var temp = memory.ReadWord(sp); memory.WriteWord(sp, iy); iy = temp; break;

                // PUSH IY
                case 0xE5: PUSH(iy); break;

                // JP (IY)
                case 0xE9: pc = iy; break;

                // LD SP, IY
                case 0xF9: sp = iy; break;

                default:
                    throw new InvalidOperationException($"Opcode FD{opCode:X2} not understood. ");

            }
        }

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

        private void Swap<T>(ref T x, ref T y)
        {
            var temp = y;
            y = x;
            x = temp;
        }
    }
}
