
namespace BlockMaker
{
	public class TestPlayerPowerup : CodePiece
	{
		public TestPlayerPowerup()
		{
			isStatement = false;
			enumerations = new string[] { "Small", "Big", "Caped", "Firey" };
			value = 0;
			queryStr = "If the player is...";
			inputStr1 = "Powerup:";
			is16Bit = false;
			inputCount = 1;
			usesConstant = true;
			listString = "If the player has a certain powerup...";
			//comparisonType = ComparisonType.Equal;
		}

		public override string GenerateCode()
		{
			return "LDA $19\nCMP " + Hex(value) + "\n" + branchType + labelName;
		}

		public override string CodeString()
		{
			return "If the player is " + (branchType.ct == ComparisonType.NotEqual ? "not " : "") + enumerations[value].ToLower() + "...";
		}
	}

	public class SetPowerupAnimate : CodePiece
	{
		public SetPowerupAnimate()
		{
			isStatement = true;
			enumerations = new string[] { "Small", "Big", "Caped", "Fiery" };
			value = 0;
			queryStr = "Make the player...";
			inputStr1 = "Powerup:";
			is16Bit = false;
			inputCount = 1;
			usesConstant = true;
			listString = "Give the player a powerup (with animation)";
		}

		public override string GenerateCode()
		{
			string ret = "PHX\nLDA #$" + value.ToString("X2") + "\nASL\nASL\nORA $19\nTAX\nLDA $01C510,x\nBEQ +\nSTA $0DC2\nLDA #$0B\nSTA $1DFC\n+\n";
			switch (value)
			{
				case 0:
					ret += "JSL $00F5B7\nSTZ $19"; break;
				case 1:
					ret += "LDA #$02\nSTA $71\nLDA #$2F\nSTA $1496\nSTA $9D"; break;
				case 2:
					ret += "LDA #$02\nSTA $19\nLDA #$0D\nSTA $1DF9\nLDA #$04\nJSL $02ACE5\nJSL $01C5AE\nINC $9D"; break;
				case 3:
					ret += "LDA #$20\nSTA $149B\nSTA $9D\nLDA #$04\nSTA $71\nDEC\nSTA $19"; break;
				default:
					throw new System.ArgumentOutOfRangeException("Invalid value.");
			}

			return ret + "\nPLX";
		}

		public override string CodeString()
		{
			return "Make the player " + enumerations[value].ToLower() + " (with the animation).";
		}
	}

	public class SetPowerupNoAnimate : CodePiece
	{
		public SetPowerupNoAnimate()
		{
			isStatement = true;
			enumerations = new string[] { "Small", "Big", "Caped", "Fiery" };
			value = 0;
			queryStr = "Make the player...";
			inputStr1 = "Powerup:";
			is16Bit = false;
			inputCount = 1;
			usesConstant = true;
			listString = "Give the player a powerup (without animation)";
		}

		public override string GenerateCode()
		{
			return "LDA " + Hex(value) + "\nSTA $19";
		}

		public override string CodeString()
		{
			return "Make the player " + enumerations[value].ToLower() + " (without the animation).";
		}
	}

	public class TestPlayerX : CodePiece
	{
		public TestPlayerX()
		{
			isStatement = false;
			value = 0;
			queryStr = "If the player's x position is...";
			inputStr1 = "X position:";
			is16Bit = true;
			inputCount = 1;
			usesConstant = true;
			allowNegative = true;
			listString = "If the player's x position is a value...";
		}

		public override string GenerateCode()
		{
			return "REP #$20\nLDA $D1\nCMP " + Hex(value) + "\nSEP #$20\n" + branchType + labelName;
		}

		public override string CodeString()
		{
			return "If the player's x position" + GetCompString(value);
		}
	}

	public class TestPlayerY : CodePiece
	{
		public TestPlayerY()
		{
			isStatement = false;
			value = 0;
			queryStr = "If the player's y position is...";
			inputStr1 = "Y position:";
			is16Bit = true;
			inputCount = 1;
			usesConstant = true;
			allowNegative = true;
			listString = "If the player's y position is a value...";
		}

		public override string GenerateCode()
		{
			return "REP #$20\nLDA $D3\nCMP " + Hex(value) + "\nSEP #$20\n" + branchType + labelName;
		}

		public override string CodeString()
		{
			return "If the player's y position" + GetCompString(value);
		}
	}

	public class SetPlayerX : CodePiece
	{
		public SetPlayerX()
		{
			isStatement = true;
			value = 0;
			queryStr = "Set the player's x position to...";
			inputStr1 = "X position...";
			is16Bit = true;
			inputCount = 1;
			usesConstant = true;
			allowNegative = true;
			listString = "Set the player's x position to a value.";
		}

		public override string GenerateCode()
		{
			if (relative)
				return "REP #$20\nLDA $94\nCLC\nADC " + Hex(value) + "\nSTA $94\n" + "SEP #$20";
			else
				return "REP #$20\nLDA " + Hex(value) + "\nSTA $94\n" + "SEP #$20";
		}

		public override string CodeString()
		{
			return SetString("the player's x position") + ValueToString(value) + ".";
		}
	}

	public class SetPlayerY : CodePiece
	{
		public SetPlayerY()
		{
			isStatement = true;
			value = 0;
			queryStr = "Set the player's y position to...";
			inputStr1 = "Y position...";
			is16Bit = true;
			inputCount = 1;
			usesConstant = true;
			allowNegative = true;
			listString = "Set the player's y position to a value.";
		}

		public override string GenerateCode()
		{
			if (relative)
				return "REP #$20\nLDA $96\nCLC\nADC " + Hex(value) + "\nSTA $96\n" + "SEP #$20";
			else
				return "REP #$20\nLDA " + Hex(value) + "\nSTA $96\n" + "SEP #$20";
		}

		public override string CodeString()
		{
			return "Set the player's y position to" + ValueToString(value) + ".";
		}
	}

	public class TestPlayerDucking : CodePiece
	{
		public TestPlayerDucking()
		{
			isStatement = false;
			value = 0;
			enumerations = trueFalse;
			queryStr = "If the player is ducking";
			inputStr1 = "True/false:";
			is16Bit = false;
			inputCount = 1;
			usesConstant = true;
			listString = "If the player is ducking...";
		}

		public override string GenerateCode()
		{
			if (value == 1)
				branchType.ct = ComparisonType.Equal;
			else
				branchType.ct = ComparisonType.NotEqual;

			return "LDA $73\n" + branchType + labelName;

		}

		public override string CodeString()
		{
			return "If the player is" + (value == 0 ? "" : " not") + " ducking...";
		}

	}

	public class TestPlayerClimbing : CodePiece
	{
		public TestPlayerClimbing()
		{
			isStatement = false;
			value = 0;
			enumerations = trueFalse;
			queryStr = "If the player is climbing";
			inputStr1 = "True/false:";
			is16Bit = false;
			inputCount = 1;
			usesConstant = true;
			listString = "If the player is climbing...";
		}

		public override string GenerateCode()
		{
			if (value == 1)
				branchType.ct = ComparisonType.Equal;
			else
				branchType.ct = ComparisonType.NotEqual;

			return "LDA $74\n" + branchType + labelName;
		}

		public override string CodeString()
		{
			return "If the player is " + (value == 0 ? "" : "not") + "climbing...";
		}
	}

	public class TestPlayerDirection : CodePiece
	{
		public TestPlayerDirection()
		{
			isStatement = false;
			value = 0;
			enumerations = new string[] { "Left", "Right" };
			queryStr = "If the player is facing...";
			inputStr1 = "Left/right:";
			is16Bit = false;
			inputCount = 1;
			usesConstant = true;
			listString = "If the player is facing left or right...";
		}

		public override string GenerateCode()
		{
			if (value == 1)
				branchType.ct = ComparisonType.Equal;
			else
				branchType.ct = ComparisonType.NotEqual;

			return "LDA $76\n" + branchType + labelName;
		}

		public override string CodeString()
		{
			return "If the player is facing " + (value == 0 ? "left" : "right") + "...";
		}
	}

	//public class TestPlayerOnGround : CodePiece
	//{
	//        public TestPlayerOnGround()
	//        {
	//                isStatement = false;
	//                enumerations = trueFalse;
	//                queryStr = "If the player is on the ground...";
	//                inputStr1 = "True/false";
	//                usesConstant = true;
	//                listString = "If the player is on the ground...";
	//        }

	//        public override string GenerateCode()
	//        {
	//                if (value == 1)
	//                        return "LDA $77\nAND #$04\nBNE " + labelName;
	//                else
	//                        return "LDA $77\nAND #$04\nBEQ " + labelName;
	//        }

	//        public override string CodeString()
	//        {
	//                return "If the player is " + (value == 0 ? "" : "not") + "on the ground.";
	//        }
	//}

	public class SetPlayerHideGraphics : CodePiece
	{
		public SetPlayerHideGraphics()
		{
			isStatement = true;
			showEditForm = false;
			listString = "Hide the player's graphics.";
		}

		public override string GenerateCode()
		{
			return "LDA #$FF\nSTA $78";
		}
		public override string CodeString()
		{
			return "Hide the player's graphics.";
		}
	}

	public class TestPlayerXSpeed : CodePiece
	{
		public TestPlayerXSpeed()
		{
			isStatement = false;
			queryStr = "If the player's x speed is...";
			inputStr1 = "X speed:";
			usesConstant = true;
			allowNegative = true;
			listString = "If the player's x speed is a value...";
		}

		public override string GenerateCode()
		{
			return "LDA $7B\nCMP " + Hex(value) + "\n" + branchType + labelName;
		}

		public override string CodeString()
		{
			return "If the player's x speed" + GetCompString(value);
		}
	}

	public class TestPlayerYSpeed : CodePiece
	{
		public TestPlayerYSpeed()
		{
			isStatement = false;
			queryStr = "If the player's y speed is...";
			inputStr1 = "Y speed:";
			usesConstant = true;
			allowNegative = true;
			listString = "If the player's y speed is a value.";
		}

		public override string GenerateCode()
		{
			return "LDA $7D\nCMP " + Hex(value) + "\n" + branchType + labelName;
		}

		public override string CodeString()
		{
			return "If the player's y speed" + GetCompString(value);
		}
	}

	public class SetPlayerXSpeed : CodePiece
	{
		public SetPlayerXSpeed()
		{
			isStatement = true;
			queryStr = "Set the player's x speed to...";
			inputStr1 = "X speed:";
			usesConstant = true;
			allowNegative = true;
			listString = "Set the player's x speed to a value.";
		}

		public override string GenerateCode()
		{
			if (relative)
				return "LDA $7B\nCLC\nADC " + Hex(value) + "\nSTA $7B";
			else
				return "LDA " + Hex(value) + "\nSTA $7B";
		}

		public override string CodeString()
		{
			return "Set the player's x speed to " + ValueToString(value) + ".";
		}
	}

	public class SetPlayerYSpeed : CodePiece
	{
		public SetPlayerYSpeed()
		{
			isStatement = true;
			queryStr = "Set the player's y speed to...";
			inputStr1 = "Y speed:";
			usesConstant = true;
			allowNegative = true;
			listString = "Set the player's y speed to a value.";
		}

