import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

// For desktop support
import 'package:flutter/foundation.dart'
    show debugDefaultTargetPlatformOverride;

import 'package:spectrum/spectrum/z80.dart';
import 'package:spectrum/spectrum/memory.dart';
import 'package:spectrum/spectrum/utility.dart';
import 'package:spectrum/spectrum/display.dart';
import 'package:spectrum/spectrum/ula.dart';
import 'package:spectrum/monitor.dart';
import 'package:spectrum/key.dart';

Z80 z80;
Memory memory;
Display display;

/// If the current platform is desktop, override the default platform to
/// a supported platform (iOS for macOS, Android for Linux and Windows).
/// Otherwise, do nothing.
void setTargetPlatformForDesktop() {
  TargetPlatform targetPlatform;

  if (Platform.isMacOS) {
    targetPlatform = TargetPlatform.iOS;
  } else if (Platform.isLinux || Platform.isWindows) {
    targetPlatform = TargetPlatform.android;
  }
  if (targetPlatform != null) {
    debugDefaultTargetPlatformOverride = targetPlatform;
  }
}

void main() {
  setTargetPlatformForDesktop();

  runApp(ProjectCambridge());
}

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
  CambridgeHomePageState createState() => CambridgeHomePageState();
}

class CambridgeHomePageState extends State<CambridgeHomePage> {
  Ticker ticker;

  bool isRomLoaded = false;

  @override
  initState() {
    super.initState();
    memory = Memory(true);
    z80 = Z80(memory, startAddress: 0x0000);
    ULA.reset();
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

  void loadSnapshot() async {
    // Per https://faqwiki.zxnet.co.uk/wiki/SNA_format
    // the snapshot format has a 27 byte header containing the Z80 registers
    final snapshot = await rootBundle.load('roms/snapshots/JETSET.SNA');
    final r = snapshot.buffer.asUint8List(0, 27);

    z80.i = r[0];
    z80.hl_ = createWord(r[1], r[2]);
    z80.de_ = createWord(r[3], r[4]);
    z80.bc_ = createWord(r[5], r[6]);
    z80.af_ = createWord(r[7], r[8]);
    z80.hl = createWord(r[9], r[10]);
    z80.de = createWord(r[11], r[12]);
    z80.bc = createWord(r[13], r[14]);
    z80.iy = createWord(r[15], r[16]);
    z80.ix = createWord(r[17], r[18]);
    z80.iff2 = z80.iff1 = isBitSet(r[19], 2);
    z80.r = r[20];
    z80.af = createWord(r[21], r[22]);
    z80.sp = createWord(r[23], r[24]);
    z80.im = r[25];
    ULA.screenBorder = r[26];

    setState(() {
      memory.load(0x4000, snapshot.buffer.asUint8List(27));

      // The program counter is pushed onto the stack, and since SP points to
      // the stack, we can simply POP it off.
      z80.pc = z80.POP();
    });
  }

  void resetEmulator() async {
    ByteData rom = await rootBundle.load('roms/48.rom');

    memory = Memory(true);
    z80 = Z80(memory, startAddress: 0x0000);
    ULA.reset();
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
      z80.interrupt();
      z80.tStates = 0;
    }
  }

  Widget menus() {
    return Column(children: <Widget>[
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          FlatButton(
            child: Text('LOAD SNA'),
            onPressed: () => loadSnapshot(),
          ),
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
    ]);
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
              menus(),
              Keyboard(),
            ],
          ),
        ),
      ),
    );
  }
}
