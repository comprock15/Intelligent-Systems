using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace lab5
{
    public partial class Form1 : Form
    {
        ProductionModel productionModel;

        public Form1()
        {
            InitializeComponent();
            productionModel = new ProductionModel("../../reformatter/facts.txt", "../../reformatter/rules.txt");
            listBox1.Items.AddRange(productionModel.GetFacts().ToArray());
            listBox2.Items.AddRange(productionModel.GetFacts().ToArray());
        }

        private void button1_Click(object sender, EventArgs e)
        {
            if (listBox2.SelectedItem == null)
            {
                textBox1.Text = "Сначала выберите целевой факт!";
                return;
            }
            HashSet<int> knowledgeBase = new HashSet<int>();
            foreach (int index in listBox1.SelectedIndices)
            {
                knowledgeBase.Add(index);
            }
            textBox1.Text = productionModel.ForwardChaining(knowledgeBase, listBox2.SelectedIndex);
        }
    }
}
