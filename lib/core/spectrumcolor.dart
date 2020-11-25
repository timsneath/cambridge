// spectrumcolor.dart -- color system for ZX Spectrum

// Based on Color from dart:ui, and values are compatible with Color, but
// assumes alpha channel is always opaque (since ZX Spectrum has no concept
// of transparency).

// TODO: this might be much better as extension methods now D27 is complete.

import 'dart:ui';

class SpectrumColor extends Color {
  @deprecated
  const SpectrumColor(int value) : super(value | 0xFF000000);

  @deprecated
  // ignore: avoid_unused_constructor_parameters
  const SpectrumColor.fromARGB(int a, int r, int g, int b)
      : super.fromARGB(0xFF, r, g, b);

  @deprecated
  // ignore: avoid_unused_constructor_parameters
  const SpectrumColor.fromRGBO(int r, int g, int b, double opacity)
      : super.fromRGBO(r, g, b, 1.0);

  SpectrumColor.fromByteValue(int value) : super(spectrumColors[value]!);

  SpectrumColor.fromName(SpectrumColors value)
      : super(spectrumColors[value.index]!);

  @override
  String toString() =>
      "SpectrumColor(0x${(value & 0x00FFFFFF).toRadixString(16).padLeft(6, '0')})";
}

const spectrumColors = <int, int>{
  0x00: 0xFF000000, // black
  0x01: 0xFF0000CD, // blue
  0x02: 0xFFCD0000, // red
  0x03: 0xFFCD00CD, // magenta
  0x04: 0xFF00CD00, // green
  0x05: 0xFF00CDCD, // cyan
  0x06: 0xFFCDCD00, // yellow
  0x07: 0xFFCDCDCD, // gray
  0x08: 0xFF000000, // black
  0x09: 0xFF0000FF, // bright blue
  0x0A: 0xFFFF0000, // bright red
  0x0B: 0xFFFF00FF, // bright magenta
  0x0C: 0xFF00FF00, // bright green
  0x0D: 0xFF00FFFF, // bright cyan
  0x0E: 0xFFFFFF00, // bright yellow
  0x0F: 0xFFFFFFFF, // white
};

enum SpectrumColors {
  black,
  blue,
  red,
  magenta,
  green,
  cyan,
  yellow,
  gray,
  brightBlack,
  brightBlue,
  brightRed,
  brightMagenta,
  brightGreen,
  brightCyan,
  brightYellow,
  white
}
