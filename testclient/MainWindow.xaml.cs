using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Data;
using System.Windows.Documents;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Imaging;
using System.Windows.Navigation;
using System.Windows.Shapes;

namespace ProjectCambridge
{
    /// <summary>
    /// Interaction logic for MainWindow.xaml
    /// </summary>
    public partial class MainWindow : Window
    {
        Z80 z80;

        public MainWindow()
        {
            InitializeComponent();
        }

        private void Execute_Click(object sender, RoutedEventArgs e)
        {
            z80 = new Z80();
            var code = new byte[] { 0x00, 0x00, 0x00, 0x00, 0x04, 0x0C, 0x04 };

            z80.LoadMemory(0xA000, code);
            z80.pc = 0xA000;

            for (;;)
            {
                z80.Tick();
                WriteRegisters();

                // lots of 'better' ways to do this - but this is a dirty hack to let the UI update without 
                // bothering to manage threads. Works well here where we deliberately want to sleep anyway.
                Application.Current.Dispatcher.Invoke(System.Windows.Threading.DispatcherPriority.Background, 
                    new System.Threading.ThreadStart(() => System.Threading.Thread.Sleep(200)));

                if (z80.pc >= 0xA000 + code.Length) break;
            }

            this.Results.Text = z80.GetState();
        }

        private void Test_Click(object sender, RoutedEventArgs e)
        {

        }

        private void WriteRegisters()
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
            FlagP.IsChecked = z80.fP;
            FlagS.IsChecked = z80.fS;
            FlagZ.IsChecked = z80.fZ;
        }
    }
}
