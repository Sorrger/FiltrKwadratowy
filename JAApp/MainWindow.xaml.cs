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
using Microsoft.Win32;

namespace SquareFilter
{
    public partial class MainWindow : Window
    {
        private BitmapSource loadedBitmap;

        [DllImport("/../../../../x64/Release/JADll.dll", CallingConvention = CallingConvention.StdCall)]
        public static extern void Darken(IntPtr pixelData, int width, int startY, int endY, int imageHeight);

        [DllImport("/../../../../x64/Release/CPPDll.dll", CallingConvention = CallingConvention.StdCall)]
        public static extern void Darken2(IntPtr pixelData, int width, int startY, int endY, int imageHeight);

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
                    int bytesPerPixel = 3; // Format RGB24, czyli x3

                    WriteableBitmap filteredBitmap = new WriteableBitmap(loadedBitmap);

                    filteredBitmap.Lock();
                    try
                    {
                        int length = width * height * bytesPerPixel;
                        byte[] pixelData = new byte[length];
                        IntPtr pBackBuffer = filteredBitmap.BackBuffer;
                        Marshal.Copy(pBackBuffer, pixelData, 0, length);

                        // Przypięcie tablicy pixelData do pamięci, by uniknąć problemów z GC
                        GCHandle handle = GCHandle.Alloc(pixelData, GCHandleType.Pinned);
                        IntPtr pixelDataPtr = Marshal.UnsafeAddrOfPinnedArrayElement(pixelData, 0);

                        // Obliczanie optymalnego podziału w pionie
                        int baseSegmentHeight = height / numThreads;
                        int extraRows = height % numThreads;

                        int[] startYs = new int[numThreads];
                        int[] endYs = new int[numThreads];

                        // Obliczanie startY i endY dla każdego wątku
                        int currentStartY = 0;
                        for (int i = 0; i < numThreads; i++)
                        {
                            int segmentHeight = baseSegmentHeight + (i < extraRows ? 1 : 0);
                            startYs[i] = currentStartY;
                            endYs[i] = currentStartY + segmentHeight;

                            currentStartY += segmentHeight;
                        }

                        bool cppButton = (bool)CRB.IsChecked;
                        bool asmButton = (bool)ARB.IsChecked;

                        Stopwatch stopwatch = Stopwatch.StartNew();
                        StringBuilder logBuilder = new StringBuilder();

                        // Parallel processing of image sections
                        Parallel.For(0, numThreads, i =>
                        {
                            int startY = startYs[i];
                            int endY = endYs[i];

                            if (cppButton)
                            {
                                Darken2(pixelDataPtr, width, startY, endY, height);
                            }
                            else if (asmButton)
                            {
                                Darken(pixelDataPtr, width, startY, endY, height);
                            }
                        });


                        Marshal.Copy(pixelData, 0, pBackBuffer, length);
                        stopwatch.Stop();

                        logBuilder.AppendLine($"Czas przetwarzania: {stopwatch.Elapsed.TotalMilliseconds} ms");
                        TimerText.Text = logBuilder.ToString();

                        handle.Free();
                    }
                    finally
                    {
                        filteredBitmap.Unlock();
                    }

                    // Ustawianie przetworzonego obrazu
                    FilteredImage.Source = filteredBitmap;
                    SaveImage(filteredBitmap);
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

        private void SaveImage(WriteableBitmap bitmap)
        {
            // Otwórz okno dialogowe, aby wybrać lokalizację i nazwę pliku
            SaveFileDialog saveFileDialog = new SaveFileDialog
            {
                Filter = "PNG Files (*.png)|*.png|JPEG Files (*.jpg)|*.jpg|BMP Files (*.bmp)|*.bmp",
                DefaultExt = ".png",
                AddExtension = true
            };

            if (saveFileDialog.ShowDialog() == true)
            {
                // Zapisz obraz do pliku
                string filePath = saveFileDialog.FileName;

                // Tworzymy encodera PNG (można zmienić format na inny)
                PngBitmapEncoder encoder = new PngBitmapEncoder();
                encoder.Frames.Add(BitmapFrame.Create(bitmap));

                using (FileStream stream = new FileStream(filePath, FileMode.Create))
                {
                    encoder.Save(stream);
                }

                MessageBox.Show($"Obraz zapisano do {filePath}", "Zapisano", MessageBoxButton.OK, MessageBoxImage.Information);
            }
        }

        private void Button_Click(object sender, RoutedEventArgs e)
        {
            ButtonTask();
        }
    }
}