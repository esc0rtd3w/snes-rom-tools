//#ifdef DEBUG
#if 0
#include <stdint.h>
#include <string.h>

const int chardat=0x0000;

extern uint8_t * wram;
extern uint16_t * vram;
extern uint16_t * cgram;
extern uint8_t * aram;//not that I'll need this...
extern uint8_t * oam;

extern uint32_t palette[32768];

uint32_t * pixels;
void initstuff(uint32_t * mypixels)
{
	pixels=mypixels;
}

void drawstuff()
{
	for (int l=0;l<2;l++)
	{
		for (int xt=0;xt<64;xt++)
		{
			for (int yt=0;yt<64;yt++)
			{
				uint32_t * tilepix=pixels+(xt*8)+(yt*8*1024)+(l*512);
				int stat=vram[0x2000+l*0x1000+(yt&32)*64+(xt&32)*32+(yt&31)*32+(xt&31)*1];
				int tileoff=(chardat+(stat&0x3FF)*32)/2;
				int pal=(stat&0x1C00)>>2>>4;
				uint8_t tile[8][8];
				memset(tile, 0, 64);
				for (int yp=0;yp<8;yp++)
				{
					for (int xp=0;xp<8;xp++)
					{
						tile[(stat&0x8000)?7-yp:yp][(stat&0x4000)?7-xp:xp]=
									((vram[tileoff+yp+0]>>(0+7-xp))&1)<<0|
									((vram[tileoff+yp+0]>>(8+7-xp))&1)<<1|
									((vram[tileoff+yp+8]>>(0+7-xp))&1)<<2|
									((vram[tileoff+yp+8]>>(8+7-xp))&1)<<3;
					}
				}
				for (int xp=0;xp<8;xp++)
				{
					for (int yp=0;yp<8;yp++)
					{
						int col=palette[cgram[tile[yp][xp]|pal]];
						tilepix[yp*1024+xp]=((col<<16)&0xFF0000)|((col>>0)&0x00FF00)|((col>>16)&0x0000FF);
					}
				}
			}
		}
	}
}
#endif