		public override string GenerateCode()
		{
			if (relative)
				return "LDA $7D\nCLC\nADC " + Hex(value) + "\nSTA $7D";
			else
				return "LDA " + Hex(value) + "\nSTA $7D";
		}

		public override string CodeString()
		{
			return "Set the player's y speed to " + ValueToString(value) + ".";
		}
	}

	public class TeleportPlayer : CodePiece
	{
		public TeleportPlayer()
		{
			isStatement = true;
			showEditForm = false;
			listString = "Teleport the player via the current screen exit.";
		}

		public override string GenerateCode()
		{
			return "LDA #$06\nSTA $71\nSTZ $88\nSTZ $89";
		}

		public override string CodeString()
		{
			return "Teleport the player via screen exit.";
		}
	}

	public class TeleportPlayerAbsolute : CodePiece
	{
		public TeleportPlayerAbsolute()
		{
			isStatement = true;
			is16Bit = true;
			queryStr = "Teleport the player to a level...";
			inputStr1 = "Level:";
			listString = "Teleport the player to a level";
			usingHex = true;
		}

		public override string GenerateCode()
		{
			return "PHX\n" +
			       "LDX $95\n" + 
			       "PEA $" + value.ToString("X4") + "\n" +
			       "PLA\n" +
			       "STA $19B8,x\n" +
			       "PLA\n" +
			       "ORA #$04\n" +
			       "STA $19D8,x\n" +
			       "LDA #$06\n" +
			       "STA $71\n" +
			       "STZ $89\n" +
			       "STZ $88\n" + 
			       "PLX";
			//return "PHX\nLDA $5B\nAND #$03\nREP #$20\nBEQ +\nLDA $94\nBRA ++\n+\nLDA $96\n++\nLSR #8\nSEP #$20\nTAX\nREP #$20\nLDA " + Hex(value) + "\nSEP #$20\nSTA $19B8,x\nREP #$20\nLSR #8\nSEP #$20\nSTA $19D8,x\nPLX";
		}

		public override string CodeString()
		{
			return "Teleport the player to level " + ValueToString(value) + ".";
		}
	}

	public class HurtPlayer : CodePiece
	{
		public HurtPlayer()
		{
			isStatement = true;
			showEditForm = false;
			listString = "Hurt the player";
		}

		public override string GenerateCode()
		{
			return "JSL $00F5B7";
		}

		public override string CodeString()
		{
			return "Hurt the player.";
		}
	}

	public class KillPlayer : CodePiece
	{

		public KillPlayer()
		{
			isStatement = true;
			showEditForm = false;
			listString = "Kill the player";
		}

		public override string GenerateCode()
		{
			return "JSL $00F606";
		}

		public override string CodeString()
		{
			return "Kill the player.";
		}
	}

	public class TestPlayer1 : CodePiece
	{
		public TestPlayer1()
		{
			isStatement = false;
			showEditForm = false;
			listString = "If the current player is player 1...";
			branchType.ct = ComparisonType.NotEqual;
		}

		public override string GenerateCode()
		{
			return "LDA $0DB3\n" + branchType + labelName;
		}

		public override string CodeString()
		{
			return "If Mario (player 1) is the current player...";
		}
	}

	public class TestPlayer2 : CodePiece
	{
		public TestPlayer2()
		{
			isStatement = false;
			showEditForm = false;
			listString = "If the current player is player 2...";
		}

		public override string GenerateCode()
		{
			return "LDA $0DB3\nBNE " + labelName;
		}

		public override string CodeString()
		{
			return "If Luigi (player 2) is the current player...";
		}
	}

	public class Test1PlayerGame : CodePiece
	{
		public Test1PlayerGame()
		{
			isStatement = false;
			showEditForm = false;
			listString = "If the current game is 1 player...";
		}

		public override string GenerateCode()
		{
			return "LDA $0DB2\nBNE " + labelName;
		}

		public override string CodeString()
		{
			return "If the current game is 1 player...";
		}
	}

	public class Test2PlayerGame : CodePiece
	{
		public Test2PlayerGame()
		{
			isStatement = false;
			showEditForm = false;
			listString = "If the current game is 2 player...";
			branchType.ct = ComparisonType.NotEqual;
		}

		public override string GenerateCode()
		{
			return "LDA $0DB2\n" + branchType + labelName;
		}

		public override string CodeString()
		{
			return "If the current game is 2 player...";
		}
	}

	public class StunPlayer : CodePiece
	{
		public StunPlayer()
		{
			isStatement = true;
			queryStr = "Stun the player.";
			inputStr1 = "Time to stun for:";
			usesConstant = true;
			listString = "Stun the player";
		}

		public override string GenerateCode()
		{
			if (relative)
				return "LDA $18BD\nCLC\nADC " + Hex(value) + "\nSTA $18BD";
			else
				return "LDA " + Hex(value) + "\nSTA $18BD";
		}

		public override string CodeString()
		{
			if (relative)
				return "Stun the player for " + ValueToString(value) + " more frame" + (value != 1 ? "s" : "" ) + ".";
			else
				return "Stun the player for " + ValueToString(value) + " frames.";
		}
	}

	public class TestPlayerSilverCoin : CodePiece
	{
		public TestPlayerSilverCoin()
		{
			isStatement = false;
			queryStr = "If the player has X silver coins...";
			inputStr1 = "Silver coins:";
			listString = "If the player's silver coin count is a value.";
		}

		public override string GenerateCode()
		{
			return "LDA $18DD\nCMP " + Hex(value) + "\n" + branchType + labelName;
		}

		public override string CodeString()
		{
			return "If the player's silver coin count" + GetCompString(value);
		}
	}

	public class SetPlayerSilverCoin : CodePiece
	{
		public SetPlayerSilverCoin()
		{
			isStatement = true;
			queryStr = "Set the player's silver coin count to...";
			inputStr1 = "Silver coins:";
			listString = "Set the player's silver coin count to a value.";
		}

		public override string GenerateCode()
		{
			if (relative)
				return "LDA $18DD\nCLC\nADC " + Hex(value) + "\nSTA $18DD";
			else
				return "LDA " + Hex(value) + "\nSTA $18DD";

		}

		public override string CodeString()
		{
			return SetString("the player's silver coin count") + ValueToString(value) + ".";
		}
	}

	public class TestPlayerSpinJumping : CodePiece
	{
		public TestPlayerSpinJumping()
		{
			isStatement = false;
			value = 0;
			enumerations = trueFalse;
			queryStr = "If the player is spin jumping";
			inputStr1 = "True/false:";
			is16Bit = false;
			inputCount = 1;
			usesConstant = true;
			listString = "If the player is spin jumping...";
		}

		public override string GenerateCode()
		{
			if (value == 1)
				branchType.ct = ComparisonType.Equal;
			else
				branchType.ct = ComparisonType.NotEqual;

			return "LDA $140D\n" + branchType + labelName;
		}

		public override string CodeString()
		{
			return "If the player is" + (value == 0 ? "" : " not") + " spin jumping...";
		}

	}


	public class TestPlayerRidingYoshi : CodePiece
	{
		public TestPlayerRidingYoshi()
		{
			isStatement = false;
			value = 0;
			enumerations = trueFalse;
			queryStr = "If the player is riding Yoshi";
			inputStr1 = "True/false:";
			is16Bit = false;
			inputCount = 1;
			usesConstant = true;
			listString = "If the player is riding Yoshi...";
		}

		public override string GenerateCode()
		{
			if (value == 1)
				branchType.ct = ComparisonType.Equal;
			else
				branchType.ct = ComparisonType.NotEqual;

			return "LDA $187A\n" + branchType + labelName;
		}

		public override string CodeString()
		{
			return "If the player is" + (value == 0 ? "" : " not") + " riding Yoshi...";
		}

	}

	public class SetPlayerInvincibility : CodePiece
	{
		public SetPlayerInvincibility()
		{
			isStatement = true;
			queryStr = "Set the invincibility timer to...";
			inputStr1 = "Invincibility timer:";
			listString = "Set the invincibility timer to a value.";
		}

		public override string GenerateCode()
		{
			if (relative)
				return "LDA $1490\nCLC\nADC " + Hex(value) + "\nSTA $1490";
			else
				return "LDA " + Hex(value) + "\nSTA $1490";

		}

		public override string CodeString()
		{
			return SetString("the invincibility timer") + ValueToString(value) + ".";
		}
	}

	public class TestPlayerInvincibility : CodePiece
	{
		public TestPlayerInvincibility()
		{
			isStatement = false;
			value = 0;
			enumerations = trueFalse;
			queryStr = "If the player is invincible";
			inputStr1 = "True/false:";
			is16Bit = false;
			inputCount = 1;
			usesConstant = true;
			listString = "If the player is invincible...";
		}

		public override string GenerateCode()
		{
			if (value == 1)
				branchType.ct = ComparisonType.Equal;
			else
				branchType.ct = ComparisonType.NotEqual;

			return "LDA $1490\nBNE " + labelName;
		}

		public override string CodeString()
		{
			return "If the player is" + (value == 0 ? "" : " not") + " invincible...";
		}
	}

	/////////////////////////////////

	public class TestSpriteXSpeed : CodePiece
	{
		public TestSpriteXSpeed()
		{
			isStatement = false;
			queryStr = "If this sprite's x speed is...";
			inputStr1 = "X speed:";
			allowNegative = true;
			listString = "If the sprite's x speed is a value.";
		}

		public override string GenerateCode()
		{
			return "LDA $B6,x\nCMP " + Hex(value) + "\n" + branchType + labelName;
		}

		public override string CodeString()
		{
			return "If the sprite's x speed" + GetCompString(value);
		}
	}

	public class TestSpriteYSpeed : CodePiece
	{
		public TestSpriteYSpeed()
		{
			isStatement = false;
			queryStr = "If this sprite's y speed is...";
			inputStr1 = "Y speed:";
			allowNegative = true;
			listString = "If the sprite's y speed is a value.";
		}

		public override string GenerateCode()
		{
			return "LDA $AA,x\nCMP " + Hex(value) + "\n" + branchType + labelName;
		}

		public override string CodeString()
		{
			return "If the player's y speed" + GetCompString(value);
		}
	}

	public class SetSpriteXSpeed : CodePiece
	{
		public SetSpriteXSpeed()
		{
			isStatement = true;
			queryStr = "Set the sprite's x speed to...";
			inputStr1 = "X speed:";
			allowNegative = true;
			listString = "Set the sprite's x speed to a value.";
		}

		public override string GenerateCode()
		{
			if (relative)
				return "LDA $B6,x\nCLC\nADC " + Hex(value) + "\nSTA $B6,x";
			else
				return "LDA " + Hex(value) + "\nSTA $B6,x";
		}

		public override string CodeString()
		{
			return SetString("the sprite's x position") + ValueToString(value) + ".";
		}
	}

	public class SetSpriteYSpeed : CodePiece
	{
		public SetSpriteYSpeed()
		{
			isStatement = true;
			queryStr = "Set the sprite's y speed to...";
			inputStr1 = "Y speed:";
			allowNegative = true;
			listString = "Set the sprite's y speed to a value.";
		}

