#ifndef EXPORT
 #if defined(CPPCLI)
  #define EXPORT extern "C" WINAPI
 #elif defined(_WIN32)
  #define EXPORT extern "C" WINAPI __declspec(dllexport)
 #else
  #define EXPORT extern "C" WINAPI __attribute__((visibility ("default")))
 #endif
#endif

#define LINE3(l) #l
#define LINE2(l) LINE3(l)
#define LINE() LINE2(__LINE__)

#define con_null 0
#define con_normal 1
#define con_verbose 2

#ifdef DEBUG
//#if 0
#define con_snes con_normal
#define con_lm con_normal
#define forceview 1
#undef DEBUG
#define DEBUG(code) code
#else
#define con_snes con_null
#define con_lm con_null
#define forceview 0
#endif

#ifndef con_snes
#define con_snes console
#endif
#ifndef con_lm
#define con_lm console
#endif

#if con_snes>=con_normal
#define CON_SNES_NORMAL(code) code
#else
#define CON_SNES_NORMAL(code) nullfunction()
#endif

#if con_snes>=con_verbose
#define CON_SNES_VERBOSE(code) code
#else
#define CON_SNES_VERBOSE(code) nullfunction()
#endif

#if con_lm>=con_verbose
#define CON_LM_NORMAL(code) code
#else
#define CON_LM_NORMAL(code) nullfunction()
#endif

#if con_lm>=con_verbose
#define CON_LM_VERBOSE(code) code
#else
#define CON_LM_VERBOSE(code) nullfunction()
#endif

#if con_snes>=con_normal || con_lm>=con_normal//AttachConsole
#define _WIN32_WINNT 0x501
#endif

#include <windows.h>
#include <stdint.h>
#include <stdlib.h>
#include <stdio.h>
#include <ctype.h>
#include <time.h>
#include "libretro.h"
bool retro_load();

#ifndef DEBUG
#define printf DO_NOT_USE
#define puts DO_NOT_USE
#endif

inline int snestopc(int addr)
{
	if (addr<0 || addr>0xFFFFFF) return -1;//not 24bit
	if ((addr&0x700000)==0x700000 ||//wram, sram
		(addr&0x008000)==0x000000)//hardware regs, ram mirrors, rom mirrors, other strange junk
			return -1;
	addr=((addr&0x7F0000)>>1|(addr&0x7FFF));
	return addr;
}

void nullfunction(){}

//These control the sound.
void audio_init(double sample_rate);
void audio_sample(int16_t left, int16_t right);
void audio_clear();
void audio_term();

//These four contain the tables of how the level looks. Equivalent to:
const uint16_t * Map16L1H;//$7x:C800
const uint16_t * Map16L2H;//$7x:E300
const uint16_t * Map16L1V;//$7x:C800
const uint16_t * Map16L2V;//$7x:E400

//This one is the table of how each 16x16 tile decompose into 8x8 tiles.
const uint16_t * map16tiles;

//This one loads a level ID, for use when Mario enters a pipe through LMSW.
CALLBACK void (*LoadLevel)(int id);

//These one scrolls the level a bit. delta is how many tiles to move.
CALLBACK void (*ScrollLevelX)(int delta);
CALLBACK void (*ScrollLevelY)(int delta);

static uint32_t mypixels[2][224*256];
static uint16_t snesoff_x[2];
static uint16_t snesoff_y[2];
static volatile uint8_t currentBitmap;

bool switchpalaces[4];

#define LMSW_MSG_FIRST (WM_APP+1686)
#define LMSW_MSG_LOADROM   (LMSW_MSG_FIRST+0)
#define LMSW_MSG_RELOADROM (LMSW_MSG_FIRST+1)
#define LMSW_MSG_LOADLEVEL (LMSW_MSG_FIRST+2)
#define LMSW_MSG_RELOADSPR (LMSW_MSG_FIRST+3)
#define LMSW_MSG_PAUSE     (LMSW_MSG_FIRST+4)
#define LMSW_MSG_STEP      (LMSW_MSG_FIRST+5)
#define LMSW_MSG_TERM      (LMSW_MSG_FIRST+6)
#define LMSW_MSG_LAST      (LMSW_MSG_FIRST+6)

#define HorzLevelMode 0
#define VertLevelMode 1
#define L1LevelMode 0
#define L2LevelMode 2
#define BadLevelMode 4

#define HorzBg (HorzLevelMode|L1LevelMode)
#define HorzLv (HorzLevelMode|L2LevelMode)
#define VertBg (VertLevelMode|L1LevelMode)
#define VertLv (VertLevelMode|L2LevelMode)
#define Garbage BadLevelMode

static const char layermode[0x20]={
	HorzBg,  HorzLv,  HorzLv,  Garbage,
	Garbage, Garbage, Garbage, VertLv,
	VertLv,  Garbage, VertBg,  Garbage,
	HorzBg,  VertBg,  HorzBg,  HorzLv,
	Garbage, HorzBg,  Garbage, Garbage,
	Garbage, Garbage, Garbage, Garbage,
	Garbage, Garbage, Garbage, Garbage,
	Garbage, Garbage, HorzBg,  HorzLv,
};

static DWORD mainthreadid;
static DWORD threadid;
static HANDLE threadhandle;

static volatile const char * romdata;
static volatile int romlen;

static uint8_t * preload_savestate=NULL;
static int preload_statelen;

static int levelnum;

static int fogOfWarType=0;
static int fogOfWarTransparency;
static int fogOfWarAdd;

static int YES=0;
static int NO=0;

static bool shouldReloadSprites=true;

static int maxscrollx=16384;
static int maxscrolly=16384;

static int initaddresses[2][256];
static int initvalues[2][256];
static int numinits[2]={0,0};

static const char * volatile retroloaderr;

uint8_t * wram;
uint16_t * vram;
//uint16_t * cgram;
//uint8_t * aram;//not that I'll need this...
//uint8_t * oam;

uint32_t palette[32768];
int palettetype=0;
const uint8_t pal5to8[3][32]={{
//zsnes mode
	0x00, 0x08, 0x10, 0x18, 0x20, 0x28, 0x30, 0x38,
	0x40, 0x48, 0x58, 0x50, 0x68, 0x60, 0x70, 0x78,
	0x80, 0x88, 0x90, 0x98, 0xA0, 0xA8, 0xB0, 0xB8,
	0xC0, 0xC8, 0xD0, 0xD8, 0xE0, 0xE8, 0xF0, 0xF8,
},{
//bsnes mode
	0x00, 0x08, 0x10, 0x19, 0x21, 0x29, 0x31, 0x3A,
	0x42, 0x4A, 0x52, 0x5A, 0x63, 0x6B, 0x73, 0x7B,
	0x84, 0x8C, 0x94, 0x9C, 0xA5, 0xAD, 0xB5, 0xBD,
	0xC5, 0xCE, 0xD6, 0xDE, 0xE6, 0xEF, 0xF7, 0xFF,
},{
//bsnes with gamma ramp
	0x00, 0x01, 0x03, 0x06, 0x0A, 0x0F, 0x15, 0x1C,
	0x24, 0x2D, 0x37, 0x42, 0x4E, 0x5B, 0x69, 0x78,
	0x88, 0x90, 0x98, 0xA0, 0xA8, 0xB0, 0xB8, 0xC0,
	0xC8, 0xD0, 0xD8, 0xE0, 0xE8, 0xF0, 0xF8, 0xFF,
}};

