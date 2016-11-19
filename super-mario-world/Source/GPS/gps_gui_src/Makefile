all: salad_dummy

CC = gcc
CFLAGS = -g
LD = gcc
LFLAGS =

#Stuff needed for Windows goes here; there is no Makefile.custom on Windows.
TRUE_CFLAGS = $(CFLAGS) -DWINDOW_WIN32 -DNEED_MANUAL_LAYOUT
TRUE_LFLAGS = $(LFLAGS) -lgdi32 -lcomctl32 -lcomdlg32 -ldinput8 -ldxguid -lopengl32 -ldsound
EXESUFFIX = .exe
EXTRAOBJ = obj/resource.o
obj/resource.o: salad.rc
	windres salad.rc obj/resource.o

-include Makefile.custom

OBJS = $(patsubst %.c,obj/%.o,$(wildcard *.c)) $(EXTRAOBJ)

TRUE_CFLAGS += -std=gnu99
TRUE_LFLAGS +=


clean:
	rm obj/* || true

obj:
	mkdir obj

obj/%.o: %.c | obj
	$(CC) $(TRUE_CFLAGS) -c $< -o $@

grilledpancakesalad$(EXESUFFIX): $(OBJS)
	$(LD) $+ $(TRUE_LFLAGS) -o $@ -lm

salad_dummy: grilledpancakesalad$(EXESUFFIX)
