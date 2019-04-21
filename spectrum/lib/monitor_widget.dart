import 'package:flutter/material.dart';
import 'package:image/image.dart' as ImageLibrary;

import 'zxspectrum/memory.dart';
import 'zxspectrum/displaybuffer.dart';

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
    var frame = ImageLibrary.Image.fromBytes(
        DisplayBuffer.width,
        DisplayBuffer.height,
        DisplayBuffer.imageBuffer(widget.memory),
        ImageLibrary.Image.RGBA);

    final jpg = ImageLibrary.encodeJpg(frame, quality: 100);
    final img = Image.memory(jpg,
        width: DisplayBuffer.width.toDouble(),
        height: DisplayBuffer.height.toDouble(),
        gaplessPlayback: true);
    return img;
  }
}
