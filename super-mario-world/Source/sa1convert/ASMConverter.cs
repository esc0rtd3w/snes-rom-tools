using System;
using System.Collections.Generic;
using System.Text;
using System.Text.RegularExpressions;

namespace VilelaBot2
{
	class ASMConverter
	{
		object locker = new object();
		string current;
		string currentNoComment;
		StringBuilder log1;
		StringBuilder log2;
		StringBuilder log3;
		bool skip;

		public int ConvertAddress(int address, bool sa1)
		{
			lock (locker)
			{
				Reset(null);
				return RemapNumber(address, sa1);
			}
		}

		public string ConvertSprite(string sprite, out string log, out string criticalLog)
		{
			lock (locker)
			{
				skip = false;
				Reset(sprite);
				spritePass1();
				if (log3.Length != 0)
				{
					current = null;
				}
				if (skip)
				{
					current = null;
				}

				log2.Insert(0, "\r\n-------- Regular Log --------\r\n");
				log2.Insert(0, log3.ToString());
				log2.Insert(0, "-------- Critical Log --------\r\n");
				log2.AppendLine("\r\n-------- Information Log --------\r\n");
				log2.AppendLine(log1.ToString());
				log = log2.ToString();
				criticalLog = log3.ToString();
				return current;
			}
		}

		private void spritePass1()
		{
			if (current.StartsWith(";@sa1"))
			{
				log2.AppendLine("File is already converted into SA-1, but it uses old tag.");
				current = ";~@sa1" + current.Substring(5);
				return;
			}
			
			if (current.StartsWith(";~@sa1"))
			{
				log2.AppendLine("File is already converted into SA-1. Ignoring for security reasons.");
				skip = true;
				return;
			}
			current = ";~@sa1 <-- DO NOT REMOVE THIS LINE!\r\n" + current;

			addr1938();
			dynamicSpriteRt();
			map16bank();
			multiplyRegisters();
			divisionRegisters();

			string[] patterns = {
				@"\$([0-9A-F]{1,2})(?![0-9A-F]{1,4})",
				@"\$([0-9A-F]{3,4})(?![0-9A-F]{1,2})",
				@"\$([0-9A-F]{5,6})",
			};

			foreach (string pattern in patterns)
			{
				Regex regex = new Regex(pattern, RegexOptions.IgnoreCase | RegexOptions.Compiled);
				current = regex.Replace(current, MatchAddress);
				currentNoComment = RemoveComments(current);
			}
		}
		
		private void map16bank()
		{
			// pretty much it's only
			// lda #$7e
			// sta $6d
			// of course more is needed if I want 100% accuracy.
			
			while(true)
			{
				int index = current.IndexOf("lda #$7e", 0, StringComparison.OrdinalIgnoreCase);
				if(index == -1)break;
				int index2 = current.IndexOf("sta $6d", index, StringComparison.OrdinalIgnoreCase);
				if(index2 == -1)break;
				
				log2.AppendLine("Possible Generic Map16 routine found, checking...");
					
				if(RemoveComments(current.Substring(index+"lda #$7e".Length,index2-index-"lda #$7e".Length))
					.Replace(" ","").Replace("\t","").Replace("\r","").Replace("\n","")=="")
				{
					log2.AppendLine("Generic Map16 routine detected");
					current = current.Remove(index,"lda #$7e".Length);
					current = current.Insert(index,"LDA #$40");
					log2.AppendLine("Replaced 'LDA #$7E' by 'LDA #$40'");
					continue;
				}
				
				log2.AppendLine("...false positive.");
				break;
			}
		}
	
