// displaybuffer.dart -- implements an attached screen buffer

import 'dart:typed_data';

import 'package:spectrum/main.dart';
import 'package:spectrum/core/spectrumcolor.dart';

// Class that provides a front-end to the raw memory that represents the
// ZX Spectrum display
class Display {
  // standard dimensions of a ZX spectrum display
  static int get screenWidth => 256;
  static int get screenHeight => 192;

  // Returns the current display from memory as a BMP image formatted as a
  // Uint8List
  //
  // Adapted from
  //   https://stackoverflow.com/questions/51315442/use-ui-decodeimagefromlist-to-display-an-image-created-from-a-list-of-bytes/51316489
  static Uint8List get bmpImage {
    const bmpHeaderSize = 54;

    final fileLength =
        bmpHeaderSize + screenWidth * screenHeight * 4; // header + bitmap

    var bitmap = Uint8List(fileLength);

    // Set the header
    //
    // Bitmap header format documented here:
    //   https://en.wikipedia.org/wiki/BMP_file_format
    //
    // Bitmap file header is 10 bytes long, followed by a 40 byte
    // BITMAPINFOHEADER that describes the bitmap itself
    ByteData bd = bitmap.buffer.asByteData();
    bd.setUint16(0, 0x424d); // header field: BM
    bd.setUint32(2, fileLength, Endian.little); // file length
    bd.setUint32(10, bmpHeaderSize, Endian.little); // start of the bitmap

    bd.setUint32(14, 40, Endian.little); // info header size
    bd.setUint32(18, screenWidth, Endian.little);
    bd.setUint32(22, -screenHeight, Endian.little); // top down, not bottom up
    bd.setUint16(26, 1, Endian.little); // planes
    bd.setUint32(28, 32, Endian.little); // bpp
    bd.setUint32(30, 0, Endian.little); // compression
    bd.setUint32(34, 0, Endian.little); // bitmap size
    // leave everything else as zero

    // Grab the current memory-backed imagebuffer and use it to fill out the
    // bitmap structure
    var imageBuffer = Display.imageBuffer();

    int size = screenWidth * screenHeight * 4;
    assert(imageBuffer.length == size);
    bitmap.setRange(bmpHeaderSize, bmpHeaderSize + size, imageBuffer);

    return bitmap;
  }

  // Returns a simple BGRA imagebuffer from memory, converting the
  // ZX Spectrum in-memory display model into a raw list of color values starting
  // at (0,0) and ending at (255,191).
  static Uint8List imageBuffer() {
    Uint8List buffer = Uint8List(256 * 192 * 4);
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
        final paperColor = SpectrumColor.fromByteValue(
            ((color & 0x78) >> 3)); // 0x78 = 01111000
        var inkColorAsByte = ((color & 0x07)); // 0x07 = 00000111
        if ((color & 0x40) == 0x40) // bright on (i.e. 0x40 = 01000000)
        {
          inkColorAsByte |= 0x08;
        }
        final inkColor = SpectrumColor.fromByteValue(inkColorAsByte);

        // apply state to the display
        for (int bit = 7; bit >= 0; bit--) {
          bool isBitSet = (pixel8 & (1 << bit)) == 1 << bit;
          buffer[idx++] = (isBitSet ? inkColor.blue : paperColor.blue);
          buffer[idx++] = (isBitSet ? inkColor.green : paperColor.green);
          buffer[idx++] = (isBitSet ? inkColor.red : paperColor.red);
          buffer[idx++] = 0xFF;
        }
      }
    }

    return buffer;
  }
}
