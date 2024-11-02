using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.IO;

class ProductionModel
{
    public ProductionModel(string facts_filename, string rules_filename)
    {
        LoadFacts(facts_filename);
        LoadRules(rules_filename);
    }

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

    public class Rule
    {
        string name;
        List<int> precondition;
        int action;
        float coefficient;
        string description;

        public Rule(string name, List<int> precondition, int action, float coefficient, string description)
        {
            this.name = name;
            this.precondition = precondition;
            this.action = action;
            this.coefficient = coefficient;
            this.description = description;
        }

        public override string ToString()
        {
            return description;
        }
    }

    private List<Fact> facts;
    public List<Fact> GetFacts() => facts;

    private List<Rule> rules;
    public List<Rule> GetRules() => rules;

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

    private void LoadRules(string filename)
    {
        rules = new List<Rule>();
        using (StreamReader sr = new StreamReader(filename))
        {
            while (!sr.EndOfStream)
            {
                var line = sr.ReadLine().Split(';');
                rules.Add(new Rule(line[0], 
                                   line[1].Split(',').Select(x => int.Parse(x.Remove(0, 1)) - 1).ToList(),
                                   int.Parse(line[2].Remove(0, 1)) - 1,
                                   float.Parse(line[3]),
                                   line[4]));
            }
        }
    }

    public string ForwardChaining(HashSet<int> knowledgeBase, int target)
    {
        return "Не удалось вывести факт";
    }
}