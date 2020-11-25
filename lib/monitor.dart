import 'package:flutter/material.dart';

import 'core/display.dart';
import 'core/spectrumcolor.dart';
import 'core/ula.dart';

// This object represents the screen of the ZX Spectrum
class Monitor extends StatefulWidget {
  @override
  MonitorState createState() => MonitorState();
}

class MonitorState extends State<Monitor> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: const [
          BoxShadow(color: Colors.grey, offset: Offset(20, 20), blurRadius: 20),
        ],
        border: Border.all(
            color: SpectrumColor.fromByteValue(ULA.screenBorder), width: 20),
        borderRadius: const BorderRadius.all(Radius.circular(10)),
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
