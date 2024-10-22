using System;
using System.Diagnostics;
using System.IO;
using System.Runtime.InteropServices;
using System.Windows;
using System.Windows.Media.Imaging;

namespace SquareFilter
{
    public partial class MainWindow : Window
    {
        private BitmapImage loadedBitmap;

        [DllImport("JA_DLL.dll", CallingConvention = CallingConvention.StdCall)]
        public static extern void Increment(ref int value);
        public MainWindow()
        {
            InitializeComponent();
            int a = 5;
            //Increment(ref a); 
            int b = 5;
        }

        private void ImageDragEnter(object sender, DragEventArgs e)
        {
            if (e.Data.GetDataPresent(DataFormats.FileDrop))
            {
                string[] files = (string[])e.Data.GetData(DataFormats.FileDrop);
                if (files != null && IsValidImageFile(files[0]))
                {
                    e.Effects = DragDropEffects.Copy;
                    Debug.WriteLine($"Plik {files[0]} został rozpoznany jako obraz.");
                }
                else
                {
                    e.Effects = DragDropEffects.None;
                }
            }
            else
            {
                e.Effects = DragDropEffects.None;
            }
        }

        private void ImageDrop(object sender, DragEventArgs e)
        {
            if (e.Data.GetDataPresent(DataFormats.FileDrop))
            {
                string[] files = (string[])e.Data.GetData(DataFormats.FileDrop);
                if (files != null && IsValidImageFile(files[0]))
                {
                    Debug.WriteLine($"Ustawianie obrazu: {files[0]}");
                    SetImage(files[0]);
                }
                else
                {
                    Debug.WriteLine("Nieprawidłowy plik obrazu.");
                }
            }
            else
            {
                Debug.WriteLine("Brak obsługiwanego formatu danych.");
            }
        }

        private void SetImage(string filePath)
        {
            try
            {
                loadedBitmap = new BitmapImage();
                loadedBitmap.BeginInit();
                loadedBitmap.UriSource = new Uri(filePath, UriKind.Absolute);
                loadedBitmap.CacheOption = BitmapCacheOption.OnLoad;
                loadedBitmap.EndInit();

                image.Source = loadedBitmap;
                Debug.WriteLine("Obraz został pomyślnie ustawiony oraz bitmapa zapisana.");
            }
            catch (Exception ex)
            {
                Debug.WriteLine($"Błąd podczas ładowania obrazu: {ex.Message}");
            }
        }

        private bool IsValidImageFile(string filePath)
        {
            string extension = Path.GetExtension(filePath)?.ToLower();
            return extension == ".png" || extension == ".jpg" || extension == ".jpeg" || extension == ".bmp";
        }
    }
}
