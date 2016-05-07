using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Runtime.InteropServices.WindowsRuntime;
using System.Text;
using System.Threading.Tasks;
using Windows.UI.Xaml.Media.Imaging;

namespace ProjectCambridge.EmulatorCore
{
    // Good tips on writing bitmaps here: http://www.charlespetzold.com/blog/2012/08/WriteableBitmap-Pixel-Arrays-in-CSharp-and-CPlusPlus.html
    public class Display
    {
        WriteableBitmap displayBitmap;
        Stream pixelStream;
        byte[] displayBuffer;

        // See http://www.animatez.co.uk/computers/zx-spectrum/screen-memory-layout/
        public Display()
        {
            // ZX Spectrum display is 256 x 192 * 4-bit
            // Windows color information is stored as BGRA (so 32-bit)

            displayBuffer = new byte[256 * 192 * 4];
            displayBitmap = new WriteableBitmap(256, 192);
            pixelStream = displayBitmap.PixelBuffer.AsStream();
        }

        public WriteableBitmap UpdateDisplay()
        {
            // TODO: Data bind this to the image control 

            // draw some stuff
            int idx;
            for (int y = 0; y < 192; y++)
            {
                for (int x = 0; x < 256; x++)
                {
                    idx = 4 * (y * 256 + x);
                    displayBuffer[idx++] = (byte)x;
                    displayBuffer[idx++] = (byte)y;
                    displayBuffer[idx++] = (byte)255;
                    displayBuffer[idx] = 255;
                }
            }

            pixelStream.Seek(0, SeekOrigin.Begin);
            pixelStream.Write(displayBuffer, 0, displayBuffer.Length);

            return displayBitmap;
        }
    }
}
