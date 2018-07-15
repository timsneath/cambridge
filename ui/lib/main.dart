import 'package:flutter/material.dart';

import 'spectrum.dart';

void main() => runApp(ProjectCambridge());

class ProjectCambridge extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Project Cambridge',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Spectrum(title: 'Project Cambridge'),
    );
  }
}
