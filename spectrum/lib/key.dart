import 'package:flutter/material.dart';

import 'package:spectrum/spectrum/ula.dart';

class Keycap extends StatelessWidget {
  final String mainKeycap;
  final String commandKeycap;
  final String redKeycap;
  final String belowKeycap;
  final String aboveKeycap;

  bool get isNumericKey => int.tryParse(mainKeycap) != null;

  Keycap(
      {this.mainKeycap = '',
      this.commandKeycap = '',
      this.redKeycap = '',
      this.belowKeycap = '',
      this.aboveKeycap = ''});

  @override
  Widget build(BuildContext context) {
    // the outer shape of the key
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: GestureDetector(
        onTapDown: (TapDownDetails details) => ULA.keyPressed(this.mainKeycap),
        onTapUp: (TapUpDetails details) => ULA.keyReleased(this.mainKeycap),
        child: Container(
          padding: const EdgeInsets.fromLTRB(4, 2, 4, 2),
          color: Colors.black,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // what appears above the key
              Container(
                padding: const EdgeInsets.fromLTRB(4, 0, 0, 0),
                child: Text(
                  this.aboveKeycap,
                  style: isNumericKey
                      ? TextStyle(color: Colors.white)
                      : TextStyle(color: Colors.green),
                ),
              ),

              // the key itself
              Container(
                height: 40,
                width: 80,
                color: Colors.grey,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Text(
                      this.mainKeycap,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    Column(
                      children: <Widget>[
                        Text(
                          this.redKeycap,
                          style: isNumericKey
                              ? TextStyle(color: Colors.white)
                              : TextStyle(color: Colors.red[900]),
                        ),
                        Container(height: 2),
                        Text(
                          this.commandKeycap,
                          style: isNumericKey
                              ? TextStyle(color: Colors.red[900])
                              : TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // what appears below the key
              Container(
                padding: const EdgeInsets.fromLTRB(4, 0, 0, 0),
                child: Text(
                  this.belowKeycap,
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Keyboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Column(
        children: <Widget>[
          Table(
            children: <TableRow>[
              TableRow(
                children: <Widget>[
                  Keycap(
                      mainKeycap: '1',
                      belowKeycap: 'DEF FN',
                      aboveKeycap: 'EDIT',
                      commandKeycap: '!',
                      redKeycap: '[]'),
                  Keycap(
                      mainKeycap: '2',
                      belowKeycap: 'FN',
                      aboveKeycap: 'CAP LOCK',
                      commandKeycap: '@',
                      redKeycap: '[]'),
                  Keycap(
                      mainKeycap: '3',
                      belowKeycap: 'LINE',
                      aboveKeycap: 'TRUE VID.',
                      commandKeycap: '#',
                      redKeycap: '[]'),
                  Keycap(
                      mainKeycap: '4',
                      belowKeycap: 'OPEN #',
                      aboveKeycap: 'INV. VIDEO',
                      commandKeycap: '\$',
                      redKeycap: '[]'),
                  Keycap(
                      mainKeycap: '5',
                      belowKeycap: 'CLOSE #',
                      aboveKeycap: '[L]',
                      commandKeycap: '%',
                      redKeycap: '[]'),
                  Keycap(
                      mainKeycap: '6',
                      belowKeycap: 'MOVE',
                      aboveKeycap: '[D]',
                      commandKeycap: '&',
                      redKeycap: '[]'),
                  Keycap(
                      mainKeycap: '7',
                      belowKeycap: 'ERASE',
                      aboveKeycap: '[U]',
                      commandKeycap: '\'',
                      redKeycap: '[]'),
                  Keycap(
                      mainKeycap: '8',
                      belowKeycap: 'POINT',
                      aboveKeycap: '[R]',
                      commandKeycap: '(',
                      redKeycap: '[]'),
                  Keycap(
                      mainKeycap: '9',
                      belowKeycap: 'CAT',
                      aboveKeycap: 'GRAPHICS',
                      commandKeycap: ')',
                      redKeycap: ''),
                  Keycap(
                      mainKeycap: '0',
                      belowKeycap: 'FORMAT',
                      aboveKeycap: 'DELETE',
                      commandKeycap: '_',
                      redKeycap: ''),
                ],
              ),
              TableRow(
                children: <Widget>[
                  Keycap(
                      mainKeycap: 'Q',
                      belowKeycap: 'ASN',
                      aboveKeycap: 'SIN',
                      commandKeycap: 'PLOT',
                      redKeycap: '<='),
                  Keycap(
                      mainKeycap: 'W',
                      belowKeycap: 'ACS',
                      aboveKeycap: 'COS',
                      commandKeycap: 'DRAW',
                      redKeycap: '<>'),
                  Keycap(
                      mainKeycap: 'E',
                      belowKeycap: 'ATN',
                      aboveKeycap: 'TAN',
                      commandKeycap: 'REM',
                      redKeycap: '>='),
                  Keycap(
                      mainKeycap: 'R',
                      belowKeycap: 'VERIFY',
                      aboveKeycap: 'INT',
                      commandKeycap: 'RUN',
                      redKeycap: '<'),
                  Keycap(
                      mainKeycap: 'T',
                      belowKeycap: 'MERGE',
                      aboveKeycap: 'RND',
                      commandKeycap: 'RAND',
                      redKeycap: '>'),
                  Keycap(
                      mainKeycap: 'Y',
                      belowKeycap: '[',
                      aboveKeycap: 'STR \$',
                      commandKeycap: 'RETURN',
                      redKeycap: 'AND'),
                  Keycap(
                      mainKeycap: 'U',
                      belowKeycap: ']',
                      aboveKeycap: 'CHR \$',
                      commandKeycap: 'IF',
                      redKeycap: 'OR'),
                  Keycap(
                      mainKeycap: 'I',
                      belowKeycap: 'IN',
                      aboveKeycap: 'CODE',
                      commandKeycap: 'INPUT',
                      redKeycap: 'AT'),
                  Keycap(
                      mainKeycap: 'O',
                      belowKeycap: 'OUT',
                      aboveKeycap: 'PEEK',
                      commandKeycap: 'POKE',
                      redKeycap: ':'),
                  Keycap(
                      mainKeycap: 'P',
                      belowKeycap: '©',
                      aboveKeycap: 'TAB',
                      commandKeycap: 'PRINT',
                      redKeycap: '\"'),
                ],
              ),
              TableRow(
                children: [
                  Keycap(
                      mainKeycap: 'A',
                      belowKeycap: '~',
                      aboveKeycap: 'READ',
                      commandKeycap: 'NEW',
                      redKeycap: 'STOP'),
                  Keycap(
                    mainKeycap: 'S',
                    belowKeycap: '|',
                    aboveKeycap: 'RESTORE',
                    commandKeycap: 'SAVE',
                    redKeycap: 'NOT',
                  ),
                  Keycap(
                      mainKeycap: 'D',
                      belowKeycap: '\\',
                      aboveKeycap: 'DATA',
                      commandKeycap: 'DIM',
                      redKeycap: 'STEP'),
                  Keycap(
                      mainKeycap: 'F',
                      belowKeycap: '{',
                      aboveKeycap: 'SGN',
                      commandKeycap: 'FOR',
                      redKeycap: 'TO'),
                  Keycap(
                      mainKeycap: 'G',
                      belowKeycap: '}',
                      aboveKeycap: 'ABS',
                      commandKeycap: 'GOTO',
                      redKeycap: 'THEN'),
                  Keycap(
                      mainKeycap: 'H',
                      belowKeycap: 'CIRCLE',
                      aboveKeycap: 'SQR',
                      commandKeycap: 'GOSUB',
                      redKeycap: '↑'),
                  Keycap(
                      mainKeycap: 'J',
                      belowKeycap: 'VAL \$',
                      aboveKeycap: 'VAL',
                      commandKeycap: 'LOAD',
                      redKeycap: '-'),
                  Keycap(
                      mainKeycap: 'K',
                      belowKeycap: 'SCREEN \$',
                      aboveKeycap: 'LEN',
                      commandKeycap: 'LIST',
                      redKeycap: '+'),
                  Keycap(
                      mainKeycap: 'L',
                      belowKeycap: 'ATTR',
                      aboveKeycap: 'USR',
                      commandKeycap: 'LET',
                      redKeycap: '='),
                  Keycap(mainKeycap: 'ENTER'),
                ],
              ),
              TableRow(
                children: <Widget>[
                  Keycap(mainKeycap: 'SHIFT'),
                  Keycap(
                      mainKeycap: 'Z',
                      belowKeycap: 'BEEP',
                      aboveKeycap: 'LN',
                      commandKeycap: 'COPY',
                      redKeycap: ':'),
                  Keycap(
                      mainKeycap: 'X',
                      belowKeycap: 'INK',
                      aboveKeycap: 'EXP',
                      commandKeycap: 'CLEAR',
                      redKeycap: '£'),
                  Keycap(
                      mainKeycap: 'C',
                      belowKeycap: 'PAPER',
                      aboveKeycap: 'L PRINT',
                      commandKeycap: 'CONT',
                      redKeycap: '?'),
                  Keycap(
                      mainKeycap: 'V',
                      belowKeycap: 'FLASH',
                      aboveKeycap: 'L LIST',
                      commandKeycap: 'CLS',
                      redKeycap: '/'),
                  Keycap(
                      mainKeycap: 'B',
                      belowKeycap: 'BRIGHT',
                      aboveKeycap: 'BIN',
                      commandKeycap: 'BORDER',
                      redKeycap: '*'),
                  Keycap(
                      mainKeycap: 'N',
                      belowKeycap: 'OVER',
                      aboveKeycap: 'IN KEY \$',
                      commandKeycap: 'NEXT',
                      redKeycap: ','),
                  Keycap(
                      mainKeycap: 'M',
                      belowKeycap: 'INVERSE',
                      aboveKeycap: 'PI',
                      commandKeycap: 'PAUSE',
                      redKeycap: '.'),
                  Keycap(mainKeycap: 'SYMBL'),
                  Keycap(mainKeycap: 'SPACE'),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
