using System;
using System.Collections.Generic;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.IO;

namespace AForge.WindowsForms
{
    /// <summary>
    /// Тип фигуры
    /// </summary>
    public enum FigureType : byte { Beta = 0, Chi, Eta, Iota, Nu, Omicron, Psi, Tau, Undef };

    public class DatasetGetter
    {
        public string datasetPath = "..\\..\\Dataset-";

        /// <summary>
        /// Бинарное представление образа
        /// </summary>
        public bool[,] img = new bool[500, 500];

        /// <summary>
        /// Количество классов генерируемых фигур (4 - максимум)
        /// </summary>
        public int FigureCount { get; set; } = 8;

        /// <summary>
        /// Очистка образа
        /// </summary>
        public void ClearImage()
        {
            for (int i = 0; i < 200; ++i)
                for (int j = 0; j < 200; ++j)
                    img[i, j] = false;
        }

        //public Sample GenerateFigure()
        //{
        //    generate_figure();
        //    double[] input = new double[400];
        //    for (int i = 0; i < 400; i++)
        //        input[i] = 0;

        //    FigureType type = currentFigure;

        //    for (int i = 0; i < 200; i++)
        //        for (int j = 0; j < 200; j++)
        //            if (img[i, j])
        //            {
        //                input[i] += 1;
        //                input[200 + j] += 1;
        //            }
        //    return new Sample(input, FigureCount, type);
        //}


        //public void generate_figure(FigureType type = FigureType.Undef)
        //{

        //    if (type == FigureType.Undef || (int)type >= FigureCount)
        //        type = (FigureType)rand.Next(FigureCount);
        //    ClearImage();
        //    switch (type)
        //    {
        //        case FigureType.Rectangle: create_rectangle(); break;
        //        case FigureType.Triangle: create_triangle(); break;
        //        case FigureType.Circle: create_circle(); break;
        //        case FigureType.Sinusiod: create_sin(); break;

        //        default:
        //            type = FigureType.Undef;
        //            throw new Exception("WTF?!!! Не могу я создать такую фигуру!");
        //    }
        //}

        /// <summary>
        /// Возвращает битовое изображение для вывода образа
        /// </summary>
        /// <returns></returns>
        public Bitmap GenBitmap()
        {
            Bitmap drawArea = new Bitmap(200, 200);
            for (int i = 0; i < 200; ++i)
                for (int j = 0; j < 200; ++j)
                    if (img[i, j])
                        drawArea.SetPixel(i, j, Color.Black);
            return drawArea;
        }

        public SamplesSet GetDataset()
        {
            SamplesSet samples = new SamplesSet();

            foreach (string subdir in Directory.GetDirectories(datasetPath))
            {
#if DEBUG
                Console.WriteLine(subdir);
#endif
                FigureType figure = GetClassByName(Path.GetDirectoryName(subdir));
                foreach (string filename in Directory.GetFiles(subdir))
                {
                    Image img = Image.FromFile(filename);
                    Bitmap bitmap = MagicEye.ToBinary(new Bitmap(img));
                    samples.AddSample(ProcessToSample(bitmap, FigureCount, figure));
                }
            }

            return samples;
        }

        public static FigureType GetClassByName(string name)
        {
            FigureType figure = FigureType.Undef;
            switch (name)
            {
                case "beta":
                    figure = FigureType.Beta;
                    break;
                case "chi":
                    figure = FigureType.Chi;
                    break;
                case "eta":
                    figure = FigureType.Eta;
                    break;
                case "iota":
                    figure = FigureType.Iota;
                    break;
                case "nu":
                    figure = FigureType.Nu;
                    break;
                case "omicron":
                    figure = FigureType.Omicron;
                    break;
                case "psi":
                    figure = FigureType.Psi;
                    break;
                case "tau":
                    figure = FigureType.Tau;
                    break;
                default:
                    break;
            }
            return figure;
        }

        public static string GetNameByClass(FigureType figureType)
        {
            switch (figureType)
            {
                case FigureType.Beta:
                    return "Бета!";
                case FigureType.Chi:
                    return "Хи!";
                case FigureType.Eta:
                    return "Эта!";
                case FigureType.Iota:
                    return "Йота!";
                case FigureType.Nu:
                    return "Ню!";
                case FigureType.Omicron:
                    return "Омикрон!";
                case FigureType.Psi:
                    return "Пси!";
                case FigureType.Tau:
                    return "Тау!";
                default:
                    break;
            }
            return "Не знаю...";
        }

        public static Sample ProcessToSample(Bitmap bitmap, int figureCount, FigureType figureType=FigureType.Undef)
        {
            short size = 500;
            double[] input = new double[size + size];
            for (int i = 0; i < size; i++)
                input[i] = 0;

            for (int i = 0; i < size; i++)
                for (int j = 0; j < size; j++)
                    if (bitmap.GetPixel(i, j).R == 0)
                    {
                        input[i] += 1;
                        input[size + j] += 1;
                    }
            return new Sample(input, figureCount, figureType);
        }
    }

}
