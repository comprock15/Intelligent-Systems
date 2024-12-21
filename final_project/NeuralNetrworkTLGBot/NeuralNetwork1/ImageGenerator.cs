using System;
using System.Collections.Generic;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace NeuralNetwork1
{
    /// <summary>
    /// Тип фигуры
    /// </summary>
    public enum FigureType : byte { Triangle = 0, Rectangle, Circle, Sinusiod, Undef };
    
    public class GenerateImage
    {
        /// <summary>
        /// Бинарное представление образа
        /// </summary>
        public bool[,] img = new bool[200, 200];
        
        //  private int margin = 50;
        private Random rand = new Random();
        
        /// <summary>
        /// Текущая сгенерированная фигура
        /// </summary>
        public FigureType current_figure = FigureType.Undef;

        /// <summary>
        /// Количество классов генерируемых фигур (4 - максимум)
        /// </summary>
        public int figure_count { get; set; } = 4;

        /// <summary>
        /// Диапазон смещения центра фигуры (по умолчанию +/- 20 пикселов от центра)
        /// </summary>
        public int figureCenterGitter { get; set; } = 50;

        /// <summary>
        /// Диапазон разброса размера фигур
        /// </summary>
        public int figureSizeGitter { get; set; } = 50;

        /// <summary>
        /// Диапазон разброса размера фигур
        /// </summary>
        public int figureSize { get; set; } = 100;
        
        /// <summary>
        /// Очистка образа
        /// </summary>
        public void ClearImage()
        {
            for (int i = 0; i < 200; ++i)
                for (int j = 0; j < 200; ++j)
                    img[i, j] = false;
        }

        public Sample GenerateFigure()
        {
            generate_figure();
            double[] input = new double[400];
            for (int i = 0; i < 400; i++)
                input[i] = 0;

            FigureType type = current_figure;

            for (int i = 0; i < 200; i++)
                for (int j = 0; j < 200; j++)
                    if (img[i, j])
                    { 
                        input[i] += 1;
                        input[200 + j] += 1;
                    }
            return new Sample(input, figure_count, type);
        }

        public static Sample GenerateFigure(AForge.Imaging.UnmanagedImage img)
        {
            double[] input = new double[400];
            for (int i = 0; i < 400; i++)
                input[i] = 0;

            FigureType type = FigureType.Undef;

            for (int i = 0; i < 200; i++)
                for (int j = 0; j < 200; j++)
                    if (img.GetPixel(i, j).GetBrightness() < 0.5)
                    {
                        input[i] += 1;
                        input[200 + j] += 1;
                    }
            return new Sample(input, 4, type);
        }

        private Point GetLeftUpperPoint()
        {
            int X = 100 - figureSize / 2 + rand.Next(-figureSizeGitter / 2, figureSizeGitter / 2);
            int Y = 100 - figureSize / 2 + rand.Next(-figureSizeGitter / 2, figureSizeGitter / 2);
            return new Point(X,Y);
        }

        private Point GetRightDownPoint()
        {
            int X = 100 + figureSize / 2 + rand.Next(-figureSizeGitter / 2, figureSizeGitter / 2);
            int Y = 100 + figureSize / 2 + rand.Next(-figureSizeGitter / 2, figureSizeGitter / 2);
            return new Point(X, Y);
        }

        private Point GetCenterPoint()
        {
            int X = 100 + rand.Next(-figureSizeGitter / 2, figureSizeGitter / 2);
            int Y = 100 + rand.Next(-figureSizeGitter / 2, figureSizeGitter / 2);
            return new Point(X, Y);
        }
       
        public void get_random_figure()
        {
            ClearImage();
            int type = rand.Next(0, 4);
            switch (type)
            {
                case 0:
                    create_sin();
                    break;
                case 1:
                    create_rectangle();
                    break;
                case 2:
                    create_triangle();
                    break;
                default:
                case 3:
                    create_circle();
                    break;
            }
        }

        private void bresenham(int x, int y, int x2, int y2)
        {
            int w = x2 - x;
            int h = y2 - y;
            int dx1 = 0, dy1 = 0, dx2 = 0, dy2 = 0;
            if (w < 0) dx1 = -1; else if (w > 0) dx1 = 1;
            if (h < 0) dy1 = -1; else if (h > 0) dy1 = 1;
            if (w < 0) dx2 = -1; else if (w > 0) dx2 = 1;
            int longest = Math.Abs(w);
            int shortest = Math.Abs(h);

            if (!(longest > shortest))
            {
                longest = Math.Abs(h);
                shortest = Math.Abs(w);
                if (h < 0) dy2 = -1; else if (h > 0) dy2 = 1;
                dx2 = 0;
            }

            int numerator = longest >> 1;
            for (int i = 0; i <= longest; i++)
            {
                img[x, y] = true;
                numerator += shortest;
                if (!(numerator < longest))
                {
                    numerator -= longest;
                    x += dx1;
                    y += dy1;
                }
                else
                {
                    x += dx2;
                    y += dy2;
                }
            }
        }

        public bool create_triangle()
        {
            current_figure = FigureType.Triangle;
            Point leftUpper = GetLeftUpperPoint();
            Point downLeft = GetRightDownPoint();
            int centerX = 100 + figureCenterGitter;


            bresenham(leftUpper.X, downLeft.Y, centerX, leftUpper.Y);
            bresenham(centerX, leftUpper.Y, downLeft.X, downLeft.Y);
            bresenham(downLeft.X, downLeft.Y, leftUpper.X, downLeft.Y);

            return true;
        }

        public bool create_rectangle()
        {
            current_figure = FigureType.Rectangle;

            Point leftUpper = GetLeftUpperPoint();
            Point downLeft = GetRightDownPoint();

            bresenham(leftUpper.X, leftUpper.Y, downLeft.X, leftUpper.Y);
            bresenham(downLeft.X, leftUpper.Y, downLeft.X, downLeft.Y);
            bresenham(downLeft.X, downLeft.Y, leftUpper.X, downLeft.Y);
            bresenham(leftUpper.X, downLeft.Y, leftUpper.X, leftUpper.Y);
            return true;
        }

        public bool create_circle()
        {
            current_figure = FigureType.Circle;

            Point center = GetCenterPoint();

            int radius = rand.Next(50, 65);

            for (double t = 0; t < 2 * Math.PI; t += 0.01)
            {
                double x = center.X + radius * Math.Cos(t);
                double y = center.Y + radius * Math.Sin(t);
                img[(int)x, (int)y] = true;
            }
            return true;
        }

        public bool create_sin()
        {
            current_figure = FigureType.Sinusiod;

            Point leftUpper = GetLeftUpperPoint();
            Point downLeft = GetRightDownPoint();

            int amp = (downLeft.Y - leftUpper.Y) / 2;
            int centerY = leftUpper.Y + amp;

            double sx = 0.25;
            for (double x = leftUpper.X; x <= downLeft.X; x += 0.05)
            {
                double y = Math.Round(centerY + amp * Math.Sin(sx * x));
                img[(int)x, (int)y] = true;
            }

            return true;
        }


        public void generate_figure(FigureType type = FigureType.Undef)
        {

            if (type == FigureType.Undef || (int)type >= figure_count)
                type = (FigureType)rand.Next(figure_count);
            ClearImage();
            switch (type)
            {
                case FigureType.Rectangle : create_rectangle(); break;
                case FigureType.Triangle  : create_triangle(); break;
                case FigureType.Circle    : create_circle(); break;
                case FigureType.Sinusiod  : create_sin(); break;

                default:
                    type = FigureType.Undef;
                    throw new Exception("WTF?!!! Не могу я создать такую фигуру!");
            }
        }

        /// <summary>
        /// Возвращает битовое изображение для вывода образа
        /// </summary>
        /// <returns></returns>
        public Bitmap genBitmap()
        {
            Bitmap DrawArea = new Bitmap(200, 200);
            for (int i = 0; i < 200; ++i)
                for (int j = 0; j < 200; ++j)
                    if (img[i, j])
                        DrawArea.SetPixel(i, j, Color.Black);
            return DrawArea;
        }
    }

}