bool hijackLMsPaletteToo=false;
uint32_t * LMPalHijackBitmap=NULL;
SIZE_T LMPalHijackBitmap_size=-1;//null clearly isn't -1 bytes
int LMPalHijackPitch;
int LMPalHijackWidth;
int LMPalHijackHeight;

static uint16_t lastStatus[0x3800];//same layout as $7xC800

enum snst {//only snes thread may write this
	snst_null,//thread not started
	snst_init,//thread started, trying to load some stuff
	snst_off,//no rom loaded
	snst_nolevel,//no level loaded
	snst_busy,//busy loading something
	snst_finalize,//almost done loading; executing another frame to get valid data into the graphics buffer
	snst_pause,//thread waiting for instructions
	snst_on,//running
} static volatile snesstate=snst_null;

enum lmst {//only main thread may write this
	lmst_off,//not running
	lmst_pause,//paused
	lmst_noinput,//running, but with input disabled
	lmst_on,//running normally
} static volatile lmstate=lmst_off;

static volatile bool mute;//merging this one into lmstate would require three new states, which isn't worth it

EXPORT void LMSW_Variables(const uint16_t * leveltable, const uint16_t * map16)
{
	Map16L1H=leveltable;
	Map16L2H=leveltable+0x1B00;
	Map16L1V=leveltable+0x0000;
	Map16L2V=leveltable+0x1C00;
	map16tiles=map16;
}

EXPORT void LMSW_Functions(CALLBACK void (*pLoadLevel)(int id), CALLBACK void (*pScrollLevelX)(int delta), CALLBACK void (*pScrollLevelY)(int delta))
{
	LoadLevel=pLoadLevel;
	ScrollLevelX=pScrollLevelX;
	ScrollLevelY=pScrollLevelY;
}

int keys[16]={
	'Z',      //RETRO_DEVICE_ID_JOYPAD_B
	'A',      //RETRO_DEVICE_ID_JOYPAD_Y
	VK_SPACE, //RETRO_DEVICE_ID_JOYPAD_SELECT
	VK_RETURN,//RETRO_DEVICE_ID_JOYPAD_START
	VK_UP,    //RETRO_DEVICE_ID_JOYPAD_UP
	VK_DOWN,  //RETRO_DEVICE_ID_JOYPAD_DOWN
	VK_LEFT,  //RETRO_DEVICE_ID_JOYPAD_LEFT
	VK_RIGHT, //RETRO_DEVICE_ID_JOYPAD_RIGHT
	'X',      //RETRO_DEVICE_ID_JOYPAD_A
	'S',      //RETRO_DEVICE_ID_JOYPAD_X
	'Q',      //RETRO_DEVICE_ID_JOYPAD_L
	'W',      //RETRO_DEVICE_ID_JOYPAD_R
	0,        //not mapped
	0,        //not mapped
	0,        //not mapped
	0,        //not mapped
};

#define ModifierKeys() /* */ \
	(GetKeyState(VK_CONTROL)>>15 || GetKeyState(VK_SHIFT)>>15 || GetKeyState(VK_MENU)>>15)
#define KeyMap() /* */ \
	for (int i=0;i<16;i++) { MapKey((i), (keys[i])); }

CALLBACK void myControllerPoll(int16_t * controller)
{
	for (int i=0;i<16;i++) controller[i]=0;
	if (ModifierKeys() || lmstate<lmst_on) return;
#define MapKey(gamepad, keyboard) controller[gamepad]=GetKeyState(keyboard)>>15
	KeyMap();
#undef MapKey
}
CALLBACK void (*PollController)(int16_t * controller)=myControllerPoll;

//Note that this can return true even if LMSW is inactive. Use LMSW_Active() as well.
EXPORT bool LMSW_KeyUsed(char c)
{
	if (ModifierKeys()) return false;
#define MapKey(gamepad, keyboard) if (c==keyboard) return true
	KeyMap();
#undef MapKey
	return false;
}

static int16_t controllerData[16];

#if con_snes>=con_normal
static int X=0;
#endif

static void VideoRefresh(const void *data, unsigned width, unsigned height, size_t pitch)
{
#if con_snes>=con_normal
	static int f=0;
	static int fs=0;
	static time_t ft=0;
	f++;
	if (time(NULL)!=ft)
	{
		ft=time(NULL);
		printf("FPS: %i\n", f-fs);
		printf("FPS2: %i\n", X);
		X=0;
		fs=f;
	}
#endif
#if !forceview
	if (snesstate<snst_finalize) return;
#endif
	uint8_t myBitmap=currentBitmap^1;
	int widthskip=(width==512)?1:0;
	for (int y=0;y<224;y++)
	{
		uint32_t * outputLine = mypixels[myBitmap] + y*256;
		const uint16_t *inputLine = ((const uint16_t*)data) + y*pitch/2;
		for (int x=0;x<256;x++) *outputLine++=palette[inputLine[x<<widthskip]];
	}
//printf("%i ",(int8_t)wram[0x7E17BD]);
	snesoff_x[myBitmap]=(wram[0x7E1462]|(wram[0x7E1463]<<8))-(int8_t)wram[0x7E17BD];
	snesoff_y[myBitmap]=(wram[0x7E1464]|(wram[0x7E1465]<<8))-(int8_t)wram[0x7E17BC]+1;
	//snesoff_x[myBitmap]=(wram[0x7E001A]|(wram[0x7E001B]<<8))-(int8_t)wram[0x7E17BD]*-1;
	//snesoff_y[myBitmap]=(wram[0x7E1464]|(wram[0x7E1465]<<8))-(int8_t)wram[0x7E17BC]+1;
	currentBitmap=myBitmap;
}

static void InputPoll()
{
	if (snesstate<snst_on)
	{
		for (int i=0;i<16;i++) controllerData[i]=0;
		return;
	}
	PollController(controllerData);
}

static int16_t InputRead(unsigned port, unsigned device, unsigned index, unsigned id)
{
	if (port!=0) return 0;
	return controllerData[id];
}

static void AudioSample(int16_t left, int16_t right)
{
	if (snesstate<snst_on) return;
	if (!mute) audio_sample(left, right);
	else audio_sample(0, 0);
}

static size_t AudioSampleBatch(const int16_t *data, size_t frames)
{
	for (size_t i=0;i<frames;i++) AudioSample(data[i*2+0], data[i*2+1]);
	return frames;
}

static bool gfxplus2;

static bool emuEnvironment(unsigned cmd, void *data)
{
	return false;//who cares
}

#define ShowError(err) \
				MessageBox(NULL, err, "LMSW", MB_OK|MB_ICONSTOP|MB_TASKMODAL)

#define DeclareCrash() \
			do \
			{ \
				ShowError("The ROM crashed.\r\nTechnical information: "LINE()); \
				snesstate=snst_off; \
				goto retryloop; \
			} \
			while(0)
#define WaitForRAM(ram, op, value, timeout) \
			frames=0; \
			while (wram[ram] op value) \
			{ \
				retro_run(); \
				frames++; \
				if (frames>=timeout) \
				{ \
					DeclareCrash(); \
				} \
			} \
			CON_SNES_NORMAL(printf("%i/%i\n", frames, timeout));
#define WaitForRAMOneOf3(ram, value1, value2, value3, timeout) \
			frames=0; \
			while (wram[ram] != value1 && wram[ram] != value2 && wram[ram] != value3) \
			{ \
				retro_run(); \
				frames++; \
				if (frames>=timeout) \
				{ \
					DeclareCrash(); \
				} \
			} \
			CON_SNES_NORMAL(printf("%i/%i\n", frames, timeout));
