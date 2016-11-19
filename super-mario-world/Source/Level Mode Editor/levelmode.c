#include "stdafx.h"
#include "resource.h"

#define ADDR_SCREEN_MODE 0x28617
#define ADDR_TM_TMW 0x28637
#define ADDR_TD_TSW 0x28657
#define ADDR_CGADSUB 0x28677
#define ADDR_FIGHT 0x28697
#define ADDR_SPRITE 0x286B7

HINSTANCE hInst;
char filename[MAX_PATH];	// ROM�̃t�@�C����
BYTE *rombuf;				// ROM�̃o�C�i���f�[�^
DWORD romsize;				// ROM�̃T�C�Y
HANDLE hFile;				// ROM�t�@�C���̃n���h��

// �t�@�C�����J���_�C�A���O
BOOL OpenROM() {
	OPENFILENAME ofn;
	ZeroMemory(&ofn, sizeof(ofn));
	
	ofn.lStructSize = sizeof(ofn);
	ofn.lpstrFilter = "SNES ROM (*.smc)\0*.smc\0���ׂẴt�@�C�� (*.*)\0*.*\0\0";
	filename[0] = '\0';
	ofn.lpstrFile = filename;
	ofn.nMaxFile = MAX_PATH;
	ofn.Flags = OFN_FILEMUSTEXIST | OFN_HIDEREADONLY;
	
	return GetOpenFileName(&ofn);
}

// ROM�̃o�C�i���f�[�^��ǂݍ���
DWORD ReadROM() {
	DWORD result;
	
	romsize = GetFileSize(hFile, NULL);
	rombuf = (BYTE*)GlobalAlloc(GMEM_FIXED, romsize);
	ReadFile(hFile, rombuf, romsize, &result, NULL);
	
	return result;
}

// ROM�̃o�C�i���f�[�^��ۑ�
DWORD SaveROM() {
	DWORD result;
	SetFilePointer(hFile, 0, NULL, FILE_BEGIN);
	WriteFile(hFile, rombuf, romsize, &result, NULL);
	return result;
}

// �R���{�{�b�N�X���̍��ڂ�ݒ�
void SetLevelModeList(HWND hwndDlg) {
	int i;
	char str[128];
	HWND ctrl;
	int current;
	
	ctrl = GetDlgItem(hwndDlg, IDC_COMBO_SELECT);
	
	current = SendMessage(ctrl, CB_GETCURSEL, 0, 0);
	if(current == CB_ERR) current = 0;
	
	SendMessage(ctrl, CB_RESETCONTENT, 0, 0);
	
	for(i = 0; i < 32; i++) {
		wsprintf(str, "%02X: TD=%02X, CG=%02X, TM=%02X, F=%02X, S=%02X",
		         i, rombuf[ADDR_TD_TSW + i], rombuf[ADDR_CGADSUB + i], rombuf[ADDR_TM_TMW + i],
		         rombuf[ADDR_FIGHT + i], rombuf[ADDR_SPRITE + i]);
		SendMessage(ctrl, CB_ADDSTRING, 0, (LPARAM)str);
	}
	
	SendMessage(ctrl, CB_SETCURSEL, current, 0);
}

// �e�L�X�g�{�b�N�X���̍��ڂ�ݒ�
void SetLevelModeValueText(HWND hwndDlg) {
	HWND ctrl;
	char str[128];
	int current;
	
	ctrl = GetDlgItem(hwndDlg, IDC_COMBO_SELECT);
	current = SendMessage(ctrl, CB_GETCURSEL, 0, 0);
	if(current == CB_ERR) return;
	
	ctrl = GetDlgItem(hwndDlg, IDC_EDIT_SCREEN);
	wsprintf(str, "%02X", rombuf[ADDR_SCREEN_MODE + current]);
	SendMessage(ctrl, WM_SETTEXT, 0, (LPARAM)str);
	
	ctrl = GetDlgItem(hwndDlg, IDC_EDIT_TM);
	wsprintf(str, "%02X", rombuf[ADDR_TM_TMW + current]);
	SendMessage(ctrl, WM_SETTEXT, 0, (LPARAM)str);
	
	ctrl = GetDlgItem(hwndDlg, IDC_EDIT_TD);
	wsprintf(str, "%02X", rombuf[ADDR_TD_TSW + current]);
	SendMessage(ctrl, WM_SETTEXT, 0, (LPARAM)str);
	
	ctrl = GetDlgItem(hwndDlg, IDC_EDIT_CGADSUB);
	wsprintf(str, "%02X", rombuf[ADDR_CGADSUB + current]);
	SendMessage(ctrl, WM_SETTEXT, 0, (LPARAM)str);
	
	ctrl = GetDlgItem(hwndDlg, IDC_EDIT_FIGHT);
	wsprintf(str, "%02X", rombuf[ADDR_FIGHT + current]);
	SendMessage(ctrl, WM_SETTEXT, 0, (LPARAM)str);
	
	ctrl = GetDlgItem(hwndDlg, IDC_EDIT_SPRITE);
	wsprintf(str, "%02X", rombuf[ADDR_SPRITE + current]);
	SendMessage(ctrl, WM_SETTEXT, 0, (LPARAM)str);
}

