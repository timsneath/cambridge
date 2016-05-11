using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.IO;
using System.Linq;
using System.Runtime.InteropServices.WindowsRuntime;
using System.Text;
using System.Threading.Tasks;
using Windows.UI;
using Windows.UI.Xaml.Media.Imaging;

namespace ProjectCambridge.EmulatorCore
{
    // Good tips on writing bitmaps here: http://www.charlespetzold.com/blog/2012/08/WriteableBitmap-Pixel-Arrays-in-CSharp-and-CPlusPlus.html
    public class Display
    {
        public WriteableBitmap Bitmap { get; }

        Stream pixelStream;
        byte[] displayBuffer;

        public ReadOnlyDictionary<byte, Windows.UI.Color> SpectrumColors;

        // See http://www.animatez.co.uk/computers/zx-spectrum/screen-memory-layout/
        public Display()
        {
            // ZX Spectrum display is 256 x 192 * 4-bit
            // Windows color information is stored as BGRA (so 32-bit)

            displayBuffer = new byte[256 * 192 * 4];
            Bitmap = new WriteableBitmap(256, 192);
            pixelStream = Bitmap.PixelBuffer.AsStream();

            var colors = new Dictionary<byte, Color>();
            colors.Add(0x00, Color.FromArgb(0xFF, 0x00, 0x00, 0x00)); // black
            colors.Add(0x01, Color.FromArgb(0xFF, 0x00, 0x00, 0xCD)); // blue
            colors.Add(0x02, Color.FromArgb(0xFF, 0xCD, 0x00, 0x00)); // red
            colors.Add(0x03, Color.FromArgb(0xFF, 0xCD, 0x00, 0xCD)); // magenta
            colors.Add(0x04, Color.FromArgb(0xFF, 0x00, 0xCD, 0x00)); // green
            colors.Add(0x05, Color.FromArgb(0xFF, 0x00, 0xCD, 0xCD)); // cyan
            colors.Add(0x06, Color.FromArgb(0xFF, 0xCD, 0xCD, 0x00)); // yellow
            colors.Add(0x07, Color.FromArgb(0xFF, 0xCD, 0xCD, 0xCD)); // gray
            colors.Add(0x08, Color.FromArgb(0xFF, 0x00, 0x00, 0x00)); // black
            colors.Add(0x09, Color.FromArgb(0xFF, 0x00, 0x00, 0xFF)); // bright blue
            colors.Add(0x0A, Color.FromArgb(0xFF, 0xFF, 0x00, 0x00)); // bright red
            colors.Add(0x0B, Color.FromArgb(0xFF, 0xFF, 0x00, 0xFF)); // bright magenta
            colors.Add(0x0C, Color.FromArgb(0xFF, 0x00, 0xFF, 0x00)); // bright green
            colors.Add(0x0D, Color.FromArgb(0xFF, 0x00, 0xFF, 0xFF)); // bright cyan
            colors.Add(0x0E, Color.FromArgb(0xFF, 0xFF, 0xFF, 0x00)); // bright yellow
            colors.Add(0x0F, Color.FromArgb(0xFF, 0xFF, 0xFF, 0xFF)); // white

            SpectrumColors = new ReadOnlyDictionary<byte, Color>(colors);
        }

        public void ShowTestImage()
        {
            // TODO: Data bind this to the image control 

            var r = new Random();

            // draw some stuff
            int idx;
            for (int y = 0; y < 192; y++)
            {
                for (int x = 0; x < 256; x++)
                {
                    idx = 4 * (y * 256 + x);
                    displayBuffer[idx++] = (byte)x;
                    displayBuffer[idx++] = (byte)y;
                    displayBuffer[idx++] = (byte)r.Next();
                    displayBuffer[idx] = 255;
                }
            }

            pixelStream.Seek(0, SeekOrigin.Begin);
            pixelStream.Write(displayBuffer, 0, displayBuffer.Length);

            Bitmap.Invalidate();

        }

        public void Repaint(Memory memory)
        {
            int idx;

            // display is 192 lines of 32 bytes
            for (int y = 0; y < 192; y++)
            {
                for (int x = 0; x < 32; x++)
                {
                    idx = 4 * (y * 256 + x);

                    // transform (x, y) coordinates to appropriate memory location
                    var y7y6 = y & 0xC0;
                    var y5y4y3 = y & 0x38;
                    var y2y1y0 = y & 0x07;
                    var hi = 0x40 | (y7y6 << 3) | y2y1y0;
                    var lo = (y5y4y3 << 5) | x;
                    var addr = (hi << 8) + lo;

                    // read in the 8 pixels of monochrome data
                    var pixel8 = memory.ReadByte((ushort)addr);

                    // identify current ink / paper color for this pixel location

                    // Color attribute data is held in the format:
                    // 
                    //    7  6  5  4  3  2  1  0
                    //    F  B  P2 P1 P0 I2 I1 I0
                    // 
                    //  for 8x8 cells starting at 0x5800
                    var color = memory.ReadByte((ushort)(0x5800 + ((y / 8) * 32 + x)));
                    var paperColor = SpectrumColors[(byte)((color & 0x78) >> 3)]; // 0x78 = 01111000
                    var inkColorAsByte = (byte)((color & 0x07)); // 0x07 = 00000111
                    if ((color & 0x40) == 0x40) // bright on (i.e. 0x40 = 01000000)
                    {
                        inkColorAsByte |= 0x08;
                    }
                    var inkColor = SpectrumColors[inkColorAsByte];


                    // apply state to the display
                    for (int bit = 0; bit < 8; bit++)
                    {
                        bool isBitSet = (pixel8 & (1 << bit)) == 1 << bit;
                        displayBuffer[idx++] = (byte)(isBitSet ? inkColor.R : paperColor.R); // red
                        displayBuffer[idx++] = (byte)(isBitSet ? inkColor.G : paperColor.G); // green
                        displayBuffer[idx++] = (byte)(isBitSet ? inkColor.B : paperColor.B); // blue
                        displayBuffer[idx] = (byte)(isBitSet ? inkColor.A : paperColor.A); // blue
                    }
                }
            }

            pixelStream.Seek(0, SeekOrigin.Begin);
            pixelStream.Write(displayBuffer, 0, displayBuffer.Length);

            Bitmap.Invalidate();
        }
    }
}
