﻿using System;
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

// TODO: A lot of the logic here will ultimately reside in EmulatorCore\spectrum.cs
namespace ProjectCambridge
{
    public sealed partial class MainPage : Page
    {
        Z80 z80;
        Memory memory;
        Spectrum spectrum;
        Display display;
        DispatcherTimer screenRefreshTimer;

        public MainPage()
        {
            this.InitializeComponent();
            memory = new Memory();
            display = new Display();

        }


        private async void RunTestCode_Click(object sender, RoutedEventArgs e)
        {
            var code = new byte[] { 0x00, 0x00, 0x00, 0x00, 0x04, 0x0C, 0x04, 0x76 };

            memory.Load(0xA000, code);
            z80 = new Z80(memory, 0xA000);

            await Execute();
        }

        private async Task Execute()
        {
            bool notHalt = true;
            long instructionsExecuted = 0;

            while (notHalt)
            {
                if (DebugSwitch.IsOn)
                {
                    UpdateRegisterDebugDisplay();

                    // probably 'better' ways to do this - but this gives the UI time to update, and slows the
                    // clock down to a manageable speed
                    await Task.Delay(TimeSpan.FromSeconds(ExecutionSpeed.Value));
                }
                else if (instructionsExecuted++ % 0x1000 == 0)
                {
                    await Task.Delay(1);
                }
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
            ZXSpectrumScreen.Source = display.Bitmap;

            memory = new Memory(ROMProtected: true);
            var rom = new byte[16384];

            var file = await StorageFile.GetFileFromApplicationUriAsync(new Uri("ms-appx:///roms/48.rom"));
            var fs = await file.OpenStreamForReadAsync();

            fs.Read(rom, 0, 16384);
            memory.Reset();
            memory.Load(0x0000, rom);

            screenRefreshTimer = new DispatcherTimer();
            screenRefreshTimer.Tick += screenRefreshTimer_Tick;
            screenRefreshTimer.Interval = new TimeSpan(0, 0, 0, 0, 100);

            screenRefreshTimer.Start();

            z80 = new Z80(memory, 0x0000);
            UpdateRegisterDebugDisplay();

            await Execute();
        }

        private void screenRefreshTimer_Tick(object sender, object e)
        {
            display.Repaint(memory);
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

        private void RepaintDisplay_Click(object sender, RoutedEventArgs e)
        {
            display.Repaint(memory);
        }

        private async void TimeBootup_Click(object sender, RoutedEventArgs e)
        {
            var stopwatch = new System.Diagnostics.Stopwatch();

            memory = new Memory(ROMProtected: true);
            var rom = new byte[16384];

            var file = await StorageFile.GetFileFromApplicationUriAsync(new Uri("ms-appx:///roms/48.rom"));
            var fs = await file.OpenStreamForReadAsync();

            fs.Read(rom, 0, 16384);

            var testElapsedTime = new List<long>();
            for (int testIter = 0; testIter < 100; testIter++)
            {
                memory.Reset();
                memory.Load(0x0000, rom);

                screenRefreshTimer = new DispatcherTimer();
                screenRefreshTimer.Tick += screenRefreshTimer_Tick;
                screenRefreshTimer.Interval = new TimeSpan(0, 0, 0, 0, 100);

                screenRefreshTimer.Start();
                z80 = new Z80(memory, 0x0000);

                stopwatch.Reset();
                stopwatch.Start();

                while (z80.pc != 0x15ED)
                {
                    z80.ExecuteNextInstruction();
                }

                screenRefreshTimer.Stop();
                stopwatch.Stop();

                testElapsedTime.Add(stopwatch.ElapsedMilliseconds);
            }

            testElapsedTime.Sort();
            var dialog = new Windows.UI.Popups.MessageDialog($"Execution took an average of {testElapsedTime.Average()}ms.\nActual time taken: {string.Join(", ", testElapsedTime.ToArray())}");
            await dialog.ShowAsync();
        }

        private async void StartEmulator_Click(object sender, RoutedEventArgs e)
        {
            spectrum = new Spectrum();
            await spectrum.InitializeROMAsync();
            ZXSpectrumScreen.Source = spectrum.DisplayBitmap;
            await spectrum.Start();
        }

        private void StopEmulator_Click(object sender, RoutedEventArgs e)
        {
            spectrum.Stop();
        }

        private void Page_KeyDown(object sender, KeyRoutedEventArgs e)
        {
        }
    }
}
