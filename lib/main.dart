import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

import 'core/display.dart';
import 'core/memory.dart';
import 'core/storage.dart';
import 'core/ula.dart';
import 'core/utility.dart';
import 'core/z80.dart';
import 'disassembly.dart';
import 'key.dart';
import 'monitor.dart';

late Z80 z80;
late Memory memory;
Display? display;
late List<int> breakpoints;

const snapshotFile = 'roms/Z80TEST.SNA';
// const snapshotFile = 'roms/JETSET.SNA';

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
  bool isDisassemblerVisible = false;

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
    // print('Tick: ${elapsed.inMilliseconds} ms.');
    await executeFrame();
  }

  Future<void> loadTestScreenshot() async {
    final screen = await rootBundle.load('assets/google.scr');

    setState(() {
      memory.load(0x4000, screen.buffer.asUint8List());
    });
  }

  Future<void> loadSnapshot() async {
    final storage = Storage(z80: z80);
    final snapshot = await rootBundle.load(snapshotFile);

    setState(() {
      if (snapshotFile.toLowerCase().endsWith('.sna')) {
        storage.loadSNASnapshot(snapshot);
      } else {
        storage.loadZ80Snapshot(snapshot);
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
    final startTime = DateTime.now().millisecondsSinceEpoch;
    setState(() {
      z80.interrupt();
    });
    while (DateTime.now().millisecondsSinceEpoch - startTime < 10) {
      z80.executeNextInstruction();
      if (breakpoints.contains(z80.pc) && ticker.isActive) {
        ticker.stop();
        break;
      }
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

  void disassemblerToggleVisibility() {
    setState(() {
      isDisassemblerVisible = !isDisassemblerVisible;
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
              tooltip: 'Load test screenshot',
              onPressed: loadTestScreenshot,
            ),
            IconButton(
              icon: const Icon(Icons.replay),
              tooltip: 'Reset emulator',
              onPressed: resetEmulator,
            ),
            IconButton(
                icon: const Icon(Icons.file_download),
                tooltip: 'Load tape snapshot',
                onPressed: loadSnapshot),
            IconButton(
              icon: ticker.isActive
                  ? const Icon(
                      Icons.pause_circle_filled,
                      color: Color(0xFF007F7F),
                    )
                  : const Icon(
                      Icons.play_circle_filled,
                      color: Color(0xFF007F00),
                    ),
              tooltip: ticker.isActive ? 'Pause' : 'Run',
              onPressed: toggleTicker,
            ),
            IconButton(
              icon: const Icon(Icons.keyboard_arrow_right),
              tooltip: 'Step one instruction',
              onPressed: stepInstruction,
            ),
            IconButton(
              icon: const Icon(Icons.keyboard),
              tooltip: 'Show/hide keyboard',
              onPressed: keyboardToggleVisibility,
            ),
            IconButton(
              icon: const Icon(Icons.bug_report),
              tooltip: 'Show/hide disassembler',
              onPressed: disassemblerToggleVisibility,
            ),
          ],
        ),
      ],
    );
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
          Monitor(memory: memory),
          Text('Program Counter: ${toHex16(z80.pc)}'),
          menus(),
          if (isDisassemblerVisible) DisassemblyView(),
          if (isKeyboardVisible) Keyboard(),
        ],
      ),
    );
  }
}
