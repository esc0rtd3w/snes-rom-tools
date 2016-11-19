using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Text;
using System.Windows.Forms;

namespace BlockMaker
{

	public partial class Map16ChangeForm : Form
	{
		public ChangeMap16 target;

		public Map16ChangeForm()
		{
			InitializeComponent();
		}

		private void Map16ChangeForm_Load(object sender, EventArgs e)
		{
			target = (ChangeMap16)Tag;

			numericUpDown1.Value = target.xPos;
			numericUpDown2.Value = target.yPos;
		}


		private void Button1_Click(object sender, EventArgs e)
		{
			DialogResult = System.Windows.Forms.DialogResult.OK;
		}

		private void Button2_Click(object sender, EventArgs e)
		{
			DialogResult = System.Windows.Forms.DialogResult.Cancel;
		}

		private void RAMEditForm_FormClosing(object sender, FormClosingEventArgs e)
		{
			if (DialogResult == System.Windows.Forms.DialogResult.OK)
			{

				uint val;
				try
				{
					val = Convert.ToUInt32(textBox1.Text, 16);
				}
				catch
				{
					MessageBox.Show("Error: Invalid value.");
					e.Cancel = true;
					return;
				}

				target.value = (int)val;
			}
		}

		private void numericUpDown1_ValueChanged(object sender, EventArgs e)
		{
			target.xPos = (short)numericUpDown1.Value;
		}

		private void numericUpDown2_ValueChanged(object sender, EventArgs e)
		{
			target.yPos = (short)numericUpDown2.Value;
		}



	}
}
