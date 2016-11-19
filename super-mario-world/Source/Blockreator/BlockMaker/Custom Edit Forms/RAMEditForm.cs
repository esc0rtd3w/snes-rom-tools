using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Text;
using System.Windows.Forms;

namespace BlockMaker
{

	public partial class RAMEditForm : Form
	{
		public RAMEdit target;

		public RAMEditForm()
		{
			InitializeComponent();
		}

		private void RAMEditForm_Load(object sender, EventArgs e)
		{
			target = (RAMEdit)Tag;

			if (target.is16Bit)
			{
				is16BitBox.Checked = true;
				textBox1.MaxLength = 4;
				textBox1.Text = target.value.ToString("X4");
			}
			else
			{
				is16BitBox.Checked = false;
				textBox1.MaxLength = 2;
				textBox1.Text = target.value.ToString("X2");
			}

			if (target.xIndexed)
				xIndexedBox.Checked = true;

			textBox2.Text = target.address.ToString("X6");
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
				uint addr;
				try
				{
					addr = Convert.ToUInt32(textBox2.Text, 16);
				}
				catch
				{
					MessageBox.Show("Error: Invalid address.");
					e.Cancel = true;
					return;
				}

				if (addr > 0xFFFFFF)
				{
					MessageBox.Show("Error: Invalid address.");
					e.Cancel = true;
					return;
				}

				target.address = (int)addr;



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

		private void subtractBox_CheckedChanged(object sender, EventArgs e)
		{
			target.sub = subtractBox.Checked;
			target.add = addBox.Checked;
			target.set = setBox.Checked;
		}

		private void is16BitBox_CheckedChanged(object sender, EventArgs e)
		{
			target.is16Bit = is16BitBox.Checked;
			textBox1.MaxLength = (is16BitBox.Checked ? 2 : 0) + 2;
		}

		private void setBox_CheckedChanged(object sender, EventArgs e)
		{
			target.sub = subtractBox.Checked;
			target.add = addBox.Checked;
			target.set = setBox.Checked;
		}

		private void addBox_CheckedChanged(object sender, EventArgs e)
		{
			target.sub = subtractBox.Checked;
			target.add = addBox.Checked;
			target.set = setBox.Checked;
		}

		private void xIndexedBox_CheckedChanged(object sender, EventArgs e)
		{
			target.xIndexed = xIndexedBox.Checked;
		}



	}
}
