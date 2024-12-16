using System;
using System.Collections.Generic;
using System.Linq;
using System.Diagnostics;
using System.Threading.Tasks;

namespace AForge.WindowsForms
{
    public class Neuron
    {
        public double Output { get; set; }
        public double Error { get; set; }
    }

    public class StudentNetwork : BaseNetwork
    {
        public Stopwatch stopWatch = new Stopwatch();

        private Random random = new Random();
        private List<List<List<double>>> weights; // [слой источника][нейрон-адресат][нейрон-источник]
        private List<List<Neuron>> layers; // [слой][нейрон]

        private Func<double, double> activationFunction; // Функция активации
        private Func<double, double> activationFunctionDerivative; // Производная функции активации
        private Func<double[], double[], double> lossFunction; // Функция потерь

        private double learningRate = 0.5;
        private double alpha = 0.1;

        public StudentNetwork(int[] structure)
        {
            activationFunction = Sigmoid;
            activationFunctionDerivative = SigmoidDerivative;

            lossFunction = MSE;

            // Добавление нейрончиков
            layers = new List<List<Neuron>>(structure.Length);
            for (int layer = 0; layer < structure.Length; ++layer)
            {
                layers.Add(new List<Neuron>(structure[layer]));
                for (int neuron = 0; neuron < structure[layer]; ++neuron)
                    layers[layer].Add(new Neuron());
            }

            // Добавление весов
            weights = new List<List<List<double>>>(layers.Count - 1);
            for (int layer = 0; layer < layers.Count - 1; ++layer)
            {
                weights.Add(new List<List<double>>(layers[layer + 1].Count));
                for (int destinationNeuron = 0; destinationNeuron < layers[layer + 1].Count; ++destinationNeuron)
                {
                    weights[layer].Add(new List<double>(layers[layer].Count + 1)); // +1 для bias
                    for (int sourceNeuron = 0; sourceNeuron < layers[layer].Count + 1; ++sourceNeuron)
                    {
                        weights[layer][destinationNeuron].Add(random.NextDouble() - 0.5); // Рандомизируем веса связей
                    }
                }
            }
        }

        public override int Train(Sample sample, double acceptableError, bool parallel)
        {
            int iters = 0;

            while (true)
            {
                iters++;
                ForwardPropagation(sample.input);
                if (lossFunction(layers.Last().Select(n => n.Output).ToArray(), sample.Output) > acceptableError && iters < 50)
                    BackPropagation(sample.Output);
                else
                    break;
            }

            return iters;
        }

        double TrainOnSample(Sample sample, double acceptableError)
        {
            ForwardPropagation(sample.input);
            double loss = lossFunction(layers.Last().Select(n => n.Output).ToArray(), sample.Output);
            if (loss > acceptableError)
                BackPropagation(sample.Output);
            return loss;
        }

        public override double TrainOnDataSet(SamplesSet samplesSet, int epochsCount, double acceptableError, bool parallel)
        {
            int totalSamples = epochsCount * samplesSet.Count;
            int processedSamples = 0;
            double errorSum = 0;

            //  Текущий счётчик эпох
            int epoch_to_run = 0;

            double error = double.PositiveInfinity;

            stopWatch.Restart();

            while (epoch_to_run < epochsCount && error > acceptableError)
            {
                epoch_to_run++;

                for (int i = 0; i < samplesSet.Count; ++i)
                {
                    errorSum += TrainOnSample(samplesSet[i], acceptableError);
                    ++processedSamples;

                    if (i % 100 == 0)
                    {
                        error = errorSum / processedSamples;
                        OnTrainProgress((processedSamples * 1.0) / totalSamples, error, stopWatch.Elapsed);
                    }
                }
                error = errorSum / processedSamples;
                OnTrainProgress((processedSamples * 1.0) / totalSamples, error, stopWatch.Elapsed);
            }

            OnTrainProgress(1.0, error, stopWatch.Elapsed);

            stopWatch.Stop();

            return error;
        }

        protected override double[] Compute(double[] input)
        {
#if DEBUG
            if (input.Length != layers[0].Count)
                throw new ArgumentException("WTF?!!! Не могу подать на вход нейросети массив другой длины!");
#endif
            ForwardPropagation(input);
            var output = layers[layers.Count - 1].Select(neuron => neuron.Output).ToArray();
#if DEBUG
            Debug.WriteLine(string.Join(" ", output));
#endif
            return output;
        }

