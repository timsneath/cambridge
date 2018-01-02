import 'package:flutter/material.dart';
import 'package:spectrum/spectrum.dart';

class Spectrum extends StatefulWidget {
  Spectrum({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _SpectrumState createState() => new _SpectrumState();
}

class _SpectrumState extends State<Spectrum> {
  Z80 z80;
  Memory memory;

  @override
  void initState() {
    super.initState();
    memory = new Memory(true);
    memory.loadSpectrum48KRom();
    z80 = new Z80(memory, startAddress: 0x0000);
  }

  @override
  void dispose() {
    memory = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(widget.title),
      ),
      body: new Center(
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new Text(toHex16(z80.af)) // yeah - we're wired up :)
          ],
        ),
      ),
    );
  }
}