		private void dynamicSpriteRt()
		{
			// time to handle dynamic sprites
			// this should a little harder
			// basically, what make it breaks is:
			// - uses DMA
			// - uses different addresses
			// I think the best way is to find the dynamic sprite copy label
			// and replace it with a new routine.
			
			int index = 0;
			
		retry:
			if((index = current.IndexOf("DMABUFFER", index, StringComparison.OrdinalIgnoreCase)) != -1)
			{
				int sX;
				string cap = capture(index, out sX);
				if(cap.IndexOf("DMABUFFER", StringComparison.OrdinalIgnoreCase)!=0)
				{
					index += cap.Length;
					goto retry;
				}
			
				log2.AppendLine("Dynamic Sprite routine found. Attempting to convert them...");
				log1.AppendLine("Dynamic Sprite routine found. Attempting to convert them...");
				
				int index2 = current.IndexOf("RTS", index, StringComparison.OrdinalIgnoreCase);
				
				if(index2 == -1)
				{
					log3.AppendLine("Couldn't find a RTS after the DMABUFFER label.");
				}
				
				index2 += 3; // add the RTS itself.
				
				string theRoutine = current.Substring(index, index2-index);
				bool xkas = theRoutine[9] == ':' || theRoutine[10] == ':';
				
				log1.AppendLine("Current DMABUFFER Routine:");
				log1.AppendLine(theRoutine);
				
				//if(!specialReplace2(ref theRoutine, "REP #$20", "LDA #$C4", "STA $2230", "REP #$21"))goto Error;
				
				if(xkas){if(!specialReplace2(ref theRoutine, "LDA !SLOTDEST", "LDY #$C4", "STY $2230", "LDA.w !SLOTDEST"))goto Error;}
				else{if(!specialReplace2(ref theRoutine, "LDA SLOTDEST", "LDY #$C4", "STY $2230", "LDA.W SLOTDEST"))goto Error;}
				if(!specialReplace2(ref theRoutine, "STA $2181", "ADC #$74BC", "STA $2235"))goto Error;
				if(!specialReplace2(ref theRoutine, "LDY #$7F", ""))goto Error;
				if(!specialReplace2(ref theRoutine, "STY $2183", ""))goto Error;
				if(!specialReplace2(ref theRoutine, "STZ $4300", ""))goto Error;
				if(!specialReplace2(ref theRoutine, "LDY #$80", ""))goto Error;
				if(!specialReplace2(ref theRoutine, "STY $4301", ""))goto Error;
				if(!specialReplace2(ref theRoutine, "STA $4302", "STA $2232"))goto Error;
				if(!specialReplace2(ref theRoutine, "STY $4304", "STY $2234"))goto Error;
				if(!specialReplace2(ref theRoutine, "STY $4305", "STZ $2238", "STY $2238"))goto Error;
				if(!specialReplace2(ref theRoutine, "LDY #$01", "LDY #$41"))goto Error;
				if(!specialReplace2(ref theRoutine, "STY $420B", "STY $2237", "", "LDY $318C", xkas?"BEQ $FB":"dcb $F0,$FB","LDY #$00","STY $318C","STY $2230"))goto Error;

				// 2-4 line
				
				for (int i=0;i<3;++i)
				{
					if(xkas){if(!specialReplace2(ref theRoutine, "LDA !SLOTDEST", "LDY #$C4", "STY $2230", "LDA.w !SLOTDEST"))goto Error;}
					else{if(!specialReplace2(ref theRoutine, "LDA SLOTDEST", "LDY #$C4", "STY $2230", "LDA.W SLOTDEST"))goto Error;}
					if(!specialReplace2(ref theRoutine, "STA $2181", "ADC #$74BC", "STA $2235"))goto Error;
					if(!specialReplace2(ref theRoutine, "STA $4302", "STA $2232"))goto Error;
					if(!specialReplace2(ref theRoutine, "STY $4304", "STY $2234"))goto Error;
					if(!specialReplace2(ref theRoutine, "STY $4305", "STZ $2238", "STY $2238"))goto Error;
					if(!specialReplace2(ref theRoutine, "LDY #$01", "LDY #$41"))goto Error;
					if(!specialReplace2(ref theRoutine, "STY $420B", "STY $2237", "", "LDY $318C", xkas?"BEQ $FB":"dcb $F0,$FB","LDY #$00","STY $318C","STY $2230"))goto Error;
				}
				
				log1.AppendLine("New DMABUFFER Routine:");
				log1.AppendLine(theRoutine);
				
				current = current.Remove(index, index2-index); // insert the new routine.
				current = current.Insert(index, theRoutine);
			}
			
			log2.AppendLine("Dynamic Sprite conversion: SUCCESS!");
			log1.AppendLine("Dynamic Sprite conversion: SUCCESS!");
			return;
			
		Error:
			log3.AppendLine("Dynamic Sprite conversion: FAIL!");
			log2.AppendLine("Dynamic Sprite conversion: FAIL!");
			log1.AppendLine("Dynamic Sprite conversion: FAIL!");
			return;
		}

