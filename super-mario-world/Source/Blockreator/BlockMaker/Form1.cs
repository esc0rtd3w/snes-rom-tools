using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Text;
using System.Windows.Forms;

namespace BlockMaker
{
	public partial class Form1 : Form
	{

		DynamicArray<CodePiece> marioBottomActions = new DynamicArray<CodePiece>();
		DynamicArray<CodePiece> marioTopActions = new DynamicArray<CodePiece>();
		DynamicArray<CodePiece> marioSideActions = new DynamicArray<CodePiece>();
		DynamicArray<CodePiece> spriteHorizontalActions = new DynamicArray<CodePiece>();
		DynamicArray<CodePiece> spriteVerticalActions = new DynamicArray<CodePiece>();
		DynamicArray<CodePiece> capeActions = new DynamicArray<CodePiece>();
		DynamicArray<CodePiece> fireballActions = new DynamicArray<CodePiece>();
		DynamicArray<CodePiece> marioCornerActions = new DynamicArray<CodePiece>();
		DynamicArray<CodePiece> marioHeadActions = new DynamicArray<CodePiece>();
		DynamicArray<CodePiece> marioBodyActions = new DynamicArray<CodePiece>();

		DynamicArray<CodePiece>[] allActions = new DynamicArray<CodePiece>[10];

		void refreshCodeBox(int action)
		{
			int oldIndex = codeListBox.SelectedIndex;
			codeListBox.Items.Clear();
			int level = 0;

			for (int i = 0; i < allActions[action].Count; i++)
			{
				if (allActions[action][i].GetType().Name == "EndBlock" || allActions[action][i].GetType().Name == "ElseCode" || allActions[action][i].GetType().Name == "OrCode")
					level -= 1;

				
				allActions[action][i].level = level;
				codeListBox.Items.Add(allActions[action][i]);

				if (!allActions[action][i].isStatement && allActions[action][i].GetType().Name != "OrCode")
					level += 1;
				if (allActions[action][i].GetType().Name == "ElseCode")
					level += 1;
			}

			try
			{
				codeListBox.SelectedIndex = oldIndex;
			}
			catch
			{
				if (codeListBox.Items.Count > 0)
					codeListBox.SelectedIndex = codeListBox.Items.Count - 1;
				else
					codeListBox.SelectedIndex = -1;
			}
		}

		public Form1()
		{
			InitializeComponent();
			// stringArray = new string[5][];
			//Application.EnableVisualStyles();
			//stringArray[0] = marioStrings;
			//stringArray[1] = spriteStrings;
			//stringArray[2] = scoreStrings;
			//stringArray[3] = envStrings;
			//stringArray[4] = miscStrings;

			allActions[0] = marioBottomActions;
			allActions[1] = marioTopActions;
			allActions[2] = marioSideActions;
			allActions[3] = spriteHorizontalActions;
			allActions[4] = spriteVerticalActions;
			allActions[5] = capeActions;
			allActions[6] = fireballActions;
			allActions[7] = marioCornerActions;
			allActions[8] = marioHeadActions;
			allActions[9] = marioBodyActions;


			//allStrings = new string[marioStrings.Length + spriteStrings.Length + scoreStrings.Length + envStrings.Length + miscStrings.Length];

			//int pos = 0;


			for (int i = 0; i < marioCodes.Length; i++) { marioCodes[i].actualCode = false; marioCodesListBox.Items.Add(marioCodes[i]); }
			for (int i = 0; i < spriteCodes.Length; i++) { spriteCodes[i].actualCode = false; spriteCodesListBox.Items.Add(spriteCodes[i]); }
			for (int i = 0; i < scoreCodes.Length; i++) { scoreCodes[i].actualCode = false; scoreCodesListBox.Items.Add(scoreCodes[i]); }
			for (int i = 0; i < envCodes.Length; i++) { envCodes[i].actualCode = false; envCodesListBox.Items.Add(envCodes[i]); }
			for (int i = 0; i < miscCodes.Length; i++) { miscCodes[i].actualCode = false; miscCodesListBox.Items.Add(miscCodes[i]); }
			// codeListBox.SelectedIndex = 0;
			//for (int i = 0; i < stringArray.Length; i++)
			//{
			//        for (int j = 0; j < stringArray[i].Length; j++)
			//        {
			//                allStrings[pos] = stringArray[i][j];
			//                pos++;
			//        }
			//}

			//for (int i = 0; i < marioStrings.Length; i++)
			//{
			//        string s = marioStrings[i];
			//        if (!s.EndsWith(".")) s += "...";
			//        marioCodesListBox.Items.Add(s);
			//}

			//for (int i = 0; i < spriteStrings.Length; i++)
			//{
			//        string s = spriteStrings[i];
			//        if (!s.EndsWith(".")) s += "...";
			//        spriteCodesListBox.Items.Add(s);
			//}

			//for (int i = 0; i < scoreStrings.Length; i++)
			//{
			//        string s = scoreStrings[i];
			//        if (!s.EndsWith(".")) s += "...";
			//        scoreCodesListBox.Items.Add(s);
			//}

			//for (int i = 0; i < envStrings.Length; i++)
			//{
			//        string s = envStrings[i];
			//        if (!s.EndsWith(".")) s += "...";
			//        envCodesListBox.Items.Add(s);
			//}

			//for (int i = 0; i < miscStrings.Length; i++)
			//{
			//        string s = miscStrings[i];
			//        if (!s.EndsWith(".")) s += "...";
			//        miscCodesListBox.Items.Add(s);
			//}

			eventListBox.SelectedIndex = 0;
			marioCodesListBox.SelectedIndex = 0;
			spriteCodesListBox.SelectedIndex = 0;
			scoreCodesListBox.SelectedIndex = 0;
			envCodesListBox.SelectedIndex = 0;
			miscCodesListBox.SelectedIndex = 0;

			this.Form1_Resize(this, null);
		}

