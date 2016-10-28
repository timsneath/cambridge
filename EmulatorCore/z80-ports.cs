using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ProjectCambridge.EmulatorCore
{
    public partial class Z80
    {
        //public Dictionary<int, byte> ports = new Dictionary<int, byte>();

        public char? keyPressed = null;

        // http://www.animatez.co.uk/computers/zx-spectrum/keyboard/ 
        private readonly Dictionary<int, char[]> ZXSPECTRUM_KEYMAP = new Dictionary<int, char[]>
        {
            { 0xFEFE, new char[] { '*', 'Z', 'X', 'C', 'V' } },
            { 0xFDFE, new char[] { 'A', 'S', 'D', 'F', 'G' } },
            { 0xFBFE, new char[] { 'Q', 'W', 'E', 'R', 'T' } },
            { 0xF7FE, new char[] { '1', '2', '3', '4', '5' } },
            { 0xEFFE, new char[] { '0', '9', '8', '7', '6' } },
            { 0xDFFE, new char[] { 'P', 'O', 'I', 'U', 'Y' } },
            { 0xBFFE, new char[] { '*', 'L', 'K', 'J', 'H' } },
            { 0x7FFE, new char[] { ' ', '*', 'M', 'N', 'B' } }
        };

        // rough placeholder code
        // TODO: move Spectrum-specific code out of Z80 class - lambda? 
        // TODO: genericize this beyond just keyboard
        public byte portRead(int port)
        {
            if (keyPressed.HasValue)
            {
                var bit = Array.IndexOf(ZXSPECTRUM_KEYMAP[port], keyPressed.Value);

                if (bit != -1)
                {
                    return SetBit(0, bit);
                }
            }

            return 0;
        }

        public void portWrite(int port, byte value)
        {

        }
    }
}
