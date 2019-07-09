import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

// For desktop support
import 'package:flutter/foundation.dart'
    show debugDefaultTargetPlatformOverride;
import 'package:spectrum/spectrum/disassembler.dart';

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
List<int> breakpoints;

/// If the current platform is desktop, override the default platform to
/// a supported platform (iOS for macOS, Android for Linux and Windows).
/// Otherwise, do nothing.
void setTargetPlatformForDesktop() {
  TargetPlatform targetPlatform;

  // This is a hacky (and temporary) workaround to test for the web,
  // since Platform.isMacOS is not implemented on web yet.
  if (!identical(0, 0.0)) {
    // If we're here, we're running Flutter natively on desktop or mobile
    if (Platform.isMacOS) {
      targetPlatform = TargetPlatform.iOS;
    } else if (Platform.isLinux || Platform.isWindows) {
      targetPlatform = TargetPlatform.android;
    }
    if (targetPlatform != null) {
      debugDefaultTargetPlatformOverride = targetPlatform;
    }
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
  bool isKeyboardVisible = false;

  @override
  initState() {
    super.initState();
    breakpoints = [];
    memory = Memory(true);
    z80 = Z80(memory, startAddress: 0x0000);
    ULA.reset();

    ticker = Ticker(onTick);

    resetEmulator();
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
    breakpoints.clear();
    setState(() {
      memory.load(0x0000, rom.buffer.asUint8List());
      isRomLoaded = true;
    });
  }

  void executeFrame() async {
    z80.interrupt();
    while (z80.tStates < 14336) {
      z80.executeNextInstruction();
      if (breakpoints.contains(z80.pc)) {
        if (ticker.isActive) {
          ticker.stop();
          break;
        }
      }
      setState(() {
        z80.tStates = 0;
      });
    }
  }

  void stepInstruction() {
    setState(() {
      z80.executeNextInstruction();
    });
  }

  void keyboardToggleVisibility() {
    setState(() {
      isKeyboardVisible = !isKeyboardVisible;
    });
  }

  Widget menus() {
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.video_label),
              onPressed: loadTestScreenshot,
            ),
            IconButton(
              icon: Icon(Icons.replay),
              onPressed: resetEmulator,
            ),
            IconButton(
              icon: Icon(Icons.file_download),
              onPressed: loadSnapshot,
            ),
            IconButton(
              icon: !ticker.isActive
                  ? Icon(
                      Icons.play_circle_filled,
                      color: Color(0xFF007F00),
                    )
                  : Icon(
                      Icons.pause_circle_filled,
                      color: Color(0xFF007F7F),
                    ),
              onPressed: toggleTicker,
            ),
            IconButton(
              icon: Icon(Icons.keyboard_arrow_right),
              onPressed: stepInstruction,
            ),
            IconButton(
              icon: Icon(Icons.keyboard),
              onPressed: keyboardToggleVisibility,
            ),
          ],
        ),
      ],
    );
  }

  Widget disassembly() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 20, 10, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            // Ugly -- needs sorting out, obviously
            Disassembler.disassembleMultipleInstructions(
                memory.memory.sublist(z80.pc, z80.pc + (4 * 8)), 8, z80.pc),
            textAlign: TextAlign.left,
            softWrap: true,
            style: TextStyle(fontFamily: 'Source Code Pro'),
            // overflow: TextOverf
          ),
          Text('Breakpoints: ${breakpoints.map((val) => toHex32(val))}'),
          Row(
            children: <Widget>[
              SizedBox(
                width: 100,
                child: TextField(
                  autocorrect: false,
                  onSubmitted: (breakpoint) => addBreakpoint(breakpoint),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  void addBreakpoint(String breakpoint) {
    var intBreakpoint = int.tryParse(breakpoint, radix: 16);
    if (intBreakpoint != null) {
      setState(() {
        if (!breakpoints.contains(intBreakpoint)) {
          breakpoints.add(intBreakpoint);
        }
      });
    }
  }

  void toggleTicker() {
    setState(() {
      if (ticker.isActive) {
        ticker.stop();
      } else {
        ticker.start();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Project Cambridge'),
      ),
      body: ListView(
        children: [
          Monitor(),
          Text('Program Counter: ${toHex16(z80.pc)}'),
          menus(),
          disassembly(),
          if (isKeyboardVisible) Keyboard(),
        ],
      ),
    );
  }
}
