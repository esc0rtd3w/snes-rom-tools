#include "window.h"
#ifdef WINDOW_WIN32
#undef _WIN32_WINNT
#define _WIN32_WINNT 0x0501
#define _WIN32_IE 0x0600
#include <windows.h>
#include <commctrl.h>
#include <ctype.h>
//#include<stdio.h>

//TODO:
//menu_create: check where it's resized if size changes

#define WS_BASE WS_OVERLAPPED|WS_CAPTION|WS_SYSMENU|WS_MINIMIZEBOX//okay microsoft, did I miss anything?
#define WS_RESIZABLE (WS_BASE|WS_MAXIMIZEBOX|WS_THICKFRAME)
#define WS_NONRESIZ (WS_BASE|WS_BORDER)

static LRESULT CALLBACK WindowProc(HWND hwnd, UINT uMsg, WPARAM wParam, LPARAM lParam);
static void _reflow(struct window * this_);

void _window_init_shell()
{
	WNDCLASS wc;
	wc.style=0;
	wc.lpfnWndProc=WindowProc;
	wc.cbClsExtra=0;
	wc.cbWndExtra=0;
	wc.hInstance=GetModuleHandle(NULL);
	wc.hIcon=LoadIcon(GetModuleHandle(NULL), MAKEINTRESOURCE(0));
	wc.hCursor=LoadCursor(NULL, IDC_ARROW);
	wc.hbrBackground=(HBRUSH)(COLOR_3DFACE + 1);
	wc.lpszMenuName=NULL;
	wc.lpszClassName="minir";
	RegisterClass(&wc);
}



struct window_win32 {
	struct window i;
	
	//used by modality
	struct window_win32 * prev;
	struct window_win32 * next;
	bool modal;
	//char padding[7];
	
	HWND hwnd;
	struct widget_base * contents;
	unsigned int numchildwin;
	
	DWORD lastmousepos;
	
	bool resizable;
	bool isdialog;
	
	bool menuactive;//odd position to reduce padding
	uint8_t delayfree;//0=normal, 1=can't free now, 2=free at next opportunity
	
	bool (*onclose)(struct window * subject, void* userdata);
	void* oncloseuserdata;
};

static HWND activedialog=NULL;

static struct window_win32 * firstwindow=NULL;
static struct window_win32 * modalwindow=NULL;

static void getBorderSizes(struct window_win32 * this, unsigned int * width, unsigned int * height)
{
	RECT inner;
	RECT outer;
	GetClientRect(this->hwnd, &inner);
	GetWindowRect(this->hwnd, &outer);
	if (width) *width=(outer.right-outer.left)-(inner.right);
	if (height) *height=(outer.bottom-outer.top)-(inner.bottom);
}

static void _reflow(struct window * this_);

static void set_is_dialog(struct window * this_)
{
	struct window_win32 * this=(struct window_win32*)this_;
	this->isdialog=true;
}

static void set_parent(struct window * this_, struct window * parent_)
{
	struct window_win32 * this=(struct window_win32*)this_;
	struct window_win32 * parent=(struct window_win32*)parent_;
	SetWindowLongPtr(this->hwnd, GWLP_HWNDPARENT, (LONG_PTR)parent->hwnd);
}

static void update_modal(struct window_win32 * this)
{
	if (this->modal && IsWindowVisible(this->hwnd))
	{
		//disable all windows
		if (!modalwindow)//except if they're already disabled because that's a waste of time.
		{
			struct window_win32 * wndw=firstwindow;
			while (wndw)
			{
				if (wndw!=this) EnableWindow(wndw->hwnd, false);
				wndw=wndw->next;
			}
			modalwindow=this;
		}
	}
	else
	{
		//we're gone now - if we're the one holding the windows locked, enable them
		if (this == modalwindow)
		{
			struct window_win32 * wndw=firstwindow;
			while (wndw)
			{
				EnableWindow(wndw->hwnd, true);
				wndw=wndw->next;
			}
			modalwindow=NULL;
		}
	}
}

static void set_modal(struct window * this_, bool modal)
{
	struct window_win32 * this=(struct window_win32*)this_;
	this->modal=modal;
	update_modal(this);
}

static void resize(struct window * this_, unsigned int width, unsigned int height)
{
	struct window_win32 * this=(struct window_win32*)this_;
	
	unsigned int padx;
	unsigned int pady;
	getBorderSizes(this, &padx, &pady);
	
	SetWindowPos(this->hwnd, NULL, 0, 0, width+padx, height+pady,
	             SWP_NOACTIVATE|SWP_NOCOPYBITS|SWP_NOMOVE|SWP_NOOWNERZORDER|SWP_NOZORDER);
	
	_reflow((struct window*)this);
}

