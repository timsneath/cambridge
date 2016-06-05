using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ProjectCambridge.EmulatorCore
{
    public class Spectrum
    {
        private Z80 z80;

        public Spectrum()
        {
            z80 = new Z80(new Memory());
            

        }
    }
}