        // Сигмоидная функция активации
        private double Sigmoid(double s) => 1.0 / (1 + System.Math.Exp(-2 * alpha * s));

        private double SigmoidDerivative(double s) => 2 * alpha * s * (1 - s);

        // Среднеквадратичная ошибка
        private double MSE(double[] predicted, double[] target)
        {
#if DEBUG
            if (predicted.Length != target.Length)
                throw new ArgumentException("WTF?!!! Я не могу такое посчитать, длины массивов не совпадают!");
#endif
            double res = 0;

            for (int i = 0; i < predicted.Length; ++i)
            {
                res += System.Math.Pow(target[i] - predicted[i], 2);
            }

            return res / predicted.Length;
        }

        // Прямой проход
        private void ForwardPropagation(double[] input)
        {
            // Задаем значения нейронов входного слоя (сенсоров)
            for (int neuron = 0; neuron < input.Length; ++neuron)
                layers[0][neuron].Output = input[neuron];

            // А теперь весело считаем значения в нейронах следующих слоёв
            for (int layer = 1; layer < layers.Count; ++layer)
            {
                Parallel.For(0, layers[layer].Count, destinationNeuron =>
                {
                    layers[layer][destinationNeuron].Output = -weights[layer - 1][destinationNeuron][0]; // bias
                    for (int sourceNeuron = 0; sourceNeuron < layers[layer - 1].Count; ++sourceNeuron)
                    {
                        layers[layer][destinationNeuron].Output += weights[layer - 1][destinationNeuron][sourceNeuron + 1] * layers[layer - 1][sourceNeuron].Output;
                    }
                    layers[layer][destinationNeuron].Output = activationFunction(layers[layer][destinationNeuron].Output);
                });
            }
            // Вообще говоря, это просто перемножение матриц, не пугайтесь
        }

        // Обратное распространение ошибки. Именно тут нейросеть обучается
        private void BackPropagation(double[] actual)
        {
            // Считаем ошибки для нейронов выходного слоя
            for (int neuron = 0; neuron < layers[layers.Count - 1].Count; ++neuron)
            {
                // [-2 * alpha * y_i * (1 - y_i)] * (d_i - y_i)
                layers[layers.Count - 1][neuron].Error = activationFunctionDerivative(layers[layers.Count - 1][neuron].Output) * (actual[neuron] - layers[layers.Count - 1][neuron].Output);
            }

            // Считаем ошибки для остальных нейронов
            for (int layer = layers.Count - 2; layer >= 0; --layer)
            {
                Parallel.For(0, layers[layer].Count, sourceNeuron =>
                {
                    // Суммируем ошибки приходящих к текущему нейрону нейронов следующего слоя
                    double nextLayerNeuronsErrorSum = 0.0;
                    for (int destinationNeuron = 0; destinationNeuron < layers[layer + 1].Count; ++destinationNeuron)
                        nextLayerNeuronsErrorSum += layers[layer + 1][destinationNeuron].Error * weights[layer][destinationNeuron][sourceNeuron + 1];
                    layers[layer][sourceNeuron].Error = activationFunctionDerivative(layers[layer][sourceNeuron].Output) * nextLayerNeuronsErrorSum;
                });
            }

            // Наконец пора пересчитывать веса и учить нейросеть
            for (int layer = layers.Count - 2; layer >= 0; --layer)
            {
                // Искренне надеемся, что bias пересчитывается правильно
                double biasError = 0.0;
                for (int destinationNeuron = 0; destinationNeuron < layers[layer + 1].Count; ++destinationNeuron)
                    biasError += layers[layer + 1][destinationNeuron].Error * weights[layer][destinationNeuron][0];
                biasError *= activationFunctionDerivative(-1);
                Parallel.For(0, layers[layer + 1].Count, destinationNeuron =>
                    weights[layer][destinationNeuron][0] = -learningRate * biasError * (-1));

                Parallel.For(0, layers[layer].Count, sourceNeuron =>
                {
                    for (int destinationNeuron = 0; destinationNeuron < layers[layer + 1].Count; ++destinationNeuron)
                    {
                        weights[layer][destinationNeuron][sourceNeuron + 1] += learningRate * layers[layer + 1][destinationNeuron].Error * layers[layer][sourceNeuron].Output;
                    }
                });
            }
        }
    }
}