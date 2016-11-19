using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Text;
using System.Windows.Forms;

namespace BlockMaker
{

	public partial class DisplayMessageForm : Form
	{
		public DisplayMessage target;

		public DisplayMessageForm()
		{
			InitializeComponent();
			comboBox2.Items.Add("The current level.");
			for (int i = 0; i <= 0x13B; i++)
			{
				comboBox2.Items.Add("Level " + i.ToString("X3"));
				if (i == 0x24)
					i = 0x100;
			}
		}

		private void RAMEditForm_Load(object sender, EventArgs e)
		{
			target = (DisplayMessage)Tag;

			comboBox1.SelectedIndex = target.value;
			comboBox2.SelectedIndex = target.value2;
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

			}
		}

		private void comboBox1_SelectedIndexChanged(object sender, EventArgs e)
		{
			target.value = comboBox1.SelectedIndex;
		}

		private void comboBox2_SelectedIndexChanged(object sender, EventArgs e)
		{
			target.value2 = comboBox2.SelectedIndex;
		}



	}
}