#define WaitForGameMode(mode, timeout) WaitForRAM(0x7E0100, <, mode, timeout)

static WINAPI DWORD ThreadProc(LPVOID ignored)
{
	int last13=0;
	int time13=0;
	MSG msg;
	MSG msg2;
	PeekMessage(&msg, (HWND)-1, LMSW_MSG_FIRST, LMSW_MSG_LAST, PM_NOREMOVE);
	AttachThreadInput(threadid, mainthreadid, TRUE);
	if (!retro_load())
	{
		retroloaderr="Couldn't open retro.dll. Please ensure it's in the correct folder and that it's a 32bit version.";
		snesstate=snst_null;
		ExitThread(1);
	}
	if (retro_api_version()!=RETRO_API_VERSION)
	{
		retroloaderr="retro_api_version() does not match RETRO_API_VERSION. DLL is incompatible.";
		snesstate=snst_null;
		ExitThread(1);
	}
	audio_init(32040.5);//bsnes returns this constant; I'm not going to care about pulling the correct frequency from anywhere.
	retro_set_environment(emuEnvironment);
	retro_init();
	retro_set_video_refresh(VideoRefresh);
	retro_set_audio_sample(AudioSample);
	retro_set_audio_sample_batch(AudioSampleBatch);
	retro_set_input_poll(InputPoll);
	retro_set_input_state(InputRead);
	retro_set_controller_port_device(0, RETRO_DEVICE_JOYPAD);
	snesstate=snst_off;
	for (int b=0;b<32;b++)
	{
		for (int g=0;g<32;g++)
		{
			for (int r=0;r<32;r++)
			{
				int index=b<<10 | g<<5 | r<<0;
				palette[index]=pal5to8[palettetype][b]<<16 | pal5to8[palettetype][g]<<8 | pal5to8[palettetype][r]<<0;
			}
		}
	}
	int frames=0;
	while (true)
	{
retryloop:
		bool found=true;
		if (lmstate<=lmst_pause) GetMessage(&msg, (HWND)-1, LMSW_MSG_FIRST, LMSW_MSG_LAST);
		else found=PeekMessage(&msg, (HWND)-1, LMSW_MSG_FIRST, LMSW_MSG_LAST, PM_REMOVE);
		if (found)
		{
			bool nuke=false;
			if ((msg.message==LMSW_MSG_PAUSE || msg.message==LMSW_MSG_STEP) &&
						PeekMessage(&msg2, (HWND)-1, LMSW_MSG_LOADROM, LMSW_MSG_PAUSE, PM_NOREMOVE)) nuke=true;
			if (PeekMessage(&msg2, (HWND)-1, LMSW_MSG_LOADROM, LMSW_MSG_LOADROM, PM_NOREMOVE)) nuke=true;
			if (PeekMessage(&msg2, (HWND)-1, msg.message, msg.message, PM_NOREMOVE)) nuke=true;
			if (nuke)
			{
				if (msg.lParam) free((void*)msg.lParam);
				continue;
			}
			switch (msg.message)
			{
			case LMSW_MSG_LOADROM:
				{
					snesstate=snst_busy;
					audio_clear();
					if (snesstate>snst_off) retro_unload_game();
					retro_game_info gameinfo={"", (void*)msg.lParam, msg.wParam, NULL};
					retro_load_game(&gameinfo);
					free((void*)msg.lParam);
					wram=((uint8_t*)retro_get_memory_data(RETRO_MEMORY_SYSTEM_RAM))-0x7E0000;//yay, jumping in and out of buffers. I hope valgrind will forgive me
					vram=(uint16_t*)retro_get_memory_data(RETRO_MEMORY_VIDEO_RAM);
					if (!vram)
					{
						snesstate=snst_null;
						retro_deinit();
						audio_term();
						ShowError("retro.dll doesn't provide the needed functions.\r\n"
											"Technical details: VRAM pointer is null");
						ExitThread(1);
					}
					//cgram=(uint16_t*)snes_get_memory_data(SNES_MEMORY_CGRAM);//doesn't exist in libretro, but not needed either
					//aram=snes_get_memory_data(SNES_MEMORY_APURAM);
					//oam=snes_get_memory_data(SNES_MEMORY_OAM);
					if (preload_savestate) free(preload_savestate);
					preload_statelen=retro_serialize_size();
					if (!preload_statelen)
					{
						snesstate=snst_null;
						retro_deinit();
						audio_term();
						ShowError("retro.dll doesn't provide the needed functions.\r\n"
											"Technical details: No savestate support");
						ExitThread(1);
					}
					preload_savestate=(uint8_t*)malloc(preload_statelen);
					//load Mario's graphics and some other important stuff
					wram[0x7E0100]=0x00;//snes.random-induced paranoia
					WaitForGameMode(0x01, 240);//skip Nintendo Presents logo
					wram[0x7E1DF5]=1;
					WaitForGameMode(0x02, 360);//skip some useless fadein as well
					
					//load ARAM
					wram[0x7E0100]=0x11;
					wram[0x7E010A]=0;//save file number
					wram[0x7E141A]=0;//not sublevel
					wram[0x7E141D]=1;//skip mario start
					wram[0x7E1B95]=0;//no yoshi wing levels
					wram[0x7E1425]=0;//no bonus games
					wram[0x7E0109]=0xE9;//force load level 0C5 (to run levelasm init)
					wram[0x7E0DD6]=0;//current player
					wram[0x7E1F11]=1;//current submap
					WaitForGameMode(0x13, 300);
					
					//set up various stuff needed by the screen exit
					wram[0x7E0100]=0x11;
					wram[0x7E005B]=0;//vertical level flag
					wram[0x7E0095]=0;//mario X high
					wram[0x7E0109]=0;//reset the level bypass flag
					wram[0x7E0DBE]=5-1;//life counter, just for good measure
					wram[0x7E0DDA]=0;//force music to reload
					wram[0x7E13BF]=0x80;//level number
					wram[0x7E141A]=1;//sublevel flag, to make it load a screen exit
					wram[0x7E1425]=0;//bonus game flag
					wram[0x7E1B95]=0;//yoshi wings flag
					
					wram[0x7E001E]=0;
					wram[0x7E001F]=0;
					wram[0x7E1466]=0;//from H:none scroll fix
					wram[0x7E1467]=0;
					
#define ramroutine 0x7F4035//can't use sizeof/etc due to scoping
					const uint8_t ramroutinehack[]={
						                       //org $008000
						                       //base $7F4000
						                       //Derpcode:
						0xC2, 0x20,            //REP #$20
						0xA9, 0x00, 0x02,      //LDA.w #$7E0200
						0x8D, 0x81, 0x21,      //STA $2181
						0xA0, 0x7E,            //LDY.b #$7E0200/65536
						0x8C, 0x83, 0x21,      //STY $2183
						0xA9, 0x08, 0x80,      //LDA.w #$8008
						0x8D, 0x00, 0x43,      //STA $4300
						0xA9, 0x18, 0xA2,      //LDA.w #$03A218;random F0 that's not in RAM because RAM->RAM DMA doesn't work
						0x8D, 0x02, 0x43,      //STA $4302
						0xA0, 0x03,            //LDY.b #$03A218/65536
						0x8C, 0x04, 0x43,      //STY $4304
						0xA9, 0x00, 0x02,      //LDA.w #$0200
						0x8D, 0x05, 0x43,      //STA $4305
						0xE2, 0x20,            //SEP #$20
						0xA0, 0x01,            //LDY #$01
						0x8C, 0x0B, 0x42,      //STY $420B
						                       //
						0x20, 0x35, 0x40,      //JSR NextCode
						0xA9, 0x60,            //LDA #$60
						0x8F, 0x35, 0x40, 0x7F,//STA.l NextCode
						0x6B,                  //RTL
						                       //
						                       //NextCode:
						                       //print pc
						0x60,                  //RTS
						};                     
					if (ramroutine!=0x7F4000+sizeof(ramroutinehack)-1)
					{
						ShowError("Internal error.");
						ExitProcess(1);
					}
					memcpy(wram+0x7F4000, ramroutinehack, sizeof(ramroutinehack));
					wram[0x7F8000]=0x4C;//JMP $4000
					wram[0x7F8001]=0x00;
					wram[0x7F8002]=0x40;
					
					for (int i=0;i<numinits[0];i++)
					{
						wram[initaddresses[0][i]]=initvalues[0][i];
					}
					
					retro_serialize(preload_savestate, preload_statelen);
					snesstate=snst_nolevel;
					break;
				}
			case LMSW_MSG_RELOADROM:
				{
					audio_clear();
					uint8_t tmpsavestate[preload_statelen];
					retro_serialize(tmpsavestate, preload_statelen);
					retro_unload_game();
					retro_game_info gameinfo={NULL, (void*)msg.lParam, msg.wParam, NULL};
					retro_load_game(&gameinfo);
					free((void*)msg.lParam);
					retro_unserialize(tmpsavestate, preload_statelen);
					wram=((uint8_t*)retro_get_memory_data(RETRO_MEMORY_SYSTEM_RAM))-0x7E0000;//no point not reloading this
					vram=(uint16_t*)retro_get_memory_data(RETRO_MEMORY_VIDEO_RAM);
					break;
				}
			case LMSW_MSG_LOADLEVEL:
				{
					audio_clear();
					snesstate=snst_busy;
					retro_unserialize(preload_savestate, preload_statelen);
					
					//set up a fake screen exit
					wram[0x7E19B8]=msg.wParam&0xFF;
					wram[0x7E19D8]=msg.wParam>>8|4;//for compatibility with LM hacks - an LM module that's incompatible with LM is completely ridiculous
					wram[0x7E1F11]=msg.wParam>>8;
					if(0);
					else if (levelnum<=0x024) wram[0x7E13BF]=levelnum;
					else if (levelnum<=0x0FF) wram[0x7E13BF]=0x00;
					else if (levelnum<=0x100) wram[0x7E13BF]=0x60;
					else if (levelnum<=0x13B) wram[0x7E13BF]=levelnum-0xDC;
					else if (levelnum<=0x1FF) wram[0x7E13BF]=0x60;
					//fusoya says it must be at the correct direction of 0x24 for screen exits to work in unedited levels
					
					//set the switch palaces
					wram[0x7E1F27]=switchpalaces[0];
					 wram[0x7E1F28]=switchpalaces[1];
					 wram[0x7E1F29]=switchpalaces[2];
					 wram[0x7E1F2A]=switchpalaces[3];
					
					//and load the level
					WaitForGameMode(0x13, 600);
					if (wram[0x7E0D9B]&0x80)
					{
						snesstate=snst_on;
						break;
					}
					
					if (wram[0x7E0DAE]==0x00) 
					{
						wram[0x7E0100]=0x14;//finalize the game mode
						wram[0x7E0DAE]=0x0F;//fix brightness since we skipped the fadein
						wram[0x7E0DAF]=0x01;//fix mosaic direction
						wram[0x7E0DB0]=0x00;//and remove the actual mosaic
					}
					else WaitForGameMode(0x14, 60);//for compatibility with ersan's windowing patch - I don't want to hardcode anything specific to that one
					
					for (int i=0;i<numinits[1];i++)
					{
						wram[initaddresses[1][i]]=initvalues[1][i];
					}
					
					snesstate=snst_finalize;
					retro_run();
					if (PeekMessage(&msg2, (HWND)-1, LMSW_MSG_LOADLEVEL, LMSW_MSG_LOADLEVEL, PM_NOREMOVE)) break;
					if (wram[0x7E1403])
					{
						for (int i=0;i<0x1C00;i++)
						{
							lastStatus[i]=wram[0x7EC800+i]|(wram[0x7FC800+i]<<8);//Map16L1H[i];
						}
						for (int i=0x1C00;i<0x3800;i++)
						{
							lastStatus[i]=Map16L1H[i];//for the tides
						}
					}
					else
					{
						for (int i=0;i<0x3800;i++)
						{
							lastStatus[i]=wram[0x7EC800+i]|(wram[0x7FC800+i]<<8);//Map16L1H[i];
						}
					}
					snesstate=snst_on;
					break;
				}
			case LMSW_MSG_RELOADSPR:
				{
					if (wram[0x7E0D9B]&0x80) break;
					for (int i=0;i<128;i++) wram[0x7E1938+i]=0;
					for (int i=0;i<12;i++) wram[0x7E161A+i]=0xFF;
					const uint8_t reloadspritecode[]={
						0x22, 0x51, 0xA7, 0x02,//JSL $02A751
						0x60,                  //RTS
					};
					wram[0x7E00CE]=(uint8_t)((ramroutine+sizeof(reloadspritecode)-1)>>0);
					wram[0x7E00CF]=(uint8_t)((ramroutine+sizeof(reloadspritecode)-1)>>8);
					wram[0x7E00D0]=(uint8_t)((ramroutine+sizeof(reloadspritecode)-1)>>16);
					memcpy(wram+ramroutine+sizeof(reloadspritecode), (void*)msg.lParam, msg.wParam);
					free((void*)msg.lParam);
					if (shouldReloadSprites)
					{
						for (int i=0;i<12;i++) wram[0x7E14C8+i]=0;
						wram[0x7E1B94]=0;//to not make the bonus game disappear
						memcpy(wram+ramroutine, reloadspritecode, sizeof(reloadspritecode));
						WaitForRAMOneOf3(0x7E0100, 0x14, 0x0C, 0x00, 600);//in case we're in a transition, wait for it to finish
						if (wram[0x7E0100]!=0x14)//dead or whatever
						{
							wram[ramroutine]=0x60;
							break;
						}
						WaitForRAM(ramroutine, !=, 0x60, 10);//force that code to run
					}
					break;
				}
			case LMSW_MSG_PAUSE:
				{
					audio_clear();
					if (msg.wParam) snesstate=snst_nolevel;
					break;
				}
			case LMSW_MSG_STEP:
				{
					bool m=mute;
					mute=true;
					retro_run();
					mute=m;
					break;
				}
			case LMSW_MSG_TERM:
				{
					if (snesstate>snst_off)
					{
						retro_unload_game();
						free((void*)romdata);
					}
					if (preload_savestate)
					{
						free(preload_savestate);
						preload_savestate=NULL;
					}
					audio_term();
					retro_deinit();
					return 0;
				}
			}
		}
		else if (snesstate>=snst_on && (wram[0x7E0D9B]&0x80)==0x00)
		{
			retro_run();
			if (wram[0x7E1426]==0 && wram[0x7E1493]==0) wram[0x7E13D2]=0;//nuke some message box bug
			if (wram[0x7E0013]==last13)
			{
				time13++;
				if (time13==((wram[0x7E0100]==0x14)?10:600)) DeclareCrash();
			}
			else
			{
				last13=wram[0x7E0013];
				time13=0;
				if (NO) wram[0x7E0000|(rand()&0x1FFF)]=rand();
			}
		}
	}
	return -1;
}

