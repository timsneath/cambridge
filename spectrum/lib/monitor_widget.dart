import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'zxspectrum/memory.dart';
import 'zxspectrum/displaybuffer.dart';

const int width = 256;
const int height = 192;

// This object represents the screen of the ZX Spectrum
class Monitor extends StatefulWidget {
  Monitor({Key key, this.memory}) : super(key: key);

  final Memory memory;

  @override
  MonitorState createState() => MonitorState();
}

class MonitorState extends State<Monitor> {
  Image displayFrame;

  Widget build(BuildContext context) {
    var bitmapImage = BitmapHeader(width, height)
        .appendBitmap(DisplayBuffer.imageBuffer(widget.memory));

    return Image.memory(
      bitmapImage,
      width: DisplayBuffer.width.toDouble(),
      height: DisplayBuffer.height.toDouble(),
      gaplessPlayback: true,
    );
  }
}

// from https://stackoverflow.com/questions/51315442/use-ui-decodeimagefromlist-to-display-an-image-created-from-a-list-of-bytes/51316489
class BitmapHeader {
  int _width; // NOTE: width must be multiple of 4 as no account is made for bitmap padding
  int _height;

  Uint8List _bmp;
  int headerSize = 54;

  BitmapHeader(this._width, this._height) : assert(_width & 3 == 0) {
    int fileLength = headerSize + _width * _height * 4; // header + bitmap
    _bmp = new Uint8List(fileLength);
    ByteData bd = _bmp.buffer.asByteData();
    // bd.setUint16(0, 0x424d, Endian.little);
    bd.setUint8(0, 0x42); // header field: BM
    bd.setUint8(1, 0x4d);
    bd.setUint32(2, fileLength, Endian.little); // file length
    bd.setUint32(10, headerSize, Endian.little); // start of the bitmap
    bd.setUint32(14, 40, Endian.little); // info header size
    bd.setUint32(18, _width, Endian.little);
    bd.setUint32(22, -_height, Endian.little); // top down, not bottom up
    bd.setUint16(26, 1, Endian.little); // planes
    bd.setUint32(28, 32, Endian.little); // bpp
    bd.setUint32(30, 0, Endian.little); // compression
    bd.setUint32(34, 0, Endian.little); // bitmap size
    // leave everything else as zero
  }

  /// Insert the provided bitmap after the header and return the whole BMP
  Uint8List appendBitmap(Uint8List bitmap) {
    int size = _width * _height * 4;
    assert(bitmap.length == size);
    _bmp.setRange(headerSize, headerSize + size, bitmap);
    return _bmp;
  }
}
