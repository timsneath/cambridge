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
        public MainWindow()
        {
            InitializeComponent();
        }

        private void Execute_Click(object sender, RoutedEventArgs e)
        {
            var z80 = new Z80();
            var code = new byte[] { 0x00, 0x00, 0x00, 0x00, 0x04, 0x0C, 0x04 };

            z80.LoadMemory(0xA000, code);
            z80.pc = 0xA000;

            foreach (var x in code)
            {
                z80.Tick();
            }

            this.Results.Text = z80.GetState();
        }
    }
}