// ROM�Ƀe�L�X�g�{�b�N�X���̍��ڂ���������
void WriteLevelModeValue(HWND hwndDlg) {
	HWND ctrl;
	int current;
	char str[128];
	long value;
	
	ctrl = GetDlgItem(hwndDlg, IDC_COMBO_SELECT);
	current = SendMessage(ctrl, CB_GETCURSEL, 0, 0);
	if(current == CB_ERR) return;
	
	ctrl = GetDlgItem(hwndDlg, IDC_EDIT_SCREEN);
	SendMessage(ctrl, WM_GETTEXT, sizeof(str), (LPARAM)str);
	value = strtol(str, NULL, 16);
	rombuf[ADDR_SCREEN_MODE + current] = (BYTE)value;
	
	ctrl = GetDlgItem(hwndDlg, IDC_EDIT_TM);
	SendMessage(ctrl, WM_GETTEXT, sizeof(str), (LPARAM)str);
	value = strtol(str, NULL, 16);
	rombuf[ADDR_TM_TMW + current] = (BYTE)value;
	
	ctrl = GetDlgItem(hwndDlg, IDC_EDIT_TD);
	SendMessage(ctrl, WM_GETTEXT, sizeof(str), (LPARAM)str);
	value = strtol(str, NULL, 16);
	rombuf[ADDR_TD_TSW + current] = (BYTE)value;
	
	ctrl = GetDlgItem(hwndDlg, IDC_EDIT_CGADSUB);
	SendMessage(ctrl, WM_GETTEXT, sizeof(str), (LPARAM)str);
	value = strtol(str, NULL, 16);
	rombuf[ADDR_CGADSUB + current] = (BYTE)value;
	
	ctrl = GetDlgItem(hwndDlg, IDC_EDIT_FIGHT);
	SendMessage(ctrl, WM_GETTEXT, sizeof(str), (LPARAM)str);
	value = strtol(str, NULL, 16);
	rombuf[ADDR_FIGHT + current] = (BYTE)value;
	
	ctrl = GetDlgItem(hwndDlg, IDC_EDIT_SPRITE);
	SendMessage(ctrl, WM_GETTEXT, sizeof(str), (LPARAM)str);
	value = strtol(str, NULL, 16);
	rombuf[ADDR_SPRITE + current] = (BYTE)value;
}

// ���C���_�C�A���O�̏���
BOOL CALLBACK MainDialogProc(HWND hwndDlg, UINT uMsg, WPARAM wParam, LPARAM lParam) {
	HICON hIcon;
	
	switch(uMsg) {
		case WM_INITDIALOG:	// ������
			hIcon = (HICON)LoadImage(hInst, MAKEINTRESOURCE(IDI_ICON1), IMAGE_ICON, 32, 32, LR_DEFAULTCOLOR);
			SendMessage(hwndDlg, WM_SETICON, ICON_BIG, (LPARAM)hIcon);
			hIcon = (HICON)LoadImage(hInst, MAKEINTRESOURCE(IDI_ICON1), IMAGE_ICON, 16, 16, LR_DEFAULTCOLOR);
			SendMessage(hwndDlg, WM_SETICON, ICON_SMALL, (LPARAM)hIcon);
			
			SetLevelModeList(hwndDlg);
			SetLevelModeValueText(hwndDlg);
			return TRUE;
		case WM_COMMAND:	// �R���g���[������̃��b�Z�[�W
			switch(LOWORD(wParam)) {
				case IDSAVE:	// �ۑ�
					WriteLevelModeValue(hwndDlg);
					SetLevelModeList(hwndDlg);
					SaveROM();
					return TRUE;
				case IDCANCEL:	// �I��
					EndDialog(hwndDlg, 0);
					return TRUE;
				case IDC_COMBO_SELECT:	// �R���{�{�b�N�X
					if(HIWORD(wParam) == CBN_DROPDOWN) {
						WriteLevelModeValue(hwndDlg);
						SetLevelModeList(hwndDlg);
					}
					else if(HIWORD(wParam) == CBN_SELCHANGE) {
						SetLevelModeValueText(hwndDlg);
					}
					return FALSE;
			}
			return FALSE;
		case WM_CLOSE:	// �I��
			EndDialog(hwndDlg, 0);
			return TRUE;
	}
	
	return FALSE;
}

// ���C���֐�
int WINAPI WinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance, LPSTR lpszCmdLine, int nCmdShow) {
	hInst = hInstance;
	
	if(strlen(lpszCmdLine) == 0) {
		if(!OpenROM()) return 0;
	} else {
		strcpy(filename, lpszCmdLine);
	}
	
	hFile = CreateFile(filename, GENERIC_READ | GENERIC_WRITE, FILE_SHARE_READ | FILE_SHARE_WRITE, NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL);
	ReadROM();
	
	DialogBox(hInstance, MAKEINTRESOURCE(IDD_DIALOG_MAIN), NULL, MainDialogProc);
	
	GlobalFree(rombuf);
	CloseHandle(hFile);
	
	return 0;
}
