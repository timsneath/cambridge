import 'package:flutter/material.dart';
import 'spectrum.dart';

void main() => runApp(new ProjectCambridge());

class ProjectCambridge extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Project Cambridge',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new Spectrum(title: 'Flutter Demo Home Page'),
    );
  }
}