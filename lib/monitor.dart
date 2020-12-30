import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';

import 'core/display.dart';
import 'core/memory.dart';
import 'core/spectrumcolor.dart';
import 'core/ula.dart';

// This object represents the screen of the ZX Spectrum
class Monitor extends StatelessWidget {
  final Memory memory;

  const Monitor({required this.memory});

  // TODO: Not used today. Perhaps use in the future?
  Future<FrameInfo> makeImage() async {
    final pixels = Display.imageBuffer(memory);

    final buffer = await ImmutableBuffer.fromUint8List(pixels);
    final descriptor = ImageDescriptor.raw(
      buffer,
      width: Display.screenWidth,
      height: Display.screenHeight,
      pixelFormat: PixelFormat.rgba8888,
    );

    final codec = await descriptor.instantiateCodec(
      targetWidth: Display.screenWidth,
      targetHeight: Display.screenHeight,
    );
    return codec.getNextFrame();
  }

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
        Display.bmpImage(memory),
        width: Display.screenWidth.toDouble(),
        height: Display.screenHeight.toDouble(),
        gaplessPlayback: true,
      ),
    );
  }
}
