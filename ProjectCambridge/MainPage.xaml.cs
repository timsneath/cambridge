using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Runtime.InteropServices.WindowsRuntime;
using System.Threading.Tasks;
using Windows.Foundation;
using Windows.Foundation.Collections;
using Windows.Storage;
using Windows.UI.Xaml;
using Windows.UI.Xaml.Controls;
using Windows.UI.Xaml.Controls.Primitives;
using Windows.UI.Xaml.Data;
using Windows.UI.Xaml.Input;
using Windows.UI.Xaml.Media;
using Windows.UI.Xaml.Navigation;

using ProjectCambridge.EmulatorCore;

// The Blank Page item template is documented at http://go.microsoft.com/fwlink/?LinkId=402352&clcid=0x409

namespace ProjectCambridge
{
    public sealed partial class MainPage : Page
    {
        Z80 z80;
        Memory memory;
        Display display;

        public MainPage()
        {
            this.InitializeComponent();
            memory = new Memory();
            display = new Display();

            ZXSpectrumScreen.Source = display.Bitmap;
        }


        private void RunTestCode_Click(object sender, RoutedEventArgs e)
        {
            var code = new byte[] { 0x00, 0x00, 0x00, 0x00, 0x04, 0x0C, 0x04, 0x76 };

            memory.Load(0xA000, code);
            z80 = new Z80(memory, 0xA000);

            Execute();
        }

        private async void Execute()
        {
            bool notHalt = true;

            while (notHalt)
            {
                UpdateRegisterDebugDisplay();

                // probably 'better' ways to do this - but this gives the UI time to update, and slows the
                // clock down to a manageable speed
                await Task.Delay(TimeSpan.FromSeconds(ExecutionSpeed.Value));

                notHalt = z80.ExecuteNextInstruction();
            }

            UpdateRegisterDebugDisplay();
        }

        private void UpdateRegisterDebugDisplay()
        {
            RegA.Text = string.Format("{0:X2}", z80.a);
            RegBC.Text = string.Format("{0:X4}", z80.bc);
            RegDE.Text = string.Format("{0:X4}", z80.de);
            RegHL.Text = string.Format("{0:X4}", z80.hl);
            RegAPrime.Text = string.Format("{0:X2}", z80.a_);
            RegBCPrime.Text = string.Format("{0:X4}", z80.bc_);
            RegDEPrime.Text = string.Format("{0:X4}", z80.de_);
            RegHLPrime.Text = string.Format("{0:X4}", z80.hl_);
            RegIX.Text = string.Format("{0:X4}", z80.ix);
            RegIY.Text = string.Format("{0:X4}", z80.iy);
            RegSP.Text = string.Format("{0:X4}", z80.sp);
            RegPC.Text = string.Format("{0:X4}", z80.pc);
            FlagC.IsChecked = z80.fC;
            FlagH.IsChecked = z80.fH;
            FlagN.IsChecked = z80.fN;
            FlagPV.IsChecked = z80.fPV;
            FlagS.IsChecked = z80.fS;
            FlagZ.IsChecked = z80.fZ;
        }

        private async void ExecuteSpectrumROM_Click(object sender, RoutedEventArgs e)
        {
            var rom = new byte[16384];

            var file = await StorageFile.GetFileFromApplicationUriAsync(new Uri("ms-appx:///roms/48.rom"));
            var fs = await file.OpenStreamForReadAsync();
            fs.Read(rom, 0, 16384);
            memory.Reset();
            memory.Load(0x0000, rom);

            z80 = new Z80(memory, 0x0000);
            UpdateRegisterDebugDisplay();

            Execute();
        }

        private void DrawTest_Click(object sender, RoutedEventArgs e)
        {
            display.ShowTestImage();
        }

        private async void ScreenTest_Click(object sender, RoutedEventArgs e)
        {
            var ram = new byte[6912];

            var file = await StorageFile.GetFileFromApplicationUriAsync(new Uri("ms-appx:///roms/AticAtac.scr"));
            var fs = await file.OpenStreamForReadAsync();

            fs.Read(ram, 0, 6912);
            memory.Load(0x4000, ram);

            display.Repaint(memory);
        }

        private void Fast_Click(object sender, RoutedEventArgs e)
        {

        }
    }
}
