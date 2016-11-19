using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Text;
using System.Windows.Forms;

namespace BlockMaker
{
	public partial class CodeForm : Form
	{
		public CodeForm(string code)
		{
			InitializeComponent();
			textBox1.Text = code;
		}

		private void saveToolStripMenuItem_Click(object sender, EventArgs e)
		{
			if (saveFileDialog1.ShowDialog() == System.Windows.Forms.DialogResult.Cancel) return;

			System.IO.File.WriteAllText(saveFileDialog1.FileName, textBox1.Text.Insert(0, "\n\n\n"));
			Close();
		}
	}
}
