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

  // Reading the port on the left side (e.g. 0xFEFE) will return an 8-bit value
  // of which the least significant five bits represent a bitmap of the value,
  // so for example: if the 'V' key is held down, the value nnn10000 can be read
  // from port 0xFEFE.
  //
  // More information at:
  //   See http://www.breakintoprogram.co.uk/computers/zx-spectrum/keyboard

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

  // Multiple keys can be pressed at once, so we create a set of keys that
  // we add or remove to based on interactions.
  static Set<String> keysPressed = {};

  static void keyPressed(String keycap) {
    keysPressed.add(keycap);

    setKeyboardPorts();
  }

  static void keyReleased(String keycap) {
    keysPressed.remove(keycap);

    setKeyboardPorts();
  }

  static void setKeyboardPorts() {
    // set all keyboard bits high at first
    for (var key in keyMap.keys) {
      inputPorts.setUint8(key, 0xFF);
    }

    for (String keyPressed in keysPressed) {
      // We should never be in a position where a key doesn't map to a port,
      // or doesn't map to an index in that port. Asserting to fail-fast in
      // this scenario.
      final port = keyPortMap(keyPressed);
      assert(port != null);

      final keyBit = keyMap[port].indexOf(keyPressed);
      assert(keyBit != 1);

      var portValue = inputPorts.getUint8(port);
      portValue = resetBit(portValue, keyBit);
      inputPorts.setUint8(port, portValue);
    }
  }

// Gets the port that maps to the keycap
  static int keyPortMap(String keycap) {
    return keyMap.keys.firstWhere((port) => keyMap[port].indexOf(keycap) != -1,
        orElse: () => null);
  }
}