#define cfgerror() return "Invalid data in lmsw.cfg."
#ifdef FUSOYA
EXPORT const char * LMSW_Init()
{
	return "This is a private build.";
}

EXPORT const char * LMSW_Init_Private()
#else
EXPORT const char * LMSW_Init();
EXPORT const char * LMSW_Init_Private()
{
	const char * ret=LMSW_Init();
	CON_LM_NORMAL(puts("LMSW_Init_Private"));
	return ret;
}

EXPORT const char * LMSW_Init()
#endif
{
	srand(time(NULL));
#if con_snes>=con_normal || con_lm>=con_normal
	if (!AttachConsole(ATTACH_PARENT_PROCESS)) AllocConsole();
	freopen("CONIN$", "rt", stdin);
	freopen("CONOUT$", "wt", stdout);
	freopen("CONOUT$", "wt", stderr);
#endif
	CON_LM_NORMAL(puts("LMSW_Init"));
#if 1
	char lmpos[MAX_PATH+1];
	GetModuleFileName(NULL, lmpos, MAX_PATH);
	char * endpath=strrchr(lmpos, '\\');
	char * endpath2=strrchr(lmpos, '/');
	if (endpath2>endpath) endpath=endpath2;
	if (endpath) endpath[1]=0;
	strcat(lmpos, "lmsw.cfg");
	FILE * keyfile=fopen(lmpos, "rt");
#else
	FILE * keyfile=fopen("lmsw.cfg", "rt");
#endif
	if (keyfile)
	{
		char line[256];
		while (!feof(keyfile))
		{
			fgets(line, 256, keyfile);
			if (strchr(line, '\r')) strchr(line, '\r')[0]='\0';
			if (strchr(line, '\n')) strchr(line, '\n')[0]='\0';
			if (strchr(line, '#')) strchr(line, '#')[0]='\0';
			while (strrchr(line, ' ') && strrchr(line, ' ')[1]=='\0') strrchr(line, ' ')[0]='\0';
			if (strchr(line, '='))
			{
				int numpars=0;
				int arg[64];
				char * x=strchr(line, '=');
				char * rawdata=x+1;
				bool isnums=true;
				do
				{
					char * y;
					if (!isdigit(x[1]))
					{
						isnums=false;
						break;
					}
					arg[numpars]=strtol(x+1, &y, 10);
					if (x==y)
					{
						isnums=false;
						break;
					}
					x=y;
					numpars++;
				}
				while (*x==',');
				if (*x) isnums=false;
				if(0);
#define handle(str, numargs) else if (!strncmp(line, str"=", strlen(str"=")) && isnums && numpars==numargs)
#define handleraw(str) else if (!strncmp(line, str"=", strlen(str"=")))
#define handleraw2(str1, str2) else if (!strncmp(line, str1"=", strlen(str1"=")) || !strncmp(line, str2"=", strlen(str2"=")))
#define clamp(id, max) if (arg[id]>max) cfgerror()
				handle("keys", 12)
				{
					for (int i=0;i<12;i++) keys[i]=arg[i];
				}
				handle("hide", 5)
				{
					clamp(0, 2); clamp(1, 255); clamp(2, 255); clamp(3, 255); clamp(4, 255);
					fogOfWarType=arg[0];
					fogOfWarTransparency=arg[4];
					fogOfWarAdd=
									(((arg[1]*(256-fogOfWarTransparency))/256)<< 0)|
									(((arg[2]*(256-fogOfWarTransparency))/256)<< 8)|
									(((arg[3]*(256-fogOfWarTransparency))/256)<<16);
				}
				handle("maxscroll", 2)
				{
					maxscrollx=arg[0]?arg[0]:16384;
					maxscrolly=arg[1]?arg[1]:16384;
				}
				handle("reloadspr", 1)
				{
					clamp(0, 1);
					shouldReloadSprites=arg[0];
				}
				handle(":)", 1)
				{
					YES=arg[0];
				}
				handle(":(", 1)
				{
					NO=arg[0];
				}
				handle("colormode", 1)
				{
					clamp(0, 2);
					int palettetypefromid[]={0,1,2,1,2};
					bool hijacklmflags[]={0,0,0,1,1};
					palettetype=palettetypefromid[arg[0]];
					hijackLMsPaletteToo=hijacklmflags[arg[0]];
				}
				handleraw2("init1", "init2")
				{
					int id=(!strncmp(line, "init2", strlen("init2")));
					while (true)
					{
						int i;
						for (i=0;isxdigit(rawdata[i]);i++);
						if (i!=2 && i!=4 && i!=6) cfgerror();
						if (rawdata[i]!='=') cfgerror();
						int addr=strtol(rawdata, NULL, 16);
						if (i==6 && (addr&0xFE0000)!=0x7E0000) cfgerror();
						if (i==4 && addr&0xE000) cfgerror();
						addr|=0x7E0000;
						rawdata+=i+1;
						for (i=0;isxdigit(rawdata[i]);i++);
						if (!i || i&1) cfgerror();
						for (int j=0;j<i/2;j++)
						{
							char c=rawdata[2];
							rawdata[2]=0;
							initaddresses[id][numinits[id]]=addr+j;
							initvalues[id][numinits[id]]=strtol(rawdata, NULL, 16);
							numinits[id]++;
							rawdata[2]=c;
							rawdata+=2;
						}
						if (rawdata[0])
						{
							if (rawdata[0]!=',') cfgerror();
							rawdata++;
						}
						else break;
					}
				}
				else cfgerror();
			}
			else if (*line) cfgerror();
		}
	}
	memset(mypixels[0], 0x00, 2*256*224*4);
	mainthreadid=GetCurrentThreadId();
	lmstate=lmst_off;
	snesstate=snst_init;
	threadhandle=CreateThread(NULL, 0, ThreadProc, NULL, 0, &threadid);
	while (snesstate==snst_init) Sleep(10);
	if (snesstate==snst_null)
	{
		CloseHandle(threadhandle);
		return retroloaderr;
	}
	currentBitmap=0;
	mute=false;
	return NULL;
}

