namespace ClipsFormsExample
{
    partial class ClipsFormsExample
    {
        /// <summary>
        /// Required designer variable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        /// Clean up any resources being used.
        /// </summary>
        /// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Windows Form Designer generated code

        /// <summary>
        /// Required method for Designer support - do not modify
        /// the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(ClipsFormsExample));
            this.panel1 = new System.Windows.Forms.Panel();
            this.splitContainer1 = new System.Windows.Forms.SplitContainer();
            this.panel2 = new System.Windows.Forms.Panel();
            this.voicesBox = new System.Windows.Forms.ComboBox();
            this.fontButton = new System.Windows.Forms.Button();
            this.nextButton = new System.Windows.Forms.Button();
            this.resetButton = new System.Windows.Forms.Button();
            this.saveAsButton = new System.Windows.Forms.Button();
            this.openButton = new System.Windows.Forms.Button();
            this.clipsOpenFileDialog = new System.Windows.Forms.OpenFileDialog();
            this.fontDialog1 = new System.Windows.Forms.FontDialog();
            this.clipsSaveFileDialog = new System.Windows.Forms.SaveFileDialog();
            this.panel3 = new System.Windows.Forms.Panel();
            this.codeBox = new System.Windows.Forms.TextBox();
            this.splitContainer2 = new System.Windows.Forms.SplitContainer();
            this.factsListBox = new System.Windows.Forms.ListBox();
            this.loadFactsButton = new System.Windows.Forms.Button();
            this.outputBox = new System.Windows.Forms.RichTextBox();
            this.panel1.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.splitContainer1)).BeginInit();
            this.splitContainer1.Panel1.SuspendLayout();
            this.splitContainer1.Panel2.SuspendLayout();
            this.splitContainer1.SuspendLayout();
            this.panel2.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.splitContainer2)).BeginInit();
            this.splitContainer2.Panel1.SuspendLayout();
            this.splitContainer2.Panel2.SuspendLayout();
            this.splitContainer2.SuspendLayout();
            this.SuspendLayout();
            // 
            // panel1
            // 
            this.panel1.Anchor = ((System.Windows.Forms.AnchorStyles)((((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom) 
            | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.panel1.Controls.Add(this.splitContainer1);
            this.panel1.Location = new System.Drawing.Point(0, 0);
            this.panel1.Margin = new System.Windows.Forms.Padding(4);
            this.panel1.Name = "panel1";
            this.panel1.Size = new System.Drawing.Size(1515, 746);
            this.panel1.TabIndex = 2;
            // 
            // splitContainer1
            // 
            this.splitContainer1.Dock = System.Windows.Forms.DockStyle.Fill;
            this.splitContainer1.Location = new System.Drawing.Point(0, 0);
            this.splitContainer1.Margin = new System.Windows.Forms.Padding(4);
            this.splitContainer1.Name = "splitContainer1";
            // 
            // splitContainer1.Panel1
            // 
            this.splitContainer1.Panel1.Controls.Add(this.codeBox);
            // 
            // splitContainer1.Panel2
            // 
            this.splitContainer1.Panel2.Controls.Add(this.splitContainer2);
            this.splitContainer1.Panel2.Controls.Add(this.panel3);
            this.splitContainer1.Size = new System.Drawing.Size(1515, 746);
            this.splitContainer1.SplitterDistance = 714;
            this.splitContainer1.SplitterWidth = 5;
            this.splitContainer1.TabIndex = 2;
            // 
            // panel2
            // 
            this.panel2.Controls.Add(this.loadFactsButton);
            this.panel2.Controls.Add(this.voicesBox);
            this.panel2.Controls.Add(this.fontButton);
            this.panel2.Controls.Add(this.nextButton);
            this.panel2.Controls.Add(this.resetButton);
            this.panel2.Controls.Add(this.saveAsButton);
            this.panel2.Controls.Add(this.openButton);
            this.panel2.Dock = System.Windows.Forms.DockStyle.Bottom;
            this.panel2.Location = new System.Drawing.Point(0, 746);
            this.panel2.Margin = new System.Windows.Forms.Padding(4);
            this.panel2.Name = "panel2";
            this.panel2.Size = new System.Drawing.Size(1517, 66);
            this.panel2.TabIndex = 6;
            // 
            // voicesBox
            // 
            this.voicesBox.FormattingEnabled = true;
            this.voicesBox.Location = new System.Drawing.Point(520, 22);
            this.voicesBox.Margin = new System.Windows.Forms.Padding(4);
            this.voicesBox.Name = "voicesBox";
            this.voicesBox.Size = new System.Drawing.Size(327, 24);
            this.voicesBox.TabIndex = 10;
            // 
            // fontButton
            // 
            this.fontButton.Location = new System.Drawing.Point(352, 15);
            this.fontButton.Margin = new System.Windows.Forms.Padding(4);
            this.fontButton.Name = "fontButton";
            this.fontButton.Size = new System.Drawing.Size(160, 37);
            this.fontButton.TabIndex = 9;
            this.fontButton.Text = "Шрифт...";
            this.fontButton.UseVisualStyleBackColor = true;
            this.fontButton.Click += new System.EventHandler(this.fontSelect_Click);
            // 
            // nextButton
            // 
            this.nextButton.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Right)));
            this.nextButton.Location = new System.Drawing.Point(1340, 15);
            this.nextButton.Margin = new System.Windows.Forms.Padding(4);
            this.nextButton.Name = "nextButton";
            this.nextButton.Size = new System.Drawing.Size(160, 37);
            this.nextButton.TabIndex = 8;
            this.nextButton.Text = "Дальше";
            this.nextButton.UseVisualStyleBackColor = true;
            this.nextButton.Click += new System.EventHandler(this.nextBtn_Click);
            // 
            // resetButton
            // 
            this.resetButton.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Right)));
            this.resetButton.Location = new System.Drawing.Point(1172, 15);
            this.resetButton.Margin = new System.Windows.Forms.Padding(4);
            this.resetButton.Name = "resetButton";
            this.resetButton.Size = new System.Drawing.Size(160, 37);
            this.resetButton.TabIndex = 7;
            this.resetButton.Text = "Рестарт";
            this.resetButton.UseVisualStyleBackColor = true;
            this.resetButton.Click += new System.EventHandler(this.resetBtn_Click);
            // 
            // saveAsButton
            // 
            this.saveAsButton.Location = new System.Drawing.Point(184, 15);
            this.saveAsButton.Margin = new System.Windows.Forms.Padding(4);
            this.saveAsButton.Name = "saveAsButton";
            this.saveAsButton.Size = new System.Drawing.Size(160, 37);
            this.saveAsButton.TabIndex = 6;
            this.saveAsButton.Text = "Сохранить как...";
            this.saveAsButton.UseVisualStyleBackColor = true;
            this.saveAsButton.Click += new System.EventHandler(this.saveAsButton_Click);
            // 
            // openButton
            // 
            this.openButton.Location = new System.Drawing.Point(16, 15);
            this.openButton.Margin = new System.Windows.Forms.Padding(4);
            this.openButton.Name = "openButton";
            this.openButton.Size = new System.Drawing.Size(160, 37);
            this.openButton.TabIndex = 5;
            this.openButton.Text = "Открыть";
            this.openButton.UseVisualStyleBackColor = true;
            this.openButton.Click += new System.EventHandler(this.openFile_Click);
            // 
            // clipsOpenFileDialog
            // 
            this.clipsOpenFileDialog.Filter = "CLIPS files|*.clp|All files|*.*";
            this.clipsOpenFileDialog.Title = "Открыть файл кода CLIPS";
            // 
            // clipsSaveFileDialog
            // 
            this.clipsSaveFileDialog.Filter = "CLIPS files|*.clp|All files|*.*";
            this.clipsSaveFileDialog.Title = "Созранить файл как...";
            // 
            // panel3
            // 
            this.panel3.Location = new System.Drawing.Point(700, 491);
            this.panel3.Name = "panel3";
            this.panel3.Size = new System.Drawing.Size(200, 100);
            this.panel3.TabIndex = 2;
            // 
            // codeBox
            // 
            this.codeBox.Dock = System.Windows.Forms.DockStyle.Fill;
            this.codeBox.Font = new System.Drawing.Font("Lucida Console", 9.75F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(204)));
            this.codeBox.Location = new System.Drawing.Point(0, 0);
            this.codeBox.Margin = new System.Windows.Forms.Padding(4);
            this.codeBox.MaxLength = 100000;
            this.codeBox.Multiline = true;
            this.codeBox.Name = "codeBox";
            this.codeBox.ScrollBars = System.Windows.Forms.ScrollBars.Vertical;
            this.codeBox.Size = new System.Drawing.Size(714, 746);
            this.codeBox.TabIndex = 2;
            // 
            // splitContainer2
            // 
            this.splitContainer2.Dock = System.Windows.Forms.DockStyle.Fill;
            this.splitContainer2.Location = new System.Drawing.Point(0, 0);
            this.splitContainer2.Name = "splitContainer2";
            // 
            // splitContainer2.Panel1
            // 
            this.splitContainer2.Panel1.Controls.Add(this.outputBox);
            this.splitContainer2.Panel1.RightToLeft = System.Windows.Forms.RightToLeft.No;
            this.splitContainer2.Panel1MinSize = 150;
            // 
            // splitContainer2.Panel2
            // 
            this.splitContainer2.Panel2.Controls.Add(this.factsListBox);
            this.splitContainer2.Panel2.RightToLeft = System.Windows.Forms.RightToLeft.No;
            this.splitContainer2.Panel2MinSize = 150;
            this.splitContainer2.RightToLeft = System.Windows.Forms.RightToLeft.No;
            this.splitContainer2.Size = new System.Drawing.Size(796, 746);
            this.splitContainer2.SplitterDistance = 409;
            this.splitContainer2.TabIndex = 3;
            // 
            // factsListBox
            // 
            this.factsListBox.Dock = System.Windows.Forms.DockStyle.Fill;
            this.factsListBox.Font = new System.Drawing.Font("Lucida Console", 9.75F);
            this.factsListBox.FormattingEnabled = true;
            this.factsListBox.ItemHeight = 16;
            this.factsListBox.Location = new System.Drawing.Point(0, 0);
            this.factsListBox.Name = "factsListBox";
            this.factsListBox.Size = new System.Drawing.Size(383, 746);
            this.factsListBox.TabIndex = 0;
            this.factsListBox.MouseDoubleClick += new System.Windows.Forms.MouseEventHandler(this.factsListBox_MouseDoubleClick);
            // 
            // loadFactsButton
            // 
            this.loadFactsButton.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Right)));
            this.loadFactsButton.Location = new System.Drawing.Point(1004, 15);
            this.loadFactsButton.Margin = new System.Windows.Forms.Padding(4);
            this.loadFactsButton.Name = "loadFactsButton";
            this.loadFactsButton.Size = new System.Drawing.Size(160, 37);
            this.loadFactsButton.TabIndex = 11;
            this.loadFactsButton.Text = "Загрузить факты";
            this.loadFactsButton.UseVisualStyleBackColor = true;
            this.loadFactsButton.Click += new System.EventHandler(this.loadFactsButton_Click);
            // 
            // outputBox
            // 
            this.outputBox.Dock = System.Windows.Forms.DockStyle.Fill;
            this.outputBox.Font = new System.Drawing.Font("Lucida Console", 9.75F);
            this.outputBox.Location = new System.Drawing.Point(0, 0);
            this.outputBox.MinimumSize = new System.Drawing.Size(100, 0);
            this.outputBox.Name = "outputBox";
            this.outputBox.Size = new System.Drawing.Size(409, 746);
            this.outputBox.TabIndex = 0;
            this.outputBox.Text = "";
            // 
            // ClipsFormsExample
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(8F, 16F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(1517, 812);
            this.Controls.Add(this.panel2);
            this.Controls.Add(this.panel1);
            this.Icon = ((System.Drawing.Icon)(resources.GetObject("$this.Icon")));
            this.Margin = new System.Windows.Forms.Padding(4);
            this.MinimumSize = new System.Drawing.Size(874, 358);
            this.Name = "ClipsFormsExample";
            this.Text = "Экспертная система \"Составление рациона на день\"";
            this.panel1.ResumeLayout(false);
            this.splitContainer1.Panel1.ResumeLayout(false);
            this.splitContainer1.Panel1.PerformLayout();
            this.splitContainer1.Panel2.ResumeLayout(false);
            ((System.ComponentModel.ISupportInitialize)(this.splitContainer1)).EndInit();
            this.splitContainer1.ResumeLayout(false);
            this.panel2.ResumeLayout(false);
            this.splitContainer2.Panel1.ResumeLayout(false);
            this.splitContainer2.Panel2.ResumeLayout(false);
            ((System.ComponentModel.ISupportInitialize)(this.splitContainer2)).EndInit();
            this.splitContainer2.ResumeLayout(false);
            this.ResumeLayout(false);

        }

        #endregion
    private System.Windows.Forms.Panel panel1;
    private System.Windows.Forms.SplitContainer splitContainer1;
    private System.Windows.Forms.Panel panel2;
    private System.Windows.Forms.Button nextButton;
    private System.Windows.Forms.Button resetButton;
    private System.Windows.Forms.Button saveAsButton;
    private System.Windows.Forms.Button openButton;
    private System.Windows.Forms.OpenFileDialog clipsOpenFileDialog;
    private System.Windows.Forms.Button fontButton;
    private System.Windows.Forms.FontDialog fontDialog1;
    private System.Windows.Forms.SaveFileDialog clipsSaveFileDialog;
        private System.Windows.Forms.ComboBox voicesBox;
        private System.Windows.Forms.TextBox codeBox;
        private System.Windows.Forms.SplitContainer splitContainer2;
        private System.Windows.Forms.Panel panel3;
        private System.Windows.Forms.ListBox factsListBox;
        private System.Windows.Forms.Button loadFactsButton;
        private System.Windows.Forms.RichTextBox outputBox;
    }
}

