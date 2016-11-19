#include "window.h"
#include <stdio.h>
#include <string.h>
#include <ctype.h>

void errormsg(const char * why)
{
	window_message_box(why, NULL, mb_err, mb_ok);
}

void error(const char * why)
{
	errormsg(why);
	exit(0);
}

void assert(bool cond, const char * err)
{
	if (!cond) error(err);
}

const char * find_rom()
{
	FILE* f=fopen("rom.txt", "rt");
	if (f)
	{
		static char ret[256];
		ret[fread(ret, 1,255, f)]='\0';
		fclose(f);
		return ret;
	}
	
	void* find=file_find_create(".");
	char* ret=NULL;
	
	char* temp;
	bool isdir;
	while (file_find_next(find, &temp, &isdir))
	{
		if (isdir) goto x;
		char * pathend=strrchr(temp, '.');
		if (!pathend) goto x;
		if (strcmp(pathend, ".sfc") && strcmp(pathend, ".smc")) goto x;
		if (ret) goto wrongnum;
		ret=temp;
		continue;
	x: free(temp);
	}
	file_find_close(find);
	if (ret) return ret;
	
wrongnum: ;
	const char * extensions[]={".sfc", ".smc", NULL};
	const char * const * roms=window_file_picker(NULL, "Select your ROM", extensions, "SMW ROMs", true, false);
	if (!roms || !*roms) exit(1);
	
	f=fopen("rom.txt", "wt");
	fputs(*roms, f);
	fclose(f);
	
	return *roms;
}

struct block {
	struct block * next;
	int id;
	int acts;
	char path[256];
};
struct block firstblock={0};
int numblocks=0;

const char * rom;

struct window * wndw;
struct widget_listbox * list=NULL;
struct widget_button * insert;
struct widget_button * new;
struct widget_button * delete;
struct widget_button * edit;

struct window * wndwitem;

bool listchanged;

struct block * insert_block(struct block * new)//this is a totally legit argument name, shut up
{
	struct block * after=&firstblock;
	while (after->next && after->next->id < new->id) after=after->next;
	if (after->id==new->id) return after;
	new->next=after->next;
	after->next=new;
	numblocks++;
	if (list) list->set_num_rows(list, numblocks);
	listchanged=true;
	return NULL;
}

void delete_block(struct block * del)
{
	struct block * after=&firstblock;
	while (after->next != del) after=after->next;
	after->next=after->next->next;
	free(del);
	numblocks--;
	if (list) list->set_num_rows(list, numblocks);
	listchanged=true;
}

void read_blocks()
{
	FILE * f=fopen("list.txt", "rt");
	if (!f) return;
	while (!feof(f))
	{
		struct block * new=malloc(sizeof(struct block));
		char tmp;
		assert(fscanf(f, " %x%c", &new->id, &tmp)==2, "Your block list is broken");
		if (tmp==':') assert(fscanf(f, "%x ", &new->acts)==1, "Your block list is broken");
		else if (tmp!=' ') error("Your block list is broken");
		else new->acts=-1;
		fgets(new->path, 255, f);
		char * pathend=strchr(new->path, '\n');
		assert(feof(f) || pathend, "Your block list is broken");
		if (pathend) *pathend='\0';
		fscanf(f, " ");
		if (new->acts<-1 || new->acts>=0x4000) error("Your block list is broken");
		if (new->id<0x200 || new->acts>=0x4000) error("Your block list is broken");
		assert(insert_block(new)==NULL, "Your block list is broken");
	}
	fclose(f);
	listchanged=false;
}

void write_blocks()
{
	if (listchanged)
	{
		FILE * f=fopen("list.txt", "wt");
		struct block * blk=firstblock.next;
		while (blk)
		{
			if (blk->acts!=-1) fprintf(f, "%.3X:%.3X %s\n", blk->id, blk->acts, blk->path);
			else fprintf(f, "%.3X %s\n", blk->id, blk->path);
			blk=blk->next;
		}
		fclose(f);
		listchanged=false;
	}
}

void ui_insert(struct widget_button * subject, void* userdata)
{
	write_blocks();
	char cmd[512];
#ifdef _WIN32
	sprintf(cmd, "gps \"%s\" > GPSTMP_e.log", rom);
#else
	sprintf(cmd, "./gps \"%s\" > GPSTMP_e.log", rom);
#endif
puts(cmd);
	if (system(cmd)!=0)
	{
		FILE * f=fopen("GPSTMP_e.log", "rt");
		memset(cmd, 0, 512);
		fgets(cmd, 512, f);
		fclose(f);
		char * nl=strchr(cmd, '\n');
		if (nl) *nl='\0';
		if (*cmd) errormsg(cmd);
		else errormsg("Couldn't open Gopher Popcorn Stew, please redownload");
	}
}

void ui_delete(struct widget_button * subject, void* userdata)
{
	size_t item=list->get_active_row(list);
	if (item==(size_t)-1) return;
	
	struct block * after=&firstblock;
	while (item--) after=after->next;
	
	struct block * del=after->next;
	after->next=after->next->next;
	free(del);
	numblocks--;
	list->set_num_rows(list, numblocks);
	listchanged=true;
}

bool cancel;

struct window * e_edit;
struct widget_textbox * e_id;
struct widget_textbox * e_acts;
struct widget_textbox * e_path;

int parse_hex(const char * hex)
{
	const char * hex2=hex;
	if (!*hex2) return -1;
	while (isxdigit(*hex2)) hex2++;
	if (*hex2) return -1;
	return strtol(hex, NULL, 16);
}

