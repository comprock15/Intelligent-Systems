using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Drawing;

namespace NeuralNetwork1
{
    internal class Settings
    {
        private int _border = 20;
        public int border
        {
            get
            {
                return _border;
            }
            set
            {
                if ((value > 0) && (value < height / 3))
                {
                    _border = value;
                    if (top > 2 * _border) top = 2 * _border;
                    if (left > 2 * _border) left = 2 * _border;
                }
            }
        }

        public int width = 640;
        public int height = 640;
        
        /// <summary>
        /// Размер сетки для сенсоров по горизонтали
        /// </summary>
        public int blocksCount = 10;

        /// <summary>
        /// Желаемый размер изображения до обработки
        /// </summary>
        public Size orignalDesiredSize = new Size(500, 500);
        /// <summary>
        /// Желаемый размер изображения после обработки
        /// </summary>
        public Size processedDesiredSize = new Size(500, 500);

        public int margin = 10;
        public int top = 40;
        public int left = 40;

        /// <summary>
        /// Второй этап обработки
        /// </summary>
        public bool processImg = false;

        /// <summary>
        /// Порог при отсечении по цвету 
        /// </summary>
        public byte threshold = 120;
        public float differenceLim = 0.15f;

        public void incTop() { if (top < 2 * _border) ++top; }
        public void decTop() { if (top > 0) --top; }
        public void incLeft() { if (left < 2 * _border) ++left; }
        public void decLeft() { if (left > 0) --left; }
    }

    internal class MagicEye
    {
        public BaseNetwork network;
        /// <summary>
        /// Обработанное изображение
        /// </summary>
        public Bitmap processed;
        /// <summary>
        /// Оригинальное изображение после обработки
        /// </summary>
        public Bitmap original;

        /// <summary>
        /// Класс настроек
        /// </summary>
        public Settings settings = new Settings();

        private int framesCount = 0;
        private string lastPrediction = "Ничего";

        public MagicEye()
        {
        }

        public bool ProcessImage(Bitmap bitmap)
        {
            framesCount++;
            // На вход поступает необработанное изображение с веб-камеры

            //  Минимальная сторона изображения (обычно это высота)
            if (bitmap.Height > bitmap.Width)
                throw new Exception("К такой забавной камере меня жизнь не готовила!");
            //  Можно было, конечено, и не кидаться эксепшенами в истерике, но идите и купите себе нормальную камеру!
            int side = bitmap.Height;

            //  Отпиливаем границы, но не более половины изображения
            if (side < 4 * settings.border) settings.border = side / 4;
            side -= 2 * settings.border;
            
            //  Мы сейчас занимаемся тем, что красиво оформляем входной кадр, чтобы вывести его на форму
            Rectangle cropRect = new Rectangle((bitmap.Width - bitmap.Height) / 2 + settings.left + settings.border, settings.top + settings.border, side, side);
            
            //  Тут создаём новый битмапчик, который будет исходным изображением
            original = new Bitmap(cropRect.Width, cropRect.Height);

            //  Объект для рисования создаём
            Graphics g = Graphics.FromImage(original);
            
            g.DrawImage(bitmap, new Rectangle(0, 0, original.Width, original.Height), cropRect, GraphicsUnit.Pixel);
            Pen p = new Pen(Color.Red);
            p.Width = 1;

            //  Теперь всю эту муть пилим в обработанное изображение
            AForge.Imaging.Filters.Grayscale grayFilter = new AForge.Imaging.Filters.Grayscale(0.2125, 0.7154, 0.0721);
            var uProcessed = grayFilter.Apply(AForge.Imaging.UnmanagedImage.FromManagedImage(original));

            // Рисуем сетку
            //int blockWidth = original.Width / settings.blocksCount;
            //int blockHeight = original.Height / settings.blocksCount;
            //for (int r = 0; r < settings.blocksCount; ++r)
            //    for (int c = 0; c < settings.blocksCount; ++c)
            //    {
            //        //  Тут ещё обработку сделать
            //        g.DrawRectangle(p, new Rectangle(c * blockWidth, r * blockHeight, blockWidth, blockHeight));
            //    }


            //  Масштабируем изображение до 500x500 - этого достаточно
            AForge.Imaging.Filters.ResizeBilinear scaleFilter = new AForge.Imaging.Filters.ResizeBilinear(settings.orignalDesiredSize.Width, settings.orignalDesiredSize.Height);
            uProcessed = scaleFilter.Apply(uProcessed);
            original = scaleFilter.Apply(original);
            g = Graphics.FromImage(original);
            //  Пороговый фильтр применяем. Величина порога берётся из настроек, и меняется на форме
            AForge.Imaging.Filters.BradleyLocalThresholding threshldFilter = new AForge.Imaging.Filters.BradleyLocalThresholding();
            threshldFilter.PixelBrightnessDifferenceLimit = settings.differenceLim;
            threshldFilter.ApplyInPlace(uProcessed);


            if (settings.processImg)
            {
                //lastPrediction = processSample(ref uProcessed);
                if (framesCount % 5 == 0)
                {
                    lastPrediction = Predict(ToBinary(original));
                    framesCount = 0;
                }
                Font f = new Font(FontFamily.GenericSansSerif, 20);
                g.DrawString(lastPrediction, f, Brushes.Black, 30, 30);
            }

            //  Получить значения сенсоров из обработанного изображения размера 100x100

            //  Можно вывести информацию на изображение!
            //Font f = new Font(FontFamily.GenericSansSerif, 10);
            //for (int r = 0; r < 4; ++r)
            //    for (int c = 0; c < 4; ++c)
            //        if (currentDeskState[r * 4 + c] >= 1 && currentDeskState[r * 4 + c] <= 16)
            //        {
            //            int num = 1 << currentDeskState[r * 4 + c];
            //            
            //        }


            processed = uProcessed.ToManagedImage();

            return true;
        }