		public override string GenerateCode()
		{
			if (relative)
				return "LDA $AA,x\nCLC\nADC " + Hex(value) + "\nSTA $AA,x";
			else
				return "LDA " + Hex(value) + "\nSTA $AA,x";
		}

		public override string CodeString()
		{
			return SetString("the sprite's y position") + ValueToString(value) + ".";
		}
	}

	public class TestSpriteXPos : CodePiece
	{
		public TestSpriteXPos()
		{
			isStatement = false;
			queryStr = "If the sprite's x position is...";
			inputStr1 = "X position:";
			allowNegative = true;
			is16Bit = true;
			listString = "If the sprite's x position is a value...";
		}

		public override string GenerateCode()
		{
			return "LDA $14E0,x\nXBA\nLDA $E4,x\nREP #$20\nCMP " + Hex(value) + "\nSEP #$20\n" + branchType + labelName;
		}

		public override string CodeString()
		{
			return "If the sprite's x speed" + GetCompString(value);
		}
	}

	public class TestSpriteYPos : CodePiece
	{
		public TestSpriteYPos()
		{
			isStatement = false;
			queryStr = "If the sprite's y position is...";
			inputStr1 = "Y position:";
			allowNegative = true;
			is16Bit = true;
			listString = "If the sprite's y position is a value...";
		}

		public override string GenerateCode()
		{
			return "LDA $14D4,x\nXBA\nLDA $D8,x\nREP #$20\nCMP " + Hex(value) + "\nSEP #$20\n" + branchType + labelName;
		}

		public override string CodeString()
		{
			return "If the sprite's y speed" + GetCompString(value);
		}
	}

	public class SetSpriteXPos : CodePiece
	{
		public SetSpriteXPos()
		{
			isStatement = true;
			queryStr = "Set the sprite's x position to...";
			inputStr1 = "X position:";
			allowNegative = true;
			is16Bit = true;
			listString = "Set the sprite's x position to a value";
		}

		public override string GenerateCode()
		{
			if (relative)
				return "LDA $14E0,x\nXBA\nLDA $E4,x\nREP #$20\nCLC\nADC " + Hex(value) + "\nSEP #$20\nSTA $E4,x\nXBA\nSTA $14E0,x";
			else
				return "REP #$20\nLDA " + Hex(value) + "\nSEP #$20\nSTA $E4,x\nXBA\nSTA $14E0,x";
		}

		public override string CodeString()
		{
			return SetString("the sprite's x position") + ValueToString(value) + ".";
		}
	}

	public class SetSpriteYPos : CodePiece
	{
		public SetSpriteYPos()
		{
			isStatement = true;
			queryStr = "Set the sprite's y position to...";
			inputStr1 = "Y position:";
			allowNegative = true;
			is16Bit = true;
			listString = "Set the sprite's y position to a value.";
		}

		public override string GenerateCode()
		{
			if (relative)
				return "LDA $14D4,x\nXBA\nLDA $D8,x\nREP #$20\nCLC\nADC " + Hex(value) + "\nSEP #$20\nSTA $D8,x\nXBA\nSTA $14D4,x";
			else
				return "REP #$20\nLDA " + Hex(value) + "\nSEP #$20\nSTA $D8,x\nXBA\nSTA $14D4,x";
		}

		public override string CodeString()
		{
			return SetString("the sprite's y position") + ValueToString(value) + ".";
		}
	}

	public class KillSprite : CodePiece
	{

		string[] enum2 = new string[] { "Kill the sprite and make it fall off-screen.",
							"Kill the sprite by smushing it.",
							"Kill the sprite as if spin-jumping it.",
							"Kill the sprite as if by lava.",
							"Kill the sprite by turning it into a coin."};
		public KillSprite()
		{
			isStatement = true;
			queryStr = "Kill the sprite by...";
			inputStr1 = "Method:";
			listString = "Kill the sprite.";
			enumerations = new string[] {
			"Fall off screen",
			"Smushed",
			"Spin-jumped",
			"Sinking in lava",
			"Turned into a coin"};
		}



		public override string GenerateCode()
		{
			switch (value)
			{
				case 0:	// Fall off screen.
					return "LDA #$02\nSTA $14C8,x\nLDA #$D0\nSTA $AA,x";
				case 1:	// Smushed
					return "LDA #$03\nSTA $14C8,x\nLDA #$20\nSTA $1540,x\nSTZ $B6,x\nSTZ $AA,x";
				case 2:	// Spin-jumped
					return "LDA #$04\nSTA $14C8,X\nLDA #$1F\nSTA $1540,X\nJSL $07FC3B\nLDA #$08\nSTA $1DF9";
				case 3:	// Sinking in lava
					return "LDA #$05\nSTA $14C8,X\nLDA #$40\nSTA $1558,x";
				case 4: // Turned into a coin
					return "LDA $1686,x\nAND #$20\nBNE +\nLDA #$10\nSTA $1540,x\nLDA #$06\nSTA $14C8,x\n+";
				default:
					return null;
			}
		}

		public override string CodeString()
		{
			return enum2[value];
		}
	}

	public class TestSpriteType : CodePiece
	{
		public TestSpriteType()
		{
			isStatement = false;
			queryStr = "If the sprite's number is...";
			inputStr1 = "Sprite number:";
			listString = "If the sprite's number is a value...";
		}

		public override string GenerateCode()
		{
			return "LDA $9E,x\n" + "CMP " + Hex(value) + "\n" + branchType + labelName;
		}

		public override string CodeString()
		{
			return "If the sprite's type" + GetCompString(value);
		}
	}

	public class TestSpriteAlive : CodePiece
	{
		public TestSpriteAlive()
		{
			isStatement = false;
			queryStr = "If the sprite is alive...";
			inputStr1 = "True/false";
			listString = "If the sprite is alive...";
			enumerations = CodePiece.trueFalse;
		}

		public override string GenerateCode()
		{
			if (value == 0)	// true
				return "LDA $14C8,x\nCMP #$08\nBCC " + labelName;
			else		// false
				return "LDA $14C8,x\nCMP #$08\nBCS " + labelName;

		}

		public override string CodeString()
		{
			return "If the sprite is " + (value == 0 ? "" : "not") + " alive...";
		}
	}

	public class TestSpriteToolType : CodePiece
	{
		public TestSpriteToolType()
		{
			isStatement = false;
			queryStr = "If the custom sprite's number is...";
			inputStr1 = "Sprite number:";
			listString = "If the Sprite Tool custom sprite's number is a value...";
		}

		public override string GenerateCode()
		{
			return "LDA $7FAB10,x\nAND #$04\n" + branchType.ToUnString() + "\nLDA $7FAB9E,x\nCMP " + Hex(value) + "\n" + branchType;
		}

		public override string CodeString()
		{
			return "If the Sprite Tool's custom sprite's type" + GetCompString(value);
		}
	}

	public class TestTesseraType : CodePiece
	{
		public TestTesseraType()
		{
			isStatement = false;
			queryStr = "If the custom sprite's number is...";
			inputStr1 = "Sprite number:";
			listString = "If the Tessera custom sprite's number is a value...";
		}

		public override string GenerateCode()
		{
			return "LDA $7FAB10,x\nAND #$80\n" + branchType.ToUnString() + "\nLDA $7FAB9E,x\nCMP " + Hex(value) + "\n" + branchType;
		}

		public override string CodeString()
		{
			return "If the Tessera's custom sprite's type" + GetCompString(value);
		}
	}

	public class SpriteOnGround : CodePiece
	{
		public SpriteOnGround()
		{
			isStatement = false;
			enumerations = trueFalse;
			queryStr = "If the sprite is on the ground...";
			inputStr1 = "True/false";
			listString = "If the sprite is on the ground...";
		}

		public override string GenerateCode()
		{
			return "LDA $1588,x\nAND #$04\n" + branchType.ToUnString();
		}

		public override string CodeString()
		{
			return "If the sprite is " + (value == 0 ? "" : "not") + "on the ground.";
		}
	}

	////////////////////////////////

	public class TestPlayerCoinCount : CodePiece
	{
		public TestPlayerCoinCount()
		{
			isStatement = false;
			queryStr = "If the player's coin count is...";
			inputStr1 = "Coins:";
			listString = "If the player's coin count is a value...";
		}

		public override string GenerateCode()
		{
			return "LDA $0DBF\nCMP " + Hex(value) + "\n" + branchType + labelName;
		}

		public override string CodeString()
		{
			return "If the player's coin count" + GetCompString(value);
		}

	}

	public class SetPlayerCoinCount : CodePiece
	{
		public SetPlayerCoinCount()
		{
			isStatement = true;
			queryStr = "Set the player's coin count to...";
			inputStr1 = "Coins:";
			listString = "Set the player's coin count to a value.";
		}

		public override string GenerateCode()
		{
			if (relative)
				return "LDA $0DBF\nCLC\nADC " + Hex(value) + "\nSTA $0DBF";
			else
				return "LDA " + Hex(value) + "\nSTA $0DBF";
		}

		public override string CodeString()
		{
			return SetString("the player's coin count") + ValueToString(value) + ".";
		}
	}

	public class TestPlayerDragonCount : CodePiece
	{
		public TestPlayerDragonCount()
		{
			isStatement = false;
			queryStr = "If the player's coin count is...";
			inputStr1 = "Coins:";
			listString = "If the player's Dragon Coin count is a value.";
		}

		public override string GenerateCode()
		{
			return "LDA $1420\nCMP " + Hex(value) + "\n" + branchType;
		}

		public override string CodeString()
		{
			return "If the player's dragon coin count" + GetCompString(value);
		}
	}

	public class TestPlayerLifeCount : CodePiece
	{
		public TestPlayerLifeCount()
		{
			isStatement = false;
			queryStr = "If the player's life count is...\nNote that this is the number of lives the player has left, not the number of lives the player has total.";
			inputStr1 = "Lives:";
			listString = "If the player's life count a value.";
		}

		public override string GenerateCode()
		{
			return "LDA $1420\nCMP " + Hex(value) + "\n" + branchType;
		}

		public override string CodeString()
		{
			return "If the player's life count" + GetCompString(value);
		}
	}

	public class SetPlayerLifeCount : CodePiece
	{
		public SetPlayerLifeCount()
		{
			isStatement = true;
			queryStr = "Set the player's life count to...\nNote that, if not relative, this is the number of lives the player has left, not the number of lives the player has total.";
			inputStr1 = "Lives:";
			listString = "Set the player's life count to a value.";
		}

		public override string GenerateCode()
		{
			if (relative)
				return "LDA " + Hex(value) + "\nSTA $18E4";
			else
				return "LDA " + Hex(value) + "\nSTA $0DBE";

		}

		public override string CodeString()
		{
			return SetString("the player's life count") + ValueToString(value) + ".";
		}
	}

	//////////////////////////////////////////////////

	public class TestWaterLevel : CodePiece
	{
		public TestWaterLevel()
		{
			isStatement = false;
			enumerations = trueFalse;
			queryStr = "If the level is a water level...";
			inputStr1 = "True/false";
			listString = "If the level is a water level...";
		}