void e_onok(struct widget_button * subject, void* userdata)
{
	struct block * blk=malloc(sizeof(struct block));
	
	blk->id=parse_hex(e_id->get_text(e_id));
	if (blk->id < 0 || blk->id<0x200 || blk->id>=0x4000)
	{
		e_id->set_invalid(e_id, true);
		free(blk);
		return;
	}
	if (*e_acts->get_text(e_acts))
	{
		blk->acts=parse_hex(e_acts->get_text(e_acts));
		if (blk->acts < 0 || blk->acts>=0x4000)
		{
			e_acts->set_invalid(e_acts, true);
			free(blk);
			return;
		}
	}
	else blk->acts=-1;
	strcpy(blk->path, e_path->get_text(e_path));
	
	struct block * collision=insert_block(blk);
	struct block * oldblk=userdata;
	if (collision && collision!=oldblk)
	{
		if (!window_message_box("There is already a block with that ID. Overwrite?", NULL, mb_warn, mb_yesno))
		{
			free(blk);
			return;
		}
		delete_block(collision);
		insert_block(blk);
	}
	
	if (oldblk) delete_block(oldblk);
	e_edit->set_visible(e_edit, false);
}

void e_pickpath(struct widget_button * subject, void* userdata)
{
	const char * extensions[]={".asm", NULL};
	const char * const * paths=window_file_picker(e_edit, "Pick path", extensions, "Blocks", true, false);
	if (paths && paths[0]) e_path->set_text(e_path, paths[0]);
}

void e_oncancel(struct widget_button * subject, void* userdata)
{
	e_edit->set_visible(e_edit, false);
}

void ui_edit_list(struct widget_listbox * subject, size_t row, void* userdata)
{
	struct widget_button * pickpath;
	
	struct widget_button * ok;
	struct widget_button * cancel;
	
	e_edit=window_create(
		widget_create_layout_vert(
			widget_create_layout_horz(
				widget_create_layout_vert(
					widget_create_label("ID"),
					widget_create_label("Acts like"),
					widget_create_label("Path"),
					NULL),
				widget_create_layout_vert(
					e_id=widget_create_textbox(),
					e_acts=widget_create_textbox(),
					widget_create_layout_horz(
						e_path=widget_create_textbox(),
						pickpath=widget_create_button("Browse..."),
						NULL),
					NULL),
				NULL),
				widget_create_layout_horz(
					widget_create_padding_horz(),
					ok=widget_create_button("OK"),
					cancel=widget_create_button("Cancel"),
				NULL),
			NULL)
		);
	
	e_id->set_length(e_id, 4);
	e_acts->set_length(e_acts, 4);
	e_path->set_length(e_path, 255);
	e_path->set_width(e_path, 32);
	struct block * oldblk;
	if (row==(size_t)-1) oldblk=NULL;
	else
	{
		oldblk=firstblock.next;
		while (row--) oldblk=oldblk->next;
		
		char tmp[5];
		sprintf(tmp, "%.3X", oldblk->id);
		e_id->set_text(e_id, tmp);
		if (oldblk->acts!=-1)
		{
			sprintf(tmp, "%.3X", oldblk->acts);
			e_acts->set_text(e_acts, tmp);
		}
		e_path->set_text(e_path, oldblk->path);
	}
	
	ok->set_onclick(ok, e_onok, oldblk);
	cancel->set_onclick(cancel, e_oncancel, NULL);
	pickpath->set_onclick(pickpath, e_pickpath, NULL);
	
	e_edit->set_title(e_edit, "GPS");
	e_edit->set_modal(e_edit, true);
	e_edit->set_is_dialog(e_edit);
	e_edit->set_parent(e_edit, wndw);
	
	e_edit->set_visible(e_edit, true);
	while (e_edit->is_visible(e_edit)) window_run_wait();
	e_edit->free(e_edit);
}

void ui_new(struct widget_button * subject, void* userdata)
{
	ui_edit_list(NULL, (size_t)-1, NULL);
}

void ui_edit(struct widget_button * subject, void* userdata)
{
	size_t id=list->get_active_row(list);
	if (id==(size_t)-1) return;
	ui_edit_list(NULL, id, NULL);
}

const char * list_getcell(struct widget_listbox * subject, size_t row, int column, void* userdata)
{
	struct block * blk=firstblock.next;
	while (row--) blk=blk->next;
	
	static char ret[5];
	switch (column)
	{
		case 0: sprintf(ret, "%.3X", blk->id); return ret;
		case 1:
			if (blk->acts<0) return "-";
			else sprintf(ret, "%.3X", blk->acts);
			return ret;
		case 2: return blk->path;
	}
	return NULL;
}

int main(int argc, char * argv[])
{
	window_init(&argc, &argv);
	rom=find_rom();
	
	read_blocks();
	
	wndw=window_create(
		widget_create_layout_vert(
			list=widget_create_listbox("ID", "Acts", "Filename", NULL),
			widget_create_layout_horz(
				insert=widget_create_button("Insert all"),
				new=widget_create_button("Add..."),
				delete=widget_create_button("Remove"),
				edit=widget_create_button("Edit..."),
				widget_create_padding_horz(),
				NULL),
			NULL)
		);
	
	list->set_onactivate(list, ui_edit_list, NULL);
	list->set_contents(list, list_getcell, NULL, NULL);
	list->set_num_rows(list, numblocks);
	list->set_size(list, 16, NULL);
	
	insert->set_onclick(insert, ui_insert, NULL);
	new->set_onclick(new, ui_new, NULL);
	delete->set_onclick(delete, ui_delete, NULL);
	edit->set_onclick(edit, ui_edit, NULL);
	
	wndw->set_title(wndw, "GPS");
	wndw->set_resizable(wndw, true, NULL, NULL);
	
	wndw->set_visible(wndw, true);
	
	while (wndw->is_visible(wndw)) window_run_wait();
	
	write_blocks();
}
