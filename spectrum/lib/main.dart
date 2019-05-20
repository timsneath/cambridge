import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'dart:typed_data';

import 'spectrum/z80.dart';
import 'spectrum/memory.dart';
import 'spectrum/utility.dart';
import 'spectrum/display.dart';

import 'monitor.dart';
import 'key.dart';

Z80 z80;
Memory memory;
Display display;

void main() => runApp(ProjectCambridge());

class ProjectCambridge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: CambridgeHomePage(),
    );
  }
}

class CambridgeHomePage extends StatefulWidget {
  @override
  _CambridgeHomePageState createState() => _CambridgeHomePageState();
}

class _CambridgeHomePageState extends State<CambridgeHomePage> {
  Ticker ticker;

  bool isRomLoaded = false;

  @override
  initState() {
    super.initState();
    memory = Memory(true);
    z80 = Z80(memory, startAddress: 0x0000);
    ticker = Ticker(onTick);
  }

  void onTick(Duration elapsed) async {
    executeFrame();
  }

  void loadTestScreenshot() async {
    ByteData screen = await rootBundle.load('assets/google.scr');

    setState(() {
      memory.load(0x4000, screen.buffer.asUint8List());
    });
  }

  void resetEmulator() async {
    ByteData rom = await rootBundle.load('roms/48.rom');

    memory = Memory(true);
    z80 = Z80(memory, startAddress: 0x0000);
    setState(() {
      memory.load(0x0000, rom.buffer.asUint8List());
    });
  }

  void executeFrame() async {
    if (!isRomLoaded) {
      ByteData rom = await rootBundle.load('roms/48.rom');
      memory.load(0x0000, rom.buffer.asUint8List());
      isRomLoaded = true;
      z80.reset();
    } else {
      while (z80.tStates < 14336) {
        setState(() {
          z80.executeNextInstruction();
        });
      }
      z80.activateInterrupt();
      z80.tStates = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Project Cambridge'),
      ),
      body: Center(
        child: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Monitor(),
              Text('Program Counter: ${toHex16(z80.pc)}'),
              ButtonBar(
                alignment: MainAxisAlignment.center,
                children: <Widget>[
                  FlatButton(
                    child: Text('TEST SCREEN'),
                    onPressed: loadTestScreenshot,
                  ),
                  FlatButton(
                    child: Text('RESET'),
                    onPressed: resetEmulator,
                  ),
                  FlatButton(
                    child: Text('STEP'),
                    onPressed: executeFrame,
                  ),
                ],
              ),
              ButtonBar(
                alignment: MainAxisAlignment.center,
                children: <Widget>[
                  FlatButton(
                    child: Text('START TICKER'),
                    onPressed: () => ticker.start(),
                  ),
                  FlatButton(
                    child: Text('STOP TICKER'),
                    onPressed: () => ticker.stop(),
                  ),
                ],
              ),
              Keyboard(),
            ],
          ),
        ),
      ),
    );
  }
}
