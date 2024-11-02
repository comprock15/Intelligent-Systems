using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.IO;

class ProductionModel
{
    public class Fact
    {
        private string name;
        private float coefficient;
        private string description;

        public Fact(string name, float coefficient, string description)
        {
            this.name = name;
            this.coefficient = coefficient;
            this.description = description;
        }

        public override string ToString()
        {
            //return string.Join(";", name, coefficient, description); 
            return description;
        }
    }

    private class Rule
    {

    }

    private List<Fact> facts;
    private List<Rule> rules;

    public ProductionModel(string facts_filename)
    {
        LoadFacts(facts_filename);
    }

    private void LoadFacts(string filename)
    {
        facts = new List<Fact>();
        using (StreamReader sr = new StreamReader(filename))
        {
            while (!sr.EndOfStream)
            {
                var line = sr.ReadLine().Split(';');
                facts.Add(new Fact(line[0], float.Parse(line[1]), line[2]));
            }
        }
    }

    public List<Fact> GetFacts() => facts;
}