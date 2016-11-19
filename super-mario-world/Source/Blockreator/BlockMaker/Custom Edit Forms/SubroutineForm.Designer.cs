namespace BlockMaker
{
	partial class SubroutineForm
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
			this.subLongBox = new System.Windows.Forms.CheckBox();
			this.subLongToJSRBox = new System.Windows.Forms.CheckBox();
			this.fastROMBox = new System.Windows.Forms.CheckBox();
			this.SuspendLayout();
			// 
			// Button2
			// 
			this.Button2.DialogResult = System.Windows.Forms.DialogResult.Cancel;
			this.Button2.Location = new System.Drawing.Point(196, 131);
			this.Button2.Name = "Button2";
			this.Button2.Size = new System.Drawing.Size(75, 23);
			this.Button2.TabIndex = 20;
			this.Button2.Text = "Cancel";
			this.Button2.UseVisualStyleBackColor = true;
			this.Button2.Click += new System.EventHandler(this.Button2_Click);
			// 
			// Button1
			// 
			this.Button1.Location = new System.Drawing.Point(16, 131);
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
			this.label1.Size = new System.Drawing.Size(114, 13);
			this.label1.TabIndex = 22;
			this.label1.Text = "Jump to a subroutine...";
			// 
			// label2
			// 
			this.label2.AutoSize = true;
			this.label2.Location = new System.Drawing.Point(16, 45);
			this.label2.Name = "label2";
			this.label2.Size = new System.Drawing.Size(48, 13);
			this.label2.TabIndex = 23;
			this.label2.Text = "Address:";
			// 
			// textBox1
			// 
			this.textBox1.Location = new System.Drawing.Point(89, 42);
			this.textBox1.MaxLength = 6;
			this.textBox1.Name = "textBox1";
			this.textBox1.Size = new System.Drawing.Size(100, 20);
			this.textBox1.TabIndex = 24;
			// 
			// subLongBox
			// 
			this.subLongBox.AutoSize = true;
			this.subLongBox.Location = new System.Drawing.Point(16, 76);
			this.subLongBox.Name = "subLongBox";
			this.subLongBox.Size = new System.Drawing.Size(66, 17);
			this.subLongBox.TabIndex = 25;
			this.subLongBox.Text = "Use JSL";
			this.subLongBox.UseVisualStyleBackColor = true;
			this.subLongBox.CheckedChanged += new System.EventHandler(this.subLongBox_CheckedChanged);
			// 
			// subLongToJSRBox
			// 
			this.subLongToJSRBox.AutoSize = true;
			this.subLongToJSRBox.Enabled = false;
			this.subLongToJSRBox.Location = new System.Drawing.Point(16, 100);
			this.subLongToJSRBox.Name = "subLongToJSRBox";
			this.subLongToJSRBox.Size = new System.Drawing.Size(88, 17);
			this.subLongToJSRBox.TabIndex = 26;
			this.subLongToJSRBox.Text = "JSL to a JSR";
			this.subLongToJSRBox.UseVisualStyleBackColor = true;
			this.subLongToJSRBox.CheckedChanged += new System.EventHandler(this.subLongToJSRBox_CheckedChanged);
			// 
			// fastROMBox
			// 
			this.fastROMBox.AutoSize = true;
			this.fastROMBox.Location = new System.Drawing.Point(141, 76);
			this.fastROMBox.Name = "fastROMBox";
			this.fastROMBox.Size = new System.Drawing.Size(101, 17);
			this.fastROMBox.TabIndex = 27;
			this.fastROMBox.Text = "Using FastROM";
			this.fastROMBox.UseVisualStyleBackColor = true;
			this.fastROMBox.CheckedChanged += new System.EventHandler(this.fastROMBox_CheckedChanged);
			// 
			// SubroutineForm
			// 
			this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
			this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
			this.ClientSize = new System.Drawing.Size(292, 166);
			this.Controls.Add(this.fastROMBox);
			this.Controls.Add(this.subLongToJSRBox);
			this.Controls.Add(this.subLongBox);
			this.Controls.Add(this.textBox1);
			this.Controls.Add(this.label2);
			this.Controls.Add(this.label1);
			this.Controls.Add(this.Button2);
			this.Controls.Add(this.Button1);
			this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.FixedSingle;
			this.MaximizeBox = false;
			this.MinimizeBox = false;
			this.Name = "SubroutineForm";
			this.ShowIcon = false;
			this.ShowInTaskbar = false;
			this.Text = "Edit properties";
			this.FormClosing += new System.Windows.Forms.FormClosingEventHandler(this.SubroutineForm_FormClosing);
			this.Load += new System.EventHandler(this.SubroutineForm_Load);
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
		private System.Windows.Forms.CheckBox subLongBox;
		private System.Windows.Forms.CheckBox subLongToJSRBox;
		private System.Windows.Forms.CheckBox fastROMBox;
	}
}