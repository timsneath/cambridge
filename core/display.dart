// display.dart -- implements an attached screen buffer

import 'dart:typed_data';

import 'memory.dart';
import 'spectrumcolor.dart';

// use Image.memory to display this in a Flutter app?
//   https://docs.flutter.io/flutter/widgets/Image/Image.memory.html

// also ref:
//   https://github.com/brendan-duncan/image/blob/master/lib/src/draw/draw_pixel.dart
final SpectrumColors = <int, SpectrumColor>{
  0x00: const SpectrumColor.fromRGB(0x00, 0x00, 0x00), // black
  0x01: const SpectrumColor.fromRGB(0x00, 0x00, 0xCD), // blue
  0x02: const SpectrumColor.fromRGB(0xCD, 0x00, 0x00), // red
  0x03: const SpectrumColor.fromRGB(0xCD, 0x00, 0xCD), // magenta
  0x04: const SpectrumColor.fromRGB(0x00, 0xCD, 0x00), // green
  0x05: const SpectrumColor.fromRGB(0x00, 0xCD, 0xCD), // cyan
  0x06: const SpectrumColor.fromRGB(0xCD, 0xCD, 0x00), // yellow
  0x07: const SpectrumColor.fromRGB(0xCD, 0xCD, 0xCD), // gray
  0x08: const SpectrumColor.fromRGB(0x00, 0x00, 0x00), // black
  0x09: const SpectrumColor.fromRGB(0x00, 0x00, 0xFF), // bright blue
  0x0A: const SpectrumColor.fromRGB(0xFF, 0x00, 0x00), // bright red
  0x0B: const SpectrumColor.fromRGB(0xFF, 0x00, 0xFF), // bright magenta
  0x0C: const SpectrumColor.fromRGB(0x00, 0xFF, 0x00), // bright green
  0x0D: const SpectrumColor.fromRGB(0x00, 0xFF, 0xFF), // bright cyan
  0x0E: const SpectrumColor.fromRGB(0xFF, 0xFF, 0x00), // bright yellow
  0x0F: const SpectrumColor.fromRGB(0xFF, 0xFF, 0xFF) // white
};

class Display {
  Uint8List imageBuffer(Memory memory) {
    Uint8List display = new Uint8List(256 * 192);
    int idx;

    // display is 192 lines of 32 bytes
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
        var y7y6 = (y & 0xC0) >> 6;
        var y5y4y3 = (y & 0x38) >> 3;
        var y2y1y0 = y & 0x07;
        var hi = 0x40 | (y7y6 << 3) | y2y1y0;
        var lo = (y5y4y3 << 5) | x;
        var addr = (hi << 8) + lo;

        assert(addr >= 0x4000);
        assert(addr < 0x5800);

        // read in the 8 pixels of monochrome data
        var pixel8 = memory.readByte(addr);

        // identify current ink / paper color for this pixel location

        // Color attribute data is held in the format:
        //
        //    7  6  5  4  3  2  1  0
        //    F  B  P2 P1 P0 I2 I1 I0
        //
        //  for 8x8 cells starting at 0x5800 (array of 32 x 24)
        var color = memory.readByte((0x5800 + ((y ~/ 8) * 32 + x)));
        var paperColor =
            SpectrumColors[((color & 0x78) >> 3)]; // 0x78 = 01111000
        var inkColorAsByte = ((color & 0x07)); // 0x07 = 00000111
        if ((color & 0x40) == 0x40) // bright on (i.e. 0x40 = 01000000)
        {
          inkColorAsByte |= 0x08;
        }
        var inkColor = SpectrumColors[inkColorAsByte];

        // apply state to the display
        for (int bit = 7; bit >= 0; bit--) {
          bool isBitSet = (pixel8 & (1 << bit)) == 1 << bit;
          display[idx++] = (isBitSet ? inkColor.value : paperColor.value);
        }
      }
    }

    return display;
  }
}
