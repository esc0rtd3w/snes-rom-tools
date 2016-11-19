#!/usr/bin/perl
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Tessera - v. 0.52, by imamelia
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Tool for Enhanced Specialization of Sprites and Expansion of Radical Attributes
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# This inserts custom sprites into your ROM.  See the readme for details.
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

use strict;
use warnings;
use feature qw(switch say);
use autodie;
use Tie::File;
use File::Spec;

our $VERSION = 0.52;	# version number of Tessera

# the user shouldn't have input any more than 4 arguments at the maximum
die "Error: Too many arguments in command string." if @ARGV > 4;

my $mainpath		= './sprite2/';	# folder containing all the sprites and data
my $inifile		= 'Tessera.ini';	# name of the .ini file
my $assembler	= 'xkas';		# the assembler that is being used
my @BitTable		= ( 0x01, 0x02, 0x04, 0x08, 0x10, 0x20, 0x40, 0x80 );
my @BitTableInv	= ( 0xFE, 0xFD, 0xFB, 0xF7, 0xEF, 0xDF, 0xBF, 0x7F );

# make "Tie" arrays for spriteloadhack.asm and spritedatatables.asm
tie my @floadhack, 'Tie::File', $mainpath . 'spriteloadhack.asm' or die "Cannot tie spriteloadhack.asm: $!";
tie my @fdatatbl,  'Tie::File', $mainpath . 'spritedatatables.asm' or die "Cannot tie spritedatatables.asm: $!";

open(my $fhtmp, '<', File::Spec->catfile($mainpath, $inifile));
my @tempary = <$fhtmp>;
map(chomp, @tempary);
my @tempary2 = split(/ = /, $tempary[0]);
my $ROMFile = $tempary2[1];
@tempary2 = split(/ = /, $tempary[1]);
my $SpriteListFile = $tempary2[1];
@tempary2 = split(/ = /, $tempary[2]);
my $ListFormat = $tempary2[1];
@tempary2 = split(/ = /, $tempary[3]);
my $LastSpecial = $tempary2[1];
@tempary2 = split(/ = /, $tempary[4]);
my $InstallSub= $tempary2[1];
@tempary2 = split(/ = /, $tempary[5]);
my $InstallNSTL = $tempary2[1];
@tempary2 = split(/ = /, $tempary[6]);
my $SubFreespaceU = $tempary2[1];

# indexes 0x000-0x3FF are normal sprites,
# 0x400-0x4FF are shooters,
# 0x500-0x5FF are generators,
# 0x600-0x6FF are run-once sprites,
# 0x700-0x7FF are cluster sprite generators,
# and 0x800-0x8FF are scroll sprites (unused).
my @SpriteNames   = ( ("") x 0x900 );		# initialize all sprite filenames
my @SpriteClones  = ( (0xFFFF) x 0x900 );	# this list determines which sprites share pointers (if the duplicate is greater than 0x3FF, the sprite doesn't have a duplicate)
my @NumExtraBytes = ( (0) x 0x400 );		# how many extra bytes each sprite has (not necessary for non-normal sprites, so only 0x400 bytes)

my $SpriteListData = "";					# initialize the string that will contain the data in the sprite list
my $ROMSize;

CheckForROM();						# set the ROM filename, overriding the .ini file if necessary
CheckForList();						# set the sprite list filename, overriding the .ini file if necessary

my $header;
if ( -e $ROMFile )						# check to make sure the specified ROM actually exists
{
	$ROMSize = -s $ROMFile;			# get the size of the ROM
	if ( $ROMSize < 0x100000 )			# if the ROM is smaller than 1 MB...
	{
		die "Error: Your ROM must be expanded.";		# quit because it hasn't been expanded
	}
	else
	{
		$header = ( $ROMSize % 0x8000 );			# the size mod 0x8000 should leave either 0 or 0x200 depending on whether or not the ROM has a header
	}
}
else
{
	die "Error: ROM file $ROMFile not found.";
}

# the ROM "name" is the ROM filename minus the extension
our $ROMName = substr( $ROMFile, 0, -4 );
my $sprdatafile = File::Spec->catfile($mainpath, $ROMName . '_spritedata.bin');
if ( -e  $sprdatafile)
{
	my $fullfiles = do { open my $fhtmp, '<', $sprdatafile; local $/; <$fhtmp> };
	EraseData();													# erase all previously-inserted sprites
}
else
{																# if there isn't already a file for the necessary data in this ROM...
	Initialize();													# create the file and insert the necessary ASM hacks
	if ( $InstallSub != 0 )
	{															# install shared subroutines if specified to do so
		InstallSubroutines() == 0 or die "Installation of shared subroutines failed: $!";
	}
	if ( $InstallNSTL != 0 )											# install No Sprite Tile Limits if specified to do so
	{
		InstallNSTL() == 0 or die "Installation of No Sprite Tile Limits failed: $!";
	}															# install the custom respawning patch always
	InstallCustRespawn() == 0 or die "Installation of custom respawning patch failed: $!";
}

# open the ROM for overwriting
open my $fhrom, '+<:raw', $ROMFile;
binmode $fhrom;
# sprites' insertion status -> array (if a pointer is 018021, the sprite has not been inserted)
my $MainDataLoc = unpack( "V", ( ReadAt( $fhrom, 3, SNEStoPC("\$0EF30C") ) ) . "\0" );

