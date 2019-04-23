import 'package:flutter/material.dart';

class Keycap extends StatelessWidget {
  final String mainKeycap;
  final String commandKeycap;
  final String redKeycap;
  final String belowKeycap;
  final String aboveKeycap;

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
        onTap: () => print(this.mainKeycap),
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
                  style: TextStyle(color: Colors.green),
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
                          style: TextStyle(color: Colors.red[900]),
                      

                        ),
                        Container(height: 2),
                        Text(
                          this.commandKeycap,
                          style: TextStyle(color: Colors.white),
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
      child: Table(
        defaultColumnWidth: FlexColumnWidth(1),
        defaultVerticalAlignment: TableCellVerticalAlignment.top,
        children: <TableRow>[
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
              // Keycap(
              //     mainKeycap: 'O',
              //     belowKeycap: 'OUT',
              //     aboveKeycap: 'PEEK',
              //     commandKeycap: 'POKE',
              //     redKeycap: ':'),
              // Keycap(
              //     mainKeycap: 'P',
              //     belowKeycap: '©',
              //     aboveKeycap: 'TAB',
              //     commandKeycap: 'PRINT',
              //     redKeycap: '\"'),
            ],
          ),
          TableRow(
            children: <Widget>[
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
              // Keycap(
              //     mainKeycap: 'L',
              //     belowKeycap: 'ATTR',
              //     aboveKeycap: 'USR',
              //     commandKeycap: 'LET',
              //     redKeycap: '='),
              // Keycap(mainKeycap: 'ENTER'),
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
              // Keycap(mainKeycap: 'SYM SHIFT'),
              // Keycap(mainKeycap: 'SPACE'),
            ],
          ),
        ],
      ),
    );
  }
}
