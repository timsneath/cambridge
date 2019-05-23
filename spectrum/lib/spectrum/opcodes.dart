// Work in progress

final z80Opcodes = const {
  '00': 'NOP', 
  '01 XX XX': 'LD BC, NN', 
  '02': 'LD (BC), A', 
  '03': 'INC BC', 
  '04': 'INC B', 
  '05': 'DEC B', 
  '06 XX': 'LD B, N', 
  '07': 'RLCA', 
  '08': 'EX AF, AF\'', 
  '09': 'ADD HL, BC', 
  '0A': 'LD A, (BC)', 
  '0B': 'DEC BC', 
  '0C': 'INC C', 
  '0D': 'DEC C', 
  '0E XX': 'LD C, N', 
  '0F': 'RRCA', 
  '10 XX': 'DJNZ N', 
  '11 XX XX': 'LD DE, NN', 
  '12': 'LD (DE), A', 
  '13': 'INC DE', 
  '14': 'INC D', 
  '15': 'DEC D', 
  '16 XX': 'LD D, N', 
  '17': 'RLA', 
  '18 XX': 'JR \$N+2', 
  '19': 'ADD HL, DE', 
  '1A': 'LD A, (DE)', 
  '1B': 'DEC DE', 
  '1C': 'INC E', 
  '1D': 'DEC E', 
  '1E XX': 'LD E, N', 
  '1F': 'RRA', 
  '20 XX': 'JR NZ, \$N+2', 
  '21 XX XX': 'LD HL, NN', 
  '22 XX XX': 'LD (NN), HL', 
  '23': 'INC HL', 
  '24': 'INC H', 
  '25': 'DEC H', 
  '26 XX': 'LD H, N', 
  '27': 'DAA', 
  '28 XX': 'JR Z, N', 
  '29': 'ADD HL, HL', 
  '2A XX XX': 'LD HL, (NN)', 
  '2B': 'DEC HL', 
  '2C': 'INC L', 
  '2D': 'DEC L', 
  '2E XX': 'LD L, N', 
  '2F': 'CPL', 
  '30 XX': 'JR NC, \$N+2', 
  '31 XX XX': 'LD SP, NN', 
  '32 XX XX': 'LD (NN), A', 
  '33': 'INC SP', 
  '34': 'INC (HL)', 
  '35': 'DEC (HL)', 
  '36 XX': 'LD (HL), N', 
  '37': 'SCF', 
  '38 XX': 'JR C, \$N+2', 
  '39': 'ADD HL, SP', 
  '3A XX XX': 'LD A, (NN)', 
  '3B': 'DEC SP', 
  '3C': 'INC A', 
  '3D': 'DEC A', 
  '3E XX': 'LD A, N', 
  '3F': 'CCF', 
  '46': 'LD B, (HL)', 
  '48+r': 'LD C, r', 
  '4E': 'LD C, (HL)', 
  '4r': 'LD B, r', 
  '56': 'LD D, (HL)', 
  '58+r': 'LD E, r', 
  '5E': 'LD E, (HL)', 
  '5r': 'LD D, r', 
  '66': 'LD H, (HL)', 
  '68+r': 'LD L, r', 
  '6E': 'LD L, (HL)', 
  '6r': 'LD H, r', 
  '76': 'HALT', 
  '78+r': 'LD A, r', 
  '7E': 'LD A, (HL)', 
  '7r': 'LD (HL), r', 
  '86': 'ADD A, (HL)', 
  '88+r': 'ADC A, r', 
  '8E': 'ADC A, (HL)', 
  '8r': 'ADD A, r', 
  '96': 'SUB (HL)', 
  '98+r': 'SBC A, r', 
  '9E': 'SBC A, (HL)', 
  '9r': 'SUB r', 
  'A6': 'AND (HL)', 
  'A8+r': 'XOR r', 
  'AE': 'XOR (HL)', 
  'Ar': 'AND r', 
  'B6': 'OR (HL)', 
  'B8+r': 'CP r', 
  'BE': 'CP (HL)', 
  'Br': 'OR r', 
  'C0': 'RET NZ', 
  'C1': 'POP BC', 
  'C2 XX XX': 'JP NZ, \$NN', 
  'C3 XX XX': 'JP \$NN', 
  'C4 XX XX': 'CALL NZ, NN', 
  'C5': 'PUSH BC', 
  'C6 XX': 'ADD A, N', 
  'C7': 'RST 0', 
  'C8': 'RET Z', 
  'C9': 'RET', 
  'CA XX XX': 'JP Z, \$NN', 
  'CB 06': 'RLC (HL)', 
  'CB 08+r': 'RRC r', 
  'CB 0E': 'RRC (HL)', 
  'CB 0r': 'RLC r', 
  'CB 16': 'RL (HL)', 
  'CB 18+r': 'RR r', 
  'CB 1E': 'RR (HL)', 
  'CB 1r': 'RL r', 
  'CB 26': 'SLA (HL)', 
  'CB 28+r': 'SRA r', 
  'CB 2E': 'SRA (HL)', 
  'CB 2r': 'SLA r', 
  'CB 36': 'SLL (HL)', 
  'CB 38+r': 'SRL r', 
  'CB 3E': 'SRL (HL)', 
  'CB 3r': 'SLL r', 
  'CB 46+8*b': 'BIT b, (HL)', 
  'CB 4r+8*b': 'BIT b, r', 
  'CB 86+8*b': 'RES b, (HL)', 
  'CB 8r+8*b': 'RES b, r', 
  'CB C6+8*b': 'SET b, (HL)', 
  'CB Cr+8*b': 'SET b, r', 
  'CC XX XX': 'CALL Z, NN', 
  'CD XX XX': 'CALL NN', 
  'CE XX': 'ADC A, N', 
  'CF': 'RST 8H', 
  'D0': 'RET NC', 
  'D1': 'POP DE', 
  'D2 XX XX': 'JP NC, \$NN', 
  'D3 XX': 'OUT (N), A', 
  'D4 XX XX': 'CALL NC, NN', 
  'D5': 'PUSH DE', 
  'D6 XX': 'SUB N', 
  'D7': 'RST 10H', 
  'D8': 'RET C', 
  'D9': 'EXX', 
  'DA XX XX': 'JP C, \$NN', 
  'DB XX': 'IN A, (N)', 
  'DC XX XX': 'CALL C, NN', 
  'DD 09': 'ADD IX, BC', 
  'DD 19': 'ADD IX, DE', 
  'DD 21 XX XX': 'LD IX, NN', 
  'DD 22 XX XX': 'LD (NN), IX', 
  'DD 23': 'INC IX', 
  'DD 24': 'INC HX', 
  'DD 26 XX': 'LD HX, N', 
  'DD 29': 'ADD IX, IX', 
  'DD 2A XX XX': 'LD IX, (NN)', 
  'DD 2B': 'DEC IX', 
  'DD 2C': 'INC LX', 
  'DD 34 XX': 'INC (IX+N)', 
  'DD 35 XX': 'DEC (IX+N)', 
  'DD 36 XX XX': 'LD (IX+N), N', 
  'DD 39': 'ADD IX, SP', 
  'DD 44': 'LD B, HX', 
  'DD 45': 'LD B, LX', 
  'DD 46 XX': 'LD B, (IX+N)', 
  'DD 4C': 'LD C, HX', 
  'DD 4D': 'LD C, LX', 
  'DD 4E XX': 'LD C, (IX+N)', 
  'DD 54': 'LD D, HX', 
  'DD 55': 'LD D, LX', 
  'DD 56 XX': 'LD D, (IX+N)', 
  'DD 5C': 'LD E, HX', 
  'DD 5D': 'LD E, LX', 
  'DD 5E XX': 'LD E, (IX+N)', 
  'DD 66 XX': 'LD H, (IX+N)', 
  'DD 68+r*': 'LD LX, r*', 
  'DD 6E XX': 'LD L, (IX+N)', 
  'DD 6r*': 'LD HX, r*', 
  'DD 7C': 'LD A, HX', 
  'DD 7D': 'LD A, LX', 
  'DD 7E XX': 'LD A, (IX+N)', 
  'DD 7r XX': 'LD (IX+N), r', 
  'DD 84': 'ADD A, HX', 
  'DD 85': 'ADD A, LX', 
  'DD 86 XX': 'ADD A, (IX+N)', 
  'DD 8C': 'ADC A, HX', 
  'DD 8D': 'ADC A, LX', 
  'DD 8E XX': 'ADC A, (IX+N)', 
  'DD 94': 'SUB HX', 
  'DD 95': 'SUB LX', 
  'DD 96 XX': 'SUB (IX+N)', 
  'DD 9C': 'SBC HX', 
  'DD 9D': 'SBC LX', 
  'DD 9E XX': 'SBC A, (IX+N)', 
  'DD A4': 'AND HX', 
  'DD A5': 'AND LX', 
  'DD A6 XX': 'AND (IX+N)', 
  'DD AC': 'XOR HX', 
  'DD AD': 'XOR LX', 
  'DD AE XX': 'XOR (IX+N)', 
  'DD B4': 'OR HX', 
  'DD B5': 'OR LX', 
  'DD B6 XX': 'OR (IX+N)', 
  'DD BC': 'CP HX', 
  'DD BD': 'CP LX', 
  'DD BE XX': 'CP (IX+N)', 
  'DD CB XX 06': 'RLC (IX+N)', 
  'DD CB XX 0E': 'RRC (IX+N)', 
  'DD CB XX 16': 'RL (IX+N)', 
  'DD CB XX 1E': 'RR (IX+N)', 
  'DD CB XX 26': 'SLA (IX+N)', 
  'DD CB XX 2E': 'SRA (IX+N)', 
  'DD CB XX 36': 'SLL (IX+N)', 
  'DD CB XX 3E': 'SRL (IX+N)', 
  'DD CB XX 46+8*b': 'BIT b, (IX+N)', 
  'DD CB XX 86+8*b': 'RES b, (IX+N)', 
  'DD CB XX C6+8*b': 'SET b, (IX+N)', 
  'DD E1': 'POP IX', 
  'DD E3': 'EX (SP), IX', 
  'DD E5': 'PUSH IX', 
  'DD E9': 'JP (IX)', 
  'DD F9': 'LD SP, IX', 
  'DE XX': 'SBC A, N', 
  'DF': 'RST 18H', 
  'E0': 'RET PO', 
  'E1': 'POP HL', 
  'E2 XX XX': 'JP PO, \$NN', 
  'E3': 'EX (SP), HL', 
  'E4 XX XX': 'CALL PO, NN', 
  'E5': 'PUSH HL', 
  'E6 XX': 'AND N', 
  'E7': 'RST 20H', 
  'E8': 'RET PE', 
  'E9': 'JP (HL)', 
  'EA XX XX': 'JP PE, \$NN', 
  'EB': 'EX DE, HL', 
  'EC XX XX': 'CALL PE, NN', 
  'ED 40': 'IN B, (C)', 
  'ED 41': 'OUT (C), B', 
  'ED 42': 'SBC HL, BC', 
  'ED 43 XX XX': 'LD (NN), BC', 
  'ED 44': 'NEG', 
  'ED 45': 'RETN', 
  'ED 46': 'IM 0', 
  'ED 47': 'LD I, A', 
  'ED 48': 'IN C, (C)', 
  'ED 49': 'OUT (C), C', 
  'ED 4A': 'ADC HL, BC', 
  'ED 4B XX XX': 'LD BC, (NN)', 
  'ED 4D': 'RETI', 
  'ED 4F': 'LD R, A', 
  'ED 50': 'IN D, (C)', 
  'ED 51': 'OUT (C), D', 
  'ED 52': 'SBC HL, DE', 
  'ED 53 XX XX': 'LD (NN), DE', 
  'ED 56': 'IM 1', 
  'ED 57': 'LD A, I', 
  'ED 58': 'IN E, (C)', 
  'ED 59': 'OUT (C), E', 
  'ED 5A': 'ADC HL, DE', 
  'ED 5B XX XX': 'LD DE, (NN)', 
  'ED 5E': 'IM 2', 
  'ED 5F': 'LD A, R', 
  'ED 60': 'IN H, (C)', 
  'ED 61': 'OUT (C), H', 
  'ED 62': 'SBC HL, HL', 
  'ED 67': 'RRD', 
  'ED 68': 'IN L, (C)', 
  'ED 69': 'OUT (C), L', 
  'ED 6A': 'ADC HL, HL', 
  'ED 6F': 'RLD', 
  'ED 70': 'IN (C)', 
  'ED 71': 'OUT (C), 0', 
  'ED 72': 'SBC HL, SP', 
  'ED 73 XX XX': 'LD (NN), SP', 
  'ED 78': 'IN A, (C)', 
  'ED 79': 'OUT (C), A', 
  'ED 7A': 'ADC HL, SP', 
  'ED 7B XX XX': 'LD SP, (NN)', 
  'ED A0': 'LDI', 
  'ED A1': 'CPI', 
  'ED A2': 'INI', 
  'ED A3': 'OUTI', 
  'ED A8': 'LDD', 
  'ED A9': 'CPD', 
  'ED AA': 'IND', 
  'ED AB': 'OUTD', 
  'ED B0': 'LDIR', 
  'ED B1': 'CPIR', 
  'ED B2': 'INIR', 
  'ED B3': 'OTIR', 
  'ED B8': 'LDDR', 
  'ED B9': 'CPDR', 
  'ED BA': 'INDR', 
  'ED BB': 'OTDR', 
  'EE XX': 'XOR N'
  'EF': 'RST 28H', 
  'F0': 'RET P', 
  'F1': 'POP AF', 
  'F2 XX XX': 'JP P, \$NN', 
  'F3': 'DI', 
  'F4 XX XX': 'CALL P, NN', 
  'F5': 'PUSH AF', 
  'F6 XX': 'OR N', 
  'F7': 'RST 30H', 
  'F8': 'RET M', 
  'F9': 'LD SP, HL', 
  'FA XX XX': 'JP M, \$NN', 
  'FB': 'EI', 
  'FC XX XX': 'CALL M, NN', 
  'FD 09': 'ADD IY, BC', 
  'FD 19': 'ADD IY, DE', 
  'FD 21 XX XX': 'LD IY, NN', 
  'FD 22 XX XX': 'LD (NN), IY', 
  'FD 23': 'INC IY', 
  'FD 24': 'INC HY', 
  'FD 26 XX': 'LD HY, N', 
  'FD 29': 'ADD IY, IY', 
  'FD 2A XX XX': 'LD IY, (NN)', 
  'FD 2B': 'DEC IY', 
  'FD 2C': 'INC LY', 
  'FD 2E XX': 'LD LX, N', 
  'FD 34 XX': 'INC (IY+N)', 
  'FD 35 XX': 'DEC (IY+N)', 
  'FD 36 XX XX': 'LD (IY+N), N', 
  'FD 39': 'ADD IY, SP', 
  'FD 44': 'LD B, HY', 
  'FD 45': 'LD B, LY', 
  'FD 46 XX': 'LD B, (IY+N)', 
  'FD 4C': 'LD C, HY', 
  'FD 4D': 'LD C, LY', 
  'FD 4E XX': 'LD C, (IY+N)', 
  'FD 54': 'LD D, HY', 
  'FD 55': 'LD D, LY', 
  'FD 56 XX': 'LD D, (IY+N)', 
  'FD 5C': 'LD E, HY', 
  'FD 5D': 'LD E, LY', 
  'FD 5E XX': 'LD E, (IY+N)', 
  'FD 66 XX': 'LD H, (IY+N)', 
  'FD 6E XX': 'LD L, (IY+N)', 
  'FD 6r*': 'LD HY, r*', 
  'FD 7C': 'LD A, HY', 
  'FD 7D': 'LD A, LY', 
  'FD 7E XX': 'LD A, (IY+N)', 
  'FD 7r XX': 'LD (IY+N), r', 
  'FD 84': 'ADD A, HY', 
  'FD 85': 'ADD A, LY', 
  'FD 86 XX': 'ADD A, (IY+N)', 
  'FD 8C': 'ADC A, HY', 
  'FD 8D': 'ADC A, LY', 
  'FD 8E XX': 'ADC A, (IY+N)', 
  'FD 94': 'SUB HY', 
  'FD 95': 'SUB LY', 
  'FD 96 XX': 'SUB (IY+N)', 
  'FD 9C': 'SBC HY', 
  'FD 9D': 'SBC LY', 
  'FD 9E XX': 'SBC A, (IY+N)', 
  'FD A4': 'AND HY', 
  'FD A5': 'AND LY', 
  'FD A6 XX': 'AND (IY+N)', 
  'FD AC': 'XOR HY', 
  'FD AD': 'XOR LY', 
  'FD AE XX': 'XOR (IY+N)', 
  'FD B4': 'OR HY', 
  'FD B5': 'OR LY', 
  'FD B6 XX': 'OR (IY+N)', 
  'FD BC': 'CP HY', 
  'FD BD': 'CP LY', 
  'FD BE XX': 'CP (IY+N)', 
  'FD CB XX 06': 'RLC (IY+N)', 
  'FD CB XX 0E': 'RRC (IY+N)', 
  'FD CB XX 16': 'RL (IY+N)', 
  'FD CB XX 1E': 'RR (IY+N)', 
  'FD CB XX 26': 'SLA (IY+N)', 
  'FD CB XX 2E': 'SRA (IY+N)', 
  'FD CB XX 36': 'SLL (IY+N)', 
  'FD CB XX 3E': 'SRL (IY+N)', 
  'FD CB XX 46+8*b': 'BIT b, (IY+N)', 
  'FD CB XX 86+8*b': 'RES b, (IY+N)', 
  'FD CB XX C6+8*b': 'SET b, (IY+N)', 
  'FD E1': 'POP IY', 
  'FD E3': 'EX (SP), IY', 
  'FD E5': 'PUSH IY', 
  'FD E9': 'JP (IY)', 
  'FD F9': 'LD SP, IY', 
  'FE XX': 'CP N', 
  'FF': 'RST 38H', 
};