		private void Form1_Resize(object sender, EventArgs e)
		{
			textBox1.Top = formInsideSize.Bottom - textBox1.Margin.Bottom - textBox1.Height;
			tabControl1.Left = formInsideSize.Right - tabControl1.Width;
			textBox1.Left = tabControl1.Left;

			tabControl1.Height = textBox1.Top - textBox1.Margin.Top;


			label3.Left = textBox1.Left - label3.Margin.Left - label3.Width;
			label3.Top = textBox1.Top + 3;

			buttonPanel.Left = tabControl1.Left - buttonPanel.Width - buttonPanel.Margin.Right - tabControl1.Margin.Left;
			codeListBox.Width = buttonPanel.Left - buttonPanel.Margin.Left - codeListBox.Margin.Right - (eventListBox.Right + eventListBox.Margin.Right + codeListBox.Margin.Left);
			codeListBox.Height = formInsideSize.Height - label2.Bottom - label2.Margin.Bottom - this.Margin.Top - codeListBox.Margin.Top;
			buttonPanel.Top = (formInsideSize.Height - label2.Bottom - label2.Margin.Bottom - this.Margin.Top - codeListBox.Margin.Top) / 2 - buttonPanel.Height / 2 + codeListBox.Top;
		

			searchListBox.Width = marioCodesListBox.Width;
			searchListBox.Height = marioCodesListBox.Height;
			searchListBox.Left = marioCodesListBox.Left + tabControl1.Left;
			searchListBox.Top = marioCodesListBox.Top + tabControl1.Top;
		}

		private void AddCode(CodePiece codePiece)
		{
			CodePiece newCode = codePiece.Copy();
			newCode.actualCode = true;
			if (newCode.showEditForm)
			{
				if (newCode.customForm == null)
				{
					if ((new EditForm(newCode)).ShowDialog() == System.Windows.Forms.DialogResult.Cancel)
						return;
				}
				else
				{
					newCode.customForm.Tag = newCode;
					if ((newCode.customForm.ShowDialog() == System.Windows.Forms.DialogResult.Cancel))
						return;
				}
			}

			if (newCode != null)
			{
				allActions[eventListBox.SelectedIndex].Insert(Math.Max(codeListBox.SelectedIndex + 1, 0), newCode);
				refreshCodeBox(eventListBox.SelectedIndex);
				codeListBox.SelectedIndex += 1;
			}
		}

