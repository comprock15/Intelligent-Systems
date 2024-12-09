using System;
using System.Collections.Generic;

namespace NeuralNetwork1
{
    public class StudentNetwork : BaseNetwork
    {
        private Random random = new Random();
        private List<List<List<double>>> weights; // [слой источника][нейрон-адресат][нейрон-источник]
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
#if DEBUG
            if (input.Length != layers[0].Count)
                throw new ArgumentException("WTF?!!! Не могу подать на вход нейросети массив другой длины!");
#endif
            ForwardPropagation(input);
            return layers[layers.Count - 1].ToArray();
        }

        // Сигмоидная функция активации
        private double Sigmoid(double s, double alpha = 1) => 1.0 / (1 + Math.Exp(-2 * alpha * s));

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
                res += Math.Pow(target[i] - predicted[i], 2);
            }

            return res / predicted.Length;
        }

        // Прямой проход
        private void ForwardPropagation(double[] input)
        {
            // Задаем значения нейронов входного слоя (сенсоров)
            for (int neuron = 0; neuron < input.Length; ++neuron)
                layers[0][neuron] = input[neuron];

            // А теперь весело считаем значения в нейронах следующих слоёв
            for (int layer = 1; layer < layers.Count; ++layer)
            {
                for (int destinationNeuron = 0; destinationNeuron < layers[layer].Count; ++destinationNeuron)
                {
                    layers[layer][destinationNeuron] = -weights[layer - 1][destinationNeuron][0]; // bias
                    for (int sourceNeuron = 0; sourceNeuron < layers[layer - 1].Count; ++sourceNeuron)
                    {
                        layers[layer][destinationNeuron] += weights[layer - 1][destinationNeuron][sourceNeuron + 1] * layers[layer - 1][sourceNeuron];
                    }
                    layers[layer][destinationNeuron] = activationFunction(layers[layer][destinationNeuron], 1);
                }
            }
        }

        // Обратное распространение ошибки. Именно тут нейросеть обучается
        private void BackPropagation()
        {

        }
    }
}