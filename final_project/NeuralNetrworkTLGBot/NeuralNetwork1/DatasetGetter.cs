using System;
using System.Collections.Generic;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.IO;
using System.Windows.Forms;

namespace NeuralNetwork1
{
    /// <summary>
    /// Тип фигуры
    /// </summary>
    public enum FigureType : byte { Beta = 0, Chi, Eta, Iota, Nu, Omicron, Psi, Tau, Undef };

    public class DatasetGetter
    {
        public string datasetPath = "..\\..\\Dataset+";
        private MagicEye processor;
        const short inputSize = 100;
        const short blackThreshold = 128;
        public Dictionary<FigureType, string> dict = new Dictionary<FigureType, string>() {
            { FigureType.Beta, "Бета" },
            { FigureType.Chi, "Хи" },
            { FigureType.Eta, "Эта" },
            { FigureType.Iota, "Йота" },
            { FigureType.Nu, "Ню" },
            { FigureType.Omicron, "Омикрон" },
            { FigureType.Psi, "Пси" },
            { FigureType.Tau, "Тау" },
            { FigureType.Undef, "Не знаю" }
        };

        /// <summary>
        /// Количество классов генерируемых фигур (8 - максимум)
        /// </summary>
        public int FigureCount { get; set; } = 8;

        public SamplesSet GetDataset()
        {
            SamplesSet samples = new SamplesSet();

            foreach (string subdir in Directory.GetDirectories(datasetPath))
            {
#if DEBUG
                Console.WriteLine(subdir + " -> " + Path.GetFileName(subdir));
#endif
                FigureType figure = GetClassByName(Path.GetFileName(subdir));
                foreach (string filename in Directory.GetFiles(subdir))
                {
                    Image img = Image.FromFile(filename);
                    Bitmap bitmap = processor.ToBinary(new Bitmap(img));
                    samples.AddSample(ProcessToSample(bitmap, FigureCount, figure));
                }
            }

            return samples;
        }

        internal void SetProcessor(MagicEye processor) => this.processor = processor;

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
                    return "Бета";
                case FigureType.Chi:
                    return "Хи";
                case FigureType.Eta:
                    return "Эта";
                case FigureType.Iota:
                    return "Йота";
                case FigureType.Nu:
                    return "Ню";
                case FigureType.Omicron:
                    return "Омикрон";
                case FigureType.Psi:
                    return "Пси";
                case FigureType.Tau:
                    return "Тау";
                default:
                    break;
            }
            return "Не знаю...";
        }

        public static Sample ProcessToSample(Bitmap bitmap, int figureCount=8, FigureType figureType = FigureType.Undef)
        {
            double[] input = new double[inputSize + inputSize];
            for (int i = 0; i < input.Length; i++)
                input[i] = 0;

            //for (int i = 0; i < inputSize; i++)
            //    for (int j = 0; j < inputSize; j++)
            //        if (bitmap.GetPixel(i, j).R == 0)
            //        {
            //            input[i] += 1;
            //            input[inputSize + j] += 1;
            //        }

            for (int i = 0; i < inputSize; i++)
            {
                bool prevBlack = bitmap.GetPixel(i, 0).R < blackThreshold;
                for (int j = 1; j < inputSize; j++)
                {
                    Color pixel = bitmap.GetPixel(i, j);
                    //Console.WriteLine(pixel);
                    if ((pixel.R < blackThreshold && !prevBlack) || (pixel.R >= blackThreshold && prevBlack))
                    {
                        ++input[i];
                        prevBlack = !prevBlack;
                    }
                }
            }

            for (int j = 0; j < inputSize; j++)
            {
                bool prevBlack = bitmap.GetPixel(0, j).R < blackThreshold;
                for (int i = 1; i < inputSize; i++)
                {
                    Color pixel = bitmap.GetPixel(i, j);
                    //Console.WriteLine(pixel);
                    if ((pixel.R < blackThreshold && !prevBlack) || (pixel.R >= blackThreshold && prevBlack))
                    {
                        ++input[inputSize + j];
                        prevBlack = !prevBlack;
                    }
                }
            }

#if DEBUG
            Console.WriteLine("FigureType: " + figureType);
            Console.WriteLine("input: " + string.Join(" ", input));
#endif
            return new Sample(input, figureCount, figureType);
        }
    }

}