		private void addButton_Click(object sender, EventArgs e)
		{

			if (searchListBox.Visible == true)
			{
				AddCode((CodePiece)searchListBox.SelectedItem); 
				return;
			}

			switch (tabControl1.SelectedIndex)
			{
				case 0:
					AddCode((CodePiece)marioCodesListBox.SelectedItem); break;
				case 1:
					AddCode((CodePiece)spriteCodesListBox.SelectedItem); break;
				case 2:
					AddCode((CodePiece)scoreCodesListBox.SelectedItem); break;
				case 3:
					AddCode((CodePiece)envCodesListBox.SelectedItem); break;
				case 4:
					AddCode((CodePiece)miscCodesListBox.SelectedItem); break;
			}
		}

		private void button1_Click(object sender, EventArgs e)
		{
			AddCode(new EndBlock());
		}

		private void editButton_Click(object sender, EventArgs e)
		{
			if (codeListBox.SelectedIndex == -1) return;

			CodePiece newCode = allActions[eventListBox.SelectedIndex][codeListBox.SelectedIndex].Copy();
			newCode.actualCode = true;
			if (newCode.customForm == null)
			{
				if ((new EditForm(newCode)).ShowDialog() == System.Windows.Forms.DialogResult.Cancel)
					return;
			}
			else
			{
				newCode.customForm.Tag = newCode;
				if ((newCode.customForm.ShowDialog() == System.Windows.Forms.DialogResult.Cancel))
					return;
			}

			if (newCode != null)
			{
				allActions[eventListBox.SelectedIndex][codeListBox.SelectedIndex] = newCode;
				refreshCodeBox(eventListBox.SelectedIndex);
			}
		}

		private void codeListBox_SelectedIndexChanged(object sender, EventArgs e)
		{
			if (codeListBox.SelectedIndex == -1)
			{
				moveDownButton.Enabled = false;
				moveUpButton.Enabled = false;
				deleteButton.Enabled = false;
				editButton.Enabled = false;
			}
			else
			{
				moveDownButton.Enabled = true;
				moveUpButton.Enabled = true;
				deleteButton.Enabled = true;
				editButton.Enabled = allActions[eventListBox.SelectedIndex][codeListBox.SelectedIndex].showEditForm;
			}

			if (codeListBox.SelectedIndex <= 0)
				moveUpButton.Enabled = false;
			else
				moveUpButton.Enabled = true;

			if (codeListBox.SelectedIndex == codeListBox.Items.Count - 1)
				moveDownButton.Enabled = false;
			else
				moveDownButton.Enabled = true;

			addButton.Enabled = true;

			if (eventListBox.SelectedIndex != 3 && eventListBox.SelectedIndex != 4)
			{
				if (tabControl1.SelectedIndex == 1)
					addButton.Enabled = false;
			}
			

		}

