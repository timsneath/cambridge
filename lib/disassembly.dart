import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
          Text('Program Counter: ${toHex16(z80.pc)}',
              style: const TextStyle(
                fontFamily: 'ZX Spectrum',
                fontSize: 10,
              )),
          Text(
              Disassembler.disassembleMultipleInstructions(
                  memory.memory.sublist(z80.pc, z80.pc + (4 * 8)), 8, z80.pc),
              textAlign: TextAlign.left,
              softWrap: true,
              style: const TextStyle(
                fontFamily: 'ZX Spectrum',
                fontSize: 10,
              )),
          Text('Breakpoints: ${breakpoints.map(toHex32)}',
              style: const TextStyle(
                fontFamily: 'ZX Spectrum',
                fontSize: 10,
              )),
          Row(
            children: <Widget>[
              const Text(
                'Add Breakpoint: ',
                style: TextStyle(
                  fontFamily: 'ZX Spectrum',
                  fontSize: 10,
                ),
              ),
              SizedBox(
                width: 100,
                child: TextField(
                    autocorrect: false,
                    onSubmitted: addBreakpoint,
                    keyboardType: TextInputType.text,
                    style: const TextStyle(
                      fontFamily: 'ZX Spectrum',
                      fontSize: 10,
                    )),
              ),
            ],
          ),
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