# retrieve the pointer to all of the necessary data, stored at $0EF30C-$0EF30E in the ROM
my @ExtraBitClip = ( 4, 3, 5 );						# number of characters to clip off the beginning of the string to indicate the sprite number/extra bits (indexed by the list format)
my @SpriteInfo;
if ( -e $SpriteListFile )							# check to make sure the specified ROM actually exists
{
	my $SpriteIndex = 0;						# all sprite-related tables will be indexed by the sprite number and extra bit setting
	open my $fhin, '<', $SpriteListFile;
	@SpriteInfo = ParseSpriteList($fhin);				# get the data from the sprite list
	close $fhin;							# and close the file
}
else
{
	die "Error: Sprite list file $SpriteListFile not found.";
}

my $CurSprNum;
given ($ListFormat)								# check the sprite list format
{
	when (1)									# if the list format is nn_e sprite.cfg...
	{
		for ( my $i = 0 ; $i < $#SpriteInfo ; $i += 4 )
		{
			my $temp1 = substr( $SpriteInfo[$i], 3, 1 );	# then the extra bit setting/sprite number high byte is the fourth character
			my $temp2 = substr( $SpriteInfo[$i], 0, 2 );	# and the sprite number low byte is the first two characters
			$CurSprNum = $temp1 . $temp2;			# so the index is the combination of the two
			InsertSprite( $CurSprNum, $SpriteInfo[$i + 1], $SpriteInfo[$i + 2], $SpriteInfo[$i + 3] );
		}
	}
	when (2)
	{										# if the list format is enn sprite.cfg...
		for ( my $i = 0 ; $i < $#SpriteInfo ; $i += 4 )
		{
			$CurSprNum = substr( $SpriteInfo[$i], 0, 3 );	# the index is the first three characters
			InsertSprite( $CurSprNum, $SpriteInfo[$i + 1], $SpriteInfo[$i + 2], $SpriteInfo[$i + 3] );
		}
	}
	when (3)
	{										# if the list format is nn Xe sprite.cfg...
		for ( my $i = 0 ; $i < $#SpriteInfo ; $i += 4 )
		{
			my $temp1 = substr( $SpriteInfo[$i], 4, 1 );	# then the extra bit setting/sprite number high byte is the fifth character
			my $temp2 = substr( $SpriteInfo[$i], 0, 2 );	# and the sprite number low byte is the first two characters
			$CurSprNum = $temp1 . $temp2;			# so the index is the combination of the two
			InsertSprite( $CurSprNum, $SpriteInfo[$i + 1], $SpriteInfo[$i + 2], $SpriteInfo[$i + 3] );
		}
	}
	default
	{
		die 'Error: Improper value for sprite list format.  Only 1-3 are valid.';
	}
}
close $fhrom;

untie @floadhack;
untie @fdatatbl;

# This subroutine takes a decimal number and converts it to a hexadecimal string.
sub ToHexStr
{
	return sprintf "%X", "$_[0]";
}

# This subroutine writes a string of data to a specific position in a file.
# It takes four arguments: filehandle, source variable, number of characters to write (if 0, will write the entire string), and offset at which to write.
# It returns the characters that were written.
# WARNING: This subroutine should be used with the "+<" file opening mode for best results.  Otherwise, it can and will erase most of the specified file.
sub WriteAt
{
	my ( $fh, $src, $nChars, $offset ) = @_;
	seek( $fh, $offset, 0 );
	if( $nChars == 0 )
	{
		print {$fh} $src;
		return $src;
	}
	else
	{
		print {$fh} substr $src, 0, $nChars;
		return substr $src, 0, $nChars;
	}
}

# This subroutine reads a string of data from a specific position in a file.
# It takes three arguments: filehandle, number of characters to read, and offset at which to read.
# It returns the characters that were read (as characters, not as a hex string).
sub ReadAt
{
	my ( $fh, $nChars, $offset ) = @_;
	seek( $fh, $offset, 0 );
	local $/ = \$nChars;
	my $temp = <$fh>;
	return $temp;
}


# This subroutine takes a SNES address and converts it to PC format, taking the ROM header into account if there is one.
# It takes one argument: the address to convert.
# It returns the converted address.
sub SNEStoPC
{
	my $temp1 = shift;
	substr( $temp1, 0, 1 ) = "" if substr( $temp1, 0, 1 ) eq '$';
	my $SNESAddr = hex($temp1);
	my $temp2 = ( $SNESAddr & 0x7FFF ) + ( ( $SNESAddr / 2 ) & 0xFF8000 );
	return $temp2 + $header;
}


# This subroutine takes a PC address and converts it to SNES format, taking the ROM header into account if there is one.
# It takes one argument: the address to convert.
# It returns the converted address.
sub PCtoSNES
{
	my $PCAddr = shift(@_);
	my $temp = $PCAddr - $header;
	return (($temp*2) & 0xFF0000) + ($temp & 0x7FFF) + 0x8000;
}


# This subroutine calculates the assembled size of an .asm file.
# It takes one argument: the .asm file to use.  (Should not contain any "org"s.)
# It returns the size of the assembled file.
sub GetSize
{
	# figure out the file name, initialize the size variable
	my $FileToUse = shift;

	# if there is already a file called "tmpasm.asm" or "tmpasm.bin", delete it
	unlink 'tmpasm.asm' if -e 'tmpasm.asm';
	unlink 'tmpasm.bin' if -e 'tmpasm.bin';

	# create a file called "tmpasm.asm"
	open my $fhtmp, '>', 'tmpasm.asm';
	print $fhtmp "lorom\n\norg \$008000\n";

	# slurp the entire file (the one the data comes from) into a string
	my $fullfiles = do { open $fhtmp, '<', $FileToUse; local $/; <$fhtmp> };

	# transfer all the data from the input file to the temporary file
	open $fhtmp, '>>', 'tmpasm.asm';
	print $fhtmp $fullfiles;
	open $fhtmp, '>', 'tmpasm.bin';
	close $fhtmp;
	system("$assembler tmpasm.asm tmpasm.bin > errlist.txt" ) == 0 or die "Could not run $assembler on tmpasm.asm: $!";
	my $size = -s 'tmpasm.bin';
	unlink 'tmpasm.asm';

	# unlink("tmpasm.bin");
	return $size;
}


# This subroutine does slightly different things depending on the context.
# In scalar context, it finds a block of freespace of a certain size in the ROM and returns the offset of said block.
# In list context, it finds ALL blocks of freespace of a certain size in the ROM and returns the offsets of said blocks.
# It takes two arguments: the filehandle and the minimum size.
sub FindFreespace
{
	my ($fh, $FreespaceSize) = @_;			# filehandle to operate on, minimum size of freespace block
	binmode($fh);						# read this as a binary file
	seek( $fh, 0, 0 );						# reset the file position keeper
	my $fullfile	= do { local $/; <$fh> };
	my $block;
	my $temp;
	my @tempary;
	my @addrlist;							# initialize the array that will hold the offsets and lengths of the blocks
	my $offset		= 0x80000 + $header;	# start searching at the beginning of the expanded space
	my $rem			= 0x8000;			# the first block is always 0x8000 bytes long
	my $skipbytes	= 0;					# how many bytes to skip after a successful pattern match

	while (($offset < $ROMSize) && ($offset < 0x200000+$header))	# loop until our offset exceeds the capacity of the ROM or bank 3F
	{
		$block = substr( $fullfile, $offset, $rem );

		# check for either a block of freespace or a RATS tag
		if ( $block =~ m/(\x00{$FreespaceSize,}|STAR)/g )
		{
			$offset = $offset + $-[1];	# set the file offset to the location of the first match

			if ( $1 eq "STAR" )			# if the tag came before the block...
			{
				my $TagSize = unpack( "v", substr( $fullfile, $offset + 4, 2 ) );
				my $TagEor  = unpack( "v", substr( $fullfile, $offset + 6, 2 ) );

				# check if the two bytes after the tag EOR #$FFFF = the next two bytes
				if ( ( $TagSize ^ 0xFFFF ) == $TagEor )
				{
					# if so, shift the offset ahead to the next byte after the tag (9 because the tag size is actually one more than specified)
					$skipbytes = $TagSize + 9;
				}
				else
				{
					# if not, just shift it to the character after the "STAR"
					$skipbytes = 4;
				}
			}
			else
			{
				my $BlockLength = length($1);		# find out how long the block is
				if ( $BlockLength >= $FreespaceSize )
				{
					if (wantarray)				# depending on the context of this subroutine, return a single offset or a list of them
					{
						@tempary = ( $offset, $BlockLength );
						push( @addrlist, @tempary );
					}
					else
					{
						return $offset;
					}
				}
				$skipbytes = $BlockLength;
			}

			# in any case, skip the specified number of bytes...
			$offset = $offset + $skipbytes;

			# ...and determine how large the next block will be
			$rem = 0x8000 - ( ( $offset - $header ) % 0x8000 );
		}
		else 	# if there are no more blocks of freespace and no more RATS tags in this block...
		{
			# then skip to the start of the next bank
			$offset = ( ($offset - $header) & 0xFF8000 ) + 0x8000 + $header;
			$rem = 0x8000;
		}
	}
	return @addrlist;	# then the subroutine is over
}

# This subroutine checks if the user has chosen to override the default ROM name, giving warning messages if the user typed the wrong things into the command prompt.
# It takes no arguments.
# It returns the name of the ROM file, whether or not it has been changed.
sub CheckForROM
{
	my @atemp = grep( /^-r$/, @ARGV );
	if ( @atemp == 1 ) {  # if the command-line arguments contain exactly one "-r", then change the ROM name if possible
		my $temp = ( grep( /.smc$/, @ARGV ) ) + ( grep( /.sfc$/, @ARGV ) );	# check for any arguments ending in .smc or .sfc
		if ( $temp < 1 ) {													 # if there was not exactly one argument ending in .smc or .sfc,
																			   # then print a warning message and use the defaults
			say 'No ROM filename found to match -r option.  The defaut will be used.';
		}
		elsif ( $temp > 1 ) {
			say 'Warning: Multiple ROM filenames found for -r option.  The default will be used.';
		}
		else {
			foreach my $arg (@ARGV) {
				$ROMFile = $arg and last if $arg =~ m/\.smc$/ or $arg =~ m/\.sfc$/;
			}
		}
	}
	elsif ( @atemp > 1 ) {
		die 'Error: Multiple instances of "-r" in argument list.  Was this intentional?...';
	}
	return $ROMFile;
}


# This subroutine checks if the user has chosen to override the default sprite list name, giving warning messages if the user typed the wrong things into the command prompt.
# It takes no arguments.
# It returns the name of the sprite list, whether or not it has been changed.
sub CheckForList
{
	my @atemp = grep( /^-l$/, @ARGV );
	if ( @atemp == 1 )					# if the command-line arguments contain exactly one "-l", then change the sprite list name if possible
	{
		my $temp = grep( /.txt$/, @ARGV );	# check for any arguments ending in .txt
		if ( $temp < 1 )					# if there was not exactly one argument ending in .txt,
		{							# then print a warning message and use the defaults
			say 'No sprite list found to match -l option.  The default will be used.';
		}
		elsif ( $temp > 1 )
		{
			say 'Warning: Multiple sprite lists found for -l option.  The default will be used.';
		}
		else
		{
			foreach my $arg (@ARGV)
			{
				$SpriteListFile = $arg and last if $arg =~ m/\.txt$/;
			}
		}
	}
	elsif ( @atemp > 0 )
	{
		die 'Error: Multiple instances of "-l" in argument list.  Was this intentional?...';
	}
	return $SpriteListFile;
}


sub ParseSpriteList
{
	my $fhin		= shift;
	my $t1		= "";
	my $tempstr	= "";		# temporary string variable
	my @tempary 	= ();		# temporary array variable
	my $Line		= "";		# a single line from the sprite list
	my @slist 		= ();		# @slist will contain the information from the sprite list: extra bits, .cfg filename, number of extra bytes, duplicate
	while (<$fhin>)
	{
		# skip the line if it contains only whitespace or if it starts with a comment marker
		next if m/^;/ or m{^//} or $_ !~ m/\S/;
		$Line = $_;

		# if the line contains a semicolon, tab, newline, or two slashes (actually, ALL lines contain \n)...
		if ( $Line =~ m/([;\t\r\n])|(\/\/)/ )
		{
			# remove everything starting at that character and use the text before it
			$tempstr = length($Line) - ( length($Line) - $-[1] );
			$Line = substr( $Line, 0, $tempstr );

			# the first slot of the array is the characters corresponding to the sprite number (and extra bits)
			$tempary[0] = substr( $Line, 0, $ExtraBitClip[$ListFormat - 1] );
			
			# if there is a ".cfg" in the line, then the sprite file name is everything from after the number to after the .cfg
			if ( $Line =~ m/(.cfg)/ )
			{
				# get the length of the sprite file name
				$t1 = $+[1] - 1 - $ExtraBitClip[$ListFormat - 1];

				# get the sprite file name into the array
				$tempary[1] = substr( $Line, $ExtraBitClip[$ListFormat - 1] + 1, $t1 );

				# set defaults for the extra bytes and duplicate, to be used if unspecified by the user (null for the duplicate)
				$tempary[2] = 0;
				$tempary[3] = 0xFFFF;

				# if, in the rest of the line, there is a sequence of a space and a digit (followed by another space or the end of the line)...
				if ( ( substr( $Line, $+[1] ) =~ m/ (\d) / ) || ( substr( $Line, $+[1] ) =~ m/ (\d$)/ ) )
				{
					if ( ( $1 >= 0 ) && ( $1 <= 4 ) )
					{
						$tempary[2] = $1;
					}
					else
					{
						say qq{Warning: Invalid extra byte specification for "$tempary[1]".  Using default (0) instead.};
					}
				}

				# if, in the rest of the line, there is a sequence of a space and three alphanumeric characters (followed by another space or the end of the line)...
				if ( ( substr( $Line, $+[1] ) =~ m/ (\w\w\w) / ) || ( substr( $Line, $+[1] ) =~ m/ (\w\w\w$)/ ) )
				{
					$tempary[3] = hex($1);
				}
			}
			else	# if there is text in the line that isn't commented, but there is no specified .cfg either...
			{
				say "Warning: Sprite name not specified in non-comment line.  Skipping this line...";
				next;
			}
		}

		# push the data for the current sprite onto the list of all sprites
		push( @slist, @tempary );
	}
	return @slist;
}

# This subroutine creates an external file with some information for the tool (location of each sprite's data)
# and patches all of the necessary hacks to the ROM, inserting all pointer tables while doing so.
sub Initialize
{
	my $tmppath = "";
	
	# open the ROM
	open my $fhrom, '<', $ROMFile;

	# erase data from the old Sprite Tool if necessary
	if (ReadAt( $fhrom, 4, SNEStoPC("\$01C08D") ) eq "\xEA\xEA\xEA\xEA")
	{
		$tmppath = File::Spec->catfile($mainpath, 'streverse.asm');
		system("$assembler $tmppath > errlist.txt") == 0 or die "Could not run $assembler on tmpasm.asm: $!";
		if(-s "errlist.txt" != 0)
			{ die "Error: streverse.asm could not be assembled properly.  See errlist.txt for details."; }
		else
			{ unlink "errlist.txt"; }
		# system("$mainpath" . "streverse.exe"); == 0 or die "Could not run $assembler on tmpasm.asm: $!";
	}
	my $temp = "";
	# create the sprite data file and fill it with a bunch of 00s
	open my $fhout, '>', File::Spec->catfile($mainpath, $ROMName . '_spritedata.bin');
	binmode $fhout;
	print {$fhout} "\x21\x80\x01" x 0x900;
	print {$fhout} "\x00" x 0x900;
	close $fhout;

	# assemble the patch at $108000 and get the size of the assembled code
	for (@floadhack) { s/!Freespace = \$\w{6}/!Freespace = \$108000/g; }
	$tmppath = File::Spec->catfile($mainpath, 'spriteloadhack.asm');
	system("$assembler $tmppath > errlist.txt") == 0 or die "Could not run $assembler on tmpasm.asm: $!";
	if(-s "errlist.txt" != 0)
		{ die "Error: spriteloadhack.asm could not be assembled properly.  See errlist.txt for details."; }
	else
		{ unlink "errlist.txt"; }
	my $HackSpaceSize = ( -s File::Spec->catfile($mainpath, 'spriteloadhack.smc') ) - 0x80000 - $header;
	unlink $mainpath . 'spriteloadhack.smc';

	# find a block of freespace large enough to hold the assembled code, then set the freespace define in the patch to that offset
	my $LoadHackOffset = FindFreespace($fhrom, $HackSpaceSize);
	if ($LoadHackOffset <= 0) { die 'Error: There is not enough freespace left in your ROM to insert the necessary hacks!'; }
	my $HackFree = PCtoSNES($LoadHackOffset);
	$temp = sprintf("%06X", "$HackFree");

	# set the freespace address and special level number, and add or remove a "header" keyword if necessary
	for (@floadhack)
	{
		s/!Freespace = \$\w{6}/!Freespace = \$$temp/g;
		s/!LastSpecial = \$\w{2}/!LastSpecial = \$$LastSpecial/g;
		if ( $header == 0 )					{ s/header\s*//; }
		elsif (( $_ =~ m/lorom/ ) && ($_ !~ m/header/))	{ $_ = "header\nlorom"; }
	}

	# patch the hacks and tables to the ROM
	$tmppath = File::Spec->catfile($mainpath, 'spriteloadhack.asm');
	system("$assembler $tmppath $ROMFile > errlist.txt") == 0 or die "Could not run $assembler on tmpasm.asm: $!";
	if(-s "errlist.txt" != 0)
		{ die "Error: spriteloadhack.asm could not be assembled properly.  See errlist.txt for details."; }
	else
		{ unlink "errlist.txt"; }
	close $fhrom;
}


# This subroutine inserts the data from one sprite into the ROM.
# It takes 4 arguments: sprite number and extra bit setting, sprite .cfg filename, number of extra bytes, duplicate sprite number.
# It assumes the "fhrom" filehandle.
sub InsertSprite
{
	my ( $sprnum, $sprcfg, $exbytecount, $dupe ) = @_;	# get the arguments
	$sprnum = hex($sprnum);
	if ( ( $sprnum >= 0xC9 ) && ( $sprnum <= 0xCD ) )	# make sure the user doesn't try to overwrite sprites 0C9-0CD
	{
		say 'Warning: Sprites C9-CD cannot be overwritten, as they are used for other sprite types.  Skipping this sprite...';
		return 1;
	}
	my $temp1 = $sprnum & 0xFF;
	my $temp2 = $sprnum >> 8;
	my $temp3 = $dupe & 0xFF;
	my $temp4 = $dupe >> 8;
	unless ($dupe == 0xFFFF )
	{
		if ( ($temp2 != $temp4) && ( ($temp2 > 4 ) || ($temp4 > 4) ) )		# if the sprite has a duplicate that isn't the same type...
		{
			say 'Warning: Duplicate sprite must be the same type as the original.  Skipping this sprite...';
			return 1;
		}
	}
	my @typefolder = qw(regular regular regular regular shooters generators runonce clustergen scroll);
	my $typeindex  = $sprnum >> 8;
	my $spritepath = File::Spec->catfile($mainpath, $typefolder[$typeindex], $sprcfg);
	open my $fhin, '<', $spritepath or die "Could not open $spritepath: $!";
	# to allow for different line endings on different operating systems, we convert all possible endings to a simple \n character
	my $cfglnstr = do { local $/; <$fhin> };
	$cfglnstr =~ s/[\r\n]+/\n/g;
	my @cfglines = split(/\n/, $cfglnstr);
	my $sprasm	= $cfglines[4];
	my $asmfile	= File::Spec->catfile($mainpath, $typefolder[$typeindex], $sprasm);

	# set the bitflag that marks this sprite as a custom one
	my $custflagbyte	= ReadAt( $fhrom, 1, SNEStoPC( ToHexStr($MainDataLoc) ) + 0x4C00 + ( $sprnum / 8 ) );
	my $flagged	= ord($custflagbyte) | $BitTable[$sprnum % 8];
	WriteAt( $fhrom, chr($flagged), 1, SNEStoPC( ToHexStr($MainDataLoc) ) + 0x4C00 + ( $sprnum / 8 ) );

	if ( $typeindex < 4 )
	{												# if the sprite type is 0-3 (normal sprite), write the .cfg data to the ROM
		# write the acts-like setting to the ROM
		WriteAt( $fhrom, chr( hex( $cfglines[1] ) ), 1, SNEStoPC( ToHexStr($MainDataLoc) ) + 0x400 + $sprnum );
		my @tempary = split( / /, $cfglines[2] );
		my @TweakerBytes = map( hex, @tempary );				# Tweaker bytes into a table
		@tempary = split( / /, $cfglines[3] );
		my @ExtraPropertyBytes = map( hex, @tempary );			# extra property bytes into a table
		# write the extra byte count to the ROM
		WriteAt( $fhrom, chr($exbytecount + 3), 1, SNEStoPC( ToHexStr($MainDataLoc) ) + $sprnum);
		
		# write the Tweaker bytes to the ROM
		WriteAt( $fhrom, chr( $TweakerBytes[0] ), 1, SNEStoPC( ToHexStr($MainDataLoc) ) + 0x800 + $sprnum);
		WriteAt( $fhrom, chr( $TweakerBytes[1] ), 1, SNEStoPC( ToHexStr($MainDataLoc) ) + 0xC00 + $sprnum);
		WriteAt( $fhrom, chr( $TweakerBytes[2] ), 1, SNEStoPC( ToHexStr($MainDataLoc) ) + 0x1000 + $sprnum);
		WriteAt( $fhrom, chr( $TweakerBytes[3] ), 1, SNEStoPC( ToHexStr($MainDataLoc) ) + 0x1400 + $sprnum);
		WriteAt( $fhrom, chr( $TweakerBytes[4] ), 1, SNEStoPC( ToHexStr($MainDataLoc) ) + 0x1800 + $sprnum);
		WriteAt( $fhrom, chr( $TweakerBytes[5] ), 1, SNEStoPC( ToHexStr($MainDataLoc) ) + 0x1C00 + $sprnum);

		# write the extra property bytes to the ROM
		WriteAt( $fhrom, chr( $ExtraPropertyBytes[0] ), 1, SNEStoPC( ToHexStr($MainDataLoc) ) + 0x2000 + $sprnum);
		WriteAt( $fhrom, chr( $ExtraPropertyBytes[1] ), 1, SNEStoPC( ToHexStr($MainDataLoc) ) + 0x2400 + $sprnum);
	}
	open my $fhext, '+<:raw', File::Spec->catfile($mainpath, $ROMName . '_spritedata.bin');
	
	my ( $initptr, $mainptr );
	if ( $dupe != 0xFFFF )			# if the sprite has a duplicate...
	{						# then the init and main pointer addresses are the same as those of the duplicate
		# set the flag in the external file that indicates that this sprite has a duplicate
		my $flagbyte	= ReadAt( $fhext, 1, 0x1B00 + $sprnum);
		my $flag		= ord($flagbyte) | 0x01;
		WriteAt( $fhext, chr($flag), 1, 0x1B00 + $sprnum );
		
		# copy the addresses over
		$initptr = ReadAt( $fhrom, 3, SNEStoPC( ToHexStr($MainDataLoc) ) + 0x2800 + $dupe * 3 );
		$mainptr = ReadAt( $fhrom, 3, SNEStoPC( ToHexStr($MainDataLoc) ) + 0x3400 +  $dupe * 3 );

		# write the pointers to the ROM
		WriteAt( $fhrom, $initptr, 3, SNEStoPC( ToHexStr($MainDataLoc) ) + 0x2800 + $sprnum * 3 );
		WriteAt( $fhrom, $mainptr, 3, SNEStoPC( ToHexStr($MainDataLoc) ) + 0x3400 + $sprnum * 3 );
		# write the pointer to an external file
		WriteAt( $fhext, $mainptr, 3, $sprnum * 3 );
		close $fhext;

		# print the insertion message
		if ( $temp2 < 4 )
		{
			print "Inserted sprite ";
			printf "%03X", "$sprnum";
			print " as a clone of sprite ";
			printf "%03X", "$dupe";
			print ".\n";
			return 0;
		}
		elsif ( $temp2 == 4 )
		{
			print "Inserted shooter ";
			printf "%02X", "$temp1";
			print " as a clone of shooter ";
			printf "%02X", "$temp3";
			print ".\n";
			return 0;
		}
		elsif ( $temp2 == 5 )
		{
			print "Inserted generator ";
			printf "%02X", "$temp1";
			print " as a clone of generator ";
			printf "%02X", "$temp3";
			print ".\n";
			return 0;
		}
		elsif ( $temp2 == 6 )
		{
			print "Inserted run-once sprite ";
			printf "%02X", "$temp1";
			print " as a clone of run-once sprite ";
			printf "%02X", "$temp3";
			print ".\n";
			return 0;
		}
		elsif ( $temp2 == 7 )
		{
			print "Inserted cluster sprite generator ";
			printf "%02X", "$temp1";
			print " as a clone of cluster sprite generator ";
			printf "%02X", "$temp3";
			print ".\n";
			return 0;
		}
		elsif ( $temp2 == 8 )
		{
			print "Inserted scroll sprite ";
			printf "%02X", "$temp1";
			print " as a clone of scroll sprite ";
			printf "%02X", "$temp3";
			print ".\n\n";
			return 0;
		}
	}
	else
	{	# if the sprite doesn't have a duplicate, start by figuring out the size of the .asm file (+2 = -6 for the pointers +8 for the RATS tag)
		my $sprdatasize = GetSize($asmfile) + 2;
		my $sprdataloc = FindFreespace( $fhrom, $sprdatasize );

		my $sprnumstr = sprintf "%03X", "$sprnum";
		# if there is not enough freespace left to insert this sprite...
		if ( $sprdataloc < 0 )
		{
			print "Warning: There is not enough freespace left in your ROM to insert sprite $sprnumstr into your ROM.  Skipping this sprite...";
			return 1;
		}

		# if there is already a file called "tmpasm.asm", delete it (delete tmpasm.bin as well)
		unlink 'tmpasm.asm' if -e 'tmpasm.asm';
		unlink 'tmpasm.bin' if -e 'tmpasm.bin';

		# create a file called "tmpasm.asm"
		open my $fhtmp, '>', 'tmpasm.asm';
		if ( $header != 0 ) { print {$fhtmp} "header\n"; }
		print {$fhtmp} "lorom\n\norg \$" . ToHexStr( PCtoSNES($sprdataloc) ) . "\n";

		# write the RATS tag
		my $TagSize = sprintf "%04X", $sprdatasize - 8;
		my $TagEor = sprintf "%04X", ( $sprdatasize - 8 ) ^ 0xFFFF;
		print {$fhtmp} "db \"STAR\"\ndw \$$TagSize\ndw \$$TagEor\n";

		# slurp the entire file (the one the data comes from) into a string
		my $fullfiles = do { open $fhtmp, '<', $asmfile; local $/; <$fhtmp> };

		# transfer all the data from the input file to the temporary file
		open $fhtmp, '>>', 'tmpasm.asm';
		print {$fhtmp} $fullfiles;

		# convert the sprite data into a binary file
		system("$assembler tmpasm.asm tmpasm.bin > errlist.txt") == 0 or die "Could not run $assembler on tmpasm.asm: $!";
		if(-s "errlist.txt" != 0)
			{ die "Error: Sprite $sprnumstr could not be assembled properly.  See errlist.txt for details."; }
		else
			{ unlink "errlist.txt"; }
		open $fhtmp, '<', 'tmpasm.bin';

		# get the assembled sprite data, the init pointer, and the main pointer into strings
		my $sprdata	= ReadAt( $fhtmp, $sprdatasize, $sprdataloc );
		my $sprinitloc	= ReadAt( $fhtmp, 3, $sprdataloc + $sprdatasize );
		my $sprmainloc	= ReadAt( $fhtmp, 3, $sprdataloc + $sprdatasize + 3 );

		# convert the pointer to the sprite data into a character string
		my $charptr = substr( pack( "V", hex( ToHexStr( PCtoSNES($sprdataloc) ) ) ), 0, 3 );

		# write the assembled sprite data to the ROM
		WriteAt( $fhrom, $sprdata, 0, $sprdataloc );

		# write the main pointer to the ROM
		WriteAt( $fhrom, $sprmainloc, 3, SNEStoPC( ToHexStr($MainDataLoc) ) + 0x3400 + $sprnum * 3 );	
		# also write it to an external file
		WriteAt( $fhext, $charptr, 3, $sprnum * 3 );
		
		# clear the flag in the external file that indicates that this sprite has a duplicate
		my $flagbyte	= ReadAt( $fhtmp, 1, 0x1B00 + $sprnum);
		my $flag		= ord($flagbyte) & 0xFE;
		WriteAt( $fhext, chr($flag), 1, 0x1B00 + $sprnum );
		close $fhext;
		close $fhtmp;

		# write the init pointer to the ROM only if the sprite type is regular
		if ( $temp2 < 4 )
		{
			WriteAt( $fhrom, $sprinitloc, 3, SNEStoPC( ToHexStr($MainDataLoc) ) + 0x2800 + $sprnum * 3 );

			# print the insertion message
			print "Inserted sprite ";
			printf "%03X", "$sprnum";
			print " successfully.\n";
		}
		elsif ( $temp2 == 4 )
		{
			print "Inserted shooter ";
			printf "%02X", "$temp1";
			print " successfully.\n";
		}
		elsif ( $temp2 == 5 )
		{
			print "Inserted generator ";
			printf "%02X", "$temp1";
			print " successfully.\n";
		}
		elsif ( $temp2 == 6 )
		{
			print "Inserted run-once sprite ";
			printf "%02X", "$temp1";
			print " successfully.\n";
		}
		elsif ( $temp2 == 7 )
		{
			print "Inserted cluster sprite generator ";
			printf "%02X", "$temp1";
			print " successfully.\n";
		}
		elsif ( $temp2 == 8 )
		{
			print "Inserted scroll sprite ";
			printf "%02X", "$temp1";
			print " successfully.\n";
		}
		#		unlink("tmpasm.asm") or die "Error: Deletion of tmpasm.asm unsuccessful: $!";
		#		unlink("tmpasm.bin") or die "Error: Deletion of tmpasm.bin unsuccessful: $!";
		return 0;
	}
}


# This subroutine erases all previously-inserted sprites from the ROM.
# It takes no arguments, and it returns 0 for success or 1 for failure.
sub EraseData
{
	open my $fhrom, '+<', $ROMFile;
	open my $fhtmp, '+<', File::Spec->catfile($mainpath, $ROMName . '_spritedata.bin');
	local $/ = \3;
	my @fullfile = <$fhtmp>;
	for (my $i = 0; $i < 0x900; $i++)
	{
		my $temp	= SNEStoPC( ToHexStr( ( unpack( "V", $fullfile[$i] . "\0" ) ) + 4 ) );
		my $datasize	= unpack( "v", ReadAt( $fhrom, 2, $temp ) ) + 8;
		my $nullstr	= "\x00" x $datasize;
		my $flagbyte	= ReadAt($fhtmp, 1, 0x1B00 + $i);
		my $flag		= ord($flagbyte);
		my $nullptr	= "\x21\x80\x01";
		# if this sprite's main pointer doesn't point to $018021 and the sprite does not have a duplicate, erase the data it points to and set the pointer to $018021
		if (($fullfile[$i] ne $nullptr) && (($flag & 0x01) == 0))
		{
			print "Erasing $datasize bytes of data from \$";
			printlnh(PCtoSNES($temp - 4));
			WriteAt($fhrom, $nullstr, 0, $temp - 4);
			WriteAt($fhtmp, $nullptr, 0, $i * 3);
		}
	}
	close $fhtmp;
	close $fhrom;
}
#my $charptr = substr(pack("V", hex(&ToHexStr(&PCtoSNES($sprdataloc)))), 0, 3);

# This subroutine installs my shared subroutine patch in the ROM.
# It takes no arguments.
# It returns 0 if the installation was successful or 1 if it failed.
sub InstallSubroutines
{
	open $fhrom, '+<', $ROMFile;
	my $freespace = Patch( File::Spec->catfile($mainpath, 'sharedsub.asm') ) or return 1;
	say "Shared subroutines installed at \$" . $freespace . ".";
	return 0;
	close $fhrom;
}

# This subroutine installs one or both No Sprite Tile Limits patches in the ROM.
# It takes no arguments.
# It returns 0 if the installation was successful or 1 if it failed.
sub InstallNSTL
{
	open my $fhrom, '+<', $ROMFile;
	if ( ( $InstallNSTL & 1 ) != 0 )
	{
		my $freespace = Patch( File::Spec->catfile($mainpath, 'NoMoreSpriteLimits.asm') ) or return 1;
		say "No Sprite Tile Limits installed at \$" . $freespace . ".";
	}
	if ( ( $InstallNSTL & 2 ) != 0 )
	{
		my $freespace = Patch( File::Spec->catfile($mainpath, "extendnstl.asm") ) or return 1;
		say "Extended No Sprite Tile Limits patch installed at \$" . $freespace . ".";
	}
	return 0;
	close $fhrom;
}

# This subroutine installs my custom sprite respawning patch in the ROM.
# It takes no arguments.
# It returns 0 if the installation was successful or 1 if it failed.
sub InstallCustRespawn
{
	open $fhrom, '+<', $ROMFile;
	my $freespace = Patch(File::Spec->catfile($mainpath, 'custrespawn.asm') ) or return 1;
	say "Custom respawn patch installed at \$" . $freespace . ".";
	return 0;
	close $fhrom;
}

# This subroutine patches an .asm file to the ROM.
# It takes one argument: the path to the .asm file used.
# It returns the freespace address used for the patch.
sub Patch
{
	my $patchtouse = shift;
	tie my @patch, 'Tie::File', $patchtouse or die "Cannot tie specified file: $!";
	if( $header != 0 )	{ $patch[0] = "header"; }
	else				{ $patch[0] = ""; }
	for (@patch) { s/!Freespace = \$\w{6}/!Freespace = \$108000/g; }
	system("$assembler $patchtouse > errlist.txt") == 0 or die "Could not run $assembler on tmpasm.asm: $!";
	if(-s "errlist.txt" != 0)
		{ die "Error: $patchtouse could not be assembled properly.  See errlist.txt for details."; }
	else
		{ unlink "errlist.txt"; }
	my $assembled = substr( $patchtouse, 0, length($patchtouse) - 3 ) . "smc";
	my $patchsize = ( -s $assembled ) - 0x80000 - $header;
	unlink $assembled;

	# find a block of freespace large enough to hold the assembled code, then set the freespace define in the patch to that offset
	my $freespacep = FindFreespace( $fhrom, $patchsize );
	if ( $freespacep <= 0 )
	{
		say 'Error: There is not enough freespace left in your ROM to insert the specified patch.';
		return 1;
	}
	my $freespaces = PCtoSNES($freespacep);
	my $temp = sprintf( "%06X", $freespaces );
	for (@patch) { s/!Freespace = \$\w{6}/!Freespace = \$$temp/g; }

	# patch the hacks and tables to the ROM
	system("$assembler $patchtouse $ROMFile > errlist.txt") == 0 or die "Could not run $assembler on tmpasm.asm: $!";
	if(-s "errlist.txt" != 0)
		{ die "Error: $patchtouse could not be assembled properly.  See errlist.txt for details."; }
	else
		{ unlink "errlist.txt"; }
	untie @patch;
	return $temp;
}

sub printlnh
{
	my $asdf = shift;
	printf "%X", $asdf;
	print "\n";
}

