#include "window.h"
#ifdef WINDOW_GTK3
#include <gtk/gtk.h>
#include <stdlib.h>
#include <string.h>
#ifdef WNDPROT_X11
#include <gdk/gdkx.h>
#endif

static bool in_callback=false;
static GtkCssProvider* cssprovider;

void _window_init_inner()
{
	cssprovider=gtk_css_provider_new();
	gtk_css_provider_load_from_data(cssprovider,
		"GtkEntry#invalid { background-image: none; background-color: #F66; color: #FFF; }"
		"GtkEntry#invalid:selected { background-color: #3465A4; color: #FFF; }"
		//this selection doesn't look too good, but not terrible either.
		, -1, NULL);
}



struct widget_padding_gtk3 {
	struct widget_padding i;
};

static void padding__free(struct widget_base * this_)
{
	struct widget_padding_gtk3 * this=(struct widget_padding_gtk3*)this_;
	//gtk_widget_destroy(GTK_WIDGET(this->i.base._widget));
	free(this);
}

struct widget_padding * widget_create_padding_horz()
{
	struct widget_padding_gtk3 * this=malloc(sizeof(struct widget_padding_gtk3));
	this->i.base._widget=GTK_DRAWING_AREA(gtk_drawing_area_new());
	this->i.base._widthprio=2;
	this->i.base._heightprio=0;
	this->i.base._free=padding__free;
	
	return (struct widget_padding*)this;
}

struct widget_padding * widget_create_padding_vert()
{
	struct widget_padding_gtk3 * this=malloc(sizeof(struct widget_padding_gtk3));
	this->i.base._widget=GTK_DRAWING_AREA(gtk_drawing_area_new());
	this->i.base._widthprio=0;
	this->i.base._heightprio=2;
	this->i.base._free=padding__free;
	
	return (struct widget_padding*)this;
}



struct widget_label_gtk3 {
	struct widget_label i;
};

static void label__free(struct widget_base * this_)
{
	struct widget_label_gtk3 * this=(struct widget_label_gtk3*)this_;
	free(this);
}

static void label_set_enabled(struct widget_label * this_, bool enable)
{
	struct widget_label_gtk3 * this=(struct widget_label_gtk3*)this_;
	gtk_widget_set_sensitive(GTK_WIDGET(this->i.base._widget), enable);
}

static void label_set_text(struct widget_label * this_, const char * text)
{
	struct widget_label_gtk3 * this=(struct widget_label_gtk3*)this_;
	gtk_label_set_text(GTK_LABEL(this->i.base._widget), text);
}

static void label_set_ellipsize(struct widget_label * this_, bool ellipsize)
{
	struct widget_label_gtk3 * this=(struct widget_label_gtk3*)this_;
	if (ellipsize)
	{
		gtk_label_set_ellipsize(GTK_LABEL(this->i.base._widget), PANGO_ELLIPSIZE_END);
		gtk_label_set_max_width_chars(GTK_LABEL(this->i.base._widget), 1);//why does this work
	}
	else
	{
		gtk_label_set_ellipsize(GTK_LABEL(this->i.base._widget), PANGO_ELLIPSIZE_NONE);
		gtk_label_set_max_width_chars(GTK_LABEL(this->i.base._widget), -1);
	}
}

static void label_set_alignment(struct widget_label * this_, int alignment)
{
	struct widget_label_gtk3 * this=(struct widget_label_gtk3*)this_;
	gtk_misc_set_alignment(GTK_MISC(this->i.base._widget), ((float)alignment)/2, 0.5);
}

struct widget_label * widget_create_label(const char * text)
{
	struct widget_label_gtk3 * this=malloc(sizeof(struct widget_label_gtk3));
	this->i.base._widget=GTK_LABEL(gtk_label_new(text));
	this->i.base._widthprio=1;
	this->i.base._heightprio=1;
	this->i.base._free=label__free;
	this->i.set_enabled=label_set_enabled;
	this->i.set_text=label_set_text;
	this->i.set_ellipsize=label_set_ellipsize;
	this->i.set_alignment=label_set_alignment;
	
	return (struct widget_label*)this;
}



struct widget_button_gtk3 {
	struct widget_button i;
	
	void (*onclick)(struct widget_button * button, void* userdata);
	void* userdata;
};

static void button__free(struct widget_base * this_)
{
	struct widget_button_gtk3 * this=(struct widget_button_gtk3*)this_;
	free(this);
}

static void button_set_enabled(struct widget_button * this_, bool enable)
{
	struct widget_button_gtk3 * this=(struct widget_button_gtk3*)this_;
	gtk_widget_set_sensitive(GTK_WIDGET(this->i.base._widget), enable);
}