		public override string GenerateCode()
		{
			if (value == 1)
				branchType.ct = ComparisonType.Equal;
			else
				branchType.ct = ComparisonType.NotEqual;

			return "LDA $85\n" + branchType + labelName;
		}

		public override string CodeString()
		{
			return "If the current level is " + (value == 0 ? "" : "not") + " a water level.";
		}
	}

	public class TestSlipperyLevel : CodePiece
	{
		public TestSlipperyLevel()
		{
			isStatement = false;
			enumerations = trueFalse;
			queryStr = "If the level is a slippery level...";
			inputStr1 = "True/false";
			listString = queryStr;
		}

		public override string GenerateCode()
		{
			if (value == 1)
				branchType.ct = ComparisonType.Equal;
			else
				branchType.ct = ComparisonType.NotEqual;

			return "LDA $86\n" + branchType + labelName;
		}

		public override string CodeString()
		{
			return "If the current level is " + (value == 0 ? "" : "not") + " a slippery level.";
		}
	}

	public class SetWaterLevel : CodePiece
	{
		public SetWaterLevel()
		{
			isStatement = true;
			showEditForm = false;
			listString = "Make the level a water level";
		}

		public override string GenerateCode()
		{
			return "LDA #$01\nSTA $85";
		}

		public override string CodeString()
		{
			return "Make the current level a water level.";
		}
	}

	public class SetSlipperyLevel : CodePiece
	{
		public SetSlipperyLevel()
		{
			isStatement = true;
			showEditForm = false;
			listString = "Make the level slippery";
		}

		public override string GenerateCode()
		{
			return "LDA #$01\nSTA $86";
		}

		public override string CodeString()
		{
			return "Make the current level a slippery level.";
		}
	}

	public class SetNonWaterLevel : CodePiece
	{
		public SetNonWaterLevel()
		{
			isStatement = true;
			showEditForm = false;
			listString = "Make the level non-watery";
		}

		public override string GenerateCode()
		{
			return "STZ $85";
		}

		public override string CodeString()
		{
			return "Make the current level a non-water level.";
		}
	}

	public class SetNonSlipperyLevel : CodePiece
	{
		public SetNonSlipperyLevel()
		{
			isStatement = true;
			showEditForm = false;
			listString = "Make the level non-slippery";
		}

		public override string GenerateCode()
		{
			return "STZ $86";
		}

		public override string CodeString()
		{
			return "Make the current level a non-slippery level.";
		}
	}

	public class TestLevelNumber : CodePiece
	{
		public TestLevelNumber()
		{
			isStatement = false;
			queryStr = "If the current level number is...";
			inputStr1 = "Level number:";
			is16Bit = true;
			listString = "If the current level is a value...";
			usingHex = true;
		}

		public override string GenerateCode()
		{
			return "REP #$20\nLDA $010B\nCMP " + Hex(value) + "\nSEP #$20\n" + branchType + labelName;
		}

		public override string CodeString()
		{
			return "If the current level" + GetCompString(value);
		}
	}

	public class TestItemBoxItem : CodePiece
	{
		public TestItemBoxItem()
		{
			enumerations = new string[] { "Nothing", "Mushroom", "Fire flower", "Star", "Feather" };
			isStatement = false;
			queryStr = "If the item in the item box is...";
			inputStr1 = "Item:";
			listString = "If the player has a certain item in their item box...";
		}

		public override string GenerateCode()
		{
			return "LDA $0DC2 \nCMP " + Hex(value) + "\n" + branchType + labelName;
		}

		public override string CodeString()
		{
			return "If the player has " + (value != 0 ? " " : "a ") + enumerations[value].ToLower() + "in their item box...";
		}
	}

	public class SetItemBox : CodePiece
	{
		public SetItemBox()
		{
			enumerations = new string[] { "Nothing", "Mushroom", "Fire flower", "Star", "Feather" };
			isStatement = true;
			queryStr = "Set the item in the item box to...";
			inputStr1 = "Item:";
			listString = "Set the item in the item box";
		}

		public override string GenerateCode()
		{
			return "LDA " + Hex(value) + "\nSTA $0DC2";
		}

		public override string CodeString()
		{
			return "Put " + (value == 0 ? "" : "a ") + enumerations[value].ToLower() + " in the player's item box...";
		}
	}

	public class TestBluePow : CodePiece
	{
		public TestBluePow()
		{
			isStatement = false;
			queryStr = "If the blue p-switch timer value is...";
			inputStr1 = "Timer value:";
			listString = "If the blue p-switch timer is a value...";
		}

		public override string GenerateCode()
		{
			return "LDA $14AD\nCMP " + Hex(value) + "\n" + branchType + labelName;
		}

		public override string CodeString()
		{
			return "If blue p-switch timer " + GetCompString(value);
		}
	}

	public class TestSilverPow : CodePiece
	{
		public TestSilverPow()
		{
			isStatement = false;
			queryStr = "If the silver p-switch timer value is...";
			inputStr1 = "Timer value:";
			listString = "If the silver p-switch timer is a value...";
		}

		public override string GenerateCode()
		{
			return "LDA $14AE\nCMP " + Hex(value) + "\n" + branchType + labelName;
		}

		public override string CodeString()
		{
			return "If silver p-switch timer" + GetCompString(value);
		}
	}

	public class SetBluePow : CodePiece
	{
		public SetBluePow()
		{
			isStatement = true;
			queryStr = "Set the blue p-switch timer value to...";
			inputStr1 = "Timer value:";
			listString = "Set the blue p-switch timer to a value";
		}

		public override string GenerateCode()
		{
			if (relative)
				return "LDA $14AD\nCLC\nADC " + Hex(value) + "\nSTA $14AD";
			else
				return "LDA " + Hex(value) + "\nSTA $14AD";
		}

		public override string CodeString()
		{
			return SetString("the blue p-switch timer") + ValueToString(value) + ".";
		}
	}

	public class SetSilverPow : CodePiece
	{
		public SetSilverPow()
		{
			isStatement = true;
			queryStr = "Set the silver p-switch timer value to...";
			inputStr1 = "Timer value:";
			listString = "Set the silver p-switch timer to a value";
		}

		public override string GenerateCode()
		{
			if (relative)
				return "LDA $14AE\nCLC\nADC " + Hex(value) + "\nSTA $14AE";
			else
				return "LDA " + Hex(value) + "\nSTA $14AE";
		}

		public override string CodeString()
		{
			return SetString("the silver p-switch timer") + ValueToString(value) + ".";
		}
	}

	public class TestSwitchON : CodePiece
	{
		public TestSwitchON()
		{
			isStatement = false;
			showEditForm = false;
			listString = "If the ON/OFF switch is ON...";
		}

		public override string GenerateCode()
		{
			return "LDA $14AF\nBNE " + labelName;
		}

		public override string CodeString()
		{
			return "If the ON/OFF switch is ON...";
		}
	}

	public class TestSwitchOFF : CodePiece
	{
		public TestSwitchOFF()
		{
			isStatement = false;
			showEditForm = false;
			listString = "If the ON/OFF switch is OFF...";
			branchType.ct = ComparisonType.NotEqual;
		}

		public override string GenerateCode()
		{
			return "LDA $14AF\n" + branchType + labelName;
		}

		public override string CodeString()
		{
			return "If the ON/OFF switch is OFF...";
		}
	}

	public class SetSwitchON : CodePiece
	{

		public SetSwitchON()
		{
			isStatement = true;
			showEditForm = false;
			listString = "Turn the ON/OFF switch ON";
		}

		public override string GenerateCode()
		{
			return "STZ $14AF" + labelName;
		}

		public override string CodeString()
		{
			return "Turn the ON/OFF switch ON...";
		}
	}

	public class SetSwitchOFF : CodePiece
	{

		public SetSwitchOFF()
		{
			isStatement = true;
			showEditForm = false;
			listString = "Turn the ON/OFF switch OFF.";
		}

		public override string GenerateCode()
		{
			return "LDA #$01\nSTA $14AF";
		}

		public override string CodeString()
		{
			return "Turn the ON/OFF switch OFF...";
		}
	}

	public class ShakeGround : CodePiece
	{
		public ShakeGround()
		{
			isStatement = true;
			queryStr = "Shake the ground...";
			inputStr1 = "Duration:";
			listString = "Shake the ground.";
		}

		public override string GenerateCode()
		{
			if (relative)
				return "LDA $1887\nCLC\nADC " + Hex(value) + "\nSTA $1887";
			else
				return "LDA " + Hex(value) + "\nSTA $1887";
		}

		public override string CodeString()
		{
			if (relative)
				return "Shake the ground for " + ValueToString(value) + " more frames.";
			else
				return "Shake the ground for " + ValueToString(value) + " frames.";
		}
	}

	///////////////////////////////////

	public class TestButtonDown : CodePiece
	{
		static int[] conv = { 0x80, 0x40, 0x20, 0x10, 0x80, 0x40, 0x20, 0x10, 0x08, 0x04, 0x02, 0x01 };
		public TestButtonDown()
		{
			enumerations = new string[] { "A", "X", "L", "R", "A or B", "X or Y", "Select", "Start", "Up", "Down", "Left", "Right" };
			isStatement = false;
			queryStr = "If a button is down...";
			inputStr1 = "Button:";
			listString = "If the player is pressing a button...";
		}

		public override string GenerateCode()
		{
			if (value < 4)
				return "LDA $17\nAND " + Hex(conv[value]) + "\n" + branchType.ToUnString() + labelName;
			else
				return "LDA $15\nAND " + Hex(conv[value]) + "\n" + branchType.ToUnString() + labelName;
		}

		public override string CodeString()
		{
			return "If the player is holding the " + enumerations[value] + " button down...";
		}
	}

	public class TestButtonClicked : CodePiece
	{
		static int[] conv = { 0x80, 0x40, 0x20, 0x10, 0x80, 0x40, 0x20, 0x10, 0x08, 0x04, 0x02, 0x01 };
		public TestButtonClicked()
		{
			enumerations = new string[] { "A", "X", "L", "R", "A or B", "X or Y", "Select", "Start", "Up", "Down", "Left", "Right" };
			isStatement = false;
			queryStr = "If a button was \"clicked\" on this frame...";
			inputStr1 = "Button:";
			listString = "If the player just pressed a button...";
		}

		public override string GenerateCode()
		{
			if (value < 4)
				return "LDA $18\nAND " + Hex(conv[value]) + "\n" + branchType.ToUnString() + labelName;
			else
				return "LDA $16\nAND " + Hex(conv[value]) + "\n" + branchType.ToUnString() + labelName;
		}

		public override string CodeString()
		{
			return "If the player has pressed the " + enumerations[value] + " button...";
		}
	}

	public class DisableButtonP1 : CodePiece
	{
		static int[] conv = { 0x80, 0x40, 0x20, 0x10, 0x80, 0x40, 0x20, 0x10, 0x08, 0x04, 0x02, 0x01 };
		public DisableButtonP1()
		{
			enumerations = new string[] { "A", "X", "L", "R", "A or B", "X or Y", "Select", "Start", "Up", "Down", "Left", "Right" };
			isStatement = true;
			queryStr = "Disable player 1's button...";
			inputStr1 = "Button:";
			listString = "Disable a button on P1's controller";
		}

