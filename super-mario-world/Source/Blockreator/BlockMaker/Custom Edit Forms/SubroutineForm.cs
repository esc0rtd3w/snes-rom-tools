using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Text;
using System.Windows.Forms;

namespace BlockMaker
{

	public partial class SubroutineForm : Form
	{
		public GoToSubroutine target;

		public SubroutineForm()
		{
			InitializeComponent();
		}

		private void SubroutineForm_Load(object sender, EventArgs e)
		{
			target = (GoToSubroutine)Tag;
			if (target.subLong)
				subLongBox.Checked = true;
			if (target.subLongToJSR)
				subLongToJSRBox.Checked = true;
			if (target.fastROM)
				fastROMBox.Checked = true;

			textBox1.Text = target.value.ToString("X6");
		}

		private void subLongBox_CheckedChanged(object sender, EventArgs e)
		{
			target.subLong = subLongBox.Checked;
			subLongToJSRBox.Enabled = subLongBox.Checked;
		}

		private void fastROMBox_CheckedChanged(object sender, EventArgs e)
		{
			target.fastROM = fastROMBox.Checked;
		}

		private void subLongToJSRBox_CheckedChanged(object sender, EventArgs e)
		{
			target.subLongToJSR = subLongToJSRBox.Checked;
		}

		private void Button1_Click(object sender, EventArgs e)
		{
			DialogResult = System.Windows.Forms.DialogResult.OK;
		}

		private void Button2_Click(object sender, EventArgs e)
		{
			DialogResult = System.Windows.Forms.DialogResult.Cancel;
		}

		private void SubroutineForm_FormClosing(object sender, FormClosingEventArgs e)
		{
			if (DialogResult == System.Windows.Forms.DialogResult.OK)
			{
				uint i;
				try
				{
					i = Convert.ToUInt32(textBox1.Text, 16);
				}
				catch
				{
					MessageBox.Show("Error: Invalid value.");
					e.Cancel = true;
					return;
				}

				if (i > 0xFFFFFF)
				{
					MessageBox.Show("Error: Invalid value.");
					e.Cancel = true;
					return;
				}
				uint bank = (i >> 0x10);
				if (bank == 8 || bank == 6 || bank == 9 || bank == 0xA || bank == 0xB || bank == 0xD || bank == 0xE || bank == 0xF)
				{
					if (target.subLongToJSR)
					{
						MessageBox.Show("Error: Bank " + bank.ToString("X2") + " has no instance of \"PLB : RTL");
						e.Cancel = true;
						return;
					}
				}

				if (bank > 0xF && target.subLongToJSR)
				{
					MessageBox.Show("Error: Cannot properly generate a JSL to an RTS beyond bank 0xF.");
					e.Cancel = true;
					return;
				}

				target.value = (int)i;
			}
		}



	}
}
