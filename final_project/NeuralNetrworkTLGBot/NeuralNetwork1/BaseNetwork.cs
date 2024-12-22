using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace NeuralNetwork1
{
    /// <summary>
    /// Базовый класс для реализации как самодельного персептрона, так и обёртки для ActivationNetwork из Accord.Net
    /// </summary>
    abstract public class BaseNetwork
    {
        //  Делегат для информирования о процессе обучения (периодически извещает форму о том, сколько процентов работы сделано)
        public FormUpdater updateDelegate = null;

        public abstract void ReInit(int[] structure, double initialLearningRate = 0.25);

        public abstract int Train(Sample sample, bool parallel = true);

        public abstract double TrainOnDataSet(SamplesSet samplesSet, int epochs_count, double acceptable_erorr, bool parallel = true);

        public abstract FigureType Predict(Sample sample);

        public abstract double TestOnDataSet(SamplesSet testSet);

        public abstract double[] getOutput();
    }
}