		private void multiplyRegisters()
		{
			// if there's $4202 and $4203, we can convert into SA-1 Registers without worrying much
			// about 16-bit.

			if (current.IndexOf(" $4202", StringComparison.OrdinalIgnoreCase) == -1 ||
				current.IndexOf(" $4203", StringComparison.OrdinalIgnoreCase) == -1)
			{
				return;
			}
			
			string[] opcodes = new string[] { "STA", "STX", "STY", "STZ" };

			foreach (string opcode in opcodes)
			{
				while (specialReplace(opcode + " $4202", "STZ $2250", opcode + " $2251", "STZ $2252")) ;
				while (specialReplace(opcode + " $4203", opcode + " $2253", "STZ $2254")) ;
			}
			
			while (specialReplace("LDA $4216", "LDA $2306")) ;
			while (specialReplace("LDX $4216", "LDX $2306")) ;
			while (specialReplace("LDY $4216", "LDY $2306")) ;
			while (specialReplace("ASL $4216", "NOP", "NOP", "NOP", "ASL $2306")) ;
			while (specialReplace("LDA $4217", "LDA $2307")) ;
		}
		
		private void divisionRegisters()
		{
			// trust me, I don't trust the sprites
			// from a lot I looked, NO sprite waited 8 or 16 cycles.
		
			while (specialReplace("STA $4204", "PHA", "LDA #$EA01", "STA $2250", "PLA", "STA $2251", "STZ $2252")) ;
			
			string[] opcodes = new string[] { "STA", "STX", "STY", "STZ" };
			
			foreach (string opcode in opcodes)
			{
				while (specialReplace(opcode + " $4205", opcode + " $2252")) ;
				while (specialReplace(opcode + " $4206", opcode + " $2253", "STZ $2254", "NOP", "NOP", "NOP")) ;
			}
			
			opcodes = new string[] { "LDA", "LDX", "LDY" };
			
			foreach (string opcode in opcodes)
			{
				while (specialReplace(opcode + " $4214", opcode + " $2306")) ;
				while (specialReplace(opcode + " $4215", opcode + " $2307")) ;
				while (specialReplace(opcode + " $4216", opcode + " $2306")) ;
				while (specialReplace(opcode + " $4217", opcode + " $2307")) ;
			}
		}

		private void addr1938()
		{
			while (specialReplace("STA $1938,y", "PHX", "TYX", "STA $418A00,x", "PLX")) ;
		}

		private bool specialReplace(string lookFor, params string[] replacements)
		{
			int index = 0;
			if ((index = current.IndexOf(lookFor, index, StringComparison.OrdinalIgnoreCase)) >= 0)
			{
				int i;
				string cap = capture(index, out i);
				string s = cap.Substring(0, index - i);

				for (int x = 0; x < s.Length; ++x)
				{
					if (s[x] != ' ' && s[x] != '\t')
					{
						s = s.Replace(s[x], ' ');
					}
				}

				string build = "";
				for (int x = 0; x < replacements.Length; ++x)
				{
					build += replacements[x];
					if (x + 1 != replacements.Length)
					{
						build += "\r\n";
						build += s;
					}
					else
					{
						int length = lookFor.Length - replacements[x].Length;
						for (int y = 0; y < length; ++y)
						{
							build += " ";
						}
					}
				}

				current = current.Remove(index, lookFor.Length);
				current = current.Insert(index, build);
				log2.AppendFormat("Processed:	'{0}'.\r\n", cap);
				return true;
			}

			return false;
		}
		
		private bool specialReplace2(ref string current, string lookFor, params string[] replacements)
		{
			int index = 0;
			if ((index = current.IndexOf(lookFor, index, StringComparison.OrdinalIgnoreCase)) >= 0)
			{
				int i;
				string cap = capture2(current, index, out i);
				string s = cap.Substring(0, index - i);

				for (int x = 0; x < s.Length; ++x)
				{
					if (s[x] != ' ' && s[x] != '\t')
					{
						s = s.Replace(s[x], ' ');
					}
				}

				string build = "";
				for (int x = 0; x < replacements.Length; ++x)
				{
					build += replacements[x];
					if (x + 1 != replacements.Length)
					{
						build += "\r\n";
						build += s;
					}
					else
					{
						int length = lookFor.Length - replacements[x].Length;
						for (int y = 0; y < length; ++y)
						{
							build += " ";
						}
					}
				}

				current = current.Remove(index, lookFor.Length);
				current = current.Insert(index, build);
				log2.AppendFormat("Processed:	'{0}'.\r\n", cap);
				return true;
			}

			return false;
		}


		private string capture(int index, out int i)
		{
			int startIndex = index;
			int endIndex = index;
			while (startIndex > 0 && current[startIndex] != '\n' && current[startIndex] != ':') --startIndex;
			while (endIndex < current.Length && current[endIndex] != '\r' && current[endIndex] != ':') ++endIndex;
			++startIndex;
			i = startIndex;
			return current.Substring(startIndex, endIndex - startIndex);
		}
		
