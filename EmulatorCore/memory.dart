// memory.dart -- implements the ZX Spectrum memory Map

// ZX Spectrum memory map, from:
//    http://www.animatez.co.uk/computers/zx-spectrum/memory-map/
//
// 0x0000-0x3FFF   ROM
// 0x4000-0x57FF   Screen memory
// 0x5800-0x5AFF   Screen memory (color data)
// 0x5B00-0x5BFF   Printer buffer
// 0x5C00-0x5CBF   System variables
// 0x5CC0-0x5CCA   Reserved
// 0x5CCB-0xFF57   Available memory
// 0xFF58-0xFFFF   Reserved
//
// The block of RAM between &4000 and &7FFF is contended, that is access
// to the RAM is shared between the processor and the ULA. The ULA has
// priority access when the screen is being drawn.

class Memory {
  static const romTop = 0x3FFF;
  static const ramTop = 0xFFFF;

  bool isRomProtected;
}