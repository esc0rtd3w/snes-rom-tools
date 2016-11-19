#ifdef KEYCONF
#include <windows.h>
#include <stdint.h>
#include <stdio.h>
#include "libretro.h"

int width=128;
int height=48;

const char * const strings[]={
	"Press the Up button",
	"Press the Down button",
	"Press the Left button",
	"Press the Right button",
	"Press the B button",
	"Press the A button",
	"Press the X button",
	"Press the Y button",
	"Press the L button",
	"Press the R button",
	"Press the Select button",
	"Press the Start button",
	NULL};
const int ids[]={
	RETRO_DEVICE_ID_JOYPAD_UP,
	RETRO_DEVICE_ID_JOYPAD_DOWN,
	RETRO_DEVICE_ID_JOYPAD_LEFT,
	RETRO_DEVICE_ID_JOYPAD_RIGHT,
	RETRO_DEVICE_ID_JOYPAD_B,
	RETRO_DEVICE_ID_JOYPAD_A,
	RETRO_DEVICE_ID_JOYPAD_X,
	RETRO_DEVICE_ID_JOYPAD_Y,
	RETRO_DEVICE_ID_JOYPAD_L,
	RETRO_DEVICE_ID_JOYPAD_R,
	RETRO_DEVICE_ID_JOYPAD_SELECT,
	RETRO_DEVICE_ID_JOYPAD_START,
};
unsigned char keys[]={0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
int keyid=0;

RECT rc = { 0, 0, 0, 0 };

LRESULT CALLBACK WindowProc(HWND hwnd, UINT Message, WPARAM wParam, LPARAM lParam);

int CALLBACK WinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance, LPSTR lpCmdLine, int nCmdShow)
{
	MSG Msg;

	HDC hdc = GetDC(0);
	SelectObject(hdc, GetStockObject(DEFAULT_GUI_FONT));
	DrawText(hdc, "Press the Select button", -1, &rc, DT_CALCRECT);
	ReleaseDC(0, hdc);
	width=rc.right;
	height=rc.bottom;

	WNDCLASSEX WndClass;

	WndClass.cbSize			= sizeof(WNDCLASSEX);
	WndClass.style			= 0;
	WndClass.lpfnWndProc	= WindowProc;
	WndClass.cbClsExtra		= 0;
	WndClass.cbWndExtra		= 0;
	WndClass.hInstance		= 0;
	WndClass.hCursor		= LoadCursor(NULL, IDC_ARROW);
	WndClass.hbrBackground	= (HBRUSH)(COLOR_WINDOW+1);
	WndClass.lpszMenuName	= NULL;
	WndClass.lpszClassName	= "mainWnd";

	WndClass.hIcon		= NULL;//LoadIcon(GetModuleHandle(NULL), MAKEINTRESOURCE(ID_ICONBIG));
	WndClass.hIconSm	= NULL;//(HICON)LoadImage(GetModuleHandle(NULL), MAKEINTRESOURCE(ID_ICONSMALL), IMAGE_ICON, 16, 16, 0);

	RegisterClassEx(&WndClass);
	HWND hwnd=CreateWindowEx(WS_EX_STATICEDGE, "mainWnd", "", WS_MINIMIZEBOX | WS_SYSMENU | WS_BORDER | WS_VISIBLE,
											CW_USEDEFAULT, CW_USEDEFAULT, 640, 480, NULL, NULL, 0, NULL);

	ShowWindow(hwnd, nCmdShow);
	UpdateWindow(hwnd);

	while(GetMessage(&Msg, NULL, 0, 0)>0)
	{
		TranslateMessage(&Msg);
		DispatchMessage(&Msg);
	}

	return Msg.wParam;
}

int trueW;
int trueH;

LRESULT CALLBACK WindowProc(HWND hwnd, UINT Message, WPARAM wParam, LPARAM lParam)
{
	switch(Message)
	{
	case WM_GETMINMAXINFO:
		{
			MINMAXINFO * mmi;
			mmi=(LPMINMAXINFO)lParam;
			mmi->ptMinTrackSize.x=trueW;//lock the size in case someone tries to resize it
			mmi->ptMinTrackSize.y=trueH;
			mmi->ptMaxTrackSize.x=trueW;
			mmi->ptMaxTrackSize.y=trueH;
		}
		break;
	case WM_CREATE:
		{
			for (int i=0;i<2;i++)
			{
				RECT rcClient;
				RECT rcWindow;
				GetClientRect(hwnd, &rcClient);
				GetWindowRect(hwnd, &rcWindow);
				trueW=width+(rcWindow.right - rcWindow.left) - rcClient.right;
				trueH=height+(rcWindow.bottom - rcWindow.top) - rcClient.bottom;
				MoveWindow(hwnd, rcWindow.left, rcWindow.top, trueW, trueH, true);
			}
		}
		break;
	case WM_CLOSE:
		DestroyWindow(hwnd);
		break;
	case WM_DESTROY:
		PostQuitMessage(0);
		break;
	case WM_ERASEBKGND://flicker is annoying
		break;
	case WM_PAINT:
		{
			RECT rc;
			if (!GetUpdateRect(hwnd, &rc, FALSE)) return 0;
			PAINTSTRUCT ps;
			HDC hdc = BeginPaint(hwnd, &ps);
			FillRect(hdc, &rc, (HBRUSH)(COLOR_WINDOW+1));
			SelectObject(hdc, GetStockObject(DEFAULT_GUI_FONT));
			TextOut(hdc, 0, 0, strings[keyid], strlen(strings[keyid]));
			EndPaint(hwnd, &ps);
		}
		break;
	case WM_KEYDOWN:
		{
			if (lParam&0x40000000) return 0;
			InvalidateRect(hwnd, NULL, FALSE);
			keys[ids[keyid++]]=wParam;
			if (!strings[keyid])
			{
				FILE * f=fopen("lmsw.cfg", "rt");
				char line[512][256];
				int lines;
				int keysline=-1;
				if (f)
				{
					for (lines=0;!feof(f);lines++)
					{
						fgets(line[lines], 256, f);
						if (!strncmp(line[lines], "keys=", strlen("keys="))) keysline=lines;
					}
					fclose(f);
				}
				else
				{
					keysline=0;
					lines=1;
				}
				sprintf(line[keysline], "keys=%i,%i,%i,%i,%i,%i,%i,%i,%i,%i,%i,%i\n",
																keys[0], keys[1], keys[2], keys[3], keys[4], keys[5],
																keys[6], keys[7], keys[8], keys[9], keys[10], keys[11]);
				f=fopen("lmsw.cfg", "wt");//easiest way to truncate it
				for (int i=0;i<lines;i++)
				{
					fputs(line[i], f);
				}
				fclose(f);
				DestroyWindow(hwnd);
			}
			break;
		}
	default:
		return DefWindowProc(hwnd, Message, wParam, lParam);
	}
	return 0;
}
#endif
