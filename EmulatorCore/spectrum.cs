using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Windows.Storage;
using Windows.System;
using Windows.UI.Xaml;
using Windows.UI.Xaml.Media.Imaging;

namespace ProjectCambridge.EmulatorCore
{
    public class Spectrum
    {
        Z80 z80;
        Memory memory;
        Display display;
        DispatcherTimer refreshTimer;
        bool cpuStopped = false;

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

        public WriteableBitmap DisplayBitmap => display.Bitmap;

        public Spectrum()
        {
            memory = new Memory(ROMProtected: true);
            display = new Display();
        }

        public async Task InitializeROMAsync()
        { 
            var rom = new byte[16384];

            var storageFile = await StorageFile.GetFileFromApplicationUriAsync(new Uri("ms-appx:///roms/48.rom"));
            var fileStream = await storageFile.OpenStreamForReadAsync();

            fileStream.Read(rom, 0, 16384);
            memory.Load(0x0000, rom);

            refreshTimer = new DispatcherTimer();
            refreshTimer.Tick += refreshTimer_Tick;
            refreshTimer.Interval = new TimeSpan(0, 0, 0, 0, 100); // every 1/10th second right now
        }

        public async Task Start()
        {
            long instructionsExecuted = 0;

            refreshTimer.Start();

            z80 = new Z80(memory, 0x0000);

            while (!cpuStopped)
            {
                z80.ExecuteNextInstruction();

                if (instructionsExecuted++ % 0x1000 == 0)
                {
                    await Task.Delay(1);
                }
            }
        }
        public void Stop()
        {
            cpuStopped = true;
            refreshTimer.Stop();
        }

        private void refreshTimer_Tick(object sender, object e)
        {
            display.Repaint(memory);
        }

        public void KeyDown(VirtualKey key)
        {
            z80.keyPressed = (char)key;
        }
    }
}
