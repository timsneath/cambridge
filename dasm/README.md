# DASM

A simple front-end disassembler for Z80 machine code. Hardcoded to the
ZX Spectrum 48K ROM. Run it as follows:

```bash
$ dart dasm.dart 0x11b7 0x1219
[11b7]  f3            DI
[11b8]  3e ff         LD A, FFh
[11ba]  ed 5b b2 5c   LD DE, (5CB2h)
[11be]  d9            EXX
[11bf]  ed 4b b4 5c   LD BC, (5CB4h)
[11c3]  ed 5b 38 5c   LD DE, (5C38h)
[11c7]  2a 7b 5c      LD HL, (5C7Bh)
[11ca]  d9            EXX
[11cb]  47            LD B, A
[11cc]  3e 07         LD A, 07h
[11ce]  d3 fe         OUT (FEh), A
[11d0]  3e 3f         LD A, 3Fh
[11d2]  ed 47         LD I, A
[11d4]  00            NOP
[11d5]  00            NOP
[11d6]  00            NOP
[11d7]  00            NOP
[11d8]  00            NOP
[11d9]  00            NOP
[11da]  62            LD H, D
[11db]  6b            LD L, E
[11dc]  36 02         LD (HL), 02h
[11de]  2b            DEC HL
[11df]  bc            CP H
[11e0]  20 fa         JR NZ, FAh
[11e2]  a7            AND A
[11e3]  ed 52         SBC HL, DE
[11e5]  19            ADD HL, DE
[11e6]  23            INC HL
[11e7]  30 06         JR NC, 06h
[11e9]  35            DEC (HL)
[11ea]  28 03         JR Z, 03h
[11ec]  35            DEC (HL)
[11ed]  28 f3         JR Z, F3h
[11ef]  2b            DEC HL
[11f0]  d9            EXX
[11f1]  ed 43 b4 5c   LD (5CB4h), BC
[11f5]  ed 53 38 5c   LD (5C38h), DE
[11f9]  22 7b 5c      LD (5C7Bh), HL
[11fc]  d9            EXX
[11fd]  04            INC B
[11fe]  28 19         JR Z, 19h
[1200]  22 b4 5c      LD (5CB4h), HL
[1203]  11 af 3e      LD DE, 3EAFh
[1206]  01 a8 00      LD BC, 00A8h
[1209]  eb            EX DE, HL
[120a]  ed b8         LDDR
[120c]  eb            EX DE, HL
[120d]  23            INC HL
[120e]  22 7b 5c      LD (5C7Bh), HL
[1211]  2b            DEC HL
[1212]  01 40 00      LD BC, 0040h
[1215]  ed 43 38 5c   LD (5C38h), BC
```