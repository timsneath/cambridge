import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:image/image.dart' as Image2;
import 'package:spectrum/spectrum.dart';

class Spectrum extends StatefulWidget {
  Spectrum({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _SpectrumState createState() => _SpectrumState();
}

class _SpectrumState extends State<Spectrum> {
  Z80 z80;
  Memory memory;
  int instructionCounter = 0;
  Image displayFrame;

  _SpectrumState() {
    memory = Memory(true);
    z80 = Z80(memory, startAddress: 0x0000);
    displayFrame = Image.asset('assets/blank.jpg');
  }

  @override
  void dispose() {
    memory = null;
    super.dispose();
  }

  executeBatch() async {
    if (instructionCounter == 0) {
      ByteData rom = await rootBundle.load('roms/48.rom');
      memory.load(0x0000, rom.buffer.asUint8List());
      z80.reset();
      instructionCounter++;
      createSpectrumFrame();
    } else {
      setState(() {
        while (instructionCounter++ % 0x10000 != 0) {
          z80.executeNextInstruction();
        }
        createSpectrumFrame();
      });
    }
  }

  loadTestScreenshot() async {
    ByteData screen = await rootBundle.load('assets/google.scr');
    setState(() {
      memory.load(0x4000, screen.buffer.asUint8List());
      createSpectrumFrame();
    });
  }

  resetEmulator() async {
    ByteData rom = await rootBundle.load('roms/48.rom');

    setState(() {
      memory = Memory(true);
      z80 = Z80(memory, startAddress: 0x0000);
      memory.load(0x0000, rom.buffer.asUint8List());
      displayFrame = Image.asset('assets/blank.jpg');
    });
  }

  createSpectrumFrame() {
    var frame = Image2.Image.fromBytes(Display.Width, Display.Height,
        Display.imageBuffer(memory), Image2.Image.RGBA);

    final jpg = Image2.encodeJpg(frame, quality: 100);
    final img = Image.memory(jpg,
        width: Display.Width.toDouble(),
        height: Display.Height.toDouble(),
        gaplessPlayback: true);
    displayFrame = img;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              displayFrame, // the Spectrum screen itself
              Text(z80 == null
                  ? 'null'
                  : 'Program Counter: ${toHex16(
                      z80.pc)}'), // yeah - we're wired up :)
              Container(
                  padding: const EdgeInsets.all(40.0),
                  child: RichText(
                      text: TextSpan(
                          text:
                              "Not yet updating the screen frame-by-frame. Use the last button below to manually advance the emulator. You'll need to press it about 10 times to fully advance through the boot process.",
                          style: TextStyle(color: Colors.black87)))),
              ButtonTheme.bar(
                  child: ButtonBar(
                alignment: MainAxisAlignment.center,
                children: <Widget>[
                  FlatButton(
                      child: Text('TEST SCREEN'),
                      onPressed: loadTestScreenshot),
                  FlatButton(child: Text('RESET'), onPressed: resetEmulator),
                  FlatButton(
                      child: Text('STEP FORWARD'), onPressed: executeBatch)
                ],
              ))
            ],
          ),
        ),
      ),
    );
  }
}