		public override string GenerateCode()
		{
			if (value < 4)
				return "LDA " + Hex(conv[value]) + "\n" + "ORA $0DAC\nSTA $0DAA";
			else
				return "LDA " + Hex(conv[value]) + "\n" + "ORA $0DAA\nSTA $0DAA";
		}

		public override string CodeString()
		{
			return "Disable player 1's " + enumerations[value] + " button...";
		}
	}

	public class DisableButtonP2 : CodePiece
	{
		static int[] conv = { 0x80, 0x40, 0x20, 0x10, 0x80, 0x40, 0x20, 0x10, 0x08, 0x04, 0x02, 0x01 };
		public DisableButtonP2()
		{
			enumerations = new string[] { "A", "X", "L", "R", "A or B", "X or Y", "Select", "Start", "Up", "Down", "Left", "Right" };
			isStatement = true;
			queryStr = "Disable player 2's button...";
			inputStr1 = "Button:";
			listString = "Disable a button on P2's controller";
		}

		public override string GenerateCode()
		{
			if (value < 4)
				return "LDA " + Hex(conv[value]) + "\n" + "ORA $0DAD\nSTA $0DAA";
			else
				return "LDA " + Hex(conv[value]) + "\n" + "ORA $0DAB\nSTA $0DAA";
		}

		public override string CodeString()
		{
			return "Disable player 2's " + enumerations[value] + " button...";
		}
	}

	public class SetSolid : CodePiece
	{
		public SetSolid()
		{
			isStatement = true;
			showEditForm = false;
			listString = "Make this block solid";
		}

		public override string GenerateCode()
		{
			return "LDA #$30\nSTA $1693\nLDY #$01";
		}

		public override string CodeString()
		{
			return "Make this block solid.";
		}
	}

	public class SetNotSolid : CodePiece
	{
		public SetNotSolid()
		{
			isStatement = true;
			showEditForm = false;
			listString = "Make this block passable";
		}

		public override string GenerateCode()
		{
			return "LDA #$25\nSTA $1693\nLDY #$00";
		}

		public override string CodeString()
		{
			return "Make this block passable.";
		}
	}

	public class ActLikeBlock : CodePiece
	{
		public ActLikeBlock()
		{
			isStatement = true;
			queryStr = "Make this block act like block...";
			inputStr1 = "Map16 number:";
			is16Bit = true;
			usingHex = true;
			listString = "Act like a certain block";
		}

		public override string GenerateCode()
		{

			is16Bit = false;
			string ret = "LDA " + Hex(value & 0xFF) + "\nSTA $1693\nLDY " + Hex((value & 0xFF00) >> 8);
			is16Bit = true;
			return ret;
		}

		public override string CodeString()
		{
			return "Make this block act like block " + ValueToString(value) + ".";
		}
	}

	public class GoToEvent : CodePiece
	{
		static string[] names = new string[] { "MarioBelow", "MarioAbove", "MarioSide", "SpriteVertical", "SpriteHorizontal", "Cape", "Fireball", "MarioCorner", "MarioHead", "MarioBody" };
		public GoToEvent()
		{
			enumerations = new string[] { "Mario below", "Mario above", "Mario side", "Sprite vertical", "Sprite horizontal", "Cape", "Fireball", "Mario corner", "Mario head", "Mario body" };
			isStatement = true;
			queryStr = "Go to event...";
			inputStr1 = "Event:";
			listString = "Go to another event";
		}

		public override string GenerateCode()
		{
			return "JMP " + names[value];
		}

		public override string CodeString()
		{
			return "Go to the " + enumerations[value] + " event.";
		}
	}

	public class ExitEvent : CodePiece
	{
		public ExitEvent()
		{
			isStatement = true;
			showEditForm = false;
			listString = "Exit this event";
		}

		public override string GenerateCode()
		{
			return "RTL";
		}

		public override string CodeString()
		{
			return "Exit this event.";
		}
	}

	public class EndBlock : CodePiece
	{
		public EndBlock()
		{
			isStatement = true;
			showEditForm = false;
			listString = "NULL";
		}

		public override string GenerateCode()
		{
			return labelName + ":";
		}

		public override string CodeString()
		{
			string s = "";
			for (int i = 0; i < level; i++)
				s += "--------";
			return s + "--------";
		}
	}

	public class DisplayMessage : CodePiece
	{
		int value2ToLevelNumber()
		{
			if (value2 > 0x25)
				return value2 + 0xDB;
			return value2 - 1;
		}

		public DisplayMessage()
		{
			isStatement = true;
			customForm = new DisplayMessageForm();
			listString = "Display a message.";
		}

		public override string GenerateCode()
		{
			string s = "";
			if (value2 != 0 && value != 2)
			{
				s += "LDA #$" + (value2 - 1).ToString("X2") + "\nSTA $13BF\n";
			}
			s += "LDA #$" + (value + 1).ToString("X2") + "\nSTA $1426";
			return s;
		}

		public override string CodeString()
		{
			if (value == 2)
				return "Display the Yoshi rescue message.";
			return "Display " + (value2 == 0 ? "this level's " : "level " + value2ToLevelNumber().ToString("X3") + "'s ") + (value == 0 ? "first" : "second") + " message.";
		}
	}

	public class GoToSubroutine : CodePiece
	{
		public int address = 0x008000;
		public bool subLong = false;
		public bool subLongToJSR = false;
		public bool fastROM = false;

		public GoToSubroutine()
		{
			isStatement = true;
			customForm = new SubroutineForm();
			listString = "Execute subroutine.";

		}

		public override string CodeString()
		{
			if (subLong || subLongToJSR)
				return "JSL to $" + ((value | (fastROM ? 0x800000 : 0)) >> 0x10).ToString("X2") + ":" + (value & 0xFFFF).ToString("X4");
			else
				return "JSR to $" + value.ToString("X4");
		}

		public override string GenerateCode()
		{
			if (subLong == false)
			{
				return "JSR $" + value.ToString("X4");
			}
			else if (subLong == true && subLongToJSR == false)
			{
				return "JSL $" + (value | (fastROM ? 0x800000 : 0)).ToString("X6");
			}
			else
			{
				string s;
				s = "LDA #$" +  (((value | (fastROM ? 0x800000 : 0)) >> 0x10) & 0xFF).ToString("X2") + "\nSTA $02\n";
				s += "LDA #$" + (((value | (fastROM ? 0x800000 : 0)) >> 0x08) & 0xFF).ToString("X2") + "\nSTA $01\n";
				s += "LDA #$" + (((value | (fastROM ? 0x800000 : 0)) >> 0x00) & 0xFF).ToString("X2") + "\nSTA $00\n";
				s += "PHK\nPER $0005\nPEA $";
				switch (value >> 0x10)
				{
					case 0x0:
						s += "84CE"; break;
					case 0x1:
						s += "8020"; break;
					case 0x2:
						s += "86EB"; break;
					case 0x3:
						s += "839E"; break;
					case 0x4:
						s += "8413"; break;
					case 0x5:
						s += "B299"; break;
					case 0x6:
						return null;
					case 0x7:
						s += "B299"; break;
					case 0x8:
						return null;
					case 0x9:
						return null;
					case 0xA:
						return null;
					case 0xB:
						return null;
					case 0xC:
						s += "9398"; break;
					case 0xD:
						return null;
					case 0xE:
						return null;
					case 0xF:
						return null;
					default:
						return null;
						
				}

				s += "\nJML [$0000]\nRTL";
				return s;
			}
		}
	}

	public class RAMEdit : CodePiece
	{
		public int address = 0x7E0000;
		public bool add = false;
		public bool sub = false;
		public bool set = true;
		public bool xIndexed = false;

		string AddrToString()
		{
			string s;
			byte bank = (byte)(address >> 0x10);
			byte hi = (byte)(address >> 0x08);
			byte lo = (byte)(address >> 0x00);

			if ((bank == 0x7E || bank == 0x00) && hi == 0x00)
				s = lo.ToString("X2");
			else if (bank == 0x7E || bank == 0x00)
				s = (hi << 8 | lo).ToString("X4");
			else
				s = address.ToString("X6");

			if (xIndexed)
				s += ",x";
			return s;
		}

		public RAMEdit()
		{
			isStatement = true;
			customForm = new RAMEditForm();
			listString = "Modify RAM address.";
		}

		public override string CodeString()
		{
			string s = "";
			if (set)
				s =  "Set $" + address.ToString("X6") + (xIndexed ? ",x" : "") + " to #$";
			else if (sub)
				s = "Subtract $" + address.ToString("X6") + (xIndexed ? ",x" : "") + " by #$";
			else if (add)
				s = "Increase $" + address.ToString("X6") + (xIndexed ? ",x" : "") + " by #$";

			if (is16Bit)
				s += value.ToString("X4");
			else
				s += value.ToString("X2");


			return s;

		}

		public override string GenerateCode()
		{
			string s = "";
			if (is16Bit)
			{
				if (set)
					s = "REP #$20\nLDA #$" + value.ToString("X4") + "\nSTA $" + AddrToString() + "\nSEP #$20";
				else if (add)
					s = "REP #$20\nLDA $" + AddrToString() + "\nCLC\nADC #$" + value.ToString("X4") + "\nSTA $" + AddrToString() + "\nSEP #$20";
				else if (sub)
					s = "REP #$20\nLDA $" + AddrToString() + "\nSEC\nSBC #$" + value.ToString("X4") + "\nSTA $" + AddrToString() + "\nSEP #$20";
			}
			else
			{
				if (set)
					s = "LDA #$" + value.ToString("X2") + "\nSTA $" + AddrToString();
				else if (add)
					s = "LDA $" + AddrToString() + "\nCLC\nADC #$" + value.ToString("X2") + "\nSTA $" + AddrToString();
				else if (sub)
					s = "LDA $" + AddrToString() + "\nSEC\nSBC #$" + value.ToString("X2") + "\nSTA $" + AddrToString();
			}

			return s;
		}
	}

	public class SpawnSprite : CodePiece
	{
		public override string GenerateCode()
		{
			return "LDA " + Hex(value) + "\nSTA $00\nJSR SpawnSpriteFromBlock";
		}

		public override string CodeString()
		{
			return "Spawn sprite #$" + value.ToString("X2") + " (" + enumerations[value] + ")";
		}