static void set_resizable(struct window * this_, bool resizable,
                          void (*onresize)(struct window * subject, unsigned int newwidth, unsigned int newheight, void* userdata), void* userdata)
{
	struct window_win32 * this=(struct window_win32*)this_;
	if (this->resizable != resizable)
	{
		this->resizable=resizable;
		SetWindowLong(this->hwnd, GWL_STYLE, GetWindowLong(this->hwnd, GWL_STYLE) ^ WS_RESIZABLE^WS_NONRESIZ);
		_reflow(this_);
	}
}

static void set_title(struct window * this_, const char * title)
{
	struct window_win32 * this=(struct window_win32*)this_;
	SetWindowText(this->hwnd, title);
}

static void set_onclose(struct window * this_, bool (*function)(struct window * subject, void* userdata), void* userdata)
{
	struct window_win32 * this=(struct window_win32*)this_;
	this->onclose=function;
	this->oncloseuserdata=userdata;
}

static void replace_contents(struct window * this_, void * contents)
{
	struct window_win32 * this=(struct window_win32*)this_;
	this->contents->_free(this->contents);
	this->contents=(struct widget_base*)contents;
	this->numchildwin=this->contents->_init(this->contents, (struct window*)this, (uintptr_t)this->hwnd);
	_reflow(this_);
}

static void set_visible(struct window * this_, bool visible)
{
	struct window_win32 * this=(struct window_win32*)this_;
	if (visible)
	{
		_reflow(this_);
		ShowWindow(this->hwnd, SW_SHOWNORMAL);
	}
	else
	{
		ShowWindow(this->hwnd, SW_HIDE);
	}
	update_modal(this);
}

static bool is_visible(struct window * this_)
{
	struct window_win32 * this=(struct window_win32*)this_;
	return IsWindowVisible(this->hwnd);
}

static void focus(struct window * this_)
{
	struct window_win32 * this=(struct window_win32*)this_;
	SetForegroundWindow(this->hwnd);
}

static bool is_active(struct window * this_)
{
	struct window_win32 * this=(struct window_win32*)this_;
	return (GetForegroundWindow()==this->hwnd);
}

static bool menu_active(struct window * this_)
{
	struct window_win32 * this=(struct window_win32*)this_;
	return (this->menuactive);
}

static void free_(struct window * this_)
{
	struct window_win32 * this=(struct window_win32*)this_;
	
	if (this->delayfree)
	{
		this->delayfree=2;
		return;
	}
	
	if (this->prev) this->prev->next=this->next;
	else firstwindow=this->next;
	if (this->next) this->next->prev=this->prev;
	
	if (this->modal)
	{
		set_visible(this_, false);
		update_modal(this);
	}
	
	this->contents->_free(this->contents);
	DestroyWindow(this->hwnd);
	free(this);
}

static uintptr_t _get_handle(struct window * this_)
{
	struct window_win32 * this=(struct window_win32*)this_;
	return (uintptr_t)this->hwnd;
}

static void _reflow(struct window * this_)
{
	struct window_win32 * this=(struct window_win32*)this_;
	
	if (!IsWindowVisible(this->hwnd)) return;
	
	//Resizing our window seems to call the resize callback again. We're not interested, it'll just recurse in irritating ways.
	static bool recursive=false;
	if (recursive) return;
	recursive=true;
	
	RECT size;
	GetClientRect(this->hwnd, &size);
	
	this->contents->_measure(this->contents);
	
	bool badx=(this->contents->_width  > size.right  || (!this->resizable && this->contents->_width  != size.right));
	bool bady=(this->contents->_height > size.bottom || (!this->resizable && this->contents->_height != size.bottom));
	
//printf("want=%u,%u have=%u,%u",this->contents->_width,this->contents->_height,size.right,size.bottom);
	if (badx) size.right=this->contents->_width;
	if (bady) size.bottom=this->contents->_height;
	
	if (badx || bady)
	{
		unsigned int outerw;
		unsigned int outerh;
		getBorderSizes(this, &outerw, &outerh);
		//we can't defer this, or GetClientRect will get stale data, and we need the actual window size to move the rest of the windows
		SetWindowPos(this->hwnd, NULL, 0, 0, size.right+outerw, size.bottom+outerh,
		             SWP_NOACTIVATE|SWP_NOCOPYBITS|SWP_NOMOVE|SWP_NOOWNERZORDER|SWP_NOZORDER);
	}
//puts("");
	
	HDWP hdwp=BeginDeferWindowPos(this->numchildwin);
	this->contents->_place(this->contents, &hdwp, 0,0, size.right, size.bottom);
	EndDeferWindowPos(hdwp);
	recursive=false;
}

