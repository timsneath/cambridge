// displaybuffer.dart -- implements an attached screen buffer

import 'dart:typed_data';

import 'memory.dart';
import 'spectrumcolor.dart';

class DisplayBuffer {
  // standard dimensions of a ZX spectrum display
  static int get width => 256;
  static int get height => 192;

  static Uint8List imageBuffer(Memory memory) {
    Uint8List display = Uint8List(256 * 192 * 4);
    int idx;

    // display is configured as 192 lines of 32 bytes
    for (int y = 0; y < 192; y++) {
      for (int x = 0; x < 32; x++) {
        idx = 4 * (y * 256 + (x * 8));

        // Screen address can be calculated as follows:
        //
        //  15 14 13 12 11 10  9  8 |  7  6  5  4  3  2  1  0
        //   0  1  0 Y7 Y6 Y2 Y1 Y0 | Y5 Y4 Y3 X4 X3 X2 X1 X0
        //
        // where Y is pixels from top of screen
        // and X is pixels / 8 from left of screen
        //
        // each address has monochrome bitmap for 8 horizontal pixels
        // where 1 = ink color and 0 = paper color

        // transform (x, y) coordinates to appropriate memory location
        final y7y6 = (y & 0xC0) >> 6;
        final y5y4y3 = (y & 0x38) >> 3;
        final y2y1y0 = y & 0x07;
        final hi = 0x40 | (y7y6 << 3) | y2y1y0;
        final lo = (y5y4y3 << 5) | x;
        final addr = (hi << 8) + lo;

        assert(addr >= 0x4000);
        assert(addr < 0x5800);

        // read in the 8 pixels of monochrome data
        final pixel8 = memory.readByte(addr);

        // identify current ink / paper color for this pixel location

        // Color attribute data is held in the format:
        //
        //    7  6  5  4  3  2  1  0
        //    F  B  P2 P1 P0 I2 I1 I0
        //
        //  for 8x8 cells starting at 0x5800 (array of 32 x 24)
        final color = memory.readByte((0x5800 + ((y ~/ 8) * 32 + x)));
        final paperColor =
            spectrumColors[((color & 0x78) >> 3)]; // 0x78 = 01111000
        var inkColorAsByte = ((color & 0x07)); // 0x07 = 00000111
        if ((color & 0x40) == 0x40) // bright on (i.e. 0x40 = 01000000)
        {
          inkColorAsByte |= 0x08;
        }
        final inkColor = spectrumColors[inkColorAsByte];

        // apply state to the display
        for (int bit = 7; bit >= 0; bit--) {
          bool isBitSet = (pixel8 & (1 << bit)) == 1 << bit;
          display[idx++] = (isBitSet ? inkColor.red : paperColor.red);
          display[idx++] = (isBitSet ? inkColor.green : paperColor.green);
          display[idx++] = (isBitSet ? inkColor.blue : paperColor.blue);
          display[idx++] = 0xFF;
        }
      }
    }

    return display;
  }
}
