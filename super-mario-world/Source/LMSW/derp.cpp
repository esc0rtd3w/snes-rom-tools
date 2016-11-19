//#ifdef DEBUG
#if 0
#include <windows.h>
#include <stdint.h>

#define width 1024
#define height 512

LRESULT CALLBACK WindowProc(HWND hwnd, UINT Message, WPARAM wParam, LPARAM lParam);
//HWND hwnd;

static bool DERPED=false;
void DERP()
#define nCmdShow 10
{
if (DERPED) return;
DERPED=true;
	MSG Msg;

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
											CW_USEDEFAULT, CW_USEDEFAULT, width, height, NULL, NULL, 0, NULL);

	ShowWindow(hwnd, nCmdShow);
	UpdateWindow(hwnd);

	//while(GetMessage(&Msg, NULL, 0, 0)>0)
	//{
	//	TranslateMessage(&Msg);
	//	DispatchMessage(&Msg);
	//}

	//return Msg.wParam;
}

int trueW=width;
int trueH=height;

HBITMAP hBM;
uint32_t * pBits;

void initstuff(uint32_t * mypixels);
void drawstuff();

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
			RECT rcClient, rcWindow;
			POINT ptDiff;
			GetClientRect(hwnd, &rcClient);
			GetWindowRect(hwnd, &rcWindow);
			ptDiff.x = (rcWindow.right - rcWindow.left) - rcClient.right;
			ptDiff.y = (rcWindow.bottom - rcWindow.top) - rcClient.bottom;//resize window to widthxheight
			trueW=width+ptDiff.x;
			trueH=height+ptDiff.y;
			SetTimer(hwnd, 0, 50, NULL);
			
			BITMAPINFO bi;
			ZeroMemory(&bi, sizeof(bi));
			bi.bmiHeader.biSize=sizeof(BITMAPINFOHEADER);
			bi.bmiHeader.biWidth=width;
			bi.bmiHeader.biHeight=-height;
			bi.bmiHeader.biPlanes=1;
			bi.bmiHeader.biBitCount=32;
			bi.bmiHeader.biCompression=BI_RGB;

			hBM=(HBITMAP)CreateDIBSection(0, (BITMAPINFO*)&bi, DIB_RGB_COLORS, (VOID**)&pBits, 0, 0);
			initstuff(pBits);
		}
		break;
	case WM_TIMER:
		InvalidateRect(hwnd, NULL, FALSE);
		break;
	case WM_CLOSE:
		DestroyWindow(hwnd);
		break;
	case WM_DESTROY:
		PostQuitMessage(0);
		break;
	case WM_ERASEBKGND://performance
		break;
	case WM_PAINT:
		{
			if (!GetUpdateRect(hwnd, NULL, FALSE)) return 0;
			PAINTSTRUCT ps;
			HDC hdc = BeginPaint(hwnd, &ps);
			drawstuff();
			HDC memDC=CreateCompatibleDC(hdc);
			SelectObject(memDC, hBM);
			BitBlt(hdc, 0, 0, width, height, memDC, 0, 0, SRCCOPY);
			DeleteDC(memDC);
			EndPaint(hwnd, &ps);
		}
		break;
	default:
		return DefWindowProc(hwnd, Message, wParam, lParam);
	}
	return 0;
}
#endif