static void button_set_text(struct widget_button * this_, const char * text)
{
	struct widget_button_gtk3 * this=(struct widget_button_gtk3*)this_;
	
	gtk_button_set_label(GTK_BUTTON(this->i.base._widget), text);
}

static void button_onclick(GtkButton *button, gpointer user_data)
{
	struct widget_button_gtk3 * this=(struct widget_button_gtk3*)user_data;
	this->onclick((struct widget_button*)this, this->userdata);
}

static void button_set_onclick(struct widget_button * this_,
                               void (*onclick)(struct widget_button * button, void* userdata), void* userdata)
{
	struct widget_button_gtk3 * this=(struct widget_button_gtk3*)this_;
	
	g_signal_connect(this->i.base._widget, "clicked", G_CALLBACK(button_onclick), this);
	this->onclick=onclick;
	this->userdata=userdata;
}

struct widget_button * widget_create_button(const char * text)
{
	struct widget_button_gtk3 * this=malloc(sizeof(struct widget_button_gtk3));
	this->i.base._widget=gtk_button_new_with_label(text);
	this->i.base._widthprio=1;
	this->i.base._heightprio=1;
	this->i.base._free=button__free;
	
	this->i.set_enabled=button_set_enabled;
	this->i.set_text=button_set_text;
	this->i.set_onclick=button_set_onclick;
	
	return (struct widget_button*)this;
}



struct widget_textbox_gtk3 {
	struct widget_textbox i;
	
	void (*onchange)(struct widget_textbox * subject, const char * text, void* userdata);
	void* ch_userdata;
	void (*onactivate)(struct widget_textbox * subject, const char * text, void* userdata);
	void* ac_userdata;
};

static void textbox__free(struct widget_base * this_)
{
	struct widget_textbox_gtk3 * this=(struct widget_textbox_gtk3*)this_;
	free(this);
}

static void textbox_set_enabled(struct widget_textbox * this_, bool enable)
{
	struct widget_textbox_gtk3 * this=(struct widget_textbox_gtk3*)this_;
	gtk_widget_set_sensitive(GTK_WIDGET(this->i.base._widget), enable);
}

static void textbox_focus(struct widget_textbox * this_)
{
	struct widget_textbox_gtk3 * this=(struct widget_textbox_gtk3*)this_;
		gtk_widget_grab_focus(this->i.base._widget);
}

static void textbox_set_text(struct widget_textbox * this_, const char * text)
{
	struct widget_textbox_gtk3 * this=(struct widget_textbox_gtk3*)this_;
	gtk_entry_set_text(GTK_ENTRY(this->i.base._widget), text);
}

static void textbox_set_length(struct widget_textbox * this_, unsigned int maxlen)
{
	struct widget_textbox_gtk3 * this=(struct widget_textbox_gtk3*)this_;
 	gtk_entry_set_max_length(GTK_ENTRY(this->i.base._widget), maxlen);
}

 
static void textbox_set_width(struct widget_textbox * this_, unsigned int xs)
{
	struct widget_textbox_gtk3 * this=(struct widget_textbox_gtk3*)this_;
	gtk_entry_set_width_chars(GTK_ENTRY(this->i.base._widget), xs);
}

static void textbox_set_invalid(struct widget_textbox * this_, bool invalid)
{
 	struct widget_textbox_gtk3 * this=(struct widget_textbox_gtk3*)this_;

	if (invalid)
	{
		GtkStyleContext* context=gtk_widget_get_style_context(this->i.base._widget);
		gtk_style_context_add_provider(context, GTK_STYLE_PROVIDER(cssprovider), GTK_STYLE_PROVIDER_PRIORITY_APPLICATION);
		gtk_widget_set_name(this->i.base._widget, "invalid");
		gtk_widget_grab_focus(this->i.base._widget);
	}
	else
	{
		gtk_widget_set_name(this->i.base._widget, "x");
	}
}

static const char * textbox_get_text(struct widget_textbox * this_)
{
	struct widget_textbox_gtk3 * this=(struct widget_textbox_gtk3*)this_;
	return gtk_entry_get_text(GTK_ENTRY(this->i.base._widget));
}

static void textbox_onchange(GtkEntry* entry, gpointer user_data)
{
	struct widget_textbox_gtk3 * this=(struct widget_textbox_gtk3*)user_data;
	gtk_widget_set_name(this->i.base._widget, "x");
	if (this->onchange)
	{
		this->onchange((struct widget_textbox*)this, gtk_entry_get_text(GTK_ENTRY(this->i.base._widget)), this->ch_userdata);
	}
}

static void textbox_set_onchange(struct widget_textbox * this_,
                                 void (*onchange)(struct widget_textbox * subject, const char * text, void* userdata),
                                 void* userdata)
{
	struct widget_textbox_gtk3 * this=(struct widget_textbox_gtk3*)this_;
	
	this->onchange=onchange;
	this->ch_userdata=userdata;
}

static void textbox_onactivate(GtkEntry* entry, gpointer user_data)
{
	struct widget_textbox_gtk3 * this=(struct widget_textbox_gtk3*)user_data;
	this->onactivate((struct widget_textbox*)this, gtk_entry_get_text(GTK_ENTRY(this->i.base._widget)), this->ac_userdata);
}

static void textbox_set_onactivate(struct widget_textbox * this_,
                                   void (*onactivate)(struct widget_textbox * subject, const char * text, void* userdata),
                                   void* userdata)
{
	struct widget_textbox_gtk3 * this=(struct widget_textbox_gtk3*)this_;
	
	g_signal_connect(this->i.base._widget, "activate", G_CALLBACK(textbox_onactivate), this);
	this->onactivate=onactivate;
	this->ac_userdata=userdata;
}

struct widget_textbox * widget_create_textbox()
{
	struct widget_textbox_gtk3 * this=malloc(sizeof(struct widget_textbox_gtk3));
	this->i.base._widget=gtk_entry_new();
	this->i.base._widthprio=3;
	this->i.base._heightprio=1;
	this->i.base._free=textbox__free;
	
	this->i.set_enabled=textbox_set_enabled;
	this->i.focus=textbox_focus;
	this->i.get_text=textbox_get_text;
	this->i.set_text=textbox_set_text;
	this->i.set_length=textbox_set_length;
	this->i.set_width=textbox_set_width;
	this->i.set_invalid=textbox_set_invalid;
	this->i.set_onchange=textbox_set_onchange;
	this->i.set_onactivate=textbox_set_onactivate;
	
	g_signal_connect(this->i.base._widget, "changed", G_CALLBACK(textbox_onchange), this);
	this->onchange=NULL;
	
	return (struct widget_textbox*)this;
}



struct widget_layout_gtk3 {
	struct widget_layout i;
	
	struct widget_base * * children;
	unsigned int numchildren;
};

static void layout__free(struct widget_base * this_)
{
	struct widget_layout_gtk3 * this=(struct widget_layout_gtk3*)this_;
	for (unsigned int i=0;i<this->numchildren;i++)
	{
		this->children[i]->_free(this->children[i]);
	}
	free(this->children);
	free(this);
}

struct widget_layout * widget_create_layout_l(bool vertical, bool uniform, unsigned int numchildren, void * * children_)
{
	struct widget_base * * children=(struct widget_base**)children_;
	if (!numchildren)
	{
		while (children[numchildren]) numchildren++;
	}
	
	struct widget_layout_gtk3 * this=malloc(sizeof(struct widget_layout_gtk3));
	this->i.base._free=layout__free;
	GtkBox* box=GTK_BOX(gtk_box_new(vertical ? GTK_ORIENTATION_VERTICAL : GTK_ORIENTATION_HORIZONTAL, 0));
	gtk_box_set_homogeneous(box, uniform);
	this->i.base._widget=box;
	
	this->numchildren=numchildren;
	this->children=malloc(sizeof(struct widget_base*)*numchildren);
	for (unsigned int i=0;i<numchildren;i++)
	{
		this->children[i]=children[i];
	}
	
	unsigned char maxwidthprio=0;
	unsigned char maxheightprio=0;
	for (unsigned int i=0;i<numchildren;i++)
	{
		if (children[i]->_widthprio  > maxwidthprio ) maxwidthprio  = children[i]->_widthprio;
		if (children[i]->_heightprio > maxheightprio) maxheightprio = children[i]->_heightprio;
	}
	for (unsigned int i=0;i<numchildren;i++)
	{
		bool vexpand=(children[i]->_heightprio == maxheightprio);
		bool hexpand=(children[i]->_widthprio == maxwidthprio);
		gtk_widget_set_vexpand(children[i]->_widget, (vexpand || !vertical));
		gtk_widget_set_hexpand(children[i]->_widget, (hexpand ||  vertical));
		if (vertical) gtk_box_pack_start(box, children[i]->_widget, vexpand, vexpand, 0);
		else          gtk_box_pack_start(box, children[i]->_widget, hexpand, hexpand, 0);
	}
	this->i.base._widthprio=maxwidthprio;
	this->i.base._heightprio=maxheightprio;
	return (struct widget_layout*)this;
}



//grids go here
#endif
