import 'package:flutter/material.dart';
// import 'package:image/image.dart' as image2;
import 'package:spectrum/spectrum.dart';

class SpectrumMonitor extends StatefulWidget {
  SpectrumMonitor({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _SpectrumMonitorState createState() => _SpectrumMonitorState();
}

class _SpectrumMonitorState extends State<SpectrumMonitor> {
  @override
  Widget build(BuildContext context) {
    return Text('Insert thing of beauty here.');
  }
}
