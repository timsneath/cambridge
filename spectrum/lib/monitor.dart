import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:spectrum/spectrum/spectrumcolor.dart';

import 'spectrum/memory.dart';
import 'spectrum/displaybuffer.dart';

const int screenWidth = 256;
const int screenHeight = 192;

// This object represents the screen of the ZX Spectrum
class Monitor extends StatefulWidget {
  Monitor({Key key, this.memory, this.border}) : super(key: key);

  final Memory memory;
  final SpectrumColor border;

  @override
  MonitorState createState() => MonitorState();
}

class MonitorState extends State<Monitor> {
  Image displayFrame;

  Widget build(BuildContext context) {
    var bitmapImage =
        BitmapHeader().appendBitmap(DisplayBuffer.imageBuffer(widget.memory));

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: spectrumColors[0x07].toColor(), width: 20),
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      child: Image.memory(
        bitmapImage,  
        width: DisplayBuffer.width.toDouble(),
        height: DisplayBuffer.height.toDouble(),
        gaplessPlayback: true,
      ),
    );
  }
}

// Adapted from
//   https://stackoverflow.com/questions/51315442/use-ui-decodeimagefromlist-to-display-an-image-created-from-a-list-of-bytes/51316489
class BitmapHeader {
  Uint8List bmp;
  int headerSize = 54;

  // Bitmap header format documented here:
  //   https://en.wikipedia.org/wiki/BMP_file_format
  // Bitmap file header is 10 bytes long, followed by a 40 byte BITMAPINFOHEADER
  // that describes the bitmap itself
  BitmapHeader() {
    final fileLength =
        headerSize + screenWidth * screenHeight * 4; // header + bitmap
    bmp = Uint8List(fileLength);
    ByteData bd = bmp.buffer.asByteData();
    bd.setUint16(0, 0x424d); // header field: BM
    bd.setUint32(2, fileLength, Endian.little); // file length
    bd.setUint32(10, headerSize, Endian.little); // start of the bitmap

    bd.setUint32(14, 40, Endian.little); // info header size
    bd.setUint32(18, screenWidth, Endian.little);
    bd.setUint32(22, -screenHeight, Endian.little); // top down, not bottom up
    bd.setUint16(26, 1, Endian.little); // planes
    bd.setUint32(28, 32, Endian.little); // bpp
    bd.setUint32(30, 0, Endian.little); // compression
    bd.setUint32(34, 0, Endian.little); // bitmap size
    // leave everything else as zero
  }

  /// Insert the provided bitmap after the header and return the whole BMP
  Uint8List appendBitmap(Uint8List bitmap) {
    int size = screenWidth * screenHeight * 4;
    assert(bitmap.length == size);
    bmp.setRange(headerSize, headerSize + size, bitmap);
    return bmp;
  }
}
