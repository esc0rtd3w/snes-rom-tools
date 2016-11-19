using System;
using System.Collections.Generic;

using System.Windows.Forms;

namespace BlockMaker
{
	static class Program
	{
		public static bool usingSA1 = false;
		/// <summary>
		/// The main entry point for the application.
		/// </summary>
		[STAThread]


		static void Main(string[] args)
		{
			foreach (string s in args)
			{
				if (s == "-visualStylesOn")
					Application.EnableVisualStyles();
			}
			Application.SetCompatibleTextRenderingDefault(false);
			Application.Run(new Form1());
		}

		static RAMAddress[] RAMAddresses = new RAMAddress[] { 
			new RAMAddress(false, false, false, 0x7E0014, "Frame counter", "This is a value that increases every frame."),
			new RAMAddress(false, false, false, 0x7E0019, "Player powerup", "The current powerup the player has. 0 = small, 1 = big, 2 = cape, 3 = fire."),
			new RAMAddress(true, true, false, 0x7E001A, "Layer 1 X position", "The current horizontal position of the level."),
			new RAMAddress(true, true, false, 0x7E001C, "Layer 1 Y position", "The current vertical position of the level."),
			new RAMAddress(true, true, false, 0x7E001E, "Layer 2 X position", "The current horizontal position of the background/layer 2."),
			new RAMAddress(true, true, false, 0x7E0020, "Layer 2 Y position", "The current vertical position of the background/layer 2."),
			new RAMAddress(true, true, false, 0x7E0022, "Layer 3 X position", "The current horizontal position of whatever is on layer 3."),
			new RAMAddress(true, true, false, 0x7E0024, "Layer 3 Y position", "The current vertical position of whatever is on layer 3."),
			new RAMAddress(false, false, false, 0x7E005D, "Screen count", "The number of screens in the current level."),
			new RAMAddress(false, true, false, 0x7E007B, "Player X speed", "The current horizontal speed of the player."),
			new RAMAddress(false, true, false, 0x7E007D, "Player Y speed", "The current vertical speed of the player."),
			new RAMAddress(true, true, false, 0x7E0094, "Player X position", "The player's current horizontal position."),
			new RAMAddress(true, true, false, 0x7E0096, "Player Y position", "The player's current vertical position."),
			new RAMAddress(false, true, true, 0x7E00AA, "Sprite X speed", "The current sprite's horizontal speed."),
			new RAMAddress(false, true, true, 0x7E00B6, "Sprite Y speed", "The current sprite's vertical speed."),
		};
	}


	public class RAMAddress
	{
		bool is16Bit;
		bool isXIndexed;
		bool isSigned;
		UInt32 address;
		string shortDescription;
		string longDescription;

		public RAMAddress(bool is16Bit, bool isSigned, bool xIndexed, UInt32 address, string shortDescription, string longDescription)
		{
			this.is16Bit = is16Bit;
			this.isSigned = isSigned;
			this.isXIndexed = xIndexed;
			this.address = address;
			this.shortDescription = shortDescription;
			this.longDescription = longDescription;
		}

		public override string ToString()
		{
			return shortDescription + "($" + ((address & 0x7F0000) >> 16) + ":" + (address & 0xFFFF) + ")";
		}
	}

	
}
