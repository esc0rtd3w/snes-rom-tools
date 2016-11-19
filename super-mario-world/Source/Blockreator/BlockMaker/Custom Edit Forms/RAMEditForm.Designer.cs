namespace BlockMaker
{
	partial class RAMEditForm
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
			this.Button2 = new System.Windows.Forms.Button();
			this.Button1 = new System.Windows.Forms.Button();
			this.helpTip = new System.Windows.Forms.ToolTip(this.components);
			this.label1 = new System.Windows.Forms.Label();
			this.label2 = new System.Windows.Forms.Label();
			this.textBox1 = new System.Windows.Forms.TextBox();
			this.xIndexedBox = new System.Windows.Forms.CheckBox();
			this.textBox2 = new System.Windows.Forms.TextBox();
			this.label3 = new System.Windows.Forms.Label();
			this.setBox = new System.Windows.Forms.RadioButton();
			this.addBox = new System.Windows.Forms.RadioButton();
			this.subtractBox = new System.Windows.Forms.RadioButton();
			this.is16BitBox = new System.Windows.Forms.CheckBox();
			this.SuspendLayout();
			// 
			// Button2
			// 
			this.Button2.DialogResult = System.Windows.Forms.DialogResult.Cancel;
			this.Button2.Location = new System.Drawing.Point(196, 206);
			this.Button2.Name = "Button2";
			this.Button2.Size = new System.Drawing.Size(75, 23);
			this.Button2.TabIndex = 20;
			this.Button2.Text = "Cancel";
			this.Button2.UseVisualStyleBackColor = true;
			this.Button2.Click += new System.EventHandler(this.Button2_Click);
			// 
			// Button1
			// 
			this.Button1.Location = new System.Drawing.Point(16, 206);
			this.Button1.Name = "Button1";
			this.Button1.Size = new System.Drawing.Size(75, 23);
			this.Button1.TabIndex = 21;
			this.Button1.Text = "OK";
			this.Button1.UseVisualStyleBackColor = true;
			this.Button1.Click += new System.EventHandler(this.Button1_Click);
			// 
			// helpTip
			// 
			this.helpTip.AutomaticDelay = 0;
			this.helpTip.IsBalloon = true;
			// 
			// label1
			// 
			this.label1.AutoSize = true;
			this.label1.Location = new System.Drawing.Point(13, 13);
			this.label1.Name = "label1";
			this.label1.Size = new System.Drawing.Size(110, 13);
			this.label1.TabIndex = 22;
			this.label1.Text = "Edit a RAM address...";
			// 
			// label2
			// 
			this.label2.AutoSize = true;
			this.label2.Location = new System.Drawing.Point(16, 45);
			this.label2.Name = "label2";
			this.label2.Size = new System.Drawing.Size(63, 13);
			this.label2.TabIndex = 23;
			this.label2.Text = "Value (hex):";
			// 
			// textBox1
			// 
			this.textBox1.Location = new System.Drawing.Point(89, 42);
			this.textBox1.MaxLength = 6;
			this.textBox1.Name = "textBox1";
			this.textBox1.Size = new System.Drawing.Size(100, 20);
			this.textBox1.TabIndex = 24;
			// 
			// xIndexedBox
			// 
			this.xIndexedBox.AutoSize = true;
			this.xIndexedBox.Location = new System.Drawing.Point(19, 104);
			this.xIndexedBox.Name = "xIndexedBox";
			this.xIndexedBox.Size = new System.Drawing.Size(73, 17);
			this.xIndexedBox.TabIndex = 25;
			this.xIndexedBox.Text = "X indexed";
			this.xIndexedBox.UseVisualStyleBackColor = true;
			this.xIndexedBox.CheckedChanged += new System.EventHandler(this.xIndexedBox_CheckedChanged);
			// 
			// textBox2
			// 
			this.textBox2.Location = new System.Drawing.Point(89, 68);
			this.textBox2.MaxLength = 6;
			this.textBox2.Name = "textBox2";
			this.textBox2.Size = new System.Drawing.Size(100, 20);
			this.textBox2.TabIndex = 24;
			// 
			// label3
			// 
			this.label3.AutoSize = true;
			this.label3.Location = new System.Drawing.Point(16, 71);
			this.label3.Name = "label3";
			this.label3.Size = new System.Drawing.Size(48, 13);
			this.label3.TabIndex = 23;
			this.label3.Text = "Address:";
			// 
			// setBox
			// 
			this.setBox.AutoSize = true;
			this.setBox.Checked = true;
			this.setBox.Location = new System.Drawing.Point(19, 128);
			this.setBox.Name = "setBox";
			this.setBox.Size = new System.Drawing.Size(41, 17);
			this.setBox.TabIndex = 26;
			this.setBox.TabStop = true;
			this.setBox.Text = "Set";
			this.setBox.UseVisualStyleBackColor = true;
			this.setBox.CheckedChanged += new System.EventHandler(this.setBox_CheckedChanged);
			// 
			// addBox
			// 
			this.addBox.AutoSize = true;
			this.addBox.Location = new System.Drawing.Point(19, 151);
			this.addBox.Name = "addBox";
			this.addBox.Size = new System.Drawing.Size(44, 17);
			this.addBox.TabIndex = 26;
			this.addBox.TabStop = true;
			this.addBox.Text = "Add";
			this.addBox.UseVisualStyleBackColor = true;
			this.addBox.CheckedChanged += new System.EventHandler(this.addBox_CheckedChanged);
			// 
			// subtractBox
			// 
			this.subtractBox.AutoSize = true;
			this.subtractBox.Location = new System.Drawing.Point(19, 174);
			this.subtractBox.Name = "subtractBox";
			this.subtractBox.Size = new System.Drawing.Size(65, 17);
			this.subtractBox.TabIndex = 26;
			this.subtractBox.TabStop = true;
			this.subtractBox.Text = "Subtract";
			this.subtractBox.UseVisualStyleBackColor = true;
			this.subtractBox.CheckedChanged += new System.EventHandler(this.subtractBox_CheckedChanged);
			// 
			// is16BitBox
			// 
			this.is16BitBox.AutoSize = true;
			this.is16BitBox.Location = new System.Drawing.Point(160, 104);
			this.is16BitBox.Name = "is16BitBox";
			this.is16BitBox.Size = new System.Drawing.Size(63, 17);
			this.is16BitBox.TabIndex = 27;
			this.is16BitBox.Text = "Is 16-bit";
			this.is16BitBox.UseVisualStyleBackColor = true;
			this.is16BitBox.CheckedChanged += new System.EventHandler(this.is16BitBox_CheckedChanged);
			// 
			// RAMEditForm
			// 
			this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
			this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
			this.ClientSize = new System.Drawing.Size(292, 241);
			this.Controls.Add(this.is16BitBox);
			this.Controls.Add(this.subtractBox);
			this.Controls.Add(this.addBox);
			this.Controls.Add(this.setBox);
			this.Controls.Add(this.xIndexedBox);
			this.Controls.Add(this.textBox2);
			this.Controls.Add(this.textBox1);
			this.Controls.Add(this.label3);
			this.Controls.Add(this.label2);
			this.Controls.Add(this.label1);
			this.Controls.Add(this.Button2);
			this.Controls.Add(this.Button1);
			this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.FixedSingle;
			this.MaximizeBox = false;
			this.MinimizeBox = false;
			this.Name = "RAMEditForm";
			this.ShowIcon = false;
			this.ShowInTaskbar = false;
			this.Text = "Edit properties";
			this.FormClosing += new System.Windows.Forms.FormClosingEventHandler(this.RAMEditForm_FormClosing);
			this.Load += new System.EventHandler(this.RAMEditForm_Load);
			this.ResumeLayout(false);
			this.PerformLayout();

		}

		#endregion

		internal System.Windows.Forms.Button Button2;
		internal System.Windows.Forms.Button Button1;
		private System.Windows.Forms.ToolTip helpTip;
		private System.Windows.Forms.Label label1;
		private System.Windows.Forms.Label label2;
		private System.Windows.Forms.TextBox textBox1;
		private System.Windows.Forms.CheckBox xIndexedBox;
		private System.Windows.Forms.TextBox textBox2;
		private System.Windows.Forms.Label label3;
		private System.Windows.Forms.RadioButton setBox;
		private System.Windows.Forms.RadioButton addBox;
		private System.Windows.Forms.RadioButton subtractBox;
		private System.Windows.Forms.CheckBox is16BitBox;
	}
}