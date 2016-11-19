using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Text;
using System.Windows.Forms;

namespace BlockMaker
{

	public partial class EditForm : Form
	{
		public CodePiece target;

		bool show16BitBox = false;
		bool showVarBox = false;
		bool showHexBox = false;
		bool showNotBox = false;
		bool showRelativeBox = false;
		bool showSignedBox = false;

		public EditForm(CodePiece target)
		{
			InitializeComponent();

			this.target = target;

			if (target.noRelative)
				relativeBox.Enabled = false;

			if (target.is16Bit && target.enumerations == null)
				show16BitBox = true;
			if (target.enumerations == null)
				showVarBox = true;
			if (target.enumerations == null)
				showHexBox = true;
			if (target.enumerations != CodePiece.trueFalse && target.isStatement == false)
				showNotBox = true;
			if (target.isStatement && target.enumerations == null)
				showRelativeBox = true;
			if (target.enumerations == null)
				showSignedBox = true;


			int height = 0;
			queryString.Text = target.queryStr;
			height += queryString.Bottom + queryString.Margin.Bottom + queryString.Margin.Top + 16;

			TextBox1.Top = TextBox1.Margin.Top + height;
			comboBox1.Top = comboBox1.Margin.Top + height;

			varBox.Checked = !target.usesConstant;

			if (target.inputCount >= 1)
			{
				Label1.Visible = true;
				Label1.Text = target.inputStr1;
				TextBox1.Visible = true;
				Label1.Top = height + Label1.Margin.Top;
				height = Label1.Bottom + Label1.Margin.Bottom;
				//TextBox1.Text = target.ValueToString(target.value).TrimStart('#').TrimStart('$');
				TextBox1.Text = target.value.ToString();
			}

			if (target.inputCount >= 2)
			{
				Label2.Visible = true;
				Label2.Text = target.inputStr2;
				TextBox2.Visible = true;
				Label2.Top = height + Label2.Margin.Top;
			}

			height = TextBox1.Bottom + TextBox1.Margin.Bottom;

			varBox.Top = hexBox.Top = height;

			if (showVarBox)
				varBox.Visible = true;
			if (showHexBox)
				hexBox.Visible = true;
			if (showVarBox || showHexBox)
				height += varBox.Height + varBox.Margin.Top + varBox.Margin.Bottom;

			notBox.Top = relativeBox.Top = height;

			if (showNotBox)
				notBox.Visible = true;
			if (showRelativeBox)
				relativeBox.Visible = true;
			if (showNotBox || showRelativeBox)
				height += notBox.Height + notBox.Margin.Top + notBox.Margin.Bottom;

			is16BitBox.Top = signedBox.Top = height;

			if (show16BitBox)
				is16BitBox.Visible = true;
			if (showSignedBox)
				signedBox.Visible = true;
			if (show16BitBox || showSignedBox)
				height += signedBox.Height + signedBox.Margin.Top + signedBox.Margin.Bottom;


			if (target.enumerations != null)
			{
				comboBox1.Visible = true;
				TextBox1.Visible = false;
				for (int i = 0; i < target.enumerations.Length; i++)
					comboBox1.Items.Add(target.enumerations[i]);
				comboBox1.SelectedIndex = target.value;
				notBox.Checked = target.branchType.ct == ComparisonType.NotEqual;
			}
			else
			{
				comboBox1.Visible = false;
				TextBox1.Visible = true;
			}

			if (TextBox2.Visible)
			{
				TextBox2.Top = height + TextBox2.Margin.Top;
				height = TextBox2.Bottom + TextBox2.Margin.Top + TextBox2.Margin.Bottom;
			}

			if (!showNotBox)
			{
				relativeBox.Left = notBox.Left;
			}

			if (target.isStatement == false && target.enumerations == null)
			{
				GroupBox1.Top = height + GroupBox1.Margin.Top;
				height = GroupBox1.Bottom + GroupBox1.Margin.Top + GroupBox1.Margin.Bottom;
				switch (target.branchType.ct)
				{
					case ComparisonType.Equal:
						equalButton.Checked = true; break;
					case ComparisonType.Greater:
					case ComparisonType.SignGreater:
						greaterButton.Checked = true; break;
					case ComparisonType.Less:
					case ComparisonType.SignLess:
						lessButton.Checked = true; break;
					case ComparisonType.Negative:
						negativeButton.Checked = true; break;
					case ComparisonType.NotEqual:
						notEqualButton.Checked = true; break;
					case ComparisonType.Positive:
						positiveButton.Checked = true; break;
				}
			}
			else
				GroupBox1.Visible = false;


			is16BitBox.Checked = target.is16Bit;
			relativeBox.Checked = target.relative;
			varBox.Checked = !target.usesConstant;
			signedBox.Checked = target.allowNegative;
			hexBox.Checked = target.usingHex;

			height += 10;

			if (!target.usesConstant)
				TextBox1.Text = target.ValueToString(target.value).TrimStart('$');

			Button2.Top = Button1.Top = height + Button1.Margin.Top;

			height = Button1.Bottom + Button1.Margin.Bottom + this.Padding.Bottom;

			UpdateTextBoxLengths();

			this.Height = height + this.Padding.Bottom + 40;
		}