const struct window_win32 window_win32_base = {{
	set_is_dialog, set_parent, set_modal, resize, set_resizable, set_title, set_onclose,
	NULL, NULL, NULL,
	replace_contents, set_visible, is_visible, focus, is_active, menu_active, free_, _get_handle, _reflow
}};

struct window * window_create(void * contents)
{
	struct window_win32 * this=malloc(sizeof(struct window_win32));
	memcpy(this, &window_win32_base, sizeof(struct window_win32));
	
	this->next=firstwindow;
	this->prev=NULL;
	if (this->next) this->next->prev=this;
	firstwindow=this;
	
	this->contents=contents;
	this->contents->_measure(this->contents);
	//the 6 and 28 are arbitrary; we'll set ourselves to a better size later. Windows' default placement algorithm sucks, anyways.
	this->hwnd=CreateWindow("minir", "", WS_NONRESIZ, CW_USEDEFAULT, CW_USEDEFAULT,
	                        this->contents->_width+6, this->contents->_height+28, NULL, NULL, GetModuleHandle(NULL), NULL);
	SetWindowLongPtr(this->hwnd, GWLP_USERDATA, (LONG_PTR)this);
	this->numchildwin=this->contents->_init(this->contents, (struct window*)this, (uintptr_t)this->hwnd);
	
	this->resizable=false;
	this->onclose=NULL;
	this->lastmousepos=-1;
	this->delayfree=0;
	
	resize((struct window*)this, this->contents->_width, this->contents->_height);
	//_reflow((struct window*)this);
	
	return (struct window*)this;
}

static LRESULT CALLBACK WindowProc(HWND hwnd, UINT uMsg, WPARAM wParam, LPARAM lParam)
{
	struct window_win32 * this=(struct window_win32*)GetWindowLongPtr(hwnd, GWLP_USERDATA);
	switch (uMsg)
	{
	case WM_CTLCOLOREDIT: return _window_get_widget_color(uMsg, (HWND)lParam, (HDC)wParam, hwnd);
	case WM_GETMINMAXINFO:
		{
			if (this)
			{
				MINMAXINFO* mmi=(MINMAXINFO*)lParam;
				
				unsigned int padx;
				unsigned int pady;
				getBorderSizes(this, &padx, &pady);
				
				mmi->ptMinTrackSize.x=padx+this->contents->_width;
				mmi->ptMinTrackSize.y=pady+this->contents->_height;
			}
		}
		break;
	case WM_ACTIVATE:
		if (LOWORD(WM_ACTIVATE) && this->isdialog) activedialog=hwnd;
		else activedialog=NULL;
		break;
	case WM_CLOSE:
	case WM_ENDSESSION://this isn't really the most elegant solution, but it should work.
		{
			if (this->onclose)
			{
				this->delayfree=1;
				if (!this->onclose((struct window*)this, this->oncloseuserdata)) break;
				if (this->delayfree==2)
				{
					this->delayfree=0;
					free_((struct window*)this);
					break;
				}
				this->delayfree=0;
			}
			ShowWindow(hwnd, SW_HIDE);
		}
		break;
	case WM_COMMAND:
		{
			if (!lParam) return 0;//ignore menu notifications
			NMHDR nmhdr={(HWND)lParam, LOWORD(wParam), HIWORD(wParam)};
			return _window_notify_inner(&nmhdr);
		}
		break;
	case WM_NOTIFY:
		{
			return _window_notify_inner((LPNMHDR)lParam);
		}
		break;
	case WM_DESTROY:
		break;
	//check WM_CONTEXTMENU
	case WM_SIZE:
		{
			//not sure which of the windows get this
			if (!this) break;//this one seems to hit only on Wine, but whatever, worth checking.
			_reflow((struct window*)this);
		}
		break;
	default:
		return DefWindowProcA(hwnd, uMsg, wParam, lParam);
	}
	return 0;
}

static void handlemessage(MSG * msg)
{
	if (activedialog && IsDialogMessage(activedialog, msg)) return;
	TranslateMessage(msg);
	DispatchMessage(msg);
}

void window_run_iter()
{
	MSG msg;
	while (PeekMessage(&msg, NULL, 0, 0, PM_REMOVE)) handlemessage(&msg);
}

void window_run_wait()
{
	MSG msg;
	GetMessage(&msg, NULL, 0, 0);
	handlemessage(&msg);
	window_run_iter();
}
#endif
