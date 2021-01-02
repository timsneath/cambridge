import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

import 'core/display.dart';
import 'core/memory.dart';
import 'core/storage.dart';
import 'core/ula.dart';
import 'core/z80.dart';
import 'disassembly.dart';
import 'key.dart';
import 'monitor.dart';

late Z80 z80;
late Memory memory;
Display? display;
late List<int> breakpoints;

const instructionTestFile = 'roms/zexdoc';
const snapshotFile = 'roms/Z80TEST.SNA';
const romFile = 'roms/Chess.rom';

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
  bool isKeyboardVisible = true;
  bool isDisassemblerVisible = false;
  bool isTurbo = true;

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
    await executeFrame();
  }

  Future<void> loadTestScreenshot() async {
    final screen = await rootBundle.load('assets/google.scr');

    setState(() {
      memory.load(0x4000, screen.buffer.asUint8List());
    });
  }

  Future<void> loadSnapshot() async {
    try {
      final storage = Storage(z80: z80);
      final rawBinary = await rootBundle.load(snapshotFile);

      setState(() {
        if (snapshotFile.toLowerCase().endsWith('.sna')) {
          storage.loadSNASnapshot(rawBinary);
        } else {
          storage.loadZ80Snapshot(rawBinary);
        }
      });
    } catch (exception) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              "Couldn't load snapshot: $snapshotFile. (Make sure it's included in the roms/ folder.)"),
        ),
      );
    }
  }

  Future<void> loadROM() async {
    try {
      final storage = Storage(z80: z80);
      final rawBinary = await rootBundle.load(romFile);

      setState(() {
        storage.loadRom(rawBinary);
      });
    } catch (exception) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Couldn't load ROM: $romFile."),
        ),
      );
    }
  }

  Future<void> testInstructionSet() async {
    try {
      final storage = Storage(z80: z80);
      final rawBinary = await rootBundle.load(instructionTestFile);

      setState(() {
        storage.loadBinaryData(rawBinary, startLocation: 0x8000, pc: 0x8000);
      });
    } catch (exception) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Couldn't load FUSE instruction test suite (zexdoc)."),
        ),
      );
    }
  }

  Future<void> resetEmulator() async {
    try {
      final rom = await rootBundle.load('roms/48.rom');

      memory = Memory(isRomProtected: true);
      z80 = Z80(memory, startAddress: 0x0000);
      ULA.reset();
      breakpoints.clear();
      setState(() {
        memory.load(0x0000, rom.buffer.asUint8List());
        isRomLoaded = true;
      });
    } catch (exception) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Couldn't load ZX Spectrum ROM (48.rom)."),
        ),
      );
    }
  }

  Future<void> executeFrame() async {
    final startTime = DateTime.now().millisecondsSinceEpoch;
    setState(() {
      z80.interrupt();
    });

    // On the original 3.5MHz Z80 microprocessor used on the ZX Spectrum, a
    // frame lasts ~1/50th second (50.08Hz, to be exact). Therefore, since:
    //   3,500,000 / 50.08 = 69,888
    // a frame lasts for 69,888 t-states. Flutter executes a frame more
    // frequently (60fps, or even 120fps), so while this executes at 1.2-2.4x
    // the speed of a real ZX Spectrum, interrupts should occur at the same rate
    // as a physical machine.

    // We also institute a "turbo" mode here, which runs as many instructions as
    // can be completed in <10ms, which (allowing 6ms for other housekeeping
    // activities, including painting the display) should allow the emulator to
    // deliver 60fps (1/60s = 16ms).
    while (
        (isTurbo && DateTime.now().millisecondsSinceEpoch - startTime < 10) ||
            (!isTurbo && z80.tStates < 58333)) {
      z80.executeNextInstruction();
      if (breakpoints.contains(z80.pc) && ticker.isActive) {
        ticker.stop();
        break;
      }
    }

    z80.tStates = 0;
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
              icon: const Icon(Icons.crop_original),
              tooltip: 'Load test screenshot',
              onPressed: loadTestScreenshot,
            ),
            IconButton(
              icon: const Icon(Icons.replay),
              tooltip: 'Reset emulator',
              onPressed: resetEmulator,
            ),
            IconButton(
              icon: const Icon(Icons.fact_check),
              tooltip: 'Test Z80 instruction set',
              onPressed: testInstructionSet,
            ),
            IconButton(
                icon: const Icon(Icons.system_update_alt),
                tooltip: 'Load tape snapshot',
                onPressed: loadSnapshot),
            IconButton(
              icon: const Icon(Icons.developer_board),
              tooltip: 'Load ROM image',
              onPressed: loadROM,
            ),
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
            Row(
              children: [
                const Text('Turbo: '),
                Switch(
                  value: isTurbo,
                  onChanged: setTurbo,
                ),
              ],
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

  // ignore: avoid_positional_boolean_parameters
  void setTurbo(bool value) {
    setState(() {
      isTurbo = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Monitor(memory: memory),
          menus(),
          if (isDisassemblerVisible) DisassemblyView(),
          if (isKeyboardVisible) Keyboard(),
        ],
      ),
    );
  }
}
