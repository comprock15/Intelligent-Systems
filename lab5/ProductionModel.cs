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
        private string name;
        private List<int> preconditions;
        private int action;
        private float coefficient;
        private string description;

        public Rule(string name, List<int> preconditions, int action, float coefficient, string description)
        {
            this.name = name;
            this.preconditions = preconditions;
            this.action = action;
            this.coefficient = coefficient;
            this.description = description;
        }

        public override string ToString()
        {
            return description;
        }

        public List<int> GetPreconditions() => preconditions;
        public int GetAction() => action;
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
        List<bool> usedRules = new List<bool>(new bool[rules.Count]);
        StringBuilder explanation = new StringBuilder();
        bool anyRulesLeft = true;
        bool targetReached = knowledgeBase.Contains(target);
        while (!targetReached && anyRulesLeft)
        {
            anyRulesLeft = false;
            for (int i = 0; i < rules.Count; i++)
            {
                if (!usedRules[i])
                {
                    bool ruleCanBeUsed = true;
                    foreach (int f in rules[i].GetPreconditions())
                    {
                        if (!knowledgeBase.Contains(f))
                        {
                            ruleCanBeUsed = false;
                            break;
                        }
                    }
                    if (ruleCanBeUsed)
                    {
                        anyRulesLeft = true;
                        knowledgeBase.Add(rules[i].GetAction());
                        usedRules[i] = true;
                        explanation.Append(rules[i].ToString() + Environment.NewLine);

                        if (rules[i].GetAction() == target)
                        {
                            targetReached = true;
                            break;
                        }
                    }
                }
            }

        }

        if (targetReached)
            return explanation.ToString();
        else
            return "Не удалось вывести факт";
    }
}