using System;
using System.Collections.Generic;
using System.Text;

namespace BlockMaker
{
	public enum ComparisonType
	{
		Equal,
		NotEqual,
		Greater,
		Less,
		Negative,
		Positive,
		SignGreater,
		SignLess
	}

	public class BranchType
	{
		public BranchType Copy()
		{
			return (BranchType)MemberwiseClone();
		}

		public ComparisonType ct = ComparisonType.Equal;

		public static BranchType operator !(BranchType a)
		{
			switch (a.ct)
			{
				case ComparisonType.Equal:
					a.ct = ComparisonType.NotEqual; break;
				case ComparisonType.NotEqual:
					a.ct = ComparisonType.Equal; break;
				case ComparisonType.Greater:
					a.ct = ComparisonType.Less; break;
				case ComparisonType.Less:
					a.ct = ComparisonType.Greater; break;
				case ComparisonType.Negative:
					a.ct = ComparisonType.Positive; break;
				case ComparisonType.Positive:
					a.ct = ComparisonType.Negative; break;
				case ComparisonType.SignGreater:
					a.ct = ComparisonType.SignLess; break;
				case ComparisonType.SignLess:
					a.ct = ComparisonType.SignGreater; break;
			}
			return a;
		}

		public override string ToString()
		{
			switch (ct)
			{
				case ComparisonType.NotEqual:
					return "BEQ ";
				case ComparisonType.Equal:
					return "BNE ";
				case ComparisonType.Less:
					return "BCS ";
				case ComparisonType.Greater:
					return "BCC ";
				case ComparisonType.Positive:
					return "BMI ";
				case ComparisonType.Negative:
					return "BPL ";
				case ComparisonType.SignLess:
					return "BPL ";
				case ComparisonType.SignGreater:
					return "BMI ";
				default:
					throw new System.ArgumentOutOfRangeException("Invalid branch command");
			}

		}

		public string ToUnString()
		{

			switch (ct)
			{
				case ComparisonType.Equal:
					return "BEQ ";
				case ComparisonType.NotEqual:
					return "BNE ";
				case ComparisonType.Greater:
					return "BCS ";
				case ComparisonType.Less:
					return "BCC ";
				case ComparisonType.Negative:
					return "BMI ";
				case ComparisonType.Positive:
					return "BPL ";
				case ComparisonType.SignGreater:
					return "BPL";
				case ComparisonType.SignLess:
					return "BMI";
			}
			throw new System.ArgumentOutOfRangeException("Invalid branch command");
		}
	}

	public abstract class CodePiece
	{
		public static string[] trueFalse = { "True", "False" };

		public string[] enumerations = null;
		public string routines = null;
		public string labelName;

		public bool isStatement;
		public int value = 0;
		public int value2;
		public string queryStr = null;
		public string inputStr1 = null;
		public string inputStr2 = null;
		public string listString = null;
		public bool is16Bit = false;
		public int inputCount = 1;
		public bool usesConstant = true;
		public BranchType branchType = new BranchType();
		public bool relative = false;
		public bool allowNegative = false;
		public bool usingHex = false;
		public bool actualCode = true;			// Set to false during list generation.
		public bool noRelative = false;

		public System.Windows.Forms.Form customForm = null;	// Set this to generate a custom editing form.
									// Note that a form's Tag is used to store the CodePiece to edit.

		public bool showEditForm = true;
		//public ComparisonType comparisonType = ComparisonType.Equal;

		public int level = 0;	// Not used in code generation.	

		public abstract string GenerateCode();

