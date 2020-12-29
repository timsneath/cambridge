# Tests

## Unit Test Creation

The FUSE emulator contains a large unit test suite of over 1,300 tests, which
cover both documented and undocumented opcodes:
   <http://fuse-emulator.sourceforge.net/>

The tests are delivered in two files: a tests.in file that contains test inputs
and a tests.expected that gives the expected output state for the Z80 processor.
These tests are licensed under the GPL, as documented in that folder.

This project loads them from disk and creates Dart unit tests out of the
results.

### Instructions

Execute the command utility `createtests.dart` from the root of the repo. If
this executes successfully, it should create a file in the `test/` folder that
contains the resultant tests.


```bash
   flutter test
```
