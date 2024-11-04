using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.IO;

class ProductionModel
{
    private AndOrGraph graph;

    public ProductionModel(string facts_filename, string rules_filename)
    {
        LoadFacts(facts_filename);
        LoadRules(rules_filename);
        graph = new AndOrGraph(facts, rules);
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

    // Прямой вывод
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
            if (explanation.ToString() == "")
                return "Выводимый факт присутствует в достоверных фактах";
            else
                return explanation.ToString();
        else
            return "Не удалось вывести факт";
    }

    // Обратный вывод
    public string BackwardChaining(HashSet<int> knowledgeBase, int target)
    {
        if (knowledgeBase.Contains(target))
            return "Выводимый факт присутствует в достоверных фактах";

        return graph.FindSolution(knowledgeBase, target);
    }

    private class AndOrGraph
    {
        private List<DataVertex> vertices;
        private List<Fact> facts;
        private List<Rule> rules;

        private enum VertexType { AND, OR, SINGLE };

        private class DataVertex
        {
            public int index;
            public List<TypeVertex> children;

            public DataVertex(int index=0)
            {
                this.index = index;
                this.children = new List<TypeVertex>();
            }
        }
        
        private class TypeVertex
        {
            public VertexType vertexType;
            public List<DataVertex> children;
            public int rule_index;

            public TypeVertex(VertexType vertexType, List<DataVertex> children, int index=0)
            {
                rule_index = index;
                this.vertexType = vertexType;
                this.children = children;
            }
        }

        public AndOrGraph(List<Fact> facts, List<Rule> rules)
        {
            this.facts = facts;
            this.rules = rules;
            this.vertices = new List<DataVertex>(facts.Count);
            for (int i = 0; i < facts.Count; ++i)
                vertices.Add(new DataVertex(i));

            for (int i = 0; i < vertices.Count; ++i)
            {
                for (int j = 0; j < rules.Count; ++j)
                {
                    if (rules[j].GetAction() == i)
                    {
                        var preconditions = rules[j].GetPreconditions();
                        if (preconditions.Count == 1)
                        {
                            vertices[i].children.Add(new TypeVertex(
                                VertexType.SINGLE, 
                                new List<DataVertex>(){ vertices[preconditions[0]] }, 
                                j));
                        }
                        else
                        {
                            var temp = new List<DataVertex>();
                            foreach (var p in preconditions)
                                temp.Add(vertices[p]);
                            vertices[i].children.Add(new TypeVertex(VertexType.AND, temp, j));
                        }
                    }
                }
            }
        }

        public string FindSolution(HashSet<int> knowledgeBase, int target)
        {
            List<int> color = new List<int>(new int[vertices.Count]);
            // 0 - не посещали, 1 - в рассмотрении, 2 - посетили

            //foreach (int i in knowledgeBase)
            //    color[i] = 2;

            Stack<int> stack = new Stack<int>();
            stack.Push(target);

            while (stack.Count > 0)
            {
                int v = stack.Peek();

                if (color[v] == 2)
                {
                    stack.Pop();
                    continue;
                }

                if (color[v] == 0)
                    color[v] = 1;

                if (knowledgeBase.Contains(v) || vertices[v].children.Count == 0)
                {
                    color[v] = 2;
                    stack.Pop();
                    continue;
                }

                bool isSolvable = true;
                bool allChildrenVisited = true;
                for (int i = 0; i < vertices[v].children.Count; ++i)
                {
                    var vchildren = vertices[v].children[i];
                    isSolvable = true;
                    foreach (DataVertex tv in vchildren.children)
                    {
                        if (color[tv.index] == 2)
                        {
                            if (!knowledgeBase.Contains(tv.index))
                            {
                                isSolvable = false;
                                break;
                            }
                        }
                        else
                        {
                            allChildrenVisited = false;
                            stack.Push(tv.index);
                        } 
                    }
                    if (isSolvable && allChildrenVisited)
                    {
                        knowledgeBase.Add(v);
                        break;
                    }
                }

                if (allChildrenVisited)
                {
                    color[v] = 2;
                    stack.Pop();
                }
            }

            if (!knowledgeBase.Contains(target))
                return "Не удалось вывести факт";

            return GetExplanation(knowledgeBase, target, color);
        }

        private string GetExplanation(HashSet<int> knowledgeBase, int target, List<int> color)
        {
            List<string> explanation = new List<string>();

            Stack<int> stack = new Stack<int>();
            stack.Push(target);

            while (stack.Count > 0)
            {
                int v = stack.Pop();

                foreach (TypeVertex tv in vertices[v].children)
                {
                    bool isSolvable = true;
                    bool allChildrenVisited = true;
                    foreach (DataVertex dv in tv.children)
                    {
                        if (color[dv.index] != 2)
                        {
                            allChildrenVisited = false;
                            break;
                        }

                        if (!knowledgeBase.Contains(dv.index))
                        {
                            isSolvable = false;
                            break;
                        }
                    }

                    if (isSolvable && allChildrenVisited)
                    {
                        explanation.Add(rules[tv.rule_index].ToString());

                        foreach (DataVertex dv in tv.children)
                        {
                            stack.Push(dv.index);
                        }
                    }
                }
                
            }

            explanation.Reverse();
            return string.Join(Environment.NewLine, explanation);
        }
    }
}