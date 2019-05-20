// spectrumcolor.dart -- color system for ZX Spectrum

// TODO: This is a mess. Should be able to pass in a value from 0x00 to 0x0F
// and should be a automatic return value for spectrumColor.BrightBlue etc.

// Based on Color from dart:ui, and values are compatible with Color, but
// assumes alpha channel is always opaque (since ZX Spectrum has no concept
// of transparency).

import 'dart:ui';

class SpectrumColor {
  const SpectrumColor(int value) : value = value | 0xFF000000;

  const SpectrumColor.fromRGB(int r, int g, int b)
      : value = (((0xFF << 24) | (r & 0xFF) << 16) |
                ((g & 0xFF) << 8) |
                ((b & 0xFF) << 0));

  final int value;

  int get red => (0xFF0000 & value) >> 16;
  int get green => (0x00FF00 & value) >> 8;
  int get blue => (0x0000FF & value) >> 0;

  @override
  bool operator ==(dynamic other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    final SpectrumColor typedOther = other;
    return value == typedOther.value;
  }

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() =>
      "SpectrumColor(0x${value.toRadixString(16).padLeft(6, '0')})";
    
  Color toColor() => Color(value);
}

const spectrumColors = <int, SpectrumColor>{
  0x00: SpectrumColor.fromRGB(0x00, 0x00, 0x00), // black
  0x01: SpectrumColor.fromRGB(0x00, 0x00, 0xCD), // blue
  0x02: SpectrumColor.fromRGB(0xCD, 0x00, 0x00), // red
  0x03: SpectrumColor.fromRGB(0xCD, 0x00, 0xCD), // magenta
  0x04: SpectrumColor.fromRGB(0x00, 0xCD, 0x00), // green
  0x05: SpectrumColor.fromRGB(0x00, 0xCD, 0xCD), // cyan
  0x06: SpectrumColor.fromRGB(0xCD, 0xCD, 0x00), // yellow
  0x07: SpectrumColor.fromRGB(0xCD, 0xCD, 0xCD), // gray
  0x08: SpectrumColor.fromRGB(0x00, 0x00, 0x00), // black
  0x09: SpectrumColor.fromRGB(0x00, 0x00, 0xFF), // bright blue
  0x0A: SpectrumColor.fromRGB(0xFF, 0x00, 0x00), // bright red
  0x0B: SpectrumColor.fromRGB(0xFF, 0x00, 0xFF), // bright magenta
  0x0C: SpectrumColor.fromRGB(0x00, 0xFF, 0x00), // bright green
  0x0D: SpectrumColor.fromRGB(0x00, 0xFF, 0xFF), // bright cyan
  0x0E: SpectrumColor.fromRGB(0xFF, 0xFF, 0x00), // bright yellow
  0x0F: SpectrumColor.fromRGB(0xFF, 0xFF, 0xFF) // white
};
