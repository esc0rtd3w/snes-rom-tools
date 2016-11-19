namespace BlockMaker
{
	partial class EditForm
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
			this.components = new System.ComponentModel.Container();
			this.queryString = new System.Windows.Forms.Label();
			this.Button2 = new System.Windows.Forms.Button();
			this.Button1 = new System.Windows.Forms.Button();
			this.GroupBox1 = new System.Windows.Forms.GroupBox();
			this.equalButton = new System.Windows.Forms.RadioButton();
			this.positiveButton = new System.Windows.Forms.RadioButton();
			this.notEqualButton = new System.Windows.Forms.RadioButton();
			this.negativeButton = new System.Windows.Forms.RadioButton();
			this.lessButton = new System.Windows.Forms.RadioButton();
			this.greaterButton = new System.Windows.Forms.RadioButton();
			this.varBox = new System.Windows.Forms.CheckBox();
			this.TextBox4 = new System.Windows.Forms.TextBox();
			this.TextBox3 = new System.Windows.Forms.TextBox();
			this.TextBox2 = new System.Windows.Forms.TextBox();
			this.TextBox1 = new System.Windows.Forms.TextBox();
			this.Label4 = new System.Windows.Forms.Label();
			this.Label3 = new System.Windows.Forms.Label();
			this.Label2 = new System.Windows.Forms.Label();
			this.Label1 = new System.Windows.Forms.Label();
			this.signedBox = new System.Windows.Forms.CheckBox();
			this.helpTip = new System.Windows.Forms.ToolTip(this.components);
			this.is16BitBox = new System.Windows.Forms.CheckBox();
			this.notBox = new System.Windows.Forms.CheckBox();
			this.comboBox1 = new System.Windows.Forms.ComboBox();
			this.relativeBox = new System.Windows.Forms.CheckBox();
			this.hexBox = new System.Windows.Forms.CheckBox();
			this.GroupBox1.SuspendLayout();
			this.SuspendLayout();
			// 
			// queryString
			// 
			this.queryString.AutoSize = true;
			this.queryString.Location = new System.Drawing.Point(12, 9);
			this.queryString.Name = "queryString";
			this.queryString.Size = new System.Drawing.Size(63, 13);
			this.queryString.TabIndex = 0;
			this.queryString.Text = "Query string";
			// 
			// Button2
			// 
			this.Button2.DialogResult = System.Windows.Forms.DialogResult.Cancel;
			this.Button2.Location = new System.Drawing.Point(195, 366);
			this.Button2.Name = "Button2";
			this.Button2.Size = new System.Drawing.Size(75, 23);
			this.Button2.TabIndex = 20;
			this.Button2.Text = "Cancel";
			this.Button2.UseVisualStyleBackColor = true;
			this.Button2.Click += new System.EventHandler(this.Button2_Click);
			// 
			// Button1
			// 
			this.Button1.Location = new System.Drawing.Point(15, 366);
			this.Button1.Name = "Button1";
			this.Button1.Size = new System.Drawing.Size(75, 23);
			this.Button1.TabIndex = 21;
			this.Button1.Text = "OK";
			this.Button1.UseVisualStyleBackColor = true;
			this.Button1.Click += new System.EventHandler(this.Button1_Click);
			// 
			// GroupBox1
			// 
			this.GroupBox1.Controls.Add(this.equalButton);
			this.GroupBox1.Controls.Add(this.positiveButton);
			this.GroupBox1.Controls.Add(this.notEqualButton);
			this.GroupBox1.Controls.Add(this.negativeButton);
			this.GroupBox1.Controls.Add(this.lessButton);
			this.GroupBox1.Controls.Add(this.greaterButton);
			this.GroupBox1.Location = new System.Drawing.Point(15, 247);
			this.GroupBox1.Name = "GroupBox1";
			this.GroupBox1.Size = new System.Drawing.Size(255, 113);
			this.GroupBox1.TabIndex = 19;
			this.GroupBox1.TabStop = false;
			this.GroupBox1.Text = "If the value is...";
			// 
			// equalButton
			// 
			this.equalButton.AutoSize = true;
			this.equalButton.Checked = true;
			this.equalButton.Location = new System.Drawing.Point(6, 19);
			this.equalButton.Name = "equalButton";
			this.equalButton.Size = new System.Drawing.Size(64, 17);
			this.equalButton.TabIndex = 4;
			this.equalButton.TabStop = true;
			this.equalButton.Text = "Equal to";
			this.equalButton.UseVisualStyleBackColor = true;
			this.equalButton.CheckedChanged += new System.EventHandler(this.UpdateBranch);
			// 
			// positiveButton
			// 
			this.positiveButton.AutoSize = true;
			this.positiveButton.Location = new System.Drawing.Point(149, 90);
			this.positiveButton.Name = "positiveButton";
			this.positiveButton.Size = new System.Drawing.Size(62, 17);
			this.positiveButton.TabIndex = 7;
			this.positiveButton.Text = "Positive";
			this.positiveButton.UseVisualStyleBackColor = true;
			this.positiveButton.Visible = false;
			this.positiveButton.CheckedChanged += new System.EventHandler(this.UpdateBranch);
			// 
			// notEqualButton
			// 
			this.notEqualButton.AutoSize = true;
			this.notEqualButton.Location = new System.Drawing.Point(6, 42);
			this.notEqualButton.Name = "notEqualButton";
			this.notEqualButton.Size = new System.Drawing.Size(83, 17);
			this.notEqualButton.TabIndex = 5;
			this.notEqualButton.Text = "Not equal to";
			this.notEqualButton.UseVisualStyleBackColor = true;
			this.notEqualButton.CheckedChanged += new System.EventHandler(this.UpdateBranch);
			// 
			// negativeButton
			// 
			this.negativeButton.AutoSize = true;
			this.negativeButton.Location = new System.Drawing.Point(149, 67);
			this.negativeButton.Name = "negativeButton";
			this.negativeButton.Size = new System.Drawing.Size(68, 17);
			this.negativeButton.TabIndex = 6;
			this.negativeButton.Text = "Negative";
			this.negativeButton.UseVisualStyleBackColor = true;
			this.negativeButton.Visible = false;
			this.negativeButton.CheckedChanged += new System.EventHandler(this.UpdateBranch);
			// 
			// lessButton
			// 
			this.lessButton.AutoSize = true;
			this.lessButton.Location = new System.Drawing.Point(6, 65);
			this.lessButton.Name = "lessButton";
			this.lessButton.Size = new System.Drawing.Size(71, 17);
			this.lessButton.TabIndex = 5;
			this.lessButton.Text = "Less than";
			this.lessButton.UseVisualStyleBackColor = true;
			this.lessButton.CheckedChanged += new System.EventHandler(this.UpdateBranch);
			// 
			// greaterButton
			// 
			this.greaterButton.AutoSize = true;
			this.greaterButton.Location = new System.Drawing.Point(6, 88);
			this.greaterButton.Name = "greaterButton";
			this.greaterButton.Size = new System.Drawing.Size(137, 17);
			this.greaterButton.TabIndex = 5;
			this.greaterButton.Text = "Greater than or equal to";
			this.greaterButton.UseVisualStyleBackColor = true;
			this.greaterButton.CheckedChanged += new System.EventHandler(this.UpdateBranch);
			// 
			// varBox
			// 
			this.varBox.AutoSize = true;
			this.varBox.Location = new System.Drawing.Point(15, 175);
			this.varBox.Name = "varBox";
			this.varBox.Size = new System.Drawing.Size(97, 17);
			this.varBox.TabIndex = 8;
			this.varBox.Text = "Check variable";
			this.helpTip.SetToolTip(this.varBox, "If this is checked, then a RAM address will be used instead of a constant.");
			this.varBox.UseVisualStyleBackColor = true;
			this.varBox.Visible = false;
			this.varBox.CheckedChanged += new System.EventHandler(this.varBox_CheckedChanged);
			this.varBox.HelpRequested += new System.Windows.Forms.HelpEventHandler(this.varBox_HelpRequested);
			// 
			// TextBox4
			// 
			this.TextBox4.Location = new System.Drawing.Point(111, 139);
			this.TextBox4.MaxLength = 4;
			this.TextBox4.Name = "TextBox4";
			this.TextBox4.Size = new System.Drawing.Size(100, 20);
			this.TextBox4.TabIndex = 16;
			this.TextBox4.Visible = false;
			// 
			// TextBox3
			// 
			this.TextBox3.Location = new System.Drawing.Point(111, 113);
			this.TextBox3.MaxLength = 4;
			this.TextBox3.Name = "TextBox3";
			this.TextBox3.Size = new System.Drawing.Size(100, 20);
			this.TextBox3.TabIndex = 17;
			this.TextBox3.Visible = false;
			// 
			// TextBox2
			// 
			this.TextBox2.Location = new System.Drawing.Point(111, 87);
			this.TextBox2.MaxLength = 4;
			this.TextBox2.Name = "TextBox2";
			this.TextBox2.Size = new System.Drawing.Size(100, 20);
			this.TextBox2.TabIndex = 14;
			this.TextBox2.Visible = false;
			// 
			// TextBox1
			// 
			this.TextBox1.Location = new System.Drawing.Point(111, 61);
			this.TextBox1.MaxLength = 4;
			this.TextBox1.Name = "TextBox1";
			this.TextBox1.Size = new System.Drawing.Size(100, 20);
			this.TextBox1.TabIndex = 15;
			this.TextBox1.Visible = false;
			// 
			// Label4
			// 
			this.Label4.AutoSize = true;
			this.Label4.Location = new System.Drawing.Point(12, 142);
			this.Label4.Name = "Label4";
			this.Label4.Size = new System.Drawing.Size(39, 13);
			this.Label4.TabIndex = 11;
			this.Label4.Text = "Label1";
			this.Label4.Visible = false;
			// 
			// Label3
			// 
			this.Label3.AutoSize = true;
			this.Label3.Location = new System.Drawing.Point(12, 116);
			this.Label3.Name = "Label3";
			this.Label3.Size = new System.Drawing.Size(39, 13);
			this.Label3.TabIndex = 10;
			this.Label3.Text = "Label1";
			this.Label3.Visible = false;
			// 
			// Label2
			// 
			this.Label2.AutoSize = true;
			this.Label2.Location = new System.Drawing.Point(12, 90);
			this.Label2.Name = "Label2";
			this.Label2.Size = new System.Drawing.Size(39, 13);
			this.Label2.TabIndex = 13;
			this.Label2.Text = "Label1";
			this.Label2.Visible = false;
			// 
			// Label1
			// 
			this.Label1.AutoSize = true;
			this.Label1.Location = new System.Drawing.Point(12, 64);
			this.Label1.Name = "Label1";
			this.Label1.Size = new System.Drawing.Size(39, 13);
			this.Label1.TabIndex = 12;
			this.Label1.Text = "Label1";
			this.Label1.Visible = false;
			// 
			// signedBox
			// 
			this.signedBox.AutoSize = true;
			this.signedBox.Enabled = false;
			this.signedBox.Location = new System.Drawing.Point(164, 222);
			this.signedBox.Name = "signedBox";
			this.signedBox.Size = new System.Drawing.Size(68, 17);
			this.signedBox.TabIndex = 8;
			this.signedBox.Text = "Is signed";
			this.helpTip.SetToolTip(this.signedBox, "If this is checked, then negative numbers are allowed.");
			this.signedBox.UseVisualStyleBackColor = true;
			this.signedBox.Visible = false;
			this.signedBox.CheckedChanged += new System.EventHandler(this.UpdateBranch);
			this.signedBox.HelpRequested += new System.Windows.Forms.HelpEventHandler(this.signedBox_HelpRequested);
			// 
			// helpTip
			// 
			this.helpTip.AutomaticDelay = 0;
			this.helpTip.IsBalloon = true;
			// 
			// is16BitBox
			// 
			this.is16BitBox.AutoSize = true;
			this.is16BitBox.Enabled = false;
			this.is16BitBox.Location = new System.Drawing.Point(15, 222);
			this.is16BitBox.Name = "is16BitBox";
			this.is16BitBox.Size = new System.Drawing.Size(63, 17);
			this.is16BitBox.TabIndex = 22;
			this.is16BitBox.Text = "Is 16-bit";
			this.helpTip.SetToolTip(this.is16BitBox, "If this is unchecked, values can be from -128 - 127 OR 0 - 255 (depending on whet" +
        "her \"Is signed\" is checked).  Otherwise, values can be from -32,768 - 32,767 or " +
        "from 0 - 65,535.");
			this.is16BitBox.UseVisualStyleBackColor = true;
			this.is16BitBox.Visible = false;
			// 
			// notBox
			// 
			this.notBox.AutoSize = true;
			this.notBox.Location = new System.Drawing.Point(15, 199);
			this.notBox.Name = "notBox";
			this.notBox.Size = new System.Drawing.Size(43, 17);
			this.notBox.TabIndex = 23;
			this.notBox.Text = "Not";
			this.notBox.UseVisualStyleBackColor = true;
			this.notBox.Visible = false;
			this.notBox.CheckedChanged += new System.EventHandler(this.UpdateBranch);
			// 
			// comboBox1
			// 
			this.comboBox1.DropDownHeight = 400;
			this.comboBox1.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList;
			this.comboBox1.FormattingEnabled = true;
			this.comboBox1.IntegralHeight = false;
			this.comboBox1.Location = new System.Drawing.Point(111, 60);
			this.comboBox1.Name = "comboBox1";
			this.comboBox1.Size = new System.Drawing.Size(169, 21);
			this.comboBox1.TabIndex = 24;
			// 
			// relativeBox
			// 
			this.relativeBox.AutoSize = true;
			this.relativeBox.Location = new System.Drawing.Point(164, 199);
			this.relativeBox.Name = "relativeBox";
			this.relativeBox.Size = new System.Drawing.Size(65, 17);
			this.relativeBox.TabIndex = 26;
			this.relativeBox.Text = "Relative";
			this.helpTip.SetToolTip(this.relativeBox, "If this is checked, then the value will be added instead.");
			this.relativeBox.UseVisualStyleBackColor = true;
			this.relativeBox.Visible = false;
			this.relativeBox.CheckedChanged += new System.EventHandler(this.relativeBox_CheckedChanged);
			// 
			// hexBox
			// 
			this.hexBox.AutoSize = true;
			this.hexBox.Location = new System.Drawing.Point(164, 176);
			this.hexBox.Name = "hexBox";
			this.hexBox.Size = new System.Drawing.Size(91, 17);
			this.hexBox.TabIndex = 27;
			this.hexBox.Text = "Use hex input";
			this.helpTip.SetToolTip(this.hexBox, "If this is checked, input will be in hexadecimal.");
			this.hexBox.UseVisualStyleBackColor = true;
			this.hexBox.Visible = false;
			this.hexBox.CheckedChanged += new System.EventHandler(this.hexBox_CheckedChanged);
			// 
			// EditForm
			// 
			this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
			this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
			this.ClientSize = new System.Drawing.Size(292, 421);
			this.Controls.Add(this.hexBox);
			this.Controls.Add(this.relativeBox);
			this.Controls.Add(this.comboBox1);
			this.Controls.Add(this.notBox);
			this.Controls.Add(this.is16BitBox);
			this.Controls.Add(this.signedBox);
			this.Controls.Add(this.Button2);
			this.Controls.Add(this.varBox);
			this.Controls.Add(this.Button1);
			this.Controls.Add(this.GroupBox1);
			this.Controls.Add(this.TextBox4);
			this.Controls.Add(this.TextBox3);
			this.Controls.Add(this.TextBox2);
			this.Controls.Add(this.TextBox1);
			this.Controls.Add(this.Label4);
			this.Controls.Add(this.Label3);
			this.Controls.Add(this.Label2);
			this.Controls.Add(this.Label1);
			this.Controls.Add(this.queryString);
			this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.FixedSingle;
			this.MaximizeBox = false;
			this.MinimizeBox = false;
			this.Name = "EditForm";
			this.ShowIcon = false;
			this.ShowInTaskbar = false;
			this.Text = "Edit properties";
			this.FormClosing += new System.Windows.Forms.FormClosingEventHandler(this.EditForm_FormClosing);
			this.GroupBox1.ResumeLayout(false);
			this.GroupBox1.PerformLayout();
			this.ResumeLayout(false);
			this.PerformLayout();

		}

		#endregion

		private System.Windows.Forms.Label queryString;
		internal System.Windows.Forms.Button Button2;
		internal System.Windows.Forms.Button Button1;
		internal System.Windows.Forms.GroupBox GroupBox1;
		internal System.Windows.Forms.CheckBox signedBox;
		internal System.Windows.Forms.CheckBox varBox;
		internal System.Windows.Forms.RadioButton equalButton;
		internal System.Windows.Forms.RadioButton positiveButton;
		internal System.Windows.Forms.RadioButton notEqualButton;
		internal System.Windows.Forms.RadioButton negativeButton;
		internal System.Windows.Forms.RadioButton lessButton;
		internal System.Windows.Forms.RadioButton greaterButton;
		internal System.Windows.Forms.TextBox TextBox4;
		internal System.Windows.Forms.TextBox TextBox3;
		internal System.Windows.Forms.TextBox TextBox2;
		internal System.Windows.Forms.TextBox TextBox1;
		internal System.Windows.Forms.Label Label4;
		internal System.Windows.Forms.Label Label3;
		internal System.Windows.Forms.Label Label2;
		internal System.Windows.Forms.Label Label1;
		private System.Windows.Forms.ToolTip helpTip;
		private System.Windows.Forms.CheckBox is16BitBox;
		private System.Windows.Forms.CheckBox notBox;
		private System.Windows.Forms.ComboBox comboBox1;
		private System.Windows.Forms.CheckBox relativeBox;
		private System.Windows.Forms.CheckBox hexBox;
	}
}