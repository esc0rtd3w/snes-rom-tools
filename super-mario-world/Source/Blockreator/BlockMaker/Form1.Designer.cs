namespace BlockMaker
{
	partial class Form1
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
            this.eventListBox = new System.Windows.Forms.ListBox();
            this.label1 = new System.Windows.Forms.Label();
            this.codeListBox = new System.Windows.Forms.ListBox();
            this.tabControl1 = new System.Windows.Forms.TabControl();
            this.tabPage1 = new System.Windows.Forms.TabPage();
            this.marioCodesListBox = new System.Windows.Forms.ListBox();
            this.tabPage2 = new System.Windows.Forms.TabPage();
            this.spriteCodesListBox = new System.Windows.Forms.ListBox();
            this.tabPage3 = new System.Windows.Forms.TabPage();
            this.scoreCodesListBox = new System.Windows.Forms.ListBox();
            this.tabPage4 = new System.Windows.Forms.TabPage();
            this.envCodesListBox = new System.Windows.Forms.ListBox();
            this.tabPage5 = new System.Windows.Forms.TabPage();
            this.miscCodesListBox = new System.Windows.Forms.ListBox();
            this.formInsideSize = new System.Windows.Forms.Label();
            this.label2 = new System.Windows.Forms.Label();
            this.buttonPanel = new System.Windows.Forms.Panel();
            this.button3 = new System.Windows.Forms.Button();
            this.elseButton = new System.Windows.Forms.Button();
            this.button1 = new System.Windows.Forms.Button();
            this.editButton = new System.Windows.Forms.Button();
            this.moveDownButton = new System.Windows.Forms.Button();
            this.moveUpButton = new System.Windows.Forms.Button();
            this.deleteButton = new System.Windows.Forms.Button();
            this.addButton = new System.Windows.Forms.Button();
            this.button2 = new System.Windows.Forms.Button();
            this.textBox1 = new System.Windows.Forms.TextBox();
            this.label3 = new System.Windows.Forms.Label();
            this.searchListBox = new System.Windows.Forms.ListBox();
            this.checkBox1 = new System.Windows.Forms.CheckBox();
            this.tabControl1.SuspendLayout();
            this.tabPage1.SuspendLayout();
            this.tabPage2.SuspendLayout();
            this.tabPage3.SuspendLayout();
            this.tabPage4.SuspendLayout();
            this.tabPage5.SuspendLayout();
            this.buttonPanel.SuspendLayout();
            this.SuspendLayout();
            // 
            // eventListBox
            // 
            this.eventListBox.FormattingEnabled = true;
            this.eventListBox.Items.AddRange(new object[] {
            "Mario below",
            "Mario above",
            "Mario side",
            "Sprite vertical",
            "Sprite horizontal",
            "Cape",
            "Fireball",
            "Mario corner",
            "Mario body",
            "Mario head"});
            this.eventListBox.Location = new System.Drawing.Point(12, 25);
            this.eventListBox.Name = "eventListBox";
            this.eventListBox.Size = new System.Drawing.Size(91, 134);
            this.eventListBox.TabIndex = 0;
            this.eventListBox.SelectedIndexChanged += new System.EventHandler(this.eventListBox_SelectedIndexChanged);
            // 
            // label1
            // 
            this.label1.AutoSize = true;
            this.label1.Location = new System.Drawing.Point(12, 9);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(43, 13);
            this.label1.TabIndex = 1;
            this.label1.Text = "Events:";
            // 
            // codeListBox
            // 
            this.codeListBox.Font = new System.Drawing.Font("Courier New", 8.25F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.codeListBox.FormattingEnabled = true;
            this.codeListBox.ItemHeight = 14;
            this.codeListBox.Location = new System.Drawing.Point(109, 25);
            this.codeListBox.Name = "codeListBox";
            this.codeListBox.Size = new System.Drawing.Size(373, 326);
            this.codeListBox.TabIndex = 2;
            this.codeListBox.SelectedIndexChanged += new System.EventHandler(this.codeListBox_SelectedIndexChanged);
            // 
            // tabControl1
            // 
            this.tabControl1.Alignment = System.Windows.Forms.TabAlignment.Right;
            this.tabControl1.Controls.Add(this.tabPage1);
            this.tabControl1.Controls.Add(this.tabPage2);
            this.tabControl1.Controls.Add(this.tabPage3);
            this.tabControl1.Controls.Add(this.tabPage4);
            this.tabControl1.Controls.Add(this.tabPage5);
            this.tabControl1.Location = new System.Drawing.Point(575, 0);
            this.tabControl1.Multiline = true;
            this.tabControl1.Name = "tabControl1";
            this.tabControl1.SelectedIndex = 0;
            this.tabControl1.Size = new System.Drawing.Size(291, 334);
            this.tabControl1.TabIndex = 3;
            this.tabControl1.SelectedIndexChanged += new System.EventHandler(this.tabControl1_SelectedIndexChanged);
            // 
            // tabPage1
            // 
            this.tabPage1.Controls.Add(this.marioCodesListBox);
            this.tabPage1.Location = new System.Drawing.Point(4, 4);
            this.tabPage1.Name = "tabPage1";
            this.tabPage1.Padding = new System.Windows.Forms.Padding(3);
            this.tabPage1.Size = new System.Drawing.Size(264, 326);
            this.tabPage1.TabIndex = 0;
            this.tabPage1.Text = "Mario";
            this.tabPage1.UseVisualStyleBackColor = true;
            // 
            // marioCodesListBox
            // 
            this.marioCodesListBox.Dock = System.Windows.Forms.DockStyle.Fill;
            this.marioCodesListBox.FormattingEnabled = true;
            this.marioCodesListBox.Location = new System.Drawing.Point(3, 3);
            this.marioCodesListBox.Name = "marioCodesListBox";
            this.marioCodesListBox.Size = new System.Drawing.Size(258, 320);
            this.marioCodesListBox.TabIndex = 0;
            // 
            // tabPage2
            // 
            this.tabPage2.Controls.Add(this.spriteCodesListBox);
            this.tabPage2.Location = new System.Drawing.Point(4, 4);
            this.tabPage2.Name = "tabPage2";
            this.tabPage2.Padding = new System.Windows.Forms.Padding(3);
            this.tabPage2.Size = new System.Drawing.Size(264, 326);
            this.tabPage2.TabIndex = 1;
            this.tabPage2.Text = "Sprite";
            this.tabPage2.UseVisualStyleBackColor = true;
            // 
            // spriteCodesListBox
            // 
            this.spriteCodesListBox.Dock = System.Windows.Forms.DockStyle.Fill;
            this.spriteCodesListBox.FormattingEnabled = true;
            this.spriteCodesListBox.Location = new System.Drawing.Point(3, 3);
            this.spriteCodesListBox.Name = "spriteCodesListBox";
            this.spriteCodesListBox.Size = new System.Drawing.Size(258, 320);
            this.spriteCodesListBox.TabIndex = 0;
            // 
            // tabPage3
            // 
            this.tabPage3.Controls.Add(this.scoreCodesListBox);
            this.tabPage3.Location = new System.Drawing.Point(4, 4);
            this.tabPage3.Name = "tabPage3";
            this.tabPage3.Padding = new System.Windows.Forms.Padding(3);
            this.tabPage3.Size = new System.Drawing.Size(264, 326);
            this.tabPage3.TabIndex = 2;
            this.tabPage3.Text = "Score";
            this.tabPage3.UseVisualStyleBackColor = true;
            // 
            // scoreCodesListBox
            // 
            this.scoreCodesListBox.Dock = System.Windows.Forms.DockStyle.Fill;
            this.scoreCodesListBox.FormattingEnabled = true;
            this.scoreCodesListBox.Location = new System.Drawing.Point(3, 3);
            this.scoreCodesListBox.Name = "scoreCodesListBox";
            this.scoreCodesListBox.Size = new System.Drawing.Size(258, 320);
            this.scoreCodesListBox.TabIndex = 0;
            // 
            // tabPage4
            // 
            this.tabPage4.Controls.Add(this.envCodesListBox);
            this.tabPage4.Location = new System.Drawing.Point(4, 4);
            this.tabPage4.Name = "tabPage4";
            this.tabPage4.Padding = new System.Windows.Forms.Padding(3);
            this.tabPage4.Size = new System.Drawing.Size(264, 326);
            this.tabPage4.TabIndex = 3;
            this.tabPage4.Text = "Environment";
            this.tabPage4.UseVisualStyleBackColor = true;
            // 
            // envCodesListBox
            // 
            this.envCodesListBox.Dock = System.Windows.Forms.DockStyle.Fill;
            this.envCodesListBox.FormattingEnabled = true;
            this.envCodesListBox.Location = new System.Drawing.Point(3, 3);
            this.envCodesListBox.Name = "envCodesListBox";
            this.envCodesListBox.Size = new System.Drawing.Size(258, 320);
            this.envCodesListBox.TabIndex = 0;
            // 
            // tabPage5
            // 
            this.tabPage5.Controls.Add(this.miscCodesListBox);
            this.tabPage5.Location = new System.Drawing.Point(4, 4);
            this.tabPage5.Name = "tabPage5";
            this.tabPage5.Padding = new System.Windows.Forms.Padding(3);
            this.tabPage5.Size = new System.Drawing.Size(264, 326);
            this.tabPage5.TabIndex = 4;
            this.tabPage5.Text = "Misc.";
            this.tabPage5.UseVisualStyleBackColor = true;
            // 
            // miscCodesListBox
            // 
            this.miscCodesListBox.Dock = System.Windows.Forms.DockStyle.Fill;
            this.miscCodesListBox.FormattingEnabled = true;
            this.miscCodesListBox.Location = new System.Drawing.Point(3, 3);
            this.miscCodesListBox.Name = "miscCodesListBox";
            this.miscCodesListBox.Size = new System.Drawing.Size(258, 320);
            this.miscCodesListBox.TabIndex = 0;
            // 
            // formInsideSize
            // 
            this.formInsideSize.BackColor = System.Drawing.SystemColors.Control;
            this.formInsideSize.Dock = System.Windows.Forms.DockStyle.Fill;
            this.formInsideSize.Location = new System.Drawing.Point(0, 0);
            this.formInsideSize.Name = "formInsideSize";
            this.formInsideSize.Size = new System.Drawing.Size(866, 423);
            this.formInsideSize.TabIndex = 4;
            // 
            // label2
            // 
            this.label2.AutoSize = true;
            this.label2.Location = new System.Drawing.Point(106, 9);
            this.label2.Name = "label2";
            this.label2.Size = new System.Drawing.Size(45, 13);
            this.label2.TabIndex = 5;
            this.label2.Text = "Actions:";
            // 
            // buttonPanel
            // 
            this.buttonPanel.Controls.Add(this.button3);
            this.buttonPanel.Controls.Add(this.elseButton);
            this.buttonPanel.Controls.Add(this.button1);
            this.buttonPanel.Controls.Add(this.editButton);
            this.buttonPanel.Controls.Add(this.moveDownButton);
            this.buttonPanel.Controls.Add(this.moveUpButton);
            this.buttonPanel.Controls.Add(this.deleteButton);
            this.buttonPanel.Controls.Add(this.addButton);
            this.buttonPanel.Location = new System.Drawing.Point(488, 4);
            this.buttonPanel.Name = "buttonPanel";
            this.buttonPanel.Size = new System.Drawing.Size(81, 323);
            this.buttonPanel.TabIndex = 6;
            // 
            // button3
            // 
            this.button3.Location = new System.Drawing.Point(3, 284);
            this.button3.Name = "button3";
            this.button3.Size = new System.Drawing.Size(75, 34);
            this.button3.TabIndex = 6;
            this.button3.Text = "Insert \"or\"";
            this.button3.UseVisualStyleBackColor = true;
            this.button3.Click += new System.EventHandler(this.button3_Click);
            // 
            // elseButton
            // 
            this.elseButton.Location = new System.Drawing.Point(3, 244);
            this.elseButton.Name = "elseButton";
            this.elseButton.Size = new System.Drawing.Size(75, 34);
            this.elseButton.TabIndex = 5;
            this.elseButton.Text = "Insert \"otherwise\"";
            this.elseButton.UseVisualStyleBackColor = true;
            this.elseButton.Click += new System.EventHandler(this.elseButton_Click);
            // 
            // button1
            // 
            this.button1.Location = new System.Drawing.Point(3, 204);
            this.button1.Name = "button1";
            this.button1.Size = new System.Drawing.Size(75, 34);
            this.button1.TabIndex = 4;
            this.button1.Text = "Insert group end";
            this.button1.UseVisualStyleBackColor = true;
            this.button1.Click += new System.EventHandler(this.button1_Click);
            // 
            // editButton
            // 
            this.editButton.Location = new System.Drawing.Point(3, 164);
            this.editButton.Name = "editButton";
            this.editButton.Size = new System.Drawing.Size(75, 34);
            this.editButton.TabIndex = 4;
            this.editButton.Text = "?\r\nEdit";
            this.editButton.UseVisualStyleBackColor = true;
            this.editButton.Click += new System.EventHandler(this.editButton_Click);
            // 
            // moveDownButton
            // 
            this.moveDownButton.Location = new System.Drawing.Point(3, 124);
            this.moveDownButton.Name = "moveDownButton";
            this.moveDownButton.Size = new System.Drawing.Size(75, 34);
            this.moveDownButton.TabIndex = 3;
            this.moveDownButton.Text = "↓\r\nMove down\r\n";
            this.moveDownButton.UseVisualStyleBackColor = true;
            this.moveDownButton.Click += new System.EventHandler(this.moveDownButton_Click);
            // 
            // moveUpButton
            // 
            this.moveUpButton.Location = new System.Drawing.Point(3, 84);
            this.moveUpButton.Name = "moveUpButton";
            this.moveUpButton.Size = new System.Drawing.Size(75, 34);
            this.moveUpButton.TabIndex = 2;
            this.moveUpButton.Text = "↑\r\nMove up";
            this.moveUpButton.UseVisualStyleBackColor = true;
            this.moveUpButton.Click += new System.EventHandler(this.moveUpBotton_Click);
            // 
            // deleteButton
            // 
            this.deleteButton.Location = new System.Drawing.Point(3, 44);
            this.deleteButton.Name = "deleteButton";
            this.deleteButton.Size = new System.Drawing.Size(75, 34);
            this.deleteButton.TabIndex = 1;
            this.deleteButton.Text = "X\r\nDelete";
            this.deleteButton.UseVisualStyleBackColor = true;
            this.deleteButton.Click += new System.EventHandler(this.deleteButton_Click);
            // 
            // addButton
            // 
            this.addButton.Location = new System.Drawing.Point(3, 4);
            this.addButton.Name = "addButton";
            this.addButton.Size = new System.Drawing.Size(75, 34);
            this.addButton.TabIndex = 0;
            this.addButton.Text = "←\r\nAdd";
            this.addButton.UseVisualStyleBackColor = true;
            this.addButton.Click += new System.EventHandler(this.addButton_Click);
            // 
            // button2
            // 
            this.button2.Location = new System.Drawing.Point(12, 215);
            this.button2.Name = "button2";
            this.button2.Size = new System.Drawing.Size(91, 23);
            this.button2.TabIndex = 7;
            this.button2.Text = "Generate Code";
            this.button2.UseVisualStyleBackColor = true;
            this.button2.Click += new System.EventHandler(this.button2_Click);
            // 
            // textBox1
            // 
            this.textBox1.Location = new System.Drawing.Point(575, 340);
            this.textBox1.Name = "textBox1";
            this.textBox1.Size = new System.Drawing.Size(271, 20);
            this.textBox1.TabIndex = 8;
            this.textBox1.TextChanged += new System.EventHandler(this.textBox1_TextChanged);
            // 
            // label3
            // 
            this.label3.AutoSize = true;
            this.label3.Location = new System.Drawing.Point(525, 343);
            this.label3.Name = "label3";
            this.label3.Size = new System.Drawing.Size(44, 13);
            this.label3.TabIndex = 9;
            this.label3.Text = "Search:";
            // 
            // searchListBox
            // 
            this.searchListBox.FormattingEnabled = true;
            this.searchListBox.Location = new System.Drawing.Point(528, 7);
            this.searchListBox.Name = "searchListBox";
            this.searchListBox.Size = new System.Drawing.Size(10, 4);
            this.searchListBox.TabIndex = 10;
            this.searchListBox.Visible = false;
            // 
            // checkBox1
            // 
            this.checkBox1.AutoSize = true;
            this.checkBox1.Location = new System.Drawing.Point(3, 252);
            this.checkBox1.Name = "checkBox1";
            this.checkBox1.Size = new System.Drawing.Size(104, 30);
            this.checkBox1.TabIndex = 11;
            this.checkBox1.Text = "Generate SA-1\r\ncompatible code";
            this.checkBox1.UseVisualStyleBackColor = true;
            this.checkBox1.CheckedChanged += new System.EventHandler(this.checkBox1_CheckedChanged);
            // 
            // Form1
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(866, 423);
            this.Controls.Add(this.checkBox1);
            this.Controls.Add(this.searchListBox);
            this.Controls.Add(this.label3);
            this.Controls.Add(this.textBox1);
            this.Controls.Add(this.button2);
            this.Controls.Add(this.buttonPanel);
            this.Controls.Add(this.label2);
            this.Controls.Add(this.tabControl1);
            this.Controls.Add(this.codeListBox);
            this.Controls.Add(this.label1);
            this.Controls.Add(this.eventListBox);
            this.Controls.Add(this.formInsideSize);
            this.MinimumSize = new System.Drawing.Size(874, 450);
            this.Name = "Form1";
            this.ShowIcon = false;
            this.Text = "Blockreator";
            this.ResizeEnd += new System.EventHandler(this.Form1_Resize);
            this.Resize += new System.EventHandler(this.Form1_Resize);
            this.tabControl1.ResumeLayout(false);
            this.tabPage1.ResumeLayout(false);
            this.tabPage2.ResumeLayout(false);
            this.tabPage3.ResumeLayout(false);
            this.tabPage4.ResumeLayout(false);
            this.tabPage5.ResumeLayout(false);
            this.buttonPanel.ResumeLayout(false);
            this.ResumeLayout(false);
            this.PerformLayout();

		}

		#endregion

		private System.Windows.Forms.ListBox eventListBox;
		private System.Windows.Forms.Label label1;
		private System.Windows.Forms.ListBox codeListBox;
		private System.Windows.Forms.TabControl tabControl1;
		private System.Windows.Forms.TabPage tabPage1;
		private System.Windows.Forms.ListBox marioCodesListBox;
		private System.Windows.Forms.TabPage tabPage2;
		private System.Windows.Forms.TabPage tabPage3;
		private System.Windows.Forms.TabPage tabPage4;
		private System.Windows.Forms.TabPage tabPage5;
		private System.Windows.Forms.Label formInsideSize;
		private System.Windows.Forms.ListBox spriteCodesListBox;
		private System.Windows.Forms.ListBox scoreCodesListBox;
		private System.Windows.Forms.ListBox envCodesListBox;
		private System.Windows.Forms.ListBox miscCodesListBox;
		private System.Windows.Forms.Label label2;
		private System.Windows.Forms.Panel buttonPanel;
		private System.Windows.Forms.Button editButton;
		private System.Windows.Forms.Button moveDownButton;
		private System.Windows.Forms.Button moveUpButton;
		private System.Windows.Forms.Button deleteButton;
		private System.Windows.Forms.Button addButton;
		private System.Windows.Forms.Button button1;
		private System.Windows.Forms.Button button2;
		private System.Windows.Forms.TextBox textBox1;
		private System.Windows.Forms.Label label3;
		private System.Windows.Forms.ListBox searchListBox;
		private System.Windows.Forms.Button elseButton;
		private System.Windows.Forms.Button button3;
		private System.Windows.Forms.CheckBox checkBox1;
	}
}

