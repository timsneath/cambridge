// ula.dart -- ports and input for ZX Spectrum

import 'dart:typed_data';

import 'package:spectrum/spectrum/utility.dart';

// See http://www.worldofspectrum.org/ZXBasicManual/zxmanchap23.html
class ULA {
  /* PORTS */

  // There are 65,536 ports, each of which can read or write an 8-bit value.
  // The keyboard ports are listed below, along with a bitmap.
  static var inputPortList = Uint8List(0xFFFF);
  static var inputPorts = ByteData.view(inputPortList.buffer);

  static int screenBorder = 0x00;

  static void reset() {
    inputPortList = Uint8List(0xFFFF);
    inputPorts = ByteData.view(inputPortList.buffer);

    screenBorder = 0x00;
  }

  /* KEYBOARD */
  // See http://www.breakintoprogram.co.uk/computers/zx-spectrum/keyboard
  static void keyPressed(String keycap) {
    // naive implementation that only allows for a single keypress
    final port = keyPortMap(keycap);

    if (port != null) {
      // set all keyboard bits high at first
      inputPorts.setUint8(0xFEFE, 0xFF);
      inputPorts.setUint8(0xFDFE, 0xFF);
      inputPorts.setUint8(0xFBFE, 0xFF);
      inputPorts.setUint8(0xF7FE, 0xFF);
      inputPorts.setUint8(0xEFFE, 0xFF);
      inputPorts.setUint8(0xDFFE, 0xFF);
      inputPorts.setUint8(0xBFFE, 0xFF);
      inputPorts.setUint8(0x7FFE, 0xFF);

      final data = keyValueMap(port, keycap);
      print(
          '$keycap down -- writing ${toHex16(data)} to port ${toHex32(port)}');
      inputPorts.setUint8(port, data);
    } else {
      print('Port not found for $keycap');
    }
  }

  static void keyReleased() {
    inputPorts.setUint8(0xFEFE, 0xFF);
    inputPorts.setUint8(0xFDFE, 0xFF);
    inputPorts.setUint8(0xFBFE, 0xFF);
    inputPorts.setUint8(0xF7FE, 0xFF);
    inputPorts.setUint8(0xEFFE, 0xFF);
    inputPorts.setUint8(0xDFFE, 0xFF);
    inputPorts.setUint8(0xBFFE, 0xFF);
    inputPorts.setUint8(0x7FFE, 0xFF);
  }

  // Reading the port on the left side (e.g. 0xFEFE) will return an 8-bit value
  // of which the least significant five bits represent a bitmap of the value,
  // so for example: if the 'V' key is held down, the value nnn10000 can be read
  // from port 0xFEFE.

  static const keyMap = <int, List<String>>{
    0xFEFE: ['SHIFT', 'Z', 'X', 'C', 'V'],
    0xFDFE: ['A', 'S', 'D', 'F', 'G'],
    0xFBFE: ['Q', 'W', 'E', 'R', 'T'],
    0xF7FE: ['1', '2', '3', '4', '5'],
    0xEFFE: ['0', '9', '8', '7', '6'],
    0xDFFE: ['P', 'O', 'I', 'U', 'Y'],
    0xBFFE: ['ENTER', 'L', 'K', 'J', 'H'],
    0x7FFE: ['SPACE', 'SYMBL', 'M', 'N', 'B']
  };

// Gets the port that maps to the keycap
  static int keyPortMap(String keycap) {
    return keyMap.keys.firstWhere((port) => keyMap[port].indexOf(keycap) != -1,
        orElse: () => null);
  }

// Gets the bitmap that maps to the keycap
  static int keyValueMap(int port, String keycap) {
    int bitField = 0xFF;

    var keyBit = keyMap[port].indexOf(keycap);
    if (keyBit != -1) {
      bitField = resetBit(bitField, keyBit);
    }

    return bitField;
  }
}