		private void signedBox_HelpRequested(object sender, HelpEventArgs hlpevent)
		{
			helpTip.SetToolTip(signedBox, "This should be checked if the specified RAM address can represent negative values.\nFor example, Mario's X speed can be either positive or negative (this box should be checked for that address).\nConversely, the frame counter, is never negative (this box should be unchecked for that address).\n");  
		}

		private void varBox_HelpRequested(object sender, HelpEventArgs hlpevent)
		{
			helpTip.SetToolTip(varBox, "Tick this box to check against a RAM address instead of a constant value.\nFor example, using this, you could check if Mario's X speed is greater than his Y speed.");
		}

		private void UpdateTargetToCheckBoxes()
		{
			target.relative = relativeBox.Checked;
			target.usingHex = hexBox.Checked;
			target.usesConstant = !varBox.Checked;
			UpdateBranch(null, null);
			UpdateTextBoxLengths();
		}

		private void varBox_CheckedChanged(object sender, EventArgs e)
		{
			hexBox.Checked = true;
			UpdateTargetToCheckBoxes();
			//signedBox.Visible = target.allowNegative;
			//is16BitBox.Enabled = false;
			//is16BitBox.Checked = target.is16Bit;

			//if (target.enumerations != null)
			//{
			//	varBox.Visible = false;
			//	signedBox.Visible = false;
			//}


			//if (is16BitBox.Visible == false) is16BitBox.Checked = false;
			//if (signedBox.Visible == false) signedBox.Checked = false;

			//target.usesConstant = !varBox.Checked;

		}

		private void UpdateBranch(object sender, EventArgs e)
		{
			if (equalButton.Checked)
				target.branchType.ct = ComparisonType.Equal;
			if (notEqualButton.Checked)
				target.branchType.ct = ComparisonType.NotEqual;
			if (lessButton.Checked)
				target.branchType.ct = ComparisonType.Less;
			if (greaterButton.Checked)
				target.branchType.ct = ComparisonType.Greater;
			if (negativeButton.Checked)
				target.branchType.ct = ComparisonType.Negative;
			if (positiveButton.Checked)
				target.branchType.ct = ComparisonType.Positive;

			if (notBox.Checked)
				target.branchType = !target.branchType;

			if (signedBox.Checked && target.allowNegative)
			{
				if (target.branchType.ct == ComparisonType.Greater)
					target.branchType.ct = ComparisonType.SignGreater;
				if (target.branchType.ct == ComparisonType.Less)
					target.branchType.ct = ComparisonType.SignLess;
			}
			else
			{
				if (target.branchType.ct == ComparisonType.SignGreater)
					target.branchType.ct = ComparisonType.Greater;
				if (target.branchType.ct == ComparisonType.SignLess)
					target.branchType.ct = ComparisonType.Less;
			}
		}

