using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ProjectCambridge.EmulatorCore
{
    public partial class Z80
    {
        // Z80 Registers

        [Flags]
        public enum Flags
        {
            C = 0x01,   // carry flag (bit 0)
            N = 0x02,   // add/subtract flag (bit 1)
            P = 0x04,   // parity/overflow flag (bit 2)
            F3 = 0x08,  // undocumented flag
            H = 0x10,   // half carry flag (bit 4)
            F5 = 0x20,  // undocumented flag
            Z = 0x40,   // zero flag (bit 6)
            S = 0x80    // sign flag (bit 7)
        }

        // The main register set can be used individually as 8-bit registers or combined to form 16-bit registers
        public byte a, b, c, d, e, h, l;

        public byte f
        {
            get
            {
                return (byte)((fS ? 0x80 : 0x00) | (fZ ? 0x40 : 0x00) | (f5 ? 0x20 : 0x00) | (fH ? 0x10 : 0x00) |
                 (f3 ? 0x08 : 0x00) | (fPV ? 0x04 : 0x00) | (fN ? 0x02 : 0x00) | (fC ? 0x01 : 0x00));
            }
            set
            {
                fS = (value & 0x80) == 0x80;
                fZ = (value & 0x40) == 0x40;
                f5 = (value & 0x20) == 0x20;
                fH = (value & 0x10) == 0x10;
                f3 = (value & 0x08) == 0x08;
                fPV = (value & 0x04) == 0x04;
                fN = (value & 0x02) == 0x02;
                fC = (value & 0x01) == 0x01;
            }
        }

        // The alternate register set (A', F', B', C', D', E', H', L')
        public byte a_, f_, b_, c_, d_, e_, h_, l_;

        public byte i; // Interrupt Page Address register
        public byte r; // Memory Refresh register

        public ushort ix, iy; // Index registers
        public ushort pc; // Program Counter
        public ushort sp; // Stack pointer

        public bool iff1;
        public bool iff2;

        public byte im; // Interrupt Mode

        public bool fC { get; set; }
        public bool fN { get; set; }
        public bool fPV { get; set; }
        public bool f3 { get; set; }
        public bool fH { get; set; }
        public bool f5 { get; set; }
        public bool fZ { get; set; }
        public bool fS { get; set; }

        public ushort af
        {
            get
            {
                return (ushort)((a << 8) + f);
            }
            set
            {
                a = HighByte(value);
                f = LowByte(value);
            }
        }

        public ushort bc
        {
            get
            {
                return (ushort)((b << 8) + c);
            }
            set
            {
                b = HighByte(value);
                c = LowByte(value);
            }
        }

        public ushort de
        {
            get
            {
                return (ushort)((d << 8) + e);
            }
            set
            {
                d = HighByte(value);
                e = LowByte(value);
            }
        }

        public ushort hl
        {
            get
            {
                return (ushort)((h << 8) + l);
            }
            set
            {
                h = HighByte(value);
                l = LowByte(value);
            }
        }

        // Z80 instructions require you to exchange these registers (e.g. AF' <-> AF) 
        // before you can read their contents. These members are provided for 
        // diagnostic purposes only. 
        public ushort af_
        {
            get { return (ushort)((a_ << 8) + f_); }
            set { a_ = HighByte(value); f_ = LowByte(value); }
        }
        public ushort bc_
        {
            get { return (ushort)((b_ << 8) + c_); }
            set { b_ = HighByte(value); c_ = LowByte(value); }
        }
        public ushort de_
        {
            get { return (ushort)((d_ << 8) + e_); }
            set { d_ = HighByte(value); e_ = LowByte(value); }
        }
        public ushort hl_
        {
            get { return (ushort)((h_ << 8) + l_); }
            set { h_ = HighByte(value); l_ = LowByte(value); }
        }

        public byte ixh
        {
            get { return HighByte(ix); }
            set { ix = (ushort)((value << 8) + LowByte(ix)); }
        }

        public byte ixl
        {
            get { return LowByte(ix); }
            set { ix = (ushort)((HighByte(ix) << 8) + value); }
        }

        public byte iyh
        {
            get { return HighByte(iy); }
            set { iy = (ushort)((value << 8) + LowByte(iy)); }
        }

        public byte iyl
        {
            get { return LowByte(iy); }
            set { iy = (ushort)((HighByte(iy) << 8) + value); }
        }


        public byte HighByte(ushort val) => (byte)((val & 0xFF00) >> 8);
        public byte LowByte(ushort val) => (byte)(val & 0x00FF);
    }
}
