# Project Cambridge

A simple ZX Spectrum emulator, originally built with UWP and C# before being
ported to Flutter and Dart.

The Z80 core passes the FUSE test suite, which contains 1356 tests that evaluate
the correctness of both documented and undocumented instructions.

Functional enough to be able to boot the supplied ZX Spectrum 48K image and
accept keyboard input, as well as load various applications in SNA or ROM
format.

Things not yet working:
 - Interrupts aren't fully enabled (IM 2 in particular)
 - No sound support

This is an ongoing project that I'm using to learn and improve; feel free to
contribute, critique or improve what you see. I work on this in my spare time
here and there; it's not supposed to be the pinnacle of coding accomplishment!
