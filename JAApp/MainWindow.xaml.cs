using System;
using System.Diagnostics;
using System.IO;
using System.Runtime.InteropServices;
using System.Text;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Media;
using System.Windows.Media.Imaging;

namespace SquareFilter
{
    public partial class MainWindow : Window
    {
        private BitmapSource loadedBitmap;

        // Importowanie funkcji z bibliotek DLL
        [DllImport("/../../../../x64/Debug/JADll.dll", CallingConvention = CallingConvention.StdCall)]
        public static extern void Darken(ref byte pixelData, int width, int startY, int segmentHeight);

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
                TimerText.Text = "Obraz nie został załadowany.";
                return;
            }

            if (threadChoice.SelectedItem is ComboBoxItem selectedItem)
            {
                if (int.TryParse(selectedItem.Content.ToString(), out int numThreads) && numThreads > 0)
                {
                    int height = loadedBitmap.PixelHeight;
                    int width = loadedBitmap.PixelWidth;
                    int bytesPerPixel = 3; // Format RGB24 czyli jest x3

                    WriteableBitmap filteredBitmap = new WriteableBitmap(loadedBitmap);

                    filteredBitmap.Lock();
                    try
                    {
                        int length = width * height * bytesPerPixel;
                        byte[] pixelData = new byte[length];
                        IntPtr pBackBuffer = filteredBitmap.BackBuffer;
                        Marshal.Copy(pBackBuffer, pixelData, 0, length);

                        int baseSegmentHeight = height / numThreads;
                        int extraRows = height % numThreads;

                        int[] startYs = new int[numThreads];
                        int[] endYs = new int[numThreads];

                        startYs[0] = 0;
                        endYs[0] = baseSegmentHeight + (extraRows > 0 ? 1 : 0) - 1;

                        for (int i = 1; i < numThreads; i++)
                        {
                            startYs[i] = endYs[i - 1] + 1;
                            endYs[i] = startYs[i] + baseSegmentHeight + (i < extraRows ? 1 : 0) - 1;
                        }

                        endYs[numThreads - 1] = height - 1;  // Ostatni wątek kończy na ostatnim wierszu

                        bool cppButton = (bool)CRB.IsChecked;
                        bool asmButton = (bool)ARB.IsChecked;

                        Stopwatch stopwatch = Stopwatch.StartNew();
                        StringBuilder logBuilder = new StringBuilder();

                        Parallel.For(0, numThreads, i =>
                        {
                            int startY = startYs[i];
                            int endY = endYs[i];

                            int startIdx = startY * width * bytesPerPixel;

                            logBuilder.AppendLine($"Wątek {i}: startY = {startY}, endY = {endY}, startIdx = {startIdx}");

                            if (asmButton)
                            {
                                Darken(ref pixelData[startIdx], width, startY, endY - startY + 1);
                            }
                            else if (cppButton)
                            {
                                Darken2(ref pixelData[startIdx], width, startY, endY - startY + 1);
                            }
                        });

                        // Kopiowanie zmodyfikowanych danych z powrotem do bitmapy
                        Marshal.Copy(pixelData, 0, pBackBuffer, length);
                        stopwatch.Stop();

                        // Wyświetlanie czasu przetwarzania
                        logBuilder.AppendLine($"Czas przetwarzania: {stopwatch.Elapsed.TotalMilliseconds} ms");
                        TimerText.Text = logBuilder.ToString();
                    }
                    finally
                    {
                        filteredBitmap.Unlock();
                    }

                    // Ustawianie przetworzonego obrazu
                    FilteredImage.Source = filteredBitmap;
                }
                else
                {
                    TimerText.Text = "Proszę wybrać prawidłową liczbę wątków.";
                }
            }
            else
            {
                TimerText.Text = "Proszę wybrać liczbę wątków z listy.";
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
                    SetImage(files[0]);
                }
                else
                {
                    Console.WriteLine("Nieprawidłowy plik obrazu.");
                }
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

                FormatConvertedBitmap rgbBitmap = new FormatConvertedBitmap(bitmapImage, PixelFormats.Rgb24, null, 0);
                loadedBitmap = rgbBitmap;

                image.Source = loadedBitmap;
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Błąd podczas ładowania obrazu: {ex.Message}");
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