        /// <summary>
        /// Обработка одного сэмпла
        /// </summary>
        /// <param name="index"></param>
        private string processSample(ref AForge.Imaging.UnmanagedImage unmanaged)
        {
            string rez = "Обработка";

            ///  Инвертируем изображение
            AForge.Imaging.Filters.Invert InvertFilter = new AForge.Imaging.Filters.Invert();
            InvertFilter.ApplyInPlace(unmanaged);

            ///    Создаём BlobCounter, выдёргиваем самый большой кусок, масштабируем, пересечение и сохраняем
            ///    изображение в эксклюзивном использовании
            AForge.Imaging.BlobCounterBase bc = new AForge.Imaging.BlobCounter();

            bc.FilterBlobs = true;
            bc.MinWidth = 3;
            bc.MinHeight = 3;
            // Упорядочиваем по размеру
            bc.ObjectsOrder = AForge.Imaging.ObjectsOrder.Size;
            // Обрабатываем картинку
            
            bc.ProcessImage(unmanaged);

            Rectangle[] rects = bc.GetObjectsRectangles();
            rez = "Насчитали " + rects.Length.ToString() + " прямоугольников!";
            //if (rects.Length == 0)
            //{
            //    finalPics[r, c] = AForge.Imaging.UnmanagedImage.FromManagedImage(new Bitmap(100, 100));
            //    return 0;
            //}

            // К сожалению, код с использованием подсчёта blob'ов не работает, поэтому просто высчитываем максимальное покрытие
            // для всех блобов - для нескольких цифр, к примеру, 16, можем получить две области - отдельно для 1, и отдельно для 6.
            // Строим оболочку, включающую все блоки. Решение плохое, требуется доработка
            int lx = unmanaged.Width;
            int ly = unmanaged.Height;
            int rx = 0;
            int ry = 0;
            for (int i = 0; i < rects.Length; ++i)
            {
                if (lx > rects[i].X) lx = rects[i].X;
                if (ly > rects[i].Y) ly = rects[i].Y;
                if (rx < rects[i].X + rects[i].Width) rx = rects[i].X + rects[i].Width;
                if (ry < rects[i].Y + rects[i].Height) ry = rects[i].Y + rects[i].Height;
            }

            // Обрезаем края, оставляя только центральные блобчики
            AForge.Imaging.Filters.Crop cropFilter = new AForge.Imaging.Filters.Crop(new Rectangle(lx, ly, rx - lx, ry - ly));
            unmanaged = cropFilter.Apply(unmanaged);

            //  Масштабируем до 100x100
            AForge.Imaging.Filters.ResizeBilinear scaleFilter = new AForge.Imaging.Filters.ResizeBilinear(100, 100);
            unmanaged = scaleFilter.Apply(unmanaged);

            return rez;
        }

        public string Predict(Bitmap bitmap)
        {
            Sample sample = DatasetGetter.ProcessToSample(bitmap, 8);
            FigureType figure = network.Predict(sample);
            return DatasetGetter.GetNameByClass(figure);
        }