EXPORT int LMSW_ApiVersion()
{
	return 101;
}

EXPORT void LMSW_Pause(int pause)
{
	CON_LM_NORMAL(puts("LMSW_Pause"));
	if (lmstate==lmst_off) return;
	if (pause==2)
	{
		if (lmstate!=lmst_pause) PostThreadMessage(threadid, LMSW_MSG_PAUSE, 0, 0);
		lmstate=lmst_pause;
	}
	else
	{
		if (lmstate==lmst_pause) PostThreadMessage(threadid, LMSW_MSG_PAUSE, 0, 0);//just to wake it up
		lmstate=(pause==1)?lmst_noinput:lmst_on;
	}
}

EXPORT void LMSW_Step()
{
	CON_LM_VERBOSE(puts("LMSW_Step"));
	PostThreadMessage(threadid, LMSW_MSG_STEP, 0, 0);
}

EXPORT void LMSW_Stop()
{
	CON_LM_NORMAL(puts("LMSW_Stop"));
	if (lmstate==lmst_off) return;
	PostThreadMessage(threadid, LMSW_MSG_PAUSE, 1, 0);
	lmstate=lmst_off;
	snesstate=snst_off;
}

EXPORT void LMSW_Term()
{
	CON_LM_NORMAL(puts("LMSW_Term"));
	if (lmstate!=lmst_off) LMSW_Stop();
	PostThreadMessage(threadid, LMSW_MSG_TERM, 0, 0);
	WaitForSingleObject(threadhandle, INFINITE);
	CloseHandle(threadhandle);
}

