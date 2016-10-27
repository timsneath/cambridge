using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Windows.Storage;
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
    }
}