		public string Code
		{
			get
			{
				string s = GenerateCode().Replace("CMP #$0000\n", "").Replace("CMP #$00\n", "");

				int tabPos = 0;
				int i;
				for (i = 0; i < s.Length; i++)
				{
					if (s[i] == '\n' && s[i - 1] != ':')
					{
						s = s.Insert(tabPos, "\t");
						i++;
						tabPos = i + 1;
					}
				}
				if (s[i - 1] != ':')
					s = s.Insert(tabPos, "\t");

				int count = 0;
				int newLines = 0;
				for (i = 0; i < s.Length; i++)
				{
					if (s[i] == '\n' || i == s.Length - 1)
					{
						bool exit = false;
						if (i == s.Length - 1) 
						{
							i++;
							count++;
							exit = true;
						}

						s = s.Insert(i, new string('\t', Math.Max(6 - (((count & ~0x7) >> 3)), 0)) + "; |");
						count = 0;
						while (!(s[i++] == '\n' || i == s.Length - 1)) ;
						i--;
						newLines++;
						if (exit) break;
						continue;
					}

					if (s[i] == '\t')
						count += 8;
					else
						count++;
				}

				//int state = 0;
				char[] s2 = s.ToCharArray();
				bool change = true;
				int newLinePos = 0;
				int commentPos = -1;
				for (i = 0; i < s2.Length; i++)
				{
					if (s2[i] == '|' && change)
					{
						s2[i] = '\\';
						change = false;
					}
					if ((s2[i] == '\n' || i == s2.Length - 1) && commentPos == -1)
					{
						newLinePos++;
						if (newLinePos >= newLines / 2)
							commentPos = i;
						if (i == s2.Length - 1)
							commentPos++;
					}

					
				}
				if (s2[s2.Length - 1] == '|')
					s2[s2.Length - 1] = '/';
				else
					s2[s2.Length - 1] = '>';
				s = new string(s2);
				s = s.Insert(commentPos, " " + CodeString());
				return s;
			}
		}

		public abstract string CodeString();

		public override string ToString()
		{
			if (actualCode)
			{
				string s = "";
				for (int i = 0; i < level; i++)
					s += "\t";

				return s + CodeString();
			}
			else
				return listString;
		}

		public string Hex(int value)
		{
			string ret;
			if (usesConstant)
			{
				if (is16Bit)
				{
					ret = value.ToString("X4");
					ret = "#$" + ret.Substring(ret.Length - 4, 4);
				}
				else
				{
					ret = value.ToString("X2");
					ret = "#$" + ret.Substring(ret.Length - 2, 2);
				}


			}
			else
			{
				if ((value & 0x7E00FF) == value)
					ret = "$" + value.ToString("X").Substring(4, 2);
				else if ((value & 0x7EFFFF) == value && value < 0x7E2000)
					ret = "$" + value.ToString("X4").Substring(2, 4);
				else 
					ret = "$" + value.ToString("X6");
			}
			return ret;

		}

		public string SA1AddrConv(int value)
		{
			if (Program.usingSA1)
			{
				if (value >= 0x0000 && value <= 0x00FF) value += 0x3000;
				if (value >= 0x0100 && value <= 0x1FFF) value += 0x6000;
			}
			string ret = "";
			if ((value & 0x7E00FF) == value)
				ret = "$" + value.ToString("X").Substring(4, 2);
			else if ((value & 0x7EFFFF) == value && value < 0x7E2000)
				ret = "$" + value.ToString("X4").Substring(2, 4);
			else
				ret = "$" + value.ToString("X6");

			return ret;
		}

		public string GetCompString(int value)
		{
			switch (branchType.ct)
			{
				case ComparisonType.Equal:
					return " is equal to " + ValueToString(value) + "...";
				case ComparisonType.Greater:
				case ComparisonType.SignGreater:
					return " is greater than " + ValueToString(value) + "...";
				case ComparisonType.Less:
				case ComparisonType.SignLess:
					return " is less than " + ValueToString(value) + "...";
				case ComparisonType.Negative:
					return " is negative...";
				case ComparisonType.NotEqual:
					return " is not equal to " + ValueToString(value) + "...";
				case ComparisonType.Positive:
					return " is positive...";
			}
			return null;
		}

		public string ValueToString(int value)
		{
			string ret = "";

			if (usesConstant)
				ret = "#$";
			else
				ret = "$";

			if (usingHex)
			{
				if (usesConstant == false)
				{
					ret += value.ToString("X6");
					if (ret.Substring(0, 5) == "$7E00")
						ret = "$" + value.ToString("X2");
					else if (ret.Substring(0, 3) == "$7E")
						ret = "$" + value.ToString("X4");
					//ret = ret.Substring(ret.Length - 6, 6);
				}
				else if (is16Bit)
				{
					ret += value.ToString("X4");
					//ret = ret.Substring(ret.Length - 4, 4);
				}
				else
				{
					ret += value.ToString("X2");
					//ret = ret.Substring(ret.Length - 2, 2);
				}
			}
			else
			{
				ret = value.ToString();
			}

			

			return ret;
		}

		public string SetString(string str)
		{
			if (relative)
				return "Change " + str + " by ";
			else
				return "Set " + str + " to ";
		}

		public CodePiece Copy()
		{
			CodePiece n = (CodePiece)this.MemberwiseClone();
			n.branchType = n.branchType.Copy();
			return (CodePiece)n;
		}
	}
}
