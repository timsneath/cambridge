import 'package:flutter/material.dart';
import 'package:image/image.dart' as ImageLibrary;
import 'package:scoped_model/scoped_model.dart';

import 'package:spectrum/spectrum.dart';
import 'spectrum_model.dart';

// This object represents the screen of the ZX Spectrum
class SpectrumDisplay extends StatefulWidget {
  @override
  SpectrumDisplayState createState() => SpectrumDisplayState();
}

class SpectrumDisplayState extends State<SpectrumDisplay> {
  Image displayFrame;

  SpectrumDisplayState() {
    displayFrame = Image.asset('assets/blank.jpg');
  }

  Image createSpectrumFrame(Memory memory) {
    if (memory != null) {
      var frame = ImageLibrary.Image.fromBytes(Display.Width, Display.Height,
          Display.imageBuffer(memory), ImageLibrary.Image.RGBA);

      final jpg = ImageLibrary.encodeJpg(frame, quality: 100);
      final img = Image.memory(jpg,
          width: Display.Width.toDouble(),
          height: Display.Height.toDouble(),
          gaplessPlayback: true);
      return img;
    } else {
      return Image.asset('assets/blank.jpg');
    }
  }

  Widget build(BuildContext context) {
    return new ScopedModelDescendant<SpectrumModel>(
      builder: (context, child, model) =>
          createSpectrumFrame(model.memory),
    );
    // return displayFrame;
  }
}
