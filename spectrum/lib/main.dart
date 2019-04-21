import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:spectrum/spectrum.dart';
import 'spectrum_model.dart';
import 'spectrum_display.dart';

void main() => runApp(ProjectCambridge());

class ProjectCambridge extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ScopedModel<SpectrumModel>(
      model: SpectrumModel(),
      child: MaterialApp(
        title: 'Project Cambridge',
        theme: ThemeData(
          primarySwatch: Colors.lightBlue,
        ),
        home: HomePage(title: 'Project Cambridge'),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  HomePage({Key key, this.title}) : super(key: key);

  final String title;

  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  SpectrumDisplay spectrum;

  // @override
  // void initState() {
  //   super.initState();
  //   spectrum = SpectrumDisplay();
  // }

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
              SpectrumDisplay(), // the Spectrum screen itself
              ScopedModelDescendant<SpectrumModel>(
                builder: (context, child, model) => Text(model.z80 == null
                    ? 'null'
                    : 'Program Counter: ${toHex16(model.z80.pc)}'),
              ), // yeah - we're wired up :)
              Container(
                  padding: const EdgeInsets.all(40.0),
                  child: RichText(
                      text: TextSpan(
                          text:
                              "Not yet updating the screen frame-by-frame. Use the last button below to manually advance the emulator. You'll need to press it about 10 times to fully advance through the boot process.",
                          style: TextStyle(color: Colors.black87)))),
              ButtonTheme.bar(
                child: ScopedModelDescendant<SpectrumModel>(
                  builder: (context, child, model) => ButtonBar(
                        alignment: MainAxisAlignment.center,
                        children: <Widget>[
                          FlatButton(
                              child: Text('TEST SCREEN'),
                              onPressed: model.loadTestScreenshot),
                          FlatButton(
                              child: Text('RESET'),
                              onPressed: model.resetEmulator),
                          FlatButton(
                              child: Text('STEP FORWARD'),
                              onPressed: model.executeInstruction),
                        ],
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}