		private string capture2(string current, int index, out int i)
		{
			int startIndex = index;
			int endIndex = index;
			while (startIndex > 0 && current[startIndex] != '\n' && current[startIndex] != ':') --startIndex;
			while (endIndex < current.Length && current[endIndex] != '\r' && current[endIndex] != ':') ++endIndex;
			++startIndex;
			i = startIndex;
			return current.Substring(startIndex, endIndex - startIndex);
		}

		#region General Methods
		void Reset(string data)
		{
			if (data != null)
			{
				current = FixLines(data);
				currentNoComment = RemoveComments(current);
			}
			log1 = new StringBuilder();
			log2 = new StringBuilder();
			log3 = new StringBuilder();
		}

		string RemoveComments(string data)
		{
			string[] tmp = data.Split(new string[] { "\r\n" }, StringSplitOptions.None);
			for (int i = 0; i < tmp.Length; ++i)
			{
				if (tmp[i].Contains(";"))
				{
					tmp[i] = tmp[i].Substring(0, tmp[i].IndexOf(";"));
				}
			}
			return String.Join("\r\n", tmp);
		}

		string FixLines(string data)
		{
			data = data.Replace("\r\n", "\n");
			data = data.Replace("\r", "\n");
			data = data.Replace("\n", "\r\n");
			return data;
		}
		#endregion

		#region Logging Methods
		void CantRemap(int address)
		{
			log3.AppendFormat("Cannot remap address '${0:X6}'.", address);
			log3.AppendLine();
		}
		void ReportConversion(int oldAddress, int newAddress)
		{
			log1.AppendFormat("Converted {0:X6} to {1:X6}", oldAddress, newAddress);
			log1.AppendLine();
		}
		#endregion

		#region Main Methods
		string MatchAddress(Match match)
		{
			int number = Convert.ToInt32(match.Groups[1].Value, 16);

			bool ignore = false;
			string line = "";
			int index = match.Index;
			while (index > 0 && current[--index] != '\n' && current[index] != ':')
			{
				line += current[index];
			}
			line = Reverse(line);

			ignore = MultiMatch(line, ";", "dcb", "dcw", "dcl", "db", "dw", "dl", "dd", ",", "#",
								"PER", "PEA", "BEQ", "BNE", "BCC", "BCS", "BMI", "BPL", "BVC",
								"BVS", "BLT", "BGE", "BRL", ",s");
			if (!ignore)
			{
				ignore = CheckForDefine(line);
			}
			index = match.Index;
			while (index < current.Length && current[index] != '\r' && current[index] != ':')
			{
				line += current[index++];
			}
			
			int newN = RemapNumber(number, true);

			if (!ignore && newN == number)
			{
				log2.AppendFormat("Unnecessary: '{0}'.\r\n", line.Trim(' ', '\t'));
			}
			else if (newN == -1)
			{
				log2.AppendFormat("Failed:		'{0}'.\r\n", line.Trim(' ', '\t'));
				ignore = true;
			}
			else if (ignore)
			{
				log2.AppendFormat("Ignored:		'{0}'.\r\n", line.Trim(' ', '\t'));
			}
			else
			{
				log2.AppendFormat("Processed:	'{0}'.\r\n", line.Trim(' ', '\t'));
			}

			if (ignore)
			{
				return match.Groups[0].Value;
			}
			else
			{
				if (match.Groups[1].Length > 4)
				{
					return "$" + newN.ToString("X6");
				}
				if (match.Groups[1].Length > 2)
				{
					return "$" + newN.ToString("X4");
				}
				if ((newN >> 8) == 0x30)
				{
					return "$" + (newN & 0xff).ToString("X2");
				}
				else
				{
					return "$" + newN.ToString("X4");
				}
			}
		}