		private void EditForm_FormClosing(object sender, FormClosingEventArgs e)
		{
			if (target != null)
			{
				try
				{
					if (TextBox1.Visible == true)
					{
						if (TextBox1.Text == "") throw new System.FormatException();

						if (hexBox.Checked)
							target.value = Convert.ToInt32(TextBox1.Text, 16);
						else
						{
							target.value = Convert.ToInt32(TextBox1.Text);
							//if (target.allowNegative)
							//{
							//        if (target.is16Bit)
							//                target.value = Convert.ToInt16(TextBox1.Text);
							//        else
							//                target.value = Convert.ToSByte(TextBox1.Text);
							//}
							//else
							//{
							//        if (target.is16Bit)
							//                target.value = Convert.ToUInt16(TextBox1.Text);
							//        else
							//                target.value = Convert.ToByte(TextBox1.Text);
							//}
						}

					}
					else
					{
						target.value = comboBox1.SelectedIndex;
					}
				}
				catch
				{
					MessageBox.Show("Error: Invalid value.", "", MessageBoxButtons.OK, MessageBoxIcon.Error);
					e.Cancel = true;
				}
			}

		}

		private void Button2_Click(object sender, EventArgs e)
		{
			DialogResult = System.Windows.Forms.DialogResult.Cancel;
			target = null;
			Close();
		}

		private void Button1_Click(object sender, EventArgs e)
		{
			DialogResult = System.Windows.Forms.DialogResult.OK;
			Close();
		}

		private void hexBox_CheckedChanged(object sender, EventArgs e)
		{
			target.usingHex = hexBox.Checked;
			if (hexBox.Checked)
			{
				try
				{
					if (target.is16Bit)
						TextBox1.Text = Convert.ToInt16(TextBox1.Text).ToString("X4");
					else
						TextBox1.Text = Convert.ToInt16(TextBox1.Text).ToString("X2");
				}
				catch
				{
					TextBox1.Text = "0";
				}
			}
			else
			{
				try
				{
					if (target.is16Bit)
						TextBox1.Text = Convert.ToInt16(TextBox1.Text, 16).ToString();
					else
						TextBox1.Text = Convert.ToSByte(TextBox1.Text, 16).ToString();
				}
				catch
				{
					TextBox1.Text = "0";
				}
			}
			UpdateTextBoxLengths();
		}

		private void UpdateTextBoxLengths()
		{
			if (target.usesConstant == false)
			{
				hexBox.Checked = true;
				hexBox.Enabled = false;
				TextBox1.MaxLength = 6;
				TextBox2.MaxLength = 6;
				TextBox3.MaxLength = 6;
				TextBox4.MaxLength = 6;
				if (TextBox1.Text.Length < 7)
					TextBox1.Text = "7E0000".Remove(6 - TextBox1.Text.Length, TextBox1.Text.Length) + TextBox1.Text;

				if (TextBox2.Text.Length < 7)
					TextBox2.Text = "7E0000".Remove(6 - TextBox2.Text.Length, TextBox2.Text.Length) + TextBox2.Text;

				if (TextBox3.Text.Length < 7)
					TextBox3.Text = "7E0000".Remove(6 - TextBox3.Text.Length, TextBox3.Text.Length) + TextBox3.Text;

				if (TextBox4.Text.Length < 7)
					TextBox4.Text = "7E0000".Remove(6 - TextBox4.Text.Length, TextBox4.Text.Length) + TextBox4.Text;

			}
			else
			{
				hexBox.Enabled = true;
				int d;
				if (target.is16Bit)
					if (hexBox.Checked)
						d = 4;
					else
						d = 6;
				else
					if (hexBox.Checked)
						d = 2;
					else
						d = 4;

				TextBox1.MaxLength = d;
				TextBox2.MaxLength = d;
				TextBox3.MaxLength = d;
				TextBox4.MaxLength = d;
				if (hexBox.Checked)
				{
					TextBox1.Text = TextBox1.Text.PadLeft(d + 2, '0').Substring(2, d);
					TextBox2.Text = TextBox2.Text.PadLeft(d + 2, '0').Substring(2, d);
					TextBox3.Text = TextBox3.Text.PadLeft(d + 2, '0').Substring(2, d);
					TextBox4.Text = TextBox4.Text.PadLeft(d + 2, '0').Substring(2, d);
				}
			}
		}

		private void relativeBox_CheckedChanged(object sender, EventArgs e)
		{
			target.relative = relativeBox.Checked;
		}
	}
}
