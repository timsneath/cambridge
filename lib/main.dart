import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

import 'core/disassembler.dart';
import 'core/display.dart';
import 'core/memory.dart';
import 'core/ula.dart';
import 'core/utility.dart';
import 'core/z80.dart';
import 'key.dart';
import 'monitor.dart';

late Z80 z80;
late Memory memory;
Display? display;
late List<int> breakpoints;

void main() {
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
  late Ticker ticker;

  bool isRomLoaded = false;
  bool isKeyboardVisible = false;

  @override
  void initState() {
    super.initState();
    breakpoints = [];
    memory = Memory(isRomProtected: true);
    z80 = Z80(memory, startAddress: 0x0000);
    ULA.reset();

    ticker = Ticker(onTick);

    resetEmulator();
  }

  Future<void> onTick(Duration elapsed) async {
    executeFrame();
  }

  Future<void> loadTestScreenshot() async {
    final screen = await rootBundle.load('assets/google.scr');

    setState(() {
      memory.load(0x4000, screen.buffer.asUint8List());
    });
  }

  Future<void> loadSNASnapshot() async {
    // Per https://faqwiki.zxnet.co.uk/wiki/SNA_format
    // the snapshot format has a 27 byte header containing the Z80 registers
    final snapshot = await rootBundle.load('roms/TIME.SNA');
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

  Future<void> loadZ80Snapshot() async {
    // Per http://rk.nvg.ntnu.no/sinclair/formats/z80-format.html
    // the snapshot format has a 30 byte header containing the Z80 registers

    final snapshot = await rootBundle.load('roms/JETSET.Z80');
    final r = snapshot.buffer.asUint8List(0, 30);

    var fileFormatVersion = 145;
    var isDataBlockCompressed = false;

    if (createWord(r[6], r[7]) == 0) {
      if (createWord(r[30], r[31]) == 54) {
        fileFormatVersion = 300;
      } else if (createWord(r[30], r[31]) == 23) {
        fileFormatVersion = 201;
      } else {
        throw Exception('Unrecognized Z80 file format.');
      }
    }

    z80.af = createWord(r[0], r[1]);
    z80.bc = createWord(r[2], r[3]);
    z80.hl = createWord(r[4], r[5]);
    if (fileFormatVersion <= 145) {
      z80.pc = createWord(r[6], r[7]);
    } else {
      z80.pc = createWord(r[32], r[33]);
    }
    z80.sp = createWord(r[8], r[9]);
    z80.i = r[10];
    z80.r = r[11];
    ULA.screenBorder = (r[12] << 1) & 0x03;
    if (isBitSet(r[12], 5)) {
      isDataBlockCompressed = true;
    }
    z80.de = createWord(r[13], r[14]);
    z80.bc_ = createWord(r[15], r[16]);
    z80.de_ = createWord(r[17], r[18]);
    z80.hl_ = createWord(r[19], r[20]);
    z80.af_ = createWord(r[21], r[22]);
    z80.iy = createWord(r[23], r[24]);
    z80.ix = createWord(r[25], r[26]);
    z80.iff1 = z80.iff2 = r[27] == 0;
    if ((r[29] & 0x03) == 0x00) {
      z80.im = 0;
    } else if ((r[29] & 0x03) == 0x01) {
      z80.im = 1;
    } else if ((r[29] & 0x03) == 0x02) {
      z80.im = 2;
    }

    setState(() {
      if (!isDataBlockCompressed && (fileFormatVersion == 145)) {
        memory.load(0x4000, snapshot.buffer.asUint8List(30));
      } else {
        throw Exception('Unsupported -- compressed v1.45 Z80 file.');
      }
    });
  }

  Future<void> resetEmulator() async {
    final rom = await rootBundle.load('roms/48.rom');

    memory = Memory(isRomProtected: true);
    z80 = Z80(memory, startAddress: 0x0000);
    ULA.reset();
    breakpoints.clear();
    setState(() {
      memory.load(0x0000, rom.buffer.asUint8List());
      isRomLoaded = true;
    });
  }

  Future<void> executeFrame() async {
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
              icon: const Icon(Icons.video_label),
              onPressed: loadTestScreenshot,
            ),
            IconButton(
              icon: const Icon(Icons.replay),
              onPressed: resetEmulator,
            ),
            IconButton(
              icon: const Icon(Icons.file_download),
              onPressed: loadZ80Snapshot,
            ),
            IconButton(
              icon: !ticker.isActive
                  ? const Icon(
                      Icons.play_circle_filled,
                      color: Color(0xFF007F00),
                    )
                  : const Icon(
                      Icons.pause_circle_filled,
                      color: Color(0xFF007F7F),
                    ),
              onPressed: toggleTicker,
            ),
            IconButton(
              icon: const Icon(Icons.keyboard_arrow_right),
              onPressed: stepInstruction,
            ),
            IconButton(
              icon: const Icon(Icons.keyboard),
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
            style: const TextStyle(fontFamily: 'Source Code Pro'),
            // overflow: TextOverf
          ),
          Text('Breakpoints: ${breakpoints.map(toHex32)}'),
          Row(
            children: <Widget>[
              SizedBox(
                width: 100,
                child: TextField(
                  autocorrect: false,
                  onSubmitted: addBreakpoint,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  void addBreakpoint(String breakpoint) {
    final intBreakpoint = int.tryParse(breakpoint, radix: 16);
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
        title: const Text('Project Cambridge'),
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
