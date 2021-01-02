# Project Cambridge

A simple ZX Spectrum emulator, originally built with UWP and C# before being
ported to Flutter and Dart.

More at:
   https://twitter.com/timsneath/status/1345088320313774080

The Z80 core passes the FUSE test suite, which contains 1356 tests that evaluate
the correctness of both documented and undocumented instructions.

Functional enough to be able to boot the supplied ZX Spectrum 48K image and
accept keyboard input, as well as load various applications in SNA or ROM
format.

Things not yet working:
 - Interrupts aren't fully enabled (IM 2 in particular)
 - No sound support

Prerequisites: this is written with the latest daily master builds of Flutter,
including sound null safety. As of the time of writing (Jan 2021), this will
not compile on the stable release of Flutter; make sure you switch to the beta
channel before attempting to run this, using:

```bash
flutter channel beta
flutter upgrade
```

This is an ongoing project that I'm using to learn and improve; feel free to
contribute, critique or improve what you see. I work on this in my spare time
here and there; it's not supposed to be the pinnacle of coding accomplishment!