uint16_t pipedat[4][8][4];

static void PrepareROM(unsigned char * romdata)
{
	//install levelnum
	romdata[0x2D8B9]=0x20;
	 romdata[0x2D8BA]=0x46;
	 romdata[0x2D8BB]=0xDC;
	
	romdata[0x2DC46]=0xA5;
	 romdata[0x2DC47]=0x0E;
	romdata[0x2DC48]=0x8D;
	 romdata[0x2DC49]=0x0B;
	 romdata[0x2DC4A]=0x01;
	romdata[0x2DC4B]=0x0A;
	romdata[0x2DC4C]=0x60;
	
	memcpy(&romdata[0x07FC0], "LMSW ENABLED ROM     ", 21);
	
	romdata[0x2DAEF]=0x60;
	
	//extract the vertical pipe tiles
	for (int col=0;col<4;col++)
	{
		int addr;
		addr=snestopc(0x058776+col*2);
		addr=snestopc(0x0D0000|romdata[addr+1]<<8|romdata[addr]);
		memcpy(pipedat[col], romdata+addr, 8*4*2);
	}
}

EXPORT void LMSW_LoadROM(const char * romdata, int romlen)
{
	CON_LM_NORMAL(puts("LMSW_LoadROM"));
	gfxplus2=(romdata[0x001E2]==0x5C);//$00:81E2, fusoya says this is what LM does
	unsigned char * romdatacopy=(unsigned char*)malloc(romlen);
	memcpy(romdatacopy, romdata, romlen);
	PrepareROM(romdatacopy);
//FILE*f=fopen("r.swc","wb");fwrite(romdata,1,romlen,f);fclose(f);
	PostThreadMessage(threadid, LMSW_MSG_LOADROM, (WPARAM)romlen, (LPARAM)romdatacopy);
}

EXPORT void LMSW_ReloadROM(const char * romdata, int romlen)
{
	CON_LM_NORMAL(puts("LMSW_ReloadROM"));
	if (gfxplus2!=(romdata[0x001E2]==0x5C))
	{
		LMSW_LoadROM(romdata, romlen);
		return;
	}
	unsigned char * romdatacopy=(unsigned char*)malloc(romlen);
	memcpy(romdatacopy, romdata, romlen);
	PrepareROM(romdatacopy);
	PostThreadMessage(threadid, LMSW_MSG_RELOADROM, (WPARAM)romlen, (LPARAM)romdatacopy);
}

EXPORT void LMSW_ReloadSprites(const char * sprdata, int len)
{
	CON_LM_NORMAL(puts("LMSW_ReloadSprites"));
	char * sprdatacopy=(char*)malloc(len);
	memcpy(sprdatacopy, sprdata, len);
	PostThreadMessage(threadid, LMSW_MSG_RELOADSPR, (WPARAM)len, (LPARAM)sprdatacopy);
}

inline void SetTile(int x, int y, bool layer2, uint16_t tile, uint8_t frameId)
{
	int offx=x-snesoff_x[frameId]/16;
	int offy=y-snesoff_y[frameId]/16;
	if (gfxplus2)
	{
		if (offx<-1 || offx>17) return;
		if (offy<0 || offy>15) return;
		for (int i=0;i<4;i++)
		{
			uint16_t tiledat=map16tiles[tile<<2|i];
			if (tile>=0x133 && tile<=0x13A) tiledat=pipedat[(x/16)&0x03][tile-0x133][i];
			vram[0x3000|(layer2<<11)      |      (x&0x10)<<6|(y&0x0F)<<6|(i&1)<<5|(x&0x0F)<<1|(i&2)>>1]=tiledat;
		}
	}
	else
	{
		if (offx<-8 || offx>=8+16) return;
		if (offy<-8 || offy>=8+16) return;
		for (int i=0;i<4;i++)
		{
			uint16_t tiledat=map16tiles[tile<<2|i];
			if (tile>=0x133 && tile<=0x13A) tiledat=pipedat[(x/16)&0x03][tile-0x133][i];
			vram[0x2000|(layer2<<12)|(y&0x10)<<7|(x&0x10)<<6|(y&0x0F)<<6|(i&1)<<5|(x&0x0F)<<1|(i&2)>>1]=tiledat;
		}
	}
}

EXPORT void LMSW_LoadLevel(int levelnum_)
{
	CON_LM_NORMAL(puts("LMSW_LoadLevel"));
	lmstate=lmst_on;
	PostThreadMessage(threadid, LMSW_MSG_LOADLEVEL, levelnum_, 0);
	levelnum=levelnum_;
	//wram[0x7E010B]=levelnum;
	//wram[0x7E010C]=levelnum>>8;
	for (int i=0;i<0x3800;i++)
	{
		lastStatus[i]=-1;//Map16L1H[i];
	}
}

static int maintransp[2]={256,256};
static int brdrtransp[2]={256,256};
static int brdradd[2]={0,0};

static int gettransp(uint32_t col)
{
	return ((col>>24)==255)?256:(col>>24);
}

EXPORT void LMSW_SetColors(uint32_t mainunpause, uint32_t mainpause, uint32_t brdrunpause, uint32_t brdrpause)
{
#if con_lm>=con_verbose
	puts("LMSW_SetColors");
#endif
	maintransp[0]=gettransp(mainunpause);
	maintransp[1]=gettransp(mainpause);
	brdrtransp[0]=gettransp(brdrunpause);
	brdrtransp[1]=gettransp(brdrpause);
	brdradd[0]=
				((((brdrunpause&0x0000FF)*(gettransp(brdrunpause)))/256)&0x0000FF)|
				((((brdrunpause&0x00FF00)*(gettransp(brdrunpause)))/256)&0x00FF00)|
				((((brdrunpause&0xFF0000)*(gettransp(brdrunpause)))/256)&0xFF0000);
	brdradd[1]=
				((((brdrpause&0x0000FF)*(gettransp(brdrpause)))/256)&0x0000FF)|
				((((brdrpause&0x00FF00)*(gettransp(brdrpause)))/256)&0x00FF00)|
				((((brdrpause&0xFF0000)*(gettransp(brdrpause)))/256)&0xFF0000);
}

