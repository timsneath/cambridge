using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ProjectCambridge
{
    /*
     *    ZX Spectrum memory map, from:
     *       http://www.animatez.co.uk/computers/zx-spectrum/memory-map/
     * 
     *    0x0000-0x3FFF   ROM
     *    0x4000-0x57FF   Screen memory
     *    0x5800-0x5AFF   Screen memory (color data)
     *    0x5B00-0x5BFF   Printer buffer
     *    0x5C00-0x5CBF   System variables
     *    0x5CC0-0x5CCA   Reserved
     *    0x5CCB-0xFF57   Available memory
     *    0xFF58-0xFFFF   Reserved
     *    
     *    The block of RAM between &4000 and &7FFF is contended, that is access 
     *    to the RAM is shared between the processor and the ULA. The ULA has 
     *    priority access when the screen is being drawn.
     *    
     */

    public class Memory
    {
        const int ROM_TOP = 0x3FFF;
        const int RAM_TOP = 0xFFFF;

        private byte[] memory;

        public Memory()
        {
            memory = new byte[RAM_TOP + 1];
            this.Reset();
        }

        public void Reset()
        {
            Array.Clear(memory, ROM_TOP + 1, RAM_TOP - ROM_TOP);
        }

        public void Load(ushort start, byte[] contents)
        {
            foreach (byte c in contents)
            {
                // TODO: avoid the encapsulated if check by writing directly
                this.WriteByte(start++, c);
            }
        }

        public byte ReadByte(ushort addr)
        {
            return memory[addr];
        }

        public ushort ReadWord(ushort addr)
        {
            return (ushort)((memory[addr] << 8) + memory[addr+1]); 
        }

        public void WriteByte(ushort addr, byte val)
        {
            if (addr > ROM_TOP)
            {
                memory[addr] = val;
            }
            else
            {
                throw new SegmentationFaultException($"Attempted to write a byte to address {addr}, which is in the ROM area.");
            }
        }

        internal void WriteWord(ushort addr, ushort val)
        {
            if (addr > ROM_TOP - 1)
            {
                memory[addr] = (byte)((val & 0xFF00) >> 8);
                memory[addr + 1] = (byte)(val & 0x00FF);
            }
            else
            {
                throw new SegmentationFaultException($"Attempted to write a word to address {addr}, which is in the ROM area.");
            }
        }
    }
}