		public SpawnSprite()
		{
			enumerations = new string[] { "Green Koopa no shell",
"Red koopa no shell",
"Blue koopa no shell",
"Yellow Koopa no shell",
"Green Koopa",
"Red koopa",
"Blue koopa",
"Yellow Koopa",
"Green Koopa flying left",
"Green bouncing Parakoopa",
"Red vertical flying koopa",
"Red horizontal flying koopa",
"Yellow Koopa with wings",
"Bob-omb",
"Keyhole",
"Goomba",
"Bouncing Goomba with wings",
"Buzzy Beetle",
"Null",
"Spiny",
"Spiny falling",
"Fish horizontal",
"Fish vertical",
"Flying fish",
"Surface jumping fish",
"Display message 1",
"Classic Pirhana Plant",
"Bouncing football in place",
"Bullet Bill",
"Hopping flame",
"Lakitu",
"Magikoopa",
"Magikoopa's magic",
"Moving coin",
"Green vertical net Koopa",
"Red fast vertical net Koopa",
"Green horizontal net Koopa",
"Red fast horizontal net Koopa",
"Thwomp",
"Thwimp",
"Big Boo",
"Koopa Kid",
"Upside down Pirhana Plant",
"Sumo Brother's fire lightning",
"Yoshi egg",
"Baby green Yoshi",
"Spike Top",
"Portable spring board",
"Dry Bones throws bones",
"Bony Beetle",
"Dry Bones stay on ledge",
"Fireball vertical",
"Boss fireball stationary",
"Green Yoshi",
"Null",
"Boo",
"Eerie",
"Eerie wave motion",
"Urchin fixed",
"Urchin wall detect",
"Urchin wall follow",
"Rip Van Fish",
"P-switch",
"Para-Goomba",
"Para-Bomb",
"Dolphin horizontal " ,
"Dolphin horizontal #2",
"Dolphin vertical",
"Torpedo Ted",
"Directional coins no time limit",
"Diggin'Chuck",
"Swimming/Jumping fish doesn't need water",
"Diggin'Chuck's rock",
"Growing/shrinking pipe end",
"Goal Point Question Sphere",
"Pipe dwelling Lakitu",
"Exploding Block",
"Ground dwelling Monty Mole",
"Ledge dwelling Monty Mole",
"Jumping Pirhana Plant",
"Jumping Pirhana Plant spit fire",
"Ninji",
"Moving ledge hole in ghost house",
"Null",
"Climbing net door",
"Checkerboard platform horizontal",
"Flying rock platform horizontal",
"Checkerboard platform vertical",
"Flying rock platform vertical",
"Turn block bridge horizontal and vertical",
"Turn block bridge horizontal",
"Brown platform floating in water",
"Checkerboard platform that falls",
"Orange platform floating in water",
"Orange platform goes on forever",
"Brown platform on a chain ",
"Flat green switch palace switch",
"Floating skulls",
"Brown platform line-guided",
"Checker/brown platform",
"Rope mechanism line guided",
"Chainsaw line-guided",
"Upside down chainsaw line-guided",
"Grinder line-guided",
"Fuzz Ball line guided",
"Null",
"Coin game cloud",
"Spring board left wall",
"Spring board right wall",
"Invisible solid block",
"Dino Rhino",
"Dino Torch",
"Pokey",
"Super Koopa red cape swoop " ,
"Super Koopa yellow cape swoop ",
"Super Koopa feather",
"Mushroom",
"Flower",
"Star",
"Feather",
"1-UP",
"Growing Vine",
"Firework makes Mario temporary invisible",
"Standard Goal Point",
"Princess Peach",
"Balloon",
"Flying red coin worth 5 coins",
"Flying Yellow 1-UP",
"Key",
"Changing item from a translucent block",
"Bonus game",
"Left flying question block",
"Question block flying back and forth",
"Null",
"Wiggler",
"Lakitu's cloud no time limit",
"Layer 3 cage",
"Layer 3 smash",
"Bird from Yoshi's house max of 4",
"Puff of smoke from Yoshi's house",
"Fireplace smoke",
"Ghost house exit sign and door",
"Invisible \"Warp Hole\" blocks",
"Scale platforms",
"Large green gas bubble",
"Chargin' Chuck",
"Splitin' Chuck",
"Bouncin' Chuck",
"Whistlin' Chuck",
"Clapin' Chuck",
"Chargin' Chuck",
"Puntin' Chuck",
"Pitchin' Chuck",
"Volcano Lotus",
"Sumo Brother",
"Hammer Brother",
"Flying blocks for Hammer Brother",
"Bubble",
"Ball and Chain",
"Banzai Bill",
"Bowser",
"Bowser's Bowling Ball",
"MechaKoopa",
"Grey platform on chain",
"Floating Spike ball",
"Fuzzball/Sparky ground-guided",
"HotHead ground-guided",
"Iggy's ball",
"Blargg",
"Reznor",
"Fishbone",
"Rex",
"Wooden Spike moving down and up",
"Wooden Spike moving up and down",
"Fishin'Boo",
"Boo Block",
"Reflecting stream of Boo Buddies",
"Creating/Eating block",
"Falling Spike",
"Bowser statue fireball",
"Grinder non-line-guided",
"Falling fireball",
"Reflecting fireball",
"Carrot Top lift upper right ",
"Carrot Top lift upper left",
"Info Box",
"Timed lift",
"Grey moving castle block horizontal",
"Bowser statue",
"Sliding Koopa without a shell",
"Swooper Bat",
"Mega Mole",
"Grey platform on lava sinks",
"Flying grey turnblocks",
"Blurp fish",
"Porcu-Puffer fish",
"Grey platform that falls",
"Big Boo Boss",
"Dark room with spot light",
"Invisible mushroom",
"Light switch block for dark room"
};
			for (int i = 0; i < enumerations.Length; i++)
				enumerations[i] = enumerations[i].Insert(0, i.ToString("X2") + " ");

			isStatement = true;
			queryStr = "Spawn a sprite...";
			inputStr1 = "Sprite to spawn:";
			listString = "Spawn a sprite.";


			routines = "SpawnSpriteFromBlock:\n" +
"	LDX #$0B		; \\ Find a last free sprite slot from 00-0B \n" +
"CODE_028907:			; |\n" +
"	LDA $14C8,X		; | \n" +
"	BEQ CODE_028922		; | \n" +
"	DEX			; | \n" +
"	CPX #$FF		; | \n" +
"	BNE CODE_028907		; / \n" +
"	DEC $1861		; \\\n" +
"	BPL CODE_02891B		; | Get an \"emergency\" slot if necessary.\n" +
"	LDA #$01		; |\n" +
"	STA $1861		; /\n" +
"CODE_02891B:			; \n" +
"	LDA $1861		;\n" +
"	CLC			;\n" +
"	ADC #$0A		;\n" +
"	TAX			;\n" +
"	STX $185E		;\n" +
"	LDY $05			;\n" +
"CODE_028922:			;\n"+
"	LDA #$01		; \\ Set sprite status \n" +
"	STA $14C8,X		; / \n" +
	"\n" +
"	LDA $00			; \\ Set sprite number \n" +
"	STA $9E,X		; / \n" +
"	STA $0E			;\n" +
"	JSL $07F7D2		;\n" +
"	INC $15A0,X 		;\n" +
"	\n" +
"	LDA $9A			; \\\n" +
"	STA $E4,X		; |\n" +
"	LDA $9B			; |\n" +
"	STA $14E0,X		; | Set the sprite's position.\n" +
"	LDA $98			; |\n" +
"	STA $D8,X		; |\n" +
"	LDA $99			; |\n" +
"	STA $14D4,X		; /\n" +
"	LDA $1933		;\n" +
"	BEQ CODE_0289A5		;\n" +
"	LDA $9A			; \\\n" +
"	SEC			; |\n" +
"	SBC $26			; |\n" +
"	STA $E4,X		; |\n" +
"	LDA $9B			; |\n" +
"	SBC $27			; | Modify the position if it's on layer 2.\n" +
"	STA $14E0,X		; |\n" +
"	LDA $98			; |\n" +
"	SEC			; |\n" +
"	SBC $28			; |\n" +
"	STA $D8,X		; |\n" +
"	LDA $99			; |\n" +
"	SBC $29			; |\n" +
"	STA $14D4,X		; /\n" +
"CODE_0289A5:			;\n" +
"	LDA #$D0		; \\ Make the sprite \"jump\" a bit.\n" +
"	STA $AA,X		; /\n" +
"	LDA #$2C		; \\ Disable interaction with the player.\n" +
"	STA $154C,X		; /\n" +
"	LDA $190F,X		; \\\n" +
"	BPL Return028A29	; | Something about getting stuck in walls?\n" +
"	LDA #$10		; |\n" +
"	STA $15AC,X		; /\n" +
"Return028A29:			;\n" +
"	RTS			; Return ";
		}
	}


	public class ElseCode : CodePiece
	{
		public ElseCode()
		{
			isStatement = true;
			showEditForm = false;
			listString = "NULL";
		}

		public override string GenerateCode()
		{
			throw new System.NotImplementedException("Error: Else code pieces must use special code generators.");
		}

		public string GenerateElseCode(string label1, string label2)
		{
			return "\tBRA " + label1 + "\n" + label2 + ": ";
		}

		public override string CodeString()
		{
			return "Otherwise,";
		}


	}


	public class OrCode : CodePiece
	{
		public OrCode()
		{
			isStatement = false;
			showEditForm = false;
			listString = "NULL";
		}

		public override string GenerateCode()
		{
			throw new System.NotImplementedException("Error: Or code pieces must use special code generators.");
		}

		public string GenerateElseCode(string label1, string label2)
		{
			return null;
		}

		public override string CodeString()
		{
			return "Or,";
		}


	}

	public class ShatterBlock : CodePiece
	{
		public ShatterBlock()
		{
			isStatement = true;
			listString = "Shatter the block";
			queryStr = "Shatter the block.";
			inputStr1 = "Shard color: ";
			enumerations = new string[] { "Normal", "Rainbow" };
		}

		public override string GenerateCode()
		{
			return "PHY\nLDA #$02\nSTA $9C\nJSL $00BEB0\nPHB\nLDA #$02\nPHA\nPLB\nLDA " + Hex(value) + "\nJSL $028663\nPLB\nPLY";
		}

		public override string CodeString()
		{
			return "Shatter the block with " + ((value == 0) ? "normal" : "rainbow") + " shards.";
		}
	}

	public class SpriteShatterBlock : CodePiece
	{
		public SpriteShatterBlock()
		{
			isStatement = true;
			showEditForm = true;
			listString = "Shatter the block (sprite version).";
			queryStr = "Shatter the block.";
			inputStr1 = "Shard color: ";
			enumerations = new string[] { "Normal", "Rainbow" };
		}

		public override string GenerateCode()
		{
			return "PHY\nLDA $0A\nAND #$F0\nSTA $9A\nLDA $0B\nSTA $9B\nLDA $0C\nAND #$F0\nSTA $98\nLDA $0D\nSTA $99\nLDA #$02\nSTA $9C\nJSL $00BEB0\nPHB\nLDA #$02\nPHA\nPLB\nLDA #$00\nJSL $028663\nPLB\nPLY";
		}

		public override string CodeString()
		{
			return "Shatter the block with " + ((value == 0) ? "normal" : "rainbow") + " shards (sprite version).";
		}
	}

	public class Every2Frames : CodePiece
	{
		public Every2Frames()
		{
			isStatement = false;
			showEditForm = false;
			listString = "Do something every other frame.";
		}

		public override string GenerateCode()
		{
			return "LDA $14\nAND #$01\nBNE " + labelName;
		}