		bool CheckForDefine(string str)
		{
			// bla = 
			string[] args = str.Split('=');
			if (args.Length != 2)
			{
				return false; // not a define
			}
			args[0] = args[0].Trim(' ', '\t');
			args[1] = args[1].Trim(' ', '\t');
			log1.AppendFormat("Processing define '{0}'.\r\n", args[0]);
			//debug += ";Define '" + args[0] + "' '" + args[1] + "'\r\n";

			string testString = currentNoComment.Replace("\t", " ");
			string escaped = @"\b" + Regex.Escape(args[0]) + @"\b";
			
			if (Regex.IsMatch(testString, @" \#\b" + Regex.Escape(args[0]) + @"\b"))  //(testString.Contains(" #" + args[0]))
			{
				log1.AppendFormat("\t- Define ignored. (constant define)\r\n");
				return true;
			}
			if (Regex.IsMatch(testString, @"dcb {0,} " + escaped))
			{
				log1.AppendFormat("\t- Define ignored. (data define)\r\n");
				return true;
			}
			if (Regex.IsMatch(testString, @"dcw {0,} " + escaped))
			{
				log1.AppendFormat("\t- Define ignored. (word data define)\r\n");
				return true;
			}
			if (Regex.IsMatch(testString, @"db {0,} " + escaped))
			{
				log1.AppendFormat("\t- Define ignored. (xkas data define)\r\n");
				return true;
			}
			if (Regex.IsMatch(testString, @"dw {0,} " + escaped))
			{
				log1.AppendFormat("\t- Define ignored. (xkas word data define)\r\n");
				return true;
			}
			if (Regex.IsMatch(testString, @"dl {0,} " + escaped))
			{
				log1.AppendFormat("\t- Define ignored. (xkas long data define)\r\n");
				return true;
			}
			if (Regex.IsMatch(testString, @"dd {0,} " + escaped))
			{
				log1.AppendFormat("\t- Define ignored. (xkas dword data define)\r\n");
				return true;
			}
			if (Regex.IsMatch(testString, @", {0,} " + escaped))
			{
				log1.AppendFormat("\t- Define ignored. (data define)\r\n");
				return true;
			}
			if (Regex.Matches(testString, escaped).Count == 1)
			{
				log1.AppendFormat("\t- Define ignored. (unused define)\r\n");
				return true;
			}


			log1.AppendFormat("\t- Define OK.\r\n");
			return false;
		}
		#endregion