        public double TrainNet(SamplesSet samples, int epochsCount, double acceptableError, bool parallel)
        {
            var err = network.TrainOnDataSet(samples, epochsCount, acceptableError, parallel);
            return err;
        }

        //public Bitmap ToBinary(Bitmap bitmap)
        //{
        //    Bitmap uProcessed = bitmap;

        //    // В оттенки серого
        //    AForge.Imaging.Filters.Grayscale grayFilter = new AForge.Imaging.Filters.Grayscale(0.2125, 0.7154, 0.0721);
        //    uProcessed = grayFilter.Apply(bitmap);

        //    AForge.Imaging.Filters.ResizeBilinear scaleDown = new AForge.Imaging.Filters.ResizeBilinear(100, 100);
        //    uProcessed = scaleDown.Apply(uProcessed);

        //    // В черно-белое
        //    AForge.Imaging.Filters.BradleyLocalThresholding threshldFilter = new AForge.Imaging.Filters.BradleyLocalThresholding();
        //    threshldFilter.PixelBrightnessDifferenceLimit = settings.differenceLim;
        //    threshldFilter.ApplyInPlace(uProcessed);

        //    return uProcessed;
        //}

        public Bitmap ToBinary(Bitmap bitmap)
        {
            Bitmap uProcessed = bitmap;

            try
            {
                // В оттенки серого
                AForge.Imaging.Filters.Grayscale grayFilter = new AForge.Imaging.Filters.Grayscale(0.2125, 0.7154, 0.0721);
                uProcessed = grayFilter.Apply(bitmap);
            }
            catch (Exception ex) { }

            AForge.Imaging.Filters.ResizeBilinear scaleFilter = new AForge.Imaging.Filters.ResizeBilinear(100, 100);
            uProcessed = scaleFilter.Apply(uProcessed);

            // В черно-белое
            AForge.Imaging.Filters.BradleyLocalThresholding threshldFilter = new AForge.Imaging.Filters.BradleyLocalThresholding();
            threshldFilter.PixelBrightnessDifferenceLimit = settings.differenceLim;
            threshldFilter.ApplyInPlace(uProcessed);

            AForge.Imaging.Filters.Invert InvertFilter = new AForge.Imaging.Filters.Invert();
            InvertFilter.ApplyInPlace(uProcessed);

            AForge.Imaging.BlobCounterBase bc = new AForge.Imaging.BlobCounter();

            bc.FilterBlobs = true;
            bc.MinWidth = 3;
            bc.MinHeight = 3;
            // Упорядочиваем по размеру
            bc.ObjectsOrder = AForge.Imaging.ObjectsOrder.Size;
            // Обрабатываем картинку

            bc.ProcessImage(uProcessed);

            Rectangle[] rects = bc.GetObjectsRectangles();

            // К сожалению, код с использованием подсчёта blob'ов не работает, поэтому просто высчитываем максимальное покрытие
            // для всех блобов - для нескольких цифр, к примеру, 16, можем получить две области - отдельно для 1, и отдельно для 6.
            // Строим оболочку, включающую все блоки. Решение плохое, требуется доработка
            int lx = uProcessed.Width;
            int ly = uProcessed.Height;
            int rx = 0;
            int ry = 0;
            for (int i = 0; i < rects.Length; ++i)
            {
                if (lx > rects[i].X) lx = rects[i].X;
                if (ly > rects[i].Y) ly = rects[i].Y;
                if (rx < rects[i].X + rects[i].Width) rx = rects[i].X + rects[i].Width;
                if (ry < rects[i].Y + rects[i].Height) ry = rects[i].Y + rects[i].Height;
            }

            // Обрезаем края, оставляя только центральные блобчики
            if (lx < rx)
            {
                AForge.Imaging.Filters.Crop cropFilter = new AForge.Imaging.Filters.Crop(new Rectangle(lx, ly, rx - lx, ry - ly));
                uProcessed = cropFilter.Apply(uProcessed);
            }

            //AForge.Imaging.Filters.GaussianBlur gaussianBlur = new AForge.Imaging.Filters.GaussianBlur(sigma: 2.0);
            //uProcessed = gaussianBlur.Apply(uProcessed);

            //AForge.Imaging.Filters.Median medianFilter = new AForge.Imaging.Filters.Median();
            //uProcessed = medianFilter.Apply(uProcessed);

            ////  Масштабируем до 100x100
            uProcessed = scaleFilter.Apply(uProcessed);
            //threshldFilter.ApplyInPlace(uProcessed);

            //processed = uProcessed;

            return uProcessed;
        }

    }
}

