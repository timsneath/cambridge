import 'package:spectrum/core/storage/tap_file.dart';

void main(List<String> args) {
  final tap = TAPFile.fromFile('roms/JENNIFER.TAP');
  print(tap);
}
