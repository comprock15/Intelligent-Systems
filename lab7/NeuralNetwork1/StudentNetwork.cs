using System;
using System.Collections.Generic;

namespace NeuralNetwork1
{
    public class StudentNetwork : BaseNetwork
    {
        private Random random = new Random();
        private List<List<List<double>>> weights; // [слой][нейрон-адресат][нейрон-источник]
        private List<List<double>> layers; // [слой][нейрон]

        private Func<double, double, double> activationFunction; // Функция активации
        private Func<double[], double[], double> lossFunction; // Функция потерь

        public StudentNetwork(int[] structure)
        {
            activationFunction = Sigmoid;
            lossFunction = MSE;

            // Добавление нейрончиков
            layers = new List<List<double>>(structure.Length);
            for (int layer = 0; layer < structure.Length; ++layer)
            {
                layers.Add(new List<double>(structure[layer]));
                for (int neuron = 0; neuron < structure[layer]; ++neuron)
                    layers[layer].Add(0);
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
            throw new NotImplementedException();
        }

        public override double TrainOnDataSet(SamplesSet samplesSet, int epochsCount, double acceptableError, bool parallel)
        {
            throw new NotImplementedException();
        }

        protected override double[] Compute(double[] input)
        {
            throw new NotImplementedException();
        }

        // Сигмоидная функция активации
        public double Sigmoid(double s, double alpha = 1) => 1.0 / (1 + Math.Exp(-2 * alpha * s));

        // Среднеквадратичная ошибка
        public double MSE(double[] predicted, double[] target)
        {
#if DEBUG
            if (predicted.Length != target.Length)
                throw new ArgumentException("WTF!?? Я не могу такое посчитать, длины массивов не совпадают!");
#endif
                double res = 0;

            for (int i = 0; i < predicted.Length; ++i)
            {
                res += Math.Pow(target[i] - predicted[i], 2);
            }

            return res / predicted.Length;
        }
    }
}