EXPORT void LMSW_DrawEmulated(uint32_t * bitmap, int pitch, int xoff, int yoff, int width, int height, RECT * rect)
{
	CON_LM_VERBOSE(puts("LMSW_DrawEmulated"));
	if (hijackLMsPaletteToo)
	{
		LMPalHijackBitmap=bitmap;
		MEMORY_BASIC_INFORMATION mem={};
		VirtualQuery(LMPalHijackBitmap, &mem, sizeof(mem));
		LMPalHijackBitmap_size=mem.RegionSize;
		LMPalHijackPitch=pitch;
		LMPalHijackWidth=width;
		LMPalHijackHeight=height;
	}
	if (rect)
	{
		rect->left=0;
		rect->top=0;
		rect->right=0;
		rect->bottom=0;
	}
//printf("%i-%i=%i;%i\n",pitch,width,pitch-width,height);
//if (snesstate<=snst_nolevel)return;else if(1);else
#if !forceview
	if (lmstate<lmst_pause || snesstate<snst_on || wram[0x7E0D9B]&0x80) return;
#endif
	int opacity=maintransp[(lmstate<=lmst_pause)?1:0];
	volatile uint8_t frameId=currentBitmap;
#define POS(x, y) ((bitmap)+((y)*(pitch))+(x))
	int xstart=xoff+snesoff_x[frameId];
	int ystart=yoff+snesoff_y[frameId];
	
	if (rect)
	{
		rect->left=max(xstart, 0);
		rect->top=max(ystart, 0);
		rect->right=min(xstart+256, width);
		rect->bottom=min(ystart+224, height);
	}
	
	if ((fogOfWarType==1 && lmstate>=lmst_on) || (fogOfWarType==2 && lmstate>=lmst_pause))
	{
		if (fogOfWarTransparency==0)
		{
			for (int i=0;i<pitch*height;i++)
			{
				bitmap[i]=fogOfWarAdd;
			}
		}
		else
		{
			for (int i=0;i<pitch*height;i++)
			{
				bitmap[i]=fogOfWarAdd+(
						(((bitmap[i]&0x0000FF)*(fogOfWarTransparency)/256)&0x0000FF)|
						(((bitmap[i]&0x00FF00)*(fogOfWarTransparency)/256)&0x00FF00)|
						(((bitmap[i]         )*(fogOfWarTransparency)/256)&0xFF0000));
			}
		}
	}
	
	if (opacity==256)
	{
		for (int y=0;y<224;y++)
		{
			int truey=y+ystart;
			if (truey<0 || truey>=height) continue;
			memcpy(bitmap+(truey*pitch)+max(xstart, 0), mypixels[frameId]+(y*256)-min(xstart, 0), max((min(xstart, 0))+(min(width-xstart, 256)), 0)*4);
		}
	}
	else
	{
		for (int y=0;y<224;y++)
		{
			int truey=y+ystart;
			if (truey<0 || truey>=height) continue;
			uint32_t * line=bitmap+(truey*pitch)+xstart;
			for (int x=-min(xstart, 0);x<min(width-xstart, 256);x++)
			{
				line[x]=
						((((line[x]&0x0000FF)*(256-opacity)+(mypixels[frameId][y*256+x]&0x0000FF)*opacity)/256)&0x0000FF)|
						((((line[x]&0x00FF00)*(256-opacity)+(mypixels[frameId][y*256+x]&0x00FF00)*opacity)/256)&0x00FF00)|
						((((line[x]         )*(256-opacity)+(mypixels[frameId][y*256+x]         )*opacity)/256)&0xFF0000);
			}
		}
	}
	
#if forceview
	if (lmstate<lmst_pause || snesstate<snst_on) return;
#endif
	
	if (lmstate<=lmst_pause) return;
	
	if (wram[0x7E0100]==0x13)
	{
		if ((wram[0x7E010B]|(wram[0x7E010C]<<8))!=levelnum)
		{
			levelnum=(wram[0x7E010B]|(wram[0x7E010C]<<8));
			LoadLevel(levelnum);//Note to self: After this point, the bitmap may not be touched.
			for (int i=0;i<0x3800;i++)
			{
				lastStatus[i]=-1;//Map16L1H[i];
			}
		}
	}
	
	if (wram[0x7E0100]==0x14)
	{
//printf("%i %i %i  %i %i %i\n",xoff,xstart,width,yoff,ystart,height);
//static int h=0;
//h++;
//if (h==60) exit(0);
//X++;
		static int framecounter=0;
		framecounter++;
		//if ((framecounter&1)==0)
		{
			if (xstart    <0      && width >256) ScrollLevelX(min(max(-maxscrollx, 256-width ), xstart       ))
											,CON_SNES_NORMAL(printf("X+=%i\n",min(max(-maxscrollx, 256-width ), xstart       )));
			if (xstart+256>width  && width >256) ScrollLevelX(max(min( maxscrollx, width-256 ), xstart-width ))
											,CON_SNES_NORMAL(printf("X+=%i\n",max(min( maxscrollx, width-256 ), xstart-width )));
			if (ystart    <0      && height>224) ScrollLevelY(min(max(-maxscrolly, 224-height), ystart       ))
											,CON_SNES_NORMAL(printf("Y+=%i\n",min(max(-maxscrolly, 224-height), ystart       )));
			if (ystart+224>height && height>224) ScrollLevelY(max(min( maxscrolly, height-224), ystart-height))
											,CON_SNES_NORMAL(printf("Y+=%i\n",max(min( maxscrolly, height-224), ystart-height)));
		}
		
		int levelmode=layermode[wram[0x7E1925]];
		if (levelmode==Garbage) return;
		if (!(levelmode&VertLevelMode))
		{
			for (int i=0;i<((levelmode&L2LevelMode)?0x1B00:0x3600);i++)
			{
				if (lastStatus[i]!=Map16L1H[i])
				{
					lastStatus[i]=Map16L1H[i];
					wram[0x7EC800+i]=Map16L1H[i]&0xFF;
					wram[0x7FC800+i]=Map16L1H[i]>>8;
					SetTile((i&15)|(i/0x1B0<<4), (i>>4)%0x1B, false, Map16L1H[i], frameId);
				}
				if ((levelmode&L2LevelMode) && lastStatus[i+0x1B00]!=Map16L2H[i])
				{
					lastStatus[i+0x1B00]=Map16L2H[i];
					wram[0x7EC800+i+0x1B00]=Map16L2H[i]&0xFF;
					wram[0x7FC800+i+0x1B00]=Map16L2H[i]>>8;
					SetTile((i&15)|(i/0x1B0<<4), (i>>4)%0x1B, true, Map16L2H[i], frameId);
				}
			}
		}
		else
		{
			for (int i=0;i<((levelmode&L2LevelMode)?0x1C00:0x3800);i++)
			{
				if (lastStatus[i]!=Map16L1V[i])
				{
					lastStatus[i]=Map16L1V[i];
					wram[0x7EC800+i]=Map16L1V[i]&0xFF;
					wram[0x7FC800+i]=Map16L1V[i]>>8;
					SetTile((i&15)|((i&0x100)>>4), ((i&0xF0)>>4)|((i&0x3E00)>>5), false, Map16L1V[i], frameId);
				}
				if ((levelmode&L2LevelMode) && lastStatus[i+0x1C00]!=Map16L2V[i])
				{
					lastStatus[i+0x1C00]=Map16L2V[i];
					wram[0x7EC800+i+0x1C00]=Map16L2V[i]&0xFF;
					wram[0x7FC800+i+0x1C00]=Map16L2V[i]>>8;
					SetTile((i&15)|((i&0x100)>>4), ((i&0xF0)>>4)|((i&0x3E00)>>5), true, Map16L2V[i], frameId);
				}
			}
		}
	}
	else if (wram[0x7E0100]==0x0C ||//load overworld
						wram[0x7E0100]==0x0D ||//fade to overworld
						wram[0x7E0100]==0x0E ||//run overworld
						wram[0x7E0100]==0x16 ||//load Time Up
						wram[0x7E0100]==0x17)//Time Up
	{
		wram[0x7E0100]=0x00;//to not trigger this one again
		LMSW_Stop();
	}
#undef POS
}

