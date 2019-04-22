import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:typed_data';
import 'monitor_widget.dart';
import 'zxspectrum/z80.dart';
import 'zxspectrum/memory.dart';
import 'zxspectrum/utility.dart';

void main() => runApp(ProjectCambridge());

class ProjectCambridge extends StatelessWidget {
  // This widget is the root of your application.
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
  Z80 z80;
  Memory memory;

  int instructionCounter = 0;

  @override
  initState() {
    super.initState();
    memory = Memory(true);
    z80 = Z80(memory, startAddress: 0x0000);
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

  void executeInstruction() async {
    if (instructionCounter == 0) {
      ByteData rom = await rootBundle.load('roms/48.rom');
      memory.load(0x0000, rom.buffer.asUint8List());
      z80.reset();
      instructionCounter++;
    } else {
      while (instructionCounter++ % 0x10000 != 0) {
        setState(() {
          z80.executeNextInstruction();
        });
      }
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
              Monitor(memory: memory),
              Text('Program Counter: ${toHex16(z80.pc)}'),
              Container(
                padding: const EdgeInsets.all(40.0),
                child: RichText(
                  text: TextSpan(
                    text:
                        "Not yet updating the screen frame-by-frame. Use the last button below to manually advance the emulator. You'll need to press it about 10 times to fully advance through the boot process.",
                    style: TextStyle(color: Colors.black87),
                  ),
                ),
              ),
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
                    onPressed: executeInstruction,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