		public override string CodeString()
		{
			return "Every other frame...";
		}
	}

	public class Every4Frames : CodePiece
	{
		public Every4Frames()
		{
			isStatement = false;
			showEditForm = false;
			listString = "Do something every 4 frames.";
		}

		public override string GenerateCode()
		{
			return "LDA $14\nAND #$03\nBNE " + labelName;
		}

		public override string CodeString()
		{
			return "Every 4 frames...";
		}
	}

	public class Every8Frames : CodePiece
	{
		public Every8Frames()
		{
			isStatement = false;
			showEditForm = false;
			listString = "Do something every 8 frames.";
		}

		public override string GenerateCode()
		{
			return "LDA $14\nAND #$07\nBNE " + labelName;
		}

		public override string CodeString()
		{
			return "Every 8 frames...";
		}
	}

	public class Every16Frames : CodePiece
	{
		public Every16Frames()
		{
			isStatement = false;
			showEditForm = false;
			listString = "Do something every 16 frames.";
		}

		public override string GenerateCode()
		{
			return "LDA $14\nAND #$0F\nBNE " + labelName;
		}

		public override string CodeString()
		{
			return "Every 16 frames...";
		}
	}

	public class Every32Frames : CodePiece
	{
		public Every32Frames()
		{
			isStatement = false;
			showEditForm = false;
			listString = "Do something every 32 frames.";
		}

		public override string GenerateCode()
		{
			return "LDA $14\nAND #$1F\nBNE " + labelName;
		}

		public override string CodeString()
		{
			return "Every 32 frames...";
		}
	}

	public class Every64Frames : CodePiece
	{
		public Every64Frames()
		{
			isStatement = false;
			showEditForm = false;
			listString = "Do something every 64 frames.";
		}

		public override string GenerateCode()
		{
			return "LDA $14\nAND #$3F\nBNE " + labelName;
		}

		public override string CodeString()
		{
			return "Every 64 frames...";
		}
	}

	public class Every128Frames : CodePiece
	{
		public Every128Frames()
		{
			isStatement = false;
			showEditForm = false;
			listString = "Do something every 128 frames.";
		}

		public override string GenerateCode()
		{
			return "LDA $14\nAND #$7F\nBNE " + labelName;
		}

		public override string CodeString()
		{
			return "Every 128 frames...";
		}
	}

	public class Every256Frames : CodePiece
	{
		public Every256Frames()
		{
			isStatement = false;
			showEditForm = false;
			listString = "Do something every 256 frames.";
		}

		public override string GenerateCode()
		{
			return "LDA $14\nAND #$FF\nBNE " + labelName;
		}

		public override string CodeString()
		{
			return "Every 256 frames...";
		}
	}

	public class Alternate1Frame : CodePiece
	{
		public Alternate1Frame()
		{
			isStatement = false;
			showEditForm = false;
			listString = "Do something, alternating every frame.";
			branchType.ct = ComparisonType.NotEqual;
		}

		public override string GenerateCode()
		{
			return "LDA $14\nAND #$01\n" + branchType + labelName;
		}

		public override string CodeString()
		{
			return "Alternating every frame...";
		}
	}

	public class Alternate2Frame : CodePiece
	{
		public Alternate2Frame()
		{
			isStatement = false;
			showEditForm = false;
			listString = "Do something, alternating every 2 frames.";
			branchType.ct = ComparisonType.NotEqual;
		}

		public override string GenerateCode()
		{
			return "LDA $14\nAND #$02\n" + branchType + labelName;
		}

		public override string CodeString()
		{
			return "Alternating every 2 frames...";
		}
	}

	public class Alternate4Frame : CodePiece
	{
		public Alternate4Frame()
		{
			isStatement = false;
			showEditForm = false;
			listString = "Do something, alternating every 4 frames.";
			branchType.ct = ComparisonType.NotEqual;
		}

		public override string GenerateCode()
		{
			return "LDA $14\nAND #$04\n" + branchType + labelName;
		}

		public override string CodeString()
		{
			return "Alternating every 4 frames...";
		}
	}

	public class Alternate8Frame : CodePiece
	{
		public Alternate8Frame()
		{
			isStatement = false;
			showEditForm = false;
			listString = "Do something, alternating every 8 frames.";
			branchType.ct = ComparisonType.NotEqual;
		}

		public override string GenerateCode()
		{
			return "LDA $14\nAND #$08\n" + branchType + labelName;
		}

		public override string CodeString()
		{
			return "Alternating every 8 frames...";
		}
	}

	public class Alternate16Frame : CodePiece
	{
		public Alternate16Frame()
		{
			isStatement = false;
			showEditForm = false;
			listString = "Do something, alternating every 16 frames.";
			branchType.ct = ComparisonType.NotEqual;
		}

		public override string GenerateCode()
		{
			return "LDA $14\nAND #$10\n" + branchType + labelName;
		}

		public override string CodeString()
		{
			return "Alternating every 16 frames...";
		}
	}

	public class Alternate32Frame : CodePiece
	{
		public Alternate32Frame()
		{
			isStatement = false;
			showEditForm = false;
			listString = "Do something, alternating every 32 frames.";
			branchType.ct = ComparisonType.NotEqual;
		}

		public override string GenerateCode()
		{
			return "LDA $14\nAND #$20\n" + branchType + labelName;
		}

		public override string CodeString()
		{
			return "Alternating every 32 frames...";
		}
	}

	public class Alternate64Frame : CodePiece
	{
		public Alternate64Frame()
		{
			isStatement = false;
			showEditForm = false;
			listString = "Do something, alternating every 64 frames.";
			branchType.ct = ComparisonType.NotEqual;
		}

		public override string GenerateCode()
		{
			return "LDA $14\nAND #$40\n" + branchType + labelName;
		}

		public override string CodeString()
		{
			return "Alternating every 64 frames...";
		}
	}

	public class Alternate128Frame : CodePiece
	{
		public Alternate128Frame()
		{
			isStatement = false;
			showEditForm = false;
			listString = "Do something, alternating every 128 frames.";
			branchType.ct = ComparisonType.NotEqual;
		}

		public override string GenerateCode()
		{
			return "LDA $14\nAND #$80\n" + branchType + labelName;
		}

		public override string CodeString()
		{
			return "Alternating every 128 frames...";
		}
	}

	public class GoToNextEvent : CodePiece
	{
		public GoToNextEvent()
		{
			isStatement = true;
			showEditForm = false;
			listString = "Go straight to the next event.";
		}

		public override string GenerateCode()
		{
			throw new System.Exception("Error: GoToNextEvent class has no code associated with it.");
		}

		public override string CodeString()
		{
			return "Go straight to the next event.";
		}
	}

	public class ChangeTile : CodePiece
	{
		public ChangeTile()
		{
			queryStr = "Change this block into a...";
			isStatement = true;
			inputStr1 = "Tile:";
			listString = "Change this block into another block";
			enumerations = new string[] { "The current block",
							"Empty, set item memory",
							"Empty",
							"Vine",
							"Bush",
							"Turning block",
							"Coin",
							"Mushroom Stem",
							"Mole hole",
							"Invisible solid block",
							"Multi-coin turn block",
							"Multi-coin ? block",
							"Turn block",
							"Used block",
							"Note block",
							"Note block",
							"4-way note block",
							"Side-bounce turn block",
							"Translucent block",
							"ON/OFF switch",
							"Left pipe side",
							"Right pipe side",
							"Used block, sets item memory",
							"O block, sets item memory",
							"Collected dragon coin",
							"Empty net frame",
							"Net door",
							"Invisible 32x32 solid block" };

		}

		public string[] enumerations2 = new string[] { 
							"Turn the current block into...the current block.",
							"Erase the current block and set item memory.",
							"Erase the current block.",
							"Turn the current block into a vine.",
							"Turn the current block into a bush",
							"Turn the current block into a turning turn block.",
							"Turn the current block into a coin.",
							"Turn the current block into a mushroom stem.",
							"Turn the current block into a mole hole.",
							"Turn the current block into an invisible solid block.",
							"Turn the current block into a multi-coin turn block.",
							"Turn the current block into a multi-coin ? block.",
							"Turn the current block into a turn block.",
							"Turn the current block into a used block.",
							"Turn the current block into a note block.",
							"Turn the current block into a note block.",
							"Turn the current block into a 4-way note block.",
							"Turn the current block into a side-bounce turn block.",
							"Turn the current block into a translucent block.",
							"Turn the current block into an ON/OFF switch.",
							"Turn the current block into a left pipe side.",
							"Turn the current block into a right pipe side.",
							"Turn the current block into a used block and set item memory.",
							"Turn the current block into an O block and set item memory.",
							"Act like a collected dragon coin.",
							"Create an empty net frame.",
							"Create a net door.",
							"Create an invisible 32x32 block."};

		public override string GenerateCode()
		{
			return "PHY\nLDA " +Hex(value) + "\nSTA $9C\nJSL $00BEB0\nPLY";
		}

		public override string CodeString()
		{
			return enumerations2[value];
		}
	}

