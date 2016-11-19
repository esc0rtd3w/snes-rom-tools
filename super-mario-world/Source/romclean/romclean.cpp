#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include "inttype.h"
#include "sha256.h"

static const unsigned char * sha256(char * data, int len)
{
	sha256_ctx sha;
	static uint8_t shahash[32];
	sha256_init(&sha);
	sha256_chunk(&sha, (uint8_t*)data, len);
	sha256_final(&sha);
	sha256_hash(&sha, shahash);
	return (unsigned char*)shahash;
}

#ifdef _WIN32
#include <windows.h>

//true - got a filename
//false - didn't
static bool getfilename(char* filename)
{
	OPENFILENAME ofn = { sizeof(OPENFILENAME) };
	ofn.lpstrFilter = "SNES ROMs\0*.sfc;*.smc\0All Files\0*.*\0\0";
	filename[0]='\0';
	ofn.lpstrFile = filename;
	ofn.nMaxFile = 512;
	ofn.Flags = OFN_FILEMUSTEXIST|OFN_PATHMUSTEXIST;
	return GetOpenFileName(&ofn);
}

//level 0 - progress
//level 1 - success
//level 2 - failure
static void message(int level, const char * text)
{
	if (level==0) return;
	MessageBox(NULL, text, "ROMclean", level==2 ? MB_ICONSTOP : 0);
}
#else
static bool getfilename(char* filename)
{
	printf("Enter ROM name with extension: ");
	gets(filename);
	return true;
}

static void message(int level, const char * text)
{
	puts(text);
}
#endif


static bool interactive=false;
static void die(const char * reason, int exitcode=1)
{
	message(1+exitcode, reason);
	exit(exitcode);
}

int main(int argc, char * argv[])
{
	message(0, "Welcome to ROMclean by Alcaro");
	char cleanromhead[512];
	memset(cleanromhead, 0, 512);
	cleanromhead[0]=0x40;
	char romname[512];
	if (argc==1)
	{
		if (!getfilename(romname)) return 0;
	}
	else if (argc==2)
	{
		strcpy(romname, argv[1]);
	}
	else
	{
		die("Usage: romclean [romname]");
	}
	
	char * ext=strrchr(romname, '.');
	if (!ext) ext=strchr(romname, '\0');
	if (ext[0]!='.' || ext[1]!='s' || ext[2]!='m' || ext[3]!='c' || ext[4]!='\0')
	{
		message(0, "Fixing file extension...");
		char oldname[512];
		strcpy(oldname, romname);
		strcpy(ext, ".smc");
		if (rename(oldname, romname)!=0) die("Couldn't rename file. The most likely reason is a typo in the file name.");
	}
	
	FILE * therom=fopen(romname, "r+b");
	if (!therom) die("Couldn't open file. The most likely reason is a typo in the file name.");
	fseek(therom, 0, SEEK_END);
	int romsize=ftell(therom);
	if (romsize!=0x80000 && romsize!=0x80200) die("Error: ROM has wrong size. Couldn't clean the ROM.");
	char * romdata=(char*)malloc(sizeof(char)*(romsize+512))+512;
	fseek(therom, 0, SEEK_SET);
	fread(romdata, sizeof(char), romsize, therom);
	const unsigned char cleanromhash[32]={
		0x08, 0x38, 0xE5, 0x31, 0xFE, 0x22, 0xC0, 0x77, 0x52, 0x8F, 0xEB, 0xE1, 0x4C, 0xB3, 0xFF, 0x7C,
		0x49, 0x2F, 0x1F, 0x5F, 0xA8, 0xDE, 0x35, 0x41, 0x92, 0xBD, 0xFF, 0x71, 0x37, 0xC2, 0x7F, 0x5B};
	const unsigned char * shahash;
	if ((romsize&0x7FFF)==0x00000) shahash=sha256(romdata, romsize);
	else shahash=sha256(romdata+512, romsize-512);
	if (memcmp(shahash, cleanromhash, 32)) die("Error: ROM has wrong contents. Couldn't clean the ROM.");
	if ((romsize&0x7FFF)==0x00000)
	{
		message(0, "Adding header...");
		fseek(therom, 0, SEEK_SET);
		fwrite(cleanromhead, sizeof(char), 512, therom);
		fwrite(romdata, sizeof(char), romsize, therom);
		die("Your ROM is now clean.", 0);
	}
	if (memcmp(romdata, cleanromhead, 512))
	{
		message(0, "Fixing header...");
		fseek(therom, 0, SEEK_SET);
		fwrite(cleanromhead, sizeof(char), 512, therom);
		die("Your ROM is now clean.", 0);
	}
	die("Your ROM is already clean.", 0);
	return 0;
}
