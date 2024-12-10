using System;
using System.Collections.Generic;
using System.Linq;

namespace NeuralNetwork1
{
    public class Neuron
    {
        public double Output { get; set; }
        public double Error { get; set; }
    }

    public class StudentNetwork : BaseNetwork
    {
        private Random random = new Random();
        private List<List<List<double>>> weights; // [слой источника][нейрон-адресат][нейрон-источник]
        private List<List<Neuron>> layers; // [слой][нейрон]

        private Func<double, double> activationFunction; // Функция активации
        private Func<double, double> activationFunctionDerivative; // Производная функции активации
        private Func<double[], double[], double> lossFunction; // Функция потерь

        private double learningRate = 0.2;
        private double alpha = 2;

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
            do
            {
                iters++;
                ForwardPropagation(sample.input);
                BackPropagation(sample.Output);
            }
            while (lossFunction(layers.Last().Select(n => n.Output).ToArray(), sample.Output) > acceptableError && iters < 50);

            return iters;
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
            return layers[layers.Count - 1].Select(neuron => neuron.Output).ToArray();
        }

        // Сигмоидная функция активации
        private double Sigmoid(double s) => 1.0 / (1 + Math.Exp(-2 * alpha * s));

        private double SigmoidDerivative(double s) => 2 * 1.0 * s * (1 - s);

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
                layers[0][neuron].Output = input[neuron];

            // А теперь весело считаем значения в нейронах следующих слоёв
            for (int layer = 1; layer < layers.Count; ++layer)
            {
                for (int destinationNeuron = 0; destinationNeuron < layers[layer].Count; ++destinationNeuron)
                {
                    layers[layer][destinationNeuron].Output = -weights[layer - 1][destinationNeuron][0]; // bias
                    for (int sourceNeuron = 0; sourceNeuron < layers[layer - 1].Count; ++sourceNeuron)
                    {
                        layers[layer][destinationNeuron].Output += weights[layer - 1][destinationNeuron][sourceNeuron + 1] * layers[layer - 1][sourceNeuron].Output;
                    }
                    layers[layer][destinationNeuron].Output = activationFunction(layers[layer][destinationNeuron].Output);
                }
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
                for (int sourceNeuron = 0; sourceNeuron < layers[layer].Count; ++sourceNeuron)
                {
                    // Суммируем ошибки приходящих к текущему нейрону нейронов следующего слоя
                    double nextLayerNeuronsErrorSum = 0;
                    for (int destinationNeuron = 0; destinationNeuron < layers[layer + 1].Count; ++destinationNeuron)
                        nextLayerNeuronsErrorSum += layers[layer + 1][destinationNeuron].Error * weights[layer][destinationNeuron][sourceNeuron + 1];
                    layers[layer][sourceNeuron].Error = activationFunctionDerivative(layers[layer][sourceNeuron].Output) * nextLayerNeuronsErrorSum;
                }
            }

            // Наконец пора пересчитывать веса и учить нейросеть
            for (int layer = layers.Count - 2; layer >= 0; --layer)
            {  
                for (int sourceNeuron = 0; sourceNeuron < layers[layer].Count; ++sourceNeuron)
                {
                    // Искренне надеемся, что bias пересчитывается правильно
                    double biasError = 0;
                    for (int destinationNeuron = 0; destinationNeuron < layers[layer + 1].Count; ++destinationNeuron)
                    {
                        biasError += layers[layer + 1][destinationNeuron].Error * weights[layer][destinationNeuron][0];

                        weights[layer][destinationNeuron][sourceNeuron + 1] += -learningRate * layers[layer][sourceNeuron].Error * layers[layer + 1][destinationNeuron].Output;
                    }
                    biasError *= activationFunctionDerivative(-1);

                    for (int destinationNeuron = 0; destinationNeuron < layers[layer + 1].Count; ++destinationNeuron)
                        weights[layer][destinationNeuron][0] += -learningRate * biasError * layers[layer + 1][destinationNeuron].Output;
                }
            }
        }
    }
}