	public class ChangeMap16 : CodePiece
	{
		public short xPos = 0;
		public short yPos = 0;
		public ChangeMap16()
		{
			queryStr = "Change this block into...\r\nNote: The code for this is long. If possible, use the \n\"change into another block\" command instead.";
			isStatement = true;
			inputStr1 = "Map16 tile:";
			listString = "Change this block into a Map16 tile";
			is16Bit = true;
			noRelative = true;
			usingHex = true;

			customForm = new Map16ChangeForm();
			
			#region routines = "..."
			routines = "PrematureEnd:\n" +
			"	PLX\n" +
			"	PLY\n" +
			"	PLB\n" +
			"	PLP\n" +
			"	RTS\n" +
			"ChangeMap16:\n" +
			"	PHP\n" +
			"	SEP #$20\n" +
			"	PHB\n" +
			"	PHY\n" +
			"	LDA #$00\n" +
			"	PHA\n" +
			"	PLB\n" +
			"	REP #$30\n" +
			"	PHX\n" +
			"	LDA $9A\n" +
			"	STA $0C\n" +
			"	LDA $98\n" +
			"	STA $0E\n" +
			"	LDA #$0000\n" +
			"	SEP #$20\n" +
			"	LDA $5B\n" +
			"	STA $09\n" +
			"	LDA $1933\n" +
			"	BEQ SkipShift\n" +
			"	LSR $09\n" +
			"SkipShift:\n" +
			"	LDY $0E\n" +
			"	LDA $09\n" +
			"	AND #$01\n" +
			"	BEQ LeaveXY\n" +
			"	LDA $9B\n" +
			"	STA $00\n" +
			"	LDA $99\n" +
			"	STA $9B\n" +
			"	LDA $00\n" +
			"	STA $99\n" +
			"	LDY $0C\n" +
			"LeaveXY:\n" +
			"	CPY #$0200\n" +
			"	BCS PrematureEnd\n" +
			"	LDA $1933\n" +
			"	ASL A\n" +
			"	TAX\n" +
			"	LDA $BEA8,x\n" +
			"	STA $65\n" +
			"	LDA $BEA9,x\n" +
			"	STA $66\n" +
			"	STZ $67\n" +
			"	LDA $1925\n" +
			"	ASL A\n" +
			"	TAY\n" +
			"	LDA [$65],y\n" +
			"	STA $04\n" +
			"	INY\n" +
			"	LDA [$65],y\n" +
			"	STA $05\n" +
			"	STZ $06\n" +
			"	LDA $9B\n" +
			"	STA $07\n" +
			"	ASL A\n" +
			"	CLC\n" +
			"	ADC $07\n" +
			"	TAY\n" +
			"	LDA [$04],y\n" +
			"	STA $6B\n" +
			"	STA $6E\n" +
			"	INY\n" +
			"	LDA [$04],y\n" +
			"	STA $6C\n" +
			"	STA $6F\n" +
			"	LDA #$7E\n" +
			"	STA $6D\n" +
			"	INC A\n" +
			"	STA $70\n" +
			"	LDA $09\n" +
			"	AND #$01\n" +
			"	BEQ SwitchXY\n" +
			"	LDA $99	\n" +
			"	LSR A\n" +
			"	LDA $9B\n" +
			"	AND #$01\n" +
			"	BRA CurrentXY\n" +
			"SwitchXY:\n" +
			"	LDA $9B\n" +
			"	LSR A\n" +
			"	LDA $99\n" +
			"CurrentXY:\n" +
			"	ROL A\n" +
			"	ASL A\n" +
			"	ASL A\n" +
			"	ORA #$20\n" +
			"	STA $04\n" +
			"	CPX #$0000\n" +
			"	BEQ NoAdd\n" +
			"	CLC\n" +
			"	ADC #$10\n" +
			"	STA $04\n" +
			"NoAdd:\n" +
			"	LDA $98\n" +
			"	AND #$F0\n" +
			"	CLC\n" +
			"	ASL A\n" +
			"	ROL A\n" +
			"	STA $05\n" +
			"	ROL A\n" +
			"	AND #$03\n" +
			"	ORA $04\n" +
			"	STA $06\n" +
			"	LDA $9A\n" +
			"	AND #$F0\n" +
			"	REP 3 : LSR A\n" +
			"	STA $04\n" +
			"	LDA $05\n" +
			"	AND #$C0\n" +
			"	ORA $04\n" +
			"	STA $07\n" +
			"	REP #$20\n" +
			"	LDA $09\n" +
			"	AND #$0001\n" +
			"	BNE LayerSwitch\n" +
			"	LDA $1A\n" +
			"	SEC\n" +
			"	SBC #$0080\n" +
			"	TAX\n" +
			"	LDY $1C\n" +
			"	LDA $1933\n" +
			"	BEQ CurrentLayer\n" +
			"	LDX $1E\n" +
			"	LDA $20\n" +
			"	SEC\n" +
			"	SBC #$0080\n" +
			"	TAY\n" +
			"	BRA CurrentLayer\n" +
			"LayerSwitch: \n" +
			"	LDX $1A\n" +
			"	LDA $1C\n" +
			"	SEC\n" +
			"	SBC #$0080\n" +
			"	TAY\n" +
			"	LDA $1933\n" +
			"	BEQ CurrentLayer\n" +
			"	LDA $1E\n" +
			"	SEC\n" +
			"	SBC #$0080\n" +
			"	TAX\n" +
			"	LDY $20\n" +
			"CurrentLayer:\n" +
			"	STX $08\n" +
			"	STY $0A\n" +
			"	LDA $98\n" +
			"	AND #$01F0\n" +
			"	STA $04\n" +
			"	LDA $9A\n" +
			"	REP 4 : LSR A\n" +
			"	AND #$000F\n" +
			"	ORA $04\n" +
			"	TAY\n" +
			"	PLA\n" +
			"	SEP #$20\n" +
			"	STA [$6B],y\n" +
			"	XBA\n" +
			"	STA [$6E],y\n" +
			"	XBA\n" +
			"	REP #$20\n" +
			"	ASL A\n" +
			"	TAY\n" +
			"	PHK\n" +
			"	PER $0006\n" +
			"	PEA $804C\n" +
			"	JML $00C0FB\n" +
			"	PLY\n" +
			"	PLB\n" +
			"	PLP\n" +
			"	RTS";
			#endregion
		}

		public override string GenerateCode()
		{
			string s = "";
			if (xPos != 0 || yPos != 0)
				s = "REP #$20\n";
			if (yPos != 0)
				s += "LDA $98\nPHA\n";
			if (xPos != 0)
				s += "LDA $9A\nPHA\n";

			if (xPos != 0)
				s += "LDA " + Hex(xPos) + "\nCLC\nADC $9A\nSTA $9A\n";
			if (yPos != 0)
				s += "LDA " + Hex(yPos) + "\nCLC\nADC $98\nSTA $98\n";

			if (xPos != 0 || yPos != 0)
				s += "SEP #$20\n";

			s += "PHX\nREP #$10\nLDX " + Hex(value) + "\nJSR ChangeMap16\nSEP #$10\nPLX";


			if (xPos != 0 || yPos != 0)
				s += "\nREP #$20\n";
			if (xPos != 0)
				s += "PLA\nSTA $9A\n";
			if (yPos != 0)
				s += "PLA\nSTA $98\n";
			if (xPos != 0 || yPos != 0)
				s += "SEP #$20\n";

			s = s.TrimEnd('\n');

			return s;
		}

		public override string CodeString()
		{
			if (xPos == 0 && yPos == 0)
				return "Change this block into Map16 tile " + Hex(value) + ".";
			else
				return "Change the block at (x" + (xPos >= 0 ? "+" : "") + xPos.ToString() + ", y" + (yPos >= 0 ? "+" : "") + yPos.ToString() + ") to " + Hex(value) + ".";
		}
	}

	public class PlaySFXBank1 : CodePiece
	{
		public PlaySFXBank1()
		{
			queryStr = "Play a sound effect...";
			isStatement = true;
			inputStr1 = "Sound effect:";
			listString = "Play a sound effect (bank 1)";
			noRelative = true;
			usingHex = true;
			enumerations = new string[] { 
			"Nothing",
			"Hit head",
			"Contact",
			"Kick shell",
			"Go in pipe, get hurt",
			"Midway point",
			"Yoshi gulp",
			"Dry bones collapse",
			"Kill enemy with a spin jump",
			"Fly with cape",
			"Get powerup",
			"ON/OFF switch",
			"Carry item past the goal",
			"Get cape",
			"Swim",
			"Hurt while flying",
			"Magikoopa shoot magic",
			"Pause (stops music)",
			"Pause (resumes music)",
			"Enemy stomp 1",
			"Enemy stomp 2",
			"Enemy stomp 3",
			"Enemy stomp 4",
			"Enemy stomp 5",
			"Enemy stomp 6",
			"Enemy stomp 7",
			"Grinder click",
			"Grinder click",
			"Yoshi/Dragon coin",
			"Running out of time 1",
			"P balloon",
			"Koopaling shrink/defeated",
			"Yoshi spit (\"OW!\")",
			"Valley of Bowser appears",
			"Lemmy/Wendy fall",
			"Blargg roar",
			"Firework whistle",
			"Firework bang",
			"Louder firework whistle",
			"Louder firework bang",
			"Peach pops up"};
		}

		public override string GenerateCode()
		{
			return "LDA " + Hex(value) + "\nSTA $1DF9";
		}

		public override string CodeString()
		{
			if (value != 0)
			{
				string s = (string)enumerations[value].Clone();
				s = s.Substring(1).Insert(0, s.Substring(0, 1).ToLower());
				return "Play the \"" + s + "\" sound effect.";
			}
			else
				return "Play no sound effect.";
		}
	}

	public class PlaySFXBank2 : CodePiece
	{
		public PlaySFXBank2()
		{
			queryStr = "Play a sound effect...";
			isStatement = true;
			inputStr1 = "Sound effect:";
			listString = "Play a sound effect (bank 2)";
			noRelative = true;
			usingHex = true;
			enumerations = new string[] { 	
			"Nothing",
			"Jump",
			"Turn on Yoshi drums",
			"Turn off Yoshi drums",
			"Grinder"};

		}

		public override string GenerateCode()
		{
			return "LDA " + Hex(value) + "\nSTA $1DFA";
		}

		public override string CodeString()
		{
			switch (value)
			{
				case 0:
					return "Play no sound effect.";
				case 2:
				case 3:
					string s = (string)enumerations[value].Clone();
					s = s.Substring(1).Insert(0, s.Substring(0, 1).ToLower());
					return "Play the \"" + s + "\" sound effect.";
				case 1:
				case 4:
					return "Play the \"" + enumerations[value] + "\" sound effect.";
			}
			return "";
		}
	}

	public class PlaySFXBank3 : CodePiece
	{
		public PlaySFXBank3()
		{
			queryStr = "Play a sound effect...";
			isStatement = true;
			inputStr1 = "Sound effect:";
			listString = "Play a sound effect (bank 3)";
			noRelative = true;
			usingHex = true;
			enumerations = new string[] { 	
			"Nothing",
			"Coin",
			"Hit a ? Block",
			"Hit a ? Block with vine",
			"Spin jump",
			"1up",
			"Shoot fireball",
			"Shatter block/Monty Mole",
			"Springboard",
			"Bullet bill shoot",
			"Egg hatch",
			"Item placed in reserve box",
			"Item falls from reserve box",
			"Item falls from reserve box",
			"L/R scroll",
			"Door",
			"Bullet bill shoot",
			"Drumroll start",
			"Drumroll end",
			"Lose Yoshi",
			"Unused?",
			"Overworld tile reveal",
			"Overworld castle collapse",
			"Fire spit",
			"Thunder",
			"Clappin' Chuck clap",
			"Castle destruction bomb",
			"Castle destruction bomb fuse",
			"Switch palace block ejection",
			"Running out of time 2",
			"Whistlin' Chuck whistle",
			"Yoshi mount",
			"Lemmy/Wendy lands in the lava",
			"Yoshi's tongue",
			"Message box/save prompt",
			"Mario moves onto a level tile",
			"P-switch running out",
			"Yoshi stomps an enemy",
			"Swooper",
			"Podoboo",
			"Enemy stunned/hurt",
			"Correct",
			"Wrong",
			"Firework whistle",
			"Firework bang",
			"Podoboo (-100% pan)",
			"Podoboo (-71% pan)",
			"Podoboo (-43% pan)",
			"Podoboo (-14% pan)",
			"Podoboo (14% pan)",
			"Podoboo (43% pan)",
			"Podoboo (71% pan)",
			"Podoboo (100% pan)"};

		}

		public override string GenerateCode()
		{
			return "LDA " + Hex(value) + "\nSTA $1DFC";
		}

		public override string CodeString()
		{
			if (value != 0)
			{
				string s = (string)enumerations[value].Clone();
				s = s.Substring(1).Insert(0, s.Substring(0, 1).ToLower());
				// All that for what s[0] = s[0].ToLower() should accomplish.
				return "Play the \"" + s + "\" sound effect.";
			}
			else
				return "Play no sound effect.";
		}
	}

}