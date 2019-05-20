import 'package:flutter/material.dart';
import 'package:spectrum/spectrum/spectrumcolor.dart';

import 'spectrum/display.dart';

// This object represents the screen of the ZX Spectrum
class Monitor extends StatefulWidget {
  @override
  MonitorState createState() => MonitorState();
}

class MonitorState extends State<Monitor> {
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
            color: spectrumColors[Display.borderColor]?.toColor() ??
                Colors.deepOrange,
            width: 20),
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      child: Image.memory(
        Display.bmpImage,
        width: Display.screenWidth.toDouble(),
        height: Display.screenHeight.toDouble(),
        gaplessPlayback: true,
      ),
    );
  }
}