		private string GenerateCode()
		{
			try
			{

                string[] jumpNames = new string[] { "MarioBelow", "MarioAbove", "MarioSide", "SpriteV", "SpriteH", "Cape", "Fireball", "MarioCorner", "MarioBody", "MarioHead" };
				int label = 0;
				Stack<int> labelStack = new Stack<int>();
				string s = "";
				string allRoutines = "";

				s = "db $42\n\n";

				for (int i = 0; i < jumpNames.Length; i++)
				{
					s += "JMP " + jumpNames[i];
					if (i == 2 || i == 4 || i == 6)
						s += "\n";
					else
						s += " : ";
				}

				s = s.Substring(0, s.Length - 3);
				s += "\n\n";

				bool otherwiseIsValid = false;
				bool orIsActive = false;

				for (int i = 0; i < allActions.Length; i++)
				{
					bool forceNoRTL = false;

					s += jumpNames[i] + ":\n";
					for (int j = 0; j < allActions[i].Count; j++)
					{
						bool shouldContinue = false;

						if (allActions[i][j].routines != null)
							if (allRoutines.Contains(allActions[i][j].routines) == false)
								allRoutines += allActions[i][j].routines + "\n\n\n";

						if (allActions[i][j].GetType().Name == "OrCode")
						{
							if (otherwiseIsValid == false)
							{
								MessageBox.Show("Error generating code: \"Or\"s may only follow query actions.");
								return null;
							}

							if (allActions[i][j - 1].GetType().Name == "OrCode")
							{
								MessageBox.Show("Error generating code: Two \"Or\"s were found in a row.");
								return null;
							}
							orIsActive = true;
							continue;
						}

						if (allActions[i][j].isStatement == false && allActions[i][j].GetType().Name != "EndBlock")
						{
							if (allActions[i][j + 1].GetType().Name == "OrCode" || orIsActive)
							{
								allActions[i][j].labelName = "Label_" + label.ToString("X4");
								if (allActions[i][j].enumerations == CodePiece.trueFalse)
									allActions[i][j].value = Convert.ToInt32(!(allActions[i][j].value > 0));

								allActions[i][j].branchType = !allActions[i][j].branchType;
								s += allActions[i][j].Code + "\n";
								allActions[i][j].branchType = !allActions[i][j].branchType;
								if (allActions[i][j].enumerations == CodePiece.trueFalse)
									allActions[i][j].value = Convert.ToInt32(!(allActions[i][j].value > 0));
								shouldContinue = true;
							}
							else
							{
								allActions[i][j].labelName = "Label_" + label.ToString("X4");
							}

							if ((orIsActive == false || allActions[i][j + 1].isStatement == true) && allActions[i][j + 1].GetType().Name != "OrCode")
							{
								if (orIsActive == true)
								{
									label++;
									s += "BRA Label_" + label.ToString("X4") + "\n";
									s += "Label_" + (label - 1).ToString("X4") + ":\n";
								}
								labelStack.Push(label);
								label++;
								orIsActive = false;
							}

							otherwiseIsValid = true;
							if (shouldContinue) continue;
						}

						if (allActions[i][j].GetType().Name == "GoToNextEvent")
						{
							forceNoRTL = true;
							continue;
						}

						if (allActions[i][j].GetType().Name == "ElseCode")
						{
							if (otherwiseIsValid)
							{
								s += ((ElseCode)allActions[i][j]).GenerateElseCode("Label_" + label.ToString("X4"), "Label_" + labelStack.Pop().ToString("X4")) + "\n";
								labelStack.Push(label);
								label++;

								otherwiseIsValid = false;
								continue;
							}
							else
							{
								MessageBox.Show("Error generating code: There may be only one \"otherwise\" per conditional.");
								return null;
							}
						}

						if (allActions[i][j].GetType().Name == "OrCode")
						{
							continue;
						}

						if (allActions[i][j].GetType().Name == "EndBlock")
						{
							try
							{
								allActions[i][j].labelName = "Label_" + labelStack.Pop().ToString("X4");
								s += allActions[i][j].Code + "\n";
								continue;
							}
							catch
							{
								MessageBox.Show("Error generating code: A group end has been improperly placed.  This means that there are more group ends than there are queries; find the extra one and take it out.");
								return null;
							}
						}
						s += allActions[i][j].Code + "\n";
					}

					if (!forceNoRTL)
					{
						if (i == allActions.Length - 1)
							s += "RTL\n\n";
						else if (allActions[i + 1].Count != 0)
							s += "RTL\n\n";
						else if (allActions[i].Count > 0)
							s += "\n\n";
					}
					else
						s += "\n\n";

					//s += "\n";
					//if (i == allActions.Length - 1)
					//	s += "RTL";
					//else if (!(allActions[i].Count == 0 && allActions[i + 1].Count == 0))
					//	s += "RTL";

					//s += "\n\n\n";
				}

				if (labelStack.Count != 0)
				{
					MessageBox.Show("Error generating code: There is a missing group end.  This means that there is a query that is missing a group end somewhere.");
					return null;
				}
				s += "\n\n" + allRoutines;


				if (Program.usingSA1)
				{
					// Now we search for all RAM addresses and adjust them for SA-1 support.
					int i = 6;	// Start at 6 to avoid parsing the db $42 bit.

					while (i < s.Length)
					{
						if (s[i] == '#')	// Skip over immediate values.
							i += 2;
						else if (s[i] == '$')
						{
							i++;
							int oldStart = i;
							int oldValue = 0;
							int digitCount = 0;
							while (char.IsDigit(s[i]) || (char.ToLower(s[i]) >= 'a' && char.ToLower(s[i]) <= 'f'))
							{
								oldValue <<= 4;
								if (char.IsDigit(s[i])) oldValue |= (s[i] - '0');
								else if (char.ToLower(s[i]) >= 'a' && char.ToLower(s[i]) <= 'f') oldValue |= (char.ToLower(s[i]) - 'a' + 10);
								else break;
								i++;
								digitCount++;
							}

							if (digitCount != 4) // Only convert 4-digit values. 2-digit values are handled by DP, 6 by long addressing.
								continue;

							if (oldValue > 0xFFFF)
							{
								i += 6;		// Long addresses don't need conversion.
								continue;
							}
							int newValue = oldValue;

							if      (oldValue >= 0x0000 && oldValue <= 0x00FF) newValue |= 0x3000;
							else if (oldValue >= 0x0100 && oldValue <= 0x1FFF) newValue |= 0x6000;

							string oldStr = "", newStr;

							if (oldValue <= 0xFF)
								oldStr = oldValue.ToString("X2");
							else if (oldValue <= 0xFFFF)
								oldStr = oldValue.ToString("X4");

							newStr = newValue.ToString("X4");

							s = s.Remove(oldStart, oldStr.Length);
							if (s[oldStart] == '\t' && oldStr.Length == 2) s = s.Remove(oldStart, 1);	// Keep tab formatting.
							s = s.Insert(oldStart, newStr);
							i = oldStart + newStr.Length;
						}
						else
							i++;
					}
				}



				return s;
			}
			catch
			{
				MessageBox.Show("Error generating code: Unidentified error.  Be sure there is no malformed code anywhere.");
				return null;
			}
		}

