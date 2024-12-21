namespace NeuralNetwork1
{
    partial class Form1
    {
        /// <summary>
        /// Обязательная переменная конструктора.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        /// Освободить все используемые ресурсы.
        /// </summary>
        /// <param name="disposing">истинно, если управляемый ресурс должен быть удален; иначе ложно.</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Код, автоматически созданный конструктором форм Windows

        /// <summary>
        /// Требуемый метод для поддержки конструктора — не изменяйте 
        /// содержимое этого метода с помощью редактора кода.
        /// </summary>
        private void InitializeComponent()
        {
            System.Windows.Forms.Label label2;
            System.Windows.Forms.Label label4;
            System.Windows.Forms.Label label5;
            System.Windows.Forms.Label label6;
            System.Windows.Forms.Label label7;
            this.pictureBox1 = new System.Windows.Forms.PictureBox();
            this.label1 = new System.Windows.Forms.Label();
            this.groupBox1 = new System.Windows.Forms.GroupBox();
            this.label11 = new System.Windows.Forms.Label();
            this.netTypeBox = new System.Windows.Forms.ComboBox();
            this.parallelCheckBox = new System.Windows.Forms.CheckBox();
            this.netStructureBox = new System.Windows.Forms.TextBox();
            this.recreateNetButton = new System.Windows.Forms.Button();
            this.classCounter = new System.Windows.Forms.NumericUpDown();
            this.label10 = new System.Windows.Forms.Label();
            this.testNetButton = new System.Windows.Forms.Button();
            this.netTrainButton = new System.Windows.Forms.Button();
            this.AccuracyCounter = new System.Windows.Forms.TrackBar();
            this.EpochesCounter = new System.Windows.Forms.NumericUpDown();
            this.TrainingSizeCounter = new System.Windows.Forms.NumericUpDown();
            this.label8 = new System.Windows.Forms.Label();
            this.label9 = new System.Windows.Forms.Label();
            this.trainOneButton = new System.Windows.Forms.Button();
            this.progressBar1 = new System.Windows.Forms.ProgressBar();
            this.statusStrip1 = new System.Windows.Forms.StatusStrip();
            this.infoStatusLabel = new System.Windows.Forms.ToolStripStatusLabel();
            this.elapsedTimeLabel = new System.Windows.Forms.Label();
            this.вапрвапрToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.StatusLabel = new System.Windows.Forms.Label();
            this.groupBox2 = new System.Windows.Forms.GroupBox();
            this.button1 = new System.Windows.Forms.Button();
            this.AIMLOutput = new System.Windows.Forms.TextBox();
            this.AIMLInput = new System.Windows.Forms.TextBox();
            this.groupBox3 = new System.Windows.Forms.GroupBox();
            this.TLGBotOnButton = new System.Windows.Forms.Button();
            this.TLGUsersMessages = new System.Windows.Forms.TextBox();
            label2 = new System.Windows.Forms.Label();
            label4 = new System.Windows.Forms.Label();
            label5 = new System.Windows.Forms.Label();
            label6 = new System.Windows.Forms.Label();
            label7 = new System.Windows.Forms.Label();
            ((System.ComponentModel.ISupportInitialize)(this.pictureBox1)).BeginInit();
            this.groupBox1.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.classCounter)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.AccuracyCounter)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.EpochesCounter)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.TrainingSizeCounter)).BeginInit();
            this.statusStrip1.SuspendLayout();
            this.groupBox2.SuspendLayout();
            this.groupBox3.SuspendLayout();
            this.SuspendLayout();
            // 
            // label2
            // 
            label2.AutoSize = true;
            label2.Location = new System.Drawing.Point(77, 47);
            label2.Name = "label2";
            label2.Size = new System.Drawing.Size(84, 13);
            label2.TabIndex = 2;
            label2.Text = "Структура сети";
            // 
            // label4
            // 
            label4.AutoSize = true;
            label4.Location = new System.Drawing.Point(8, 73);
            label4.Name = "label4";
            label4.Size = new System.Drawing.Size(153, 13);
            label4.TabIndex = 5;
            label4.Text = "Размер обучающей выборки";
            // 
            // label5
            // 
            label5.AutoSize = true;
            label5.Location = new System.Drawing.Point(69, 100);
            label5.Name = "label5";
            label5.Size = new System.Drawing.Size(92, 13);
            label5.TabIndex = 7;
            label5.Text = "Количество эпох";
            // 
            // label6
            // 
            label6.AutoSize = true;
            label6.Location = new System.Drawing.Point(23, 194);
            label6.Name = "label6";
            label6.Size = new System.Drawing.Size(54, 13);
            label6.TabIndex = 9;
            label6.Text = "Точность";
            // 
            // label7
            // 
            label7.AutoSize = true;
            label7.Location = new System.Drawing.Point(545, 342);
            label7.Name = "label7";
            label7.Size = new System.Drawing.Size(40, 13);
            label7.TabIndex = 14;
            label7.Text = "Status:";
            // 
            // pictureBox1
            // 
            this.pictureBox1.BorderStyle = System.Windows.Forms.BorderStyle.Fixed3D;
            this.pictureBox1.Location = new System.Drawing.Point(9, 10);
            this.pictureBox1.Margin = new System.Windows.Forms.Padding(2);
            this.pictureBox1.Name = "pictureBox1";
            this.pictureBox1.Size = new System.Drawing.Size(500, 500);
            this.pictureBox1.SizeMode = System.Windows.Forms.PictureBoxSizeMode.Zoom;
            this.pictureBox1.TabIndex = 1;
            this.pictureBox1.TabStop = false;
            this.pictureBox1.MouseClick += new System.Windows.Forms.MouseEventHandler(this.pictureBox1_MouseClick);
            // 
            // label1
            // 
            this.label1.AutoSize = true;
            this.label1.Location = new System.Drawing.Point(514, 10);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(83, 13);
            this.label1.TabIndex = 2;
            this.label1.Text = "Какой-то текст";
            // 
            // groupBox1
            // 
            this.groupBox1.Controls.Add(this.label11);
            this.groupBox1.Controls.Add(this.netTypeBox);
            this.groupBox1.Controls.Add(this.parallelCheckBox);
            this.groupBox1.Controls.Add(this.netStructureBox);
            this.groupBox1.Controls.Add(this.recreateNetButton);
            this.groupBox1.Controls.Add(this.classCounter);
            this.groupBox1.Controls.Add(this.label10);
            this.groupBox1.Controls.Add(this.testNetButton);
            this.groupBox1.Controls.Add(this.netTrainButton);
            this.groupBox1.Controls.Add(this.AccuracyCounter);
            this.groupBox1.Controls.Add(label6);
            this.groupBox1.Controls.Add(this.EpochesCounter);
            this.groupBox1.Controls.Add(label5);
            this.groupBox1.Controls.Add(this.TrainingSizeCounter);
            this.groupBox1.Controls.Add(label4);
            this.groupBox1.Controls.Add(label2);
            this.groupBox1.Location = new System.Drawing.Point(514, 40);
            this.groupBox1.Name = "groupBox1";
            this.groupBox1.Size = new System.Drawing.Size(294, 299);
            this.groupBox1.TabIndex = 3;
            this.groupBox1.TabStop = false;
            this.groupBox1.Text = "Параметры сети";
            // 
            // label11
            // 
            this.label11.AutoSize = true;
            this.label11.Location = new System.Drawing.Point(129, 22);
            this.label11.Name = "label11";
            this.label11.Size = new System.Drawing.Size(31, 13);
            this.label11.TabIndex = 21;
            this.label11.Text = "Сеть";
            // 
            // netTypeBox
            // 
            this.netTypeBox.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList;
            this.netTypeBox.Enabled = false;
            this.netTypeBox.FormattingEnabled = true;
            this.netTypeBox.Items.AddRange(new object[] {
            "Hand Crafted Perseptron",
            "Accord.Net Perseptron"});
            this.netTypeBox.Location = new System.Drawing.Point(166, 19);
            this.netTypeBox.Name = "netTypeBox";
            this.netTypeBox.Size = new System.Drawing.Size(121, 21);
            this.netTypeBox.TabIndex = 20;
            this.netTypeBox.SelectedIndexChanged += new System.EventHandler(this.netTypeBox_SelectedIndexChanged);
            // 
            // parallelCheckBox
            // 
            this.parallelCheckBox.AutoSize = true;
            this.parallelCheckBox.Checked = true;
            this.parallelCheckBox.CheckState = System.Windows.Forms.CheckState.Checked;
            this.parallelCheckBox.Location = new System.Drawing.Point(34, 243);
            this.parallelCheckBox.Name = "parallelCheckBox";
            this.parallelCheckBox.Size = new System.Drawing.Size(139, 17);
            this.parallelCheckBox.TabIndex = 19;
            this.parallelCheckBox.Text = "Параллельный расчёт";
            this.parallelCheckBox.UseVisualStyleBackColor = true;
            // 
            // netStructureBox
            // 
            this.netStructureBox.Location = new System.Drawing.Point(167, 44);
            this.netStructureBox.Name = "netStructureBox";
            this.netStructureBox.Size = new System.Drawing.Size(120, 20);
            this.netStructureBox.TabIndex = 18;
            this.netStructureBox.Text = "400;500;20;2";
            // 
            // recreateNetButton
            // 
            this.recreateNetButton.Location = new System.Drawing.Point(77, 161);
            this.recreateNetButton.Name = "recreateNetButton";
            this.recreateNetButton.Size = new System.Drawing.Size(140, 30);
            this.recreateNetButton.TabIndex = 17;
            this.recreateNetButton.Text = "Пересоздать сеть";
            this.recreateNetButton.UseVisualStyleBackColor = true;
            this.recreateNetButton.Click += new System.EventHandler(this.button3_Click);
            this.recreateNetButton.MouseEnter += new System.EventHandler(this.recreateNetButton_MouseEnter);
            // 
            // classCounter
            // 
            this.classCounter.Location = new System.Drawing.Point(167, 125);
            this.classCounter.Maximum = new decimal(new int[] {
            4,
            0,
            0,
            0});
            this.classCounter.Minimum = new decimal(new int[] {
            1,
            0,
            0,
            0});
            this.classCounter.Name = "classCounter";
            this.classCounter.Size = new System.Drawing.Size(120, 20);
            this.classCounter.TabIndex = 16;
            this.classCounter.Value = new decimal(new int[] {
            2,
            0,
            0,
            0});
            this.classCounter.ValueChanged += new System.EventHandler(this.classCounter_ValueChanged);
            // 
            // label10
            // 
            this.label10.AutoSize = true;
            this.label10.Location = new System.Drawing.Point(50, 125);
            this.label10.Name = "label10";
            this.label10.Size = new System.Drawing.Size(111, 13);
            this.label10.TabIndex = 15;
            this.label10.Text = "Количество классов";
            // 
            // testNetButton
            // 
            this.testNetButton.Location = new System.Drawing.Point(163, 261);
            this.testNetButton.Name = "testNetButton";
            this.testNetButton.Size = new System.Drawing.Size(100, 30);
            this.testNetButton.TabIndex = 14;
            this.testNetButton.Text = "Тест";
            this.testNetButton.UseVisualStyleBackColor = true;
            this.testNetButton.Click += new System.EventHandler(this.button2_Click);
            this.testNetButton.MouseEnter += new System.EventHandler(this.testNetButton_MouseEnter);
            // 
            // netTrainButton
            // 
            this.netTrainButton.Location = new System.Drawing.Point(31, 261);
            this.netTrainButton.Name = "netTrainButton";
            this.netTrainButton.Size = new System.Drawing.Size(100, 30);
            this.netTrainButton.TabIndex = 11;
            this.netTrainButton.Text = "Обучить";
            this.netTrainButton.UseVisualStyleBackColor = true;
            this.netTrainButton.Click += new System.EventHandler(this.button1_Click);
            this.netTrainButton.MouseEnter += new System.EventHandler(this.netTrainButton_MouseEnter);
            // 
            // AccuracyCounter
            // 
            this.AccuracyCounter.Location = new System.Drawing.Point(25, 210);
            this.AccuracyCounter.Maximum = 100;
            this.AccuracyCounter.Name = "AccuracyCounter";
            this.AccuracyCounter.Size = new System.Drawing.Size(245, 45);
            this.AccuracyCounter.TabIndex = 10;
            this.AccuracyCounter.TickFrequency = 10;
            this.AccuracyCounter.Value = 80;
            // 
            // EpochesCounter
            // 
            this.EpochesCounter.Location = new System.Drawing.Point(167, 98);
            this.EpochesCounter.Maximum = new decimal(new int[] {
            1000000,
            0,
            0,
            0});
            this.EpochesCounter.Minimum = new decimal(new int[] {
            1,
            0,
            0,
            0});
            this.EpochesCounter.Name = "EpochesCounter";
            this.EpochesCounter.Size = new System.Drawing.Size(120, 20);
            this.EpochesCounter.TabIndex = 8;
            this.EpochesCounter.Value = new decimal(new int[] {
            20,
            0,
            0,
            0});
            // 
            // TrainingSizeCounter
            // 
            this.TrainingSizeCounter.Location = new System.Drawing.Point(167, 71);
            this.TrainingSizeCounter.Maximum = new decimal(new int[] {
            100000,
            0,
            0,
            0});
            this.TrainingSizeCounter.Minimum = new decimal(new int[] {
            1,
            0,
            0,
            0});
            this.TrainingSizeCounter.Name = "TrainingSizeCounter";
            this.TrainingSizeCounter.Size = new System.Drawing.Size(120, 20);
            this.TrainingSizeCounter.TabIndex = 6;
            this.TrainingSizeCounter.Value = new decimal(new int[] {
            700,
            0,
            0,
            0});
            // 
            // label8
            // 
            this.label8.AutoSize = true;
            this.label8.Location = new System.Drawing.Point(556, 367);
            this.label8.Name = "label8";
            this.label8.Size = new System.Drawing.Size(35, 13);
            this.label8.TabIndex = 6;
            this.label8.Text = "label8";
            // 
            // label9
            // 
            this.label9.AutoSize = true;
            this.label9.Location = new System.Drawing.Point(522, 367);
            this.label9.Name = "label9";
            this.label9.Size = new System.Drawing.Size(16, 52);
            this.label9.TabIndex = 7;
            this.label9.Text = "0:\r\n1:\r\n2:\r\n3:";
            // 
            // trainOneButton
            // 
            this.trainOneButton.Location = new System.Drawing.Point(514, 480);
            this.trainOneButton.Name = "trainOneButton";
            this.trainOneButton.Size = new System.Drawing.Size(126, 30);
            this.trainOneButton.TabIndex = 8;
            this.trainOneButton.Text = "Обучить образцу";
            this.trainOneButton.UseVisualStyleBackColor = true;
            this.trainOneButton.Click += new System.EventHandler(this.btnTrainOne_Click);
            // 
            // progressBar1
            // 
            this.progressBar1.Location = new System.Drawing.Point(517, 424);
            this.progressBar1.Name = "progressBar1";
            this.progressBar1.Size = new System.Drawing.Size(291, 22);
            this.progressBar1.Step = 1;
            this.progressBar1.Style = System.Windows.Forms.ProgressBarStyle.Continuous;
            this.progressBar1.TabIndex = 10;
            // 
            // statusStrip1
            // 
            this.statusStrip1.Items.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.infoStatusLabel});
            this.statusStrip1.Location = new System.Drawing.Point(0, 519);
            this.statusStrip1.Name = "statusStrip1";
            this.statusStrip1.Size = new System.Drawing.Size(1182, 22);
            this.statusStrip1.TabIndex = 11;
            this.statusStrip1.Text = "statusStrip1";
            // 
            // infoStatusLabel
            // 
            this.infoStatusLabel.DisplayStyle = System.Windows.Forms.ToolStripItemDisplayStyle.Text;
            this.infoStatusLabel.Name = "infoStatusLabel";
            this.infoStatusLabel.Size = new System.Drawing.Size(80, 17);
            this.infoStatusLabel.Text = "Обучите сеть";
            this.infoStatusLabel.TextAlign = System.Drawing.ContentAlignment.MiddleLeft;
            // 
            // elapsedTimeLabel
            // 
            this.elapsedTimeLabel.AutoSize = true;
            this.elapsedTimeLabel.Location = new System.Drawing.Point(522, 449);
            this.elapsedTimeLabel.Name = "elapsedTimeLabel";
            this.elapsedTimeLabel.Size = new System.Drawing.Size(43, 13);
            this.elapsedTimeLabel.TabIndex = 12;
            this.elapsedTimeLabel.Text = "Время:";
            // 
            // вапрвапрToolStripMenuItem
            // 
            this.вапрвапрToolStripMenuItem.Name = "вапрвапрToolStripMenuItem";
            this.вапрвапрToolStripMenuItem.Size = new System.Drawing.Size(180, 22);
            this.вапрвапрToolStripMenuItem.Text = "вапрвапр";
            // 
            // StatusLabel
            // 
            this.StatusLabel.AutoSize = true;
            this.StatusLabel.Location = new System.Drawing.Point(588, 342);
            this.StatusLabel.Name = "StatusLabel";
            this.StatusLabel.Size = new System.Drawing.Size(38, 13);
            this.StatusLabel.TabIndex = 15;
            this.StatusLabel.Text = "NONE";
            // 
            // groupBox2
            // 
            this.groupBox2.Controls.Add(this.button1);
            this.groupBox2.Controls.Add(this.AIMLOutput);
            this.groupBox2.Controls.Add(this.AIMLInput);
            this.groupBox2.Location = new System.Drawing.Point(814, 12);
            this.groupBox2.Name = "groupBox2";
            this.groupBox2.Size = new System.Drawing.Size(356, 184);
            this.groupBox2.TabIndex = 16;
            this.groupBox2.TabStop = false;
            this.groupBox2.Text = "AIML чат-бот";
            // 
            // button1
            // 
            this.button1.Location = new System.Drawing.Point(219, 58);
            this.button1.Name = "button1";
            this.button1.Size = new System.Drawing.Size(122, 34);
            this.button1.TabIndex = 2;
            this.button1.Text = "Обработать";
            this.button1.UseVisualStyleBackColor = true;
            this.button1.Click += new System.EventHandler(this.button1_Click_1);
            // 
            // AIMLOutput
            // 
            this.AIMLOutput.Location = new System.Drawing.Point(13, 101);
            this.AIMLOutput.Multiline = true;
            this.AIMLOutput.Name = "AIMLOutput";
            this.AIMLOutput.Size = new System.Drawing.Size(328, 77);
            this.AIMLOutput.TabIndex = 1;
            // 
            // AIMLInput
            // 
            this.AIMLInput.Font = new System.Drawing.Font("Microsoft Sans Serif", 14F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(204)));
            this.AIMLInput.Location = new System.Drawing.Point(11, 23);
            this.AIMLInput.Name = "AIMLInput";
            this.AIMLInput.Size = new System.Drawing.Size(330, 29);
            this.AIMLInput.TabIndex = 0;
            // 
            // groupBox3
            // 
            this.groupBox3.Controls.Add(this.TLGBotOnButton);
            this.groupBox3.Controls.Add(this.TLGUsersMessages);
            this.groupBox3.Location = new System.Drawing.Point(814, 201);
            this.groupBox3.Name = "groupBox3";
            this.groupBox3.Size = new System.Drawing.Size(356, 309);
            this.groupBox3.TabIndex = 17;
            this.groupBox3.TabStop = false;
            this.groupBox3.Text = "Telegram";
            // 
            // TLGBotOnButton
            // 
            this.TLGBotOnButton.Location = new System.Drawing.Point(219, 19);
            this.TLGBotOnButton.Name = "TLGBotOnButton";
            this.TLGBotOnButton.Size = new System.Drawing.Size(122, 34);
            this.TLGBotOnButton.TabIndex = 1;
            this.TLGBotOnButton.Text = "BotOn";
            this.TLGBotOnButton.UseVisualStyleBackColor = true;
            this.TLGBotOnButton.Click += new System.EventHandler(this.TLGBotOnButton_Click);
            // 
            // TLGUsersMessages
            // 
            this.TLGUsersMessages.Location = new System.Drawing.Point(6, 66);
            this.TLGUsersMessages.Multiline = true;
            this.TLGUsersMessages.Name = "TLGUsersMessages";
            this.TLGUsersMessages.Size = new System.Drawing.Size(344, 237);
            this.TLGUsersMessages.TabIndex = 0;
            // 
            // Form1
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(1182, 541);
            this.Controls.Add(this.groupBox3);
            this.Controls.Add(this.groupBox2);
            this.Controls.Add(this.StatusLabel);
            this.Controls.Add(label7);
            this.Controls.Add(this.elapsedTimeLabel);
            this.Controls.Add(this.statusStrip1);
            this.Controls.Add(this.progressBar1);
            this.Controls.Add(this.trainOneButton);
            this.Controls.Add(this.label9);
            this.Controls.Add(this.label8);
            this.Controls.Add(this.groupBox1);
            this.Controls.Add(this.label1);
            this.Controls.Add(this.pictureBox1);
            this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.FixedDialog;
            this.Margin = new System.Windows.Forms.Padding(2);
            this.MaximizeBox = false;
            this.Name = "Form1";
            this.Text = "Банальный студенческий перспетрон";
            ((System.ComponentModel.ISupportInitialize)(this.pictureBox1)).EndInit();
            this.groupBox1.ResumeLayout(false);
            this.groupBox1.PerformLayout();
            ((System.ComponentModel.ISupportInitialize)(this.classCounter)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.AccuracyCounter)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.EpochesCounter)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.TrainingSizeCounter)).EndInit();
            this.statusStrip1.ResumeLayout(false);
            this.statusStrip1.PerformLayout();
            this.groupBox2.ResumeLayout(false);
            this.groupBox2.PerformLayout();
            this.groupBox3.ResumeLayout(false);
            this.groupBox3.PerformLayout();
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.PictureBox pictureBox1;
        private System.Windows.Forms.Label label1;
        private System.Windows.Forms.GroupBox groupBox1;
        private System.Windows.Forms.NumericUpDown TrainingSizeCounter;
        private System.Windows.Forms.NumericUpDown EpochesCounter;
        private System.Windows.Forms.TrackBar AccuracyCounter;
        private System.Windows.Forms.Label label8;
        private System.Windows.Forms.Label label9;
        private System.Windows.Forms.Button recreateNetButton;
        private System.Windows.Forms.NumericUpDown classCounter;
        private System.Windows.Forms.Label label10;
        private System.Windows.Forms.Button trainOneButton;
        private System.Windows.Forms.TextBox netStructureBox;
		private System.Windows.Forms.ProgressBar progressBar1;
        private System.Windows.Forms.StatusStrip statusStrip1;
        private System.Windows.Forms.ToolStripStatusLabel infoStatusLabel;
        private System.Windows.Forms.Label elapsedTimeLabel;
        private System.Windows.Forms.Button testNetButton;
        private System.Windows.Forms.Button netTrainButton;
        private System.Windows.Forms.CheckBox parallelCheckBox;
        private System.Windows.Forms.ToolStripMenuItem вапрвапрToolStripMenuItem;
        private System.Windows.Forms.ComboBox netTypeBox;
        private System.Windows.Forms.Label label11;
        private System.Windows.Forms.Label StatusLabel;
        private System.Windows.Forms.GroupBox groupBox2;
        private System.Windows.Forms.Button button1;
        private System.Windows.Forms.TextBox AIMLOutput;
        private System.Windows.Forms.TextBox AIMLInput;
        private System.Windows.Forms.GroupBox groupBox3;
        private System.Windows.Forms.Button TLGBotOnButton;
        private System.Windows.Forms.TextBox TLGUsersMessages;
    }
}

