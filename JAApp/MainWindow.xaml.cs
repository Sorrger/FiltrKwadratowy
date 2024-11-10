using System;
using System.Diagnostics;
using System.IO;
using System.Runtime.InteropServices;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Media;
using System.Windows.Media.Imaging;

namespace SquareFilter
{
    public partial class MainWindow : Window
    {
        private BitmapSource loadedBitmap;

        [DllImport("/../../../../x64/Debug/JADll.dll", CallingConvention = CallingConvention.StdCall)]
        public static extern void Darken(ref byte pixelData, int length);

        [DllImport("/../../../../x64/Debug/CPPDll.dll", CallingConvention = CallingConvention.StdCall)]
        public static extern void Darken2(ref byte pixelData, int width, int startY, int segmentHeight);

        public MainWindow()
        {
            InitializeComponent();

        }
        public void ButtonTask()
        {
            if (loadedBitmap == null)
            {
                Debug.WriteLine("Obraz nie został załadowany.");
                return;
            }
            if (threadChoice.SelectedItem is ComboBoxItem selectedItem)
            {
                int numThreads;
                if (int.TryParse(selectedItem.Content.ToString(), out numThreads) && numThreads > 0)
                {
                    int height = loadedBitmap.PixelHeight;
                    int width = loadedBitmap.PixelWidth;

                    WriteableBitmap filteredBitmap = new WriteableBitmap(loadedBitmap);

                    filteredBitmap.Lock();
                    try
                    {
                        int length = width * height * 3;
                        byte[] pixelData = new byte[length];

                        IntPtr pBackBuffer = filteredBitmap.BackBuffer;
                        Marshal.Copy(pBackBuffer, pixelData, 0, length);

                        int baseSegmentHeight = height / numThreads;
                        int extraRows = height % numThreads;

                        int[] segmentHeights = new int[numThreads];
                        for (int i = 0; i < numThreads; i++)
                        {
                            segmentHeights[i] = baseSegmentHeight;
                            if (i < extraRows)
                            {
                                segmentHeights[i]++;
                            }
                        }

                        bool cppButton = (bool)CRB.IsChecked;
                        bool asmButton = (bool)ARB.IsChecked;

                        Stopwatch stopwatch = Stopwatch.StartNew();

                        Parallel.For(0, numThreads, i =>
                        {
                            int startY = 0;
                            for (int j = 0; j < i; j++)
                            {
                                startY += segmentHeights[j];
                            }
                            int segmentHeight = segmentHeights[i];

                            int startIdx = startY * width * 3;

                            if (asmButton)
                                Darken(ref pixelData[startIdx], segmentHeight * width * 3);
                            else if (cppButton)
                                Darken2(ref pixelData[startIdx], width, startY, segmentHeight);
                            else
                                Debug.WriteLine("Bez filtrowania - nie wybrano trybu");
                        });

                        Marshal.Copy(pixelData, 0, pBackBuffer, length);

                        stopwatch.Stop();
                        TimeSpan ts = stopwatch.Elapsed;

                        TimerText.Text = $"Czas przetwarzania: {ts.TotalMilliseconds} ms";
                    }
                    finally
                    {
                        filteredBitmap.Unlock();
                    }

                    FilteredImage.Source = filteredBitmap;
                }
                else
                {
                    Debug.WriteLine("Proszę wybrać prawidłową liczbę wątków.");
                }
            }
            else
            {
                Debug.WriteLine("Proszę wybrać liczbę wątków z listy.");
            }
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
                BitmapImage bitmapImage = new BitmapImage();
                bitmapImage.BeginInit();
                bitmapImage.UriSource = new Uri(filePath, UriKind.Absolute);
                bitmapImage.CacheOption = BitmapCacheOption.OnLoad;
                bitmapImage.EndInit();

                // Konwersja do formatu RGB (24bpp)
                FormatConvertedBitmap rgbBitmap = new FormatConvertedBitmap(bitmapImage, PixelFormats.Rgb24, null, 0);
                loadedBitmap = rgbBitmap;

                image.Source = loadedBitmap;
                Debug.WriteLine("Obraz został pomyślnie ustawiony jako RGB.");
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

        private void Button_Click(object sender, RoutedEventArgs e)
        {
            ButtonTask();
        }
    }
}