#include "window.h"
#ifdef WINDOW_GTK3
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <gtk/gtk.h>
#ifdef WNDPROT_X11
#include <gdk/gdkx.h>
#endif



struct window_gtk3 {
	struct window i;
	
	GtkWindow* wndw;
	GtkGrid* grid;
	struct widget_base * contents;
	
	bool visible;
	uint8_t delayfree;//0=normal, 1=can't free now, 2=free at next opportunity
	
	//char padding1[2];
	
	bool (*onclose)(struct window * subject, void* userdata);
	void* oncloseuserdata;
};

static void resize(struct window * this_, unsigned int width, unsigned int height)
{
	struct window_gtk3 * this=(struct window_gtk3*)this_;
	gtk_window_resize(this->wndw, width, height);
}

static gboolean onclose_gtk(GtkWidget* widget, GdkEvent* event, gpointer user_data);
static gboolean popup_esc_close(GtkWidget* widget, GdkEvent* event, gpointer user_data)
{
	if (event->key.keyval==GDK_KEY_Escape)
	{
		onclose_gtk(widget, event, user_data);
		return TRUE;
	}
	return FALSE;
}

static void set_is_dialog(struct window * this_)
{
	struct window_gtk3 * this=(struct window_gtk3*)this_;
	
	gtk_widget_add_events(GTK_WIDGET(this->wndw), GDK_KEY_PRESS_MASK);
	g_signal_connect(this->wndw, "key-press-event", G_CALLBACK(popup_esc_close), this);
	
	gtk_window_set_type_hint(this->wndw, GDK_WINDOW_TYPE_HINT_DIALOG);
}

static void set_parent(struct window * this_, struct window * parent_)
{
	struct window_gtk3 * this=(struct window_gtk3*)this_;
	struct window_gtk3 * parent=(struct window_gtk3*)parent_;
	gtk_window_set_transient_for(this->wndw, parent->wndw);
}

static void set_modal(struct window * this_)
{
	struct window_gtk3 * this=(struct window_gtk3*)this_;
	gtk_window_set_modal(this->wndw, true);
}

static void set_resizable(struct window * this_, bool resizable,
                          void (*onresize)(struct window * subject, unsigned int newwidth, unsigned int newheight, void* userdata),
                          void* userdata)
{
	struct window_gtk3 * this=(struct window_gtk3*)this_;
	gtk_window_set_resizable(this->wndw, resizable);
}

static void set_title(struct window * this_, const char * title)
{
	struct window_gtk3 * this=(struct window_gtk3*)this_;
	gtk_window_set_title(this->wndw, title);
}

static void set_onclose(struct window * this_, bool (*function)(struct window * subject, void* userdata), void* userdata)
{
	struct window_gtk3 * this=(struct window_gtk3*)this_;
	this->onclose=function;
	this->oncloseuserdata=userdata;
}

static bool is_visible(struct window * this_)
{
	struct window_gtk3 * this=(struct window_gtk3*)this_;
	return this->visible;
}

static void set_visible(struct window * this_, bool visible)
{
	struct window_gtk3 * this=(struct window_gtk3*)this_;
	this->visible=visible;
	if (visible) gtk_widget_show_all(GTK_WIDGET(this->wndw));
	else gtk_widget_hide(GTK_WIDGET(this->wndw));
}

static void focus(struct window * this_)
{
	struct window_gtk3 * this=(struct window_gtk3*)this_;
	gtk_window_present(this->wndw);
}

static bool is_active(struct window * this_)
{
	struct window_gtk3 * this=(struct window_gtk3*)this_;
	
	return gtk_window_is_active(this->wndw);
}

static void free_(struct window * this_)
{
	struct window_gtk3 * this=(struct window_gtk3*)this_;
	if (this->delayfree)
	{
		this->delayfree=2;
		return;
	}
	this->contents->_free(this->contents);
	
	gtk_widget_destroy(GTK_WIDGET(this->wndw));
	
	free(this);
}

static size_t _get_handle(struct window * this_)
{
	struct window_gtk3 * this=(struct window_gtk3*)this_;
	return (size_t)this->wndw;
}

static gboolean onclose_gtk(GtkWidget* widget, GdkEvent* event, gpointer user_data)
{
	struct window_gtk3 * this=(struct window_gtk3*)user_data;
	if (this->onclose)
	{
		this->delayfree=1;
		if (this->onclose((struct window*)this, this->oncloseuserdata)==false) return TRUE;
		if (this->delayfree==2)
		{
			this->delayfree=0;
			free_((struct window*)this);
			return TRUE;
		}
		this->delayfree=0;
	}
	
	this->visible=false;
	gtk_widget_hide(GTK_WIDGET(this->wndw));
	return TRUE;
}

const struct window_gtk3 window_gtk3_base = {{
	set_is_dialog, set_parent, set_modal, resize, set_resizable, set_title, set_onclose, NULL,
	NULL, NULL, NULL,
	set_visible, is_visible, focus, is_active, NULL, free_, _get_handle, NULL
}};
struct window * window_create(void * contents_)
{
	struct window_gtk3 * this=malloc(sizeof(struct window_gtk3));
	memcpy(&this->i, &window_gtk3_base, sizeof(struct window_gtk3));
	
	this->wndw=GTK_WINDOW(gtk_window_new(GTK_WINDOW_TOPLEVEL));
	g_signal_connect(this->wndw, "delete-event", G_CALLBACK(onclose_gtk), this);//GtkWidget delete-event maybe
	gtk_window_set_has_resize_grip(this->wndw, false);
	gtk_window_set_resizable(this->wndw, false);
	
	this->contents=(struct widget_base*)contents_;
	gtk_container_add(GTK_CONTAINER(this->wndw), GTK_WIDGET(this->contents->_widget));
	
	this->visible=false;
	
//GdkRGBA color={0,0,1,1};
//gtk_widget_override_background_color(GTK_WIDGET(this->wndw),GTK_STATE_FLAG_NORMAL,&color);
	return (struct window*)this;
}
#endif
