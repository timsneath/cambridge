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
            C = 1,   // carry flag (bit 0)
            N = 2,   // add/subtract flag (bit 1)
            P = 4,   // parity/overflow flag (bit 2)
            F3 = 8,  // undocumented flag
            H = 16,  // half carry flag (bit 4)
            F5 = 32, // undocumented flag
            Z = 64,  // zero flag (bit 6)
            S = 128  // sign flag (bit 7)
        }

        // The main register set can be used individually as 8-bit registers or combined to form 16-bit registers
        public byte a, b, c, d, e, h, l;
        public Flags f;

        // The alternate register set (A', F', B', C', D', E', H', L')
        public byte a_, b_, c_, d_, e_, h_, l_;
        public Flags f_;

        public byte i; // Interrupt Page Address register
        public byte r; // Memory Refresh register

        public ushort ix, iy; // Index registers
        public ushort pc; // Program Counter
        public ushort sp; // Stack pointer

        public bool iff1;
        public bool iff2;

        public byte im; // Interrupt Mode

        public bool fC
        {
            get { return (f & Flags.C) == Flags.C; }
            set { if (value) f |= Flags.C; else f &= ~Flags.C; }
        }

        public bool fN
        {
            get { return (f & Flags.N) == Flags.N; }
            set { if (value) f |= Flags.N; else f &= ~Flags.N; }
        }

        public bool fPV
        {
            get { return (f & Flags.P) == Flags.P; }
            set { if (value) f |= Flags.P; else f &= ~Flags.P; }
        }

        public bool f3
        {
            get { return (f & Flags.F3) == Flags.F3; }
            set { if (value) f |= Flags.F3; else f &= ~Flags.F3; }
        }

        public bool fH
        {
            get { return (f & Flags.H) == Flags.H; }
            set { if (value) f |= Flags.H; else f &= ~Flags.H; }
        }

        public bool f5
        {
            get { return (f & Flags.F5) == Flags.F5; }
            set { if (value) f |= Flags.F5; else f &= ~Flags.F5; }
        }

        public bool fZ
        {
            get { return (f & Flags.Z) == Flags.Z; }
            set { if (value) f |= Flags.Z; else f &= ~Flags.Z; }
        }

        public bool fS
        {
            get { return (f & Flags.S) == Flags.S; }
            set { if (value) f |= Flags.S; else f &= ~Flags.S; }
        }

        public ushort af
        {
            get
            {
                return (ushort)((a << 8) + f);
            }
            set
            {
                a = HighByte(value);
                f = (Flags)LowByte(value);
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
            set { a_ = HighByte(value); f_ = (Flags)LowByte(value); }
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
