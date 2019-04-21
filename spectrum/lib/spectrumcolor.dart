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
