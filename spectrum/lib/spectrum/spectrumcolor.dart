// spectrumcolor.dart -- color system for ZX Spectrum

// Based on Color from dart:ui, and values are compatible with Color, but
// assumes alpha channel is always opaque (since ZX Spectrum has no concept
// of transparency). Separating it out also enables use without taking a
// dependency on Flutter.

class SpectrumColor {
  const SpectrumColor(int value) : value = value | 0xFF000000 & 0xFFFFFFFF;

  const SpectrumColor.fromRGB(int r, int g, int b)
      : value = (((0xFF << 24) | (r & 0xFF) << 16) |
                ((g & 0xFF) << 8) |
                ((b & 0xFF) << 0)) &
            0xFFFFFF;

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
}

final spectrumColors = <int, SpectrumColor>{
  0x00: const SpectrumColor.fromRGB(0x00, 0x00, 0x00), // black
  0x01: const SpectrumColor.fromRGB(0x00, 0x00, 0xCD), // blue
  0x02: const SpectrumColor.fromRGB(0xCD, 0x00, 0x00), // red
  0x03: const SpectrumColor.fromRGB(0xCD, 0x00, 0xCD), // magenta
  0x04: const SpectrumColor.fromRGB(0x00, 0xCD, 0x00), // green
  0x05: const SpectrumColor.fromRGB(0x00, 0xCD, 0xCD), // cyan
  0x06: const SpectrumColor.fromRGB(0xCD, 0xCD, 0x00), // yellow
  0x07: const SpectrumColor.fromRGB(0xCD, 0xCD, 0xCD), // gray
  0x08: const SpectrumColor.fromRGB(0x00, 0x00, 0x00), // black
  0x09: const SpectrumColor.fromRGB(0x00, 0x00, 0xFF), // bright blue
  0x0A: const SpectrumColor.fromRGB(0xFF, 0x00, 0x00), // bright red
  0x0B: const SpectrumColor.fromRGB(0xFF, 0x00, 0xFF), // bright magenta
  0x0C: const SpectrumColor.fromRGB(0x00, 0xFF, 0x00), // bright green
  0x0D: const SpectrumColor.fromRGB(0x00, 0xFF, 0xFF), // bright cyan
  0x0E: const SpectrumColor.fromRGB(0xFF, 0xFF, 0x00), // bright yellow
  0x0F: const SpectrumColor.fromRGB(0xFF, 0xFF, 0xFF) // white
};
