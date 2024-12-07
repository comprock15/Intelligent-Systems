using System;

namespace NeuralNetwork1
{
    public class StudentNetwork : BaseNetwork
    {
        public StudentNetwork(int[] structure)
        {
            // TODO
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
    }
}