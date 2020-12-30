import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'core/disassembler.dart';
import 'core/utility.dart';
import 'main.dart';

class DisassemblyView extends StatefulWidget {
  @override
  _DisassemblyViewState createState() => _DisassemblyViewState();
}

class _DisassemblyViewState extends State<DisassemblyView> {
  @override
  Widget build(BuildContext context) {
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
            style: GoogleFonts.sourceCodePro(),
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
}