		private void button2_Click(object sender, EventArgs e)
		{
			string s = GenerateCode();
			if (s != null)
			{
				s = s.Replace("\n", "\r\n");
				new CodeForm(s).ShowDialog();
			}
		}

		private void eventListBox_SelectedIndexChanged(object sender, EventArgs e)
		{
			refreshCodeBox(eventListBox.SelectedIndex);
			codeListBox.SelectedIndex = -1;
			codeListBox_SelectedIndexChanged(sender, e);
			textBox1_TextChanged(sender, e);
		}

		private void deleteButton_Click(object sender, EventArgs e)
		{
			allActions[eventListBox.SelectedIndex].RemoveAt(codeListBox.SelectedIndex);
			refreshCodeBox(eventListBox.SelectedIndex);
			if (codeListBox.SelectedIndex == -1) 
				deleteButton.Enabled = false;
		}

		private void moveUpBotton_Click(object sender, EventArgs e)
		{
			CodePiece c = allActions[eventListBox.SelectedIndex][codeListBox.SelectedIndex];
			allActions[eventListBox.SelectedIndex].RemoveAt(codeListBox.SelectedIndex);
			allActions[eventListBox.SelectedIndex].Insert(codeListBox.SelectedIndex - 1, c);
			refreshCodeBox(eventListBox.SelectedIndex);
			codeListBox.SelectedIndex--;
		}

		private void moveDownButton_Click(object sender, EventArgs e)
		{
			CodePiece c = allActions[eventListBox.SelectedIndex][codeListBox.SelectedIndex];
			allActions[eventListBox.SelectedIndex].RemoveAt(codeListBox.SelectedIndex);
			allActions[eventListBox.SelectedIndex].Insert(codeListBox.SelectedIndex + 1, c);
			refreshCodeBox(eventListBox.SelectedIndex);
			codeListBox.SelectedIndex++;
		}

		private void tabControl1_SelectedIndexChanged(object sender, EventArgs e)
		{
			codeListBox_SelectedIndexChanged(sender, e);
		}

		private void textBox1_TextChanged(object sender, EventArgs e)
		{
			if (textBox1.Text == "")
			{
				searchListBox.Visible = false;
				tabControl1.Visible = true;
				return;
			}

			searchListBox.Items.Clear();
			searchListBox.Visible = true;
			tabControl1.Visible = false;

			for (int i = 0; i < allCodePieces.Length; i++)
			{
				for (int j = 0; j < allCodePieces[i].Length; j++)
				{
					bool add = true;

					if (eventListBox.SelectedIndex != 3 && eventListBox.SelectedIndex != 4)
					{
						if (i == 1)
							add = false;
					}

					if (add && allCodePieces[i][j].ToString().ToLower().Contains(textBox1.Text.ToLower()))
						searchListBox.Items.Add(allCodePieces[i][j]);
				}
			}
		}

		private void elseButton_Click(object sender, EventArgs e)
		{
			AddCode(new ElseCode());
		}



