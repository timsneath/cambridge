// z80.dart -- implements the Zilog Z80 processor core
//
// Reference notes:
// The Z80 microprocessor user manual can be downloaded from Zilog:
//    http://tinyurl.com/z80manual
//
// Other useful details of the Z80 architecture can be found here:
//    http://landley.net/history/mirror/cpm/z80.html
// and here:
//    http://z80.info/z80code.htm

class Z80 {
  // REGISTERS
  final flags = const {
    'C': 0x01, // carry flag (bit 0)
    'N': 0x02, // add/subtract flag (bit 1)
    'P': 0x04, // parity/overflow flag (bit 2)
    'F3': 0x08, // undocumented flag
    'H': 0x10, // half carry flag (bit 4)
    'F5': 0x20, // undocumented flag
    'Z': 0x40, // zero flag (bit 6)
    'S': 0x80 // sign flag (bit 7)
  };

  // Core registers
  int a, f, b, c, d, e, h, l;
  int ix, iy;

  // The alternate register set (A', F', B', C', D', E', H', L')
  int a_, f_, b_, c_, d_, e_, h_, l_;

  int i; // Interrupt Page Address register
  int r; // Memory Refresh register

  int pc; // Program Counter
  int sp; // Stack pointer

  bool iff1;
  bool iff2;

  int im; // Interrupt Mode

  int get af => a * 256 + f;
  set af(num value) {
    a = highByte(value);
    f = lowByte(value);
  }

  int get bc => b * 256 + c;
  set bc(num value) {
    b = highByte(value);
    c = lowByte(value);
  }

  int get de => d * 256 + e;
  set de(num value) {
    d = highByte(value);
    e = lowByte(value);
  }

  int get hl => h * 256 + l;
  set hl(num value) {
    h = highByte(value);
    l = lowByte(value);
  }

  int get ixh => ix & 0xFF00 >> 8;
  int get ixl => ix & 0x00FF;

  int get iyh => iy & 0xFF00 >> 8;
  int get iyl => iy & 0x00FF;

  bool get fC => f & flags['C'] == flags['C'];
  bool get fN => f & flags['N'] == flags['N'];
  bool get fP => f & flags['P'] == flags['P'];
  bool get fF3 => f & flags['F3'] == flags['F3'];
  bool get fH => f & flags['H'] == flags['H'];
  bool get fF5 => f & flags['F5'] == flags['F5'];
  bool get fZ => f & flags['Z'] == flags['Z'];
  bool get fS => f & flags['S'] == flags['S'];

  int highByte(int value) => (value & 0xFF00) >> 8;
  int lowByte(int value) => value & 0x00FF;
}