EXPORT void LMSW_DrawBorder(uint32_t * bitmap, int pitch, int xoff, int yoff, int width, int height, RECT * rect)
{
	CON_LM_VERBOSE(puts("LMSW_DrawBorder"));
	if (rect)
	{
		rect->left=0;
		rect->top=0;
		rect->right=0;
		rect->bottom=0;
	}
	if (lmstate<lmst_pause || snesstate<snst_on || wram[0x7E0D9B]&0x80) return;
	//while (busy) Sleep(1);//synchronize with libsnes to kill race conditions
	volatile uint8_t frameId=currentBitmap;
#define POS(x, y) ((bitmap)+((y)*(pitch))+(x))
	int xstart=xoff+snesoff_x[frameId];
	int ystart=yoff+snesoff_y[frameId];
	
	int pausestate=(lmstate<=lmst_pause)?1:0;
	int opacity=brdrtransp[pausestate];
	int coladd=brdradd[pausestate];
	
	if (rect)
	{
		rect->left=max(xstart-1, 0);
		rect->top=max(ystart-1, 0);
		rect->right=min(xstart+256+1, width);
		rect->bottom=min(ystart+224+1, height);
	}
	
	uint32_t *outputLine;
	if (opacity==256)
	{
		if (ystart>0 && ystart<height)
		{
			outputLine=POS(xstart-1, ystart-1);
			if (xstart<=0) outputLine-=xstart-1;
			for (int x=-min(xstart-1, 0);x<min(width-xstart, 258);x++) *outputLine++=coladd;
		}
		
		if (ystart+224>0 && ystart+224<height)
		{
			outputLine=POS(xstart-1, ystart+224);
			if (xstart<=0) outputLine-=xstart-1;
			for (int x=-min(xstart-1, 0);x<min(width-xstart, 258);x++) *outputLine++=coladd;
		}
		
		if (xstart>0 && xstart<width)
		{
			outputLine=POS(xstart-1, ystart);
			if (ystart<0) outputLine-=ystart*pitch;
			for (int y=-min(ystart, 0);y<min(height-ystart, 224);y++)
			{
				*outputLine=coladd;
				outputLine+=pitch;
			}
		}
		
		if (xstart+256>0 && xstart+256<width)
		{
			outputLine=POS(xstart+256, ystart);
			if (ystart<0) outputLine-=ystart*pitch;
			for (int y=-min(ystart, 0);y<min(height-ystart, 224);y++)
			{
				*outputLine=coladd;
				outputLine+=pitch;
			}
		}
	}
	else
	{
		if (ystart>0 && ystart<height)
		{
			outputLine=POS(xstart-1, ystart-1);
			if (xstart<=0) outputLine-=xstart-1;
			for (int x=-min(xstart-1, 0);x<min(width-xstart, 258);x++)
			{
				*outputLine=coladd+(
					(((*outputLine&0x0000FF)*(256-opacity)/256)&0x0000FF)|
					(((*outputLine&0x00FF00)*(256-opacity)/256)&0x00FF00)|
					(((*outputLine         )*(256-opacity)/256)&0xFF0000));
				outputLine++;
			}
		}
		
		if (ystart+224>0 && ystart+224<height)
		{
			outputLine=POS(xstart-1, ystart+224);
			if (xstart<=0) outputLine-=xstart-1;
			for (int x=-min(xstart-1, 0);x<min(width-xstart, 258);x++)
			{
				*outputLine=coladd+(
					(((*outputLine&0x0000FF)*(256-opacity)/256)&0x0000FF)|
					(((*outputLine&0x00FF00)*(256-opacity)/256)&0x00FF00)|
					(((*outputLine         )*(256-opacity)/256)&0xFF0000));
				outputLine++;
			}
		}
		
		if (xstart>0 && xstart<width)
		{
			outputLine=POS(xstart-1, ystart);
			if (ystart<0) outputLine-=ystart*pitch;
			for (int y=-min(ystart, 0);y<min(height-ystart, 224);y++)
			{
				*outputLine=coladd+(
					(((*outputLine&0x0000FF)*(256-opacity)/256)&0x0000FF)|
					(((*outputLine&0x00FF00)*(256-opacity)/256)&0x00FF00)|
					(((*outputLine         )*(256-opacity)/256)&0xFF0000));
				outputLine+=pitch;
			}
		}
		
		if (xstart+256>0 && xstart+256<width)
		{
			outputLine=POS(xstart+256, ystart);
			if (ystart<0) outputLine-=ystart*pitch;
			for (int y=-min(ystart, 0);y<min(height-ystart, 224);y++)
			{
				*outputLine=coladd+(
					(((*outputLine&0x0000FF)*(256-opacity)/256)&0x0000FF)|
					(((*outputLine&0x00FF00)*(256-opacity)/256)&0x00FF00)|
					(((*outputLine         )*(256-opacity)/256)&0xFF0000));
				outputLine+=pitch;
			}
		}
	}
#undef POS
}

#define LMSW_OFF 0//Not initialized, no ROM given, or LMSW_Stop called.
#define LMSW_BUSY 1//Fastforwarding through a loading routine. Will soon change to LMSW_ON or LMSW_PAUSE.
#define LMSW_PAUSE 2//Paused. Can draw, but won't move.
#define LMSW_NOMOVE 3//Input disabled.
#define LMSW_ON 4//Currently active.
EXPORT int LMSW_Active()
{
	CON_LM_VERBOSE(puts("LMSW_Active"));
	if (hijackLMsPaletteToo && LMPalHijackBitmap)
	{
		MEMORY_BASIC_INFORMATION mem={};
		VirtualQuery(LMPalHijackBitmap, &mem, sizeof(mem));
		if (mem.BaseAddress==LMPalHijackBitmap && mem.RegionSize==LMPalHijackBitmap_size)//if it moves, fail quickly
		{
			if ((LMPalHijackBitmap[0]&1)==0)
			{
				for (int i=0;i<LMPalHijackPitch*LMPalHijackHeight;i++)
				{
					int col24=LMPalHijackBitmap[i];
					int col15=
						((col24&0xFF0000)>>(16+3)<<10)|
						((col24&0x00FF00)>>( 8+3)<< 5)|
						((col24&0x0000FF)>>( 0+3)<< 0);
					LMPalHijackBitmap[i]=palette[col15];
				}
			}
			LMPalHijackBitmap[0]|=1;//this may be inaccurate, but I waste cpu and risk higher inaccuracy by converting twice.
		}
		else LMPalHijackBitmap=NULL;
		//memset(LMPalHijackBitmap, 0, LMPalHijackPitch*LMPalHijackHeight*4);
	}
	if (Map16L1H)
	{
		for (int i=0;i<YES;i++) ((uint16_t*)Map16L1H)[i]=303;
	}
	if (lmstate<=lmst_off || snesstate<=snst_nolevel) return LMSW_OFF;
#if forceview
	return LMSW_ON;
#endif
	if (snesstate<snst_on) return LMSW_BUSY;
	if (lmstate<=lmst_pause) return LMSW_PAUSE;
	if (lmstate<=lmst_noinput) return LMSW_NOMOVE;
	return LMSW_ON;
}

EXPORT void LMSW_SetSound(bool on)
{
	CON_LM_NORMAL(puts("LMSW_SetSound"));
	mute=!on;
}

EXPORT void LMSW_SwitchFlags(int flagmask)
{
	switchpalaces[0]=(flagmask&1)>>0;
	switchpalaces[1]=(flagmask&2)>>1;
	switchpalaces[2]=(flagmask&4)>>2;
	switchpalaces[3]=(flagmask&8)>>3;
}