		public static CodePiece[] marioCodes = { new TestPlayerPowerup(),
						new SetPowerupAnimate(),
						new SetPowerupNoAnimate(),
						new TestPlayerX(),
						new TestPlayerY(),
						new SetPlayerX(),
						new SetPlayerY(),
						new TestPlayerDucking(),
						new TestPlayerClimbing(),
						new TestPlayerDirection(),
						new SetPlayerHideGraphics(),
						new TestPlayerXSpeed(),
						new TestPlayerYSpeed(),
						new SetPlayerXSpeed(),
						new SetPlayerYSpeed(),
						new TestPlayerSpinJumping(),
						new TestPlayerRidingYoshi(),
						new HurtPlayer(),
						new KillPlayer(),
						new StunPlayer(),
						new TestPlayerInvincibility(),
						new SetPlayerInvincibility()};

		public static CodePiece[] spriteCodes = { new TestSpriteXSpeed(),
						   new TestSpriteYSpeed(),
						   new SetSpriteXSpeed(),
						   new SetSpriteYSpeed(),
						   new TestSpriteXPos(),
						   new TestSpriteYPos(),
						   new SetSpriteXPos(),
						   new SetSpriteYPos(),
						   new TestSpriteAlive(),
						   new KillSprite(),
						   new TestSpriteType(),
						   new TestSpriteToolType(),
						   new TestTesseraType(),
						   new SpriteOnGround()};

		public static CodePiece[] scoreCodes = { new TestPlayerCoinCount(),
						  new SetPlayerCoinCount(),
						  new TestPlayerDragonCount(),
						  new TestPlayerLifeCount(),
						  new SetPlayerLifeCount(),
						  new TestPlayerSilverCoin(),
						  new SetPlayerSilverCoin()};

		public static CodePiece[] envCodes = { new TestWaterLevel(),
						new TestSlipperyLevel(),
						new SetWaterLevel(),
						new SetSlipperyLevel(),
						new SetNonWaterLevel(),
						new SetNonSlipperyLevel(),
						new ShakeGround(),
						new TestLevelNumber(),
						new TeleportPlayer(),
						new TeleportPlayerAbsolute(),
						new TestItemBoxItem(),
						new SetItemBox(),
						new TestBluePow(),
						new TestSilverPow(),
						new SetBluePow(),
						new SetSilverPow(),
						new TestSwitchON(),
						new TestSwitchOFF(),
						new SetSwitchON(),
						new SetSwitchOFF()};

		public static CodePiece[] miscCodes = { new ShatterBlock(),
						 new SpriteShatterBlock(),
						 new SpawnSprite(),
						 new DisplayMessage(),
						 new TestButtonDown(),
					         new TestButtonClicked(),
						 new DisableButtonP1(),
						 new DisableButtonP2(),
						 new SetSolid(),
						 new SetNotSolid(),
						 new ActLikeBlock(),
						 new ChangeTile(),
						 new ChangeMap16(),
						 new PlaySFXBank1(),
						 new PlaySFXBank2(),
						 new PlaySFXBank3(),
						 new Every2Frames(),
						 new Every4Frames(),
						 new Every8Frames(),
						 new Every16Frames(),
						 new Every32Frames(),
						 new Every64Frames(),
						 new Every128Frames(),
						 new Every256Frames(),
						 new Alternate1Frame(),
						 new Alternate2Frame(),
						 new Alternate4Frame(),
						 new Alternate8Frame(),
						 new Alternate16Frame(),
						 new Alternate32Frame(),
						 new Alternate64Frame(),
						 new Alternate128Frame(),
						 new TestPlayer1(),
						 new TestPlayer2(),
						 new Test1PlayerGame(),
						 new Test2PlayerGame(),
						 new GoToSubroutine(),
						 new RAMEdit(),
						 new GoToEvent(),
						 new GoToNextEvent(),
						 new ExitEvent(),
					       };

		public CodePiece[][] allCodePieces = new CodePiece[][] { marioCodes, spriteCodes, scoreCodes, envCodes, miscCodes };

		private void button3_Click(object sender, EventArgs e)
		{
			AddCode(new OrCode());
		}

		private void checkBox1_CheckedChanged(object sender, EventArgs e)
		{
			Program.usingSA1 = checkBox1.Checked;
		}
	}




}