		#region Converters
		int RemapNumber(int number, bool sa1)
		{
			int bank = number >> 16;
			int addr = number & 0xFFFF;

			if (bank >= 0x80)
			{
				bank &= 0x7F;
				if (bank >= 0x40)
				{
					bank += 0x40;
				}

				log1.AppendFormat("Bank ${0:X2} changed to ${1:X2}.\r\n", number >> 16, bank);
			}

			if (number >= 0x700000 && number <= 0x7007FF)
			{
				ReportConversion(number, number - 0x700000 + 0x41C000);
				return number - 0x700000 + 0x41C000;
			}

			if (bank == 0x7E)
			{
				if (addr >= 0x7938 && addr < 0x1938 + 128)
				{
					ReportConversion(number, addr - 0x7938 + 0x418A00);
					return addr - 0x7938 + 0x418A00;
				}

				if (addr >= 0x0000 && addr <= 0x00FF)
				{
					ReportConversion(number, 0x003000 | addr);
					return 0x003000 | addr;
				}
				if (addr >= 0x0100 && addr <= 0x1FFF)
				{
					ReportConversion(number, 0x400000 | addr);
					return 0x400000 | addr;
				}
			}
			if (bank == 0x7F)
			{
				switch (addr)
				{
					case 0xAB10: ReportConversion(number, 0x400040); return 0x400040;
					case 0xAB1C: ReportConversion(number, 0x400056); return 0x400056;
					case 0xAB28: ReportConversion(number, 0x400057); return 0x400057;
					case 0xAB34: ReportConversion(number, 0x40006D); return 0x40006D;
					case 0xAB9E: ReportConversion(number, 0x400083); return 0x400083;
					
					case 0x8900+0*12: ReportConversion(number, 0x403e00+0*22); return 0x403e00+0*22;
					case 0x8900+1*12: ReportConversion(number, 0x403e00+1*22); return 0x403e00+1*22;
					case 0x8900+2*12: ReportConversion(number, 0x403e00+2*22); return 0x403e00+2*22;
					case 0x8900+3*12: ReportConversion(number, 0x403e00+3*22); return 0x403e00+3*22;
					case 0x8900+4*12: ReportConversion(number, 0x403e00+4*22); return 0x403e00+4*22;
					case 0x8900+5*12: ReportConversion(number, 0x403e00+5*22); return 0x403e00+5*22;
					case 0x8900+6*12: ReportConversion(number, 0x403e00+6*22); return 0x403e00+6*22;
					case 0x8900+7*12: ReportConversion(number, 0x403e00+7*22); return 0x403e00+7*22;
					case 0x8900+8*12: ReportConversion(number, 0x403e00+8*22); return 0x403e00+8*22;
					case 0x8900+9*12: ReportConversion(number, 0x403e00+9*22); return 0x403e00+9*22;
					case 0x8900+10*12: ReportConversion(number, 0x403e00+10*22); return 0x403e00+10*22;
					case 0x8900+11*12: ReportConversion(number, 0x403e00+11*22); return 0x403e00+11*22;
					
					
					
				}

				if (addr >= 0x9A7B && addr < 0x9A7B + 512)
				{
					ReportConversion(number, number - 0x7F9A7B + 0x418800);
				}
			}
			if (bank == 0x7E || bank == 0x7F)
			{
				if (addr >= 0xC800 && addr <= 0xFFFF)
				{
					ReportConversion(number, 0x400000 | addr);
					return 0x400000 | addr;
				}
				if (sa1)
				{
					CantRemap(number);
					return -1;
				}
			}

			if (addr < 0x0100)
			{
				addr |= 0x3000;
			}
			else if (addr < 0x2000)
			{
				addr |= 0x6000;
			}
			else if (((addr >= 0x2000 && addr <= 0x2200)
				|| (addr >= 0x2400 && addr <= 0x2FFF)
				|| (addr >= 0x3800 && addr <= 0x5FFF)) && sa1)
			{
				CantRemap(number);
				return -1;
			}
			else if ((addr >= 0x3000 && addr <= 0x37FF) || (addr >= 0x6000 && addr <= 0x7FFF))
			{
			}
			else
			{
				return (bank << 16) | addr;
			}

			if (addr >= 0x7938 && addr < 0x7938 + 128)
			{
				CantRemap(number);
				return -1;
				//ReportConversion(number, addr - 0x7938 + 0x418A00);
				//return addr - 0x7938 + 0x418A00;
			}

			int[] array = {
							  0x30AA, 0x309E, 0x30B6, 0x30B6, 0x30C2, 0x30D8, 0x309E, 0x3200, 0x30D8, 0x3216,
							  0x30E4, 0x322C, 0x14C8, 0x3242, 0x14D4, 0x3258, 0x14E0, 0x326E, 0x151C, 0x3284,
							  0x1528, 0x329A, 0x1534, 0x32B0, 0x1540, 0x32C6, 0x154C, 0x32DC, 0x1558, 0x32F2,
							  0x1564, 0x3308, 0x1570, 0x331E, 0x157C, 0x3334, 0x1588, 0x334A, 0x1594, 0x3360,
							  0x15A0, 0x3376, 0x15AC, 0x338C, 0x15EA, 0x33A2, 0x15F6, 0x33B8, 0x1602, 0x33CE,
							  0x160E, 0x33E4, 0x163E, 0x33FA, 0x187B, 0x3410, 0x14EC, 0x74C8, 0x14F8, 0x74DE,
							  0x1504, 0x74F4, 0x1510, 0x750A, 0x15B8, 0x7520, 0x15C4, 0x7536, 0x15D0, 0x754C,
							  0x15DC, 0x7562, 0x161A, 0x7578, 0x1626, 0x758E, 0x1632, 0x75A4, 0x190F, 0x7658,
							  0x1FD6, 0x766E, 0x1FE2, 0x7FD6, 0x164A, 0x75BA, 0x1656, 0x75D0, 0x1662, 0x75EA,
							  0x166E, 0x7600, 0x167A, 0x7616, 0x1686, 0x762C, 0x186C, 0x7642
						  };

			for (int i = 0; i < array.Length; i += 2)
			{
				if (array[i] < 0x2000)
				{
					array[i] |= 0x6000;
				}
				if (SpriteRemap(ref addr, array[i], array[i + 1]))
				{
					ReportConversion(number, (bank << 16) | addr);
					return (bank << 16) + addr;
				}
			}

			ReportConversion(number, (bank << 16) | addr);
			return (bank << 16) | addr;
		}

		bool SpriteRemap(ref int address, int oldAddr, int newAddr)
		{
			for (int i = 0; i < 12; ++i)
			{
				if (address == oldAddr + i)
				{
					address = newAddr + i;
					return true;
				}
			}
			return false;
		}
		#endregion

		bool MultiMatch(string str, params string[] matches)
		{
			foreach (string s in matches)
			{
				if (str.Contains(s))
				{
					return true;
				}
			}
			return false;
		}

		string Reverse(string s)
		{
			char[] arr = s.ToCharArray();
			Array.Reverse(arr);
			return new string(arr);
		}
	}
}
