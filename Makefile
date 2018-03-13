CC := g++
SRCDIR := src/cpp
BUILDDIR := build
TARGET := bin/app
 
SRCEXT := cpp
SOURCES := $(wildcard $(SRCDIR)/*.$(SRCEXT))
OBJECTS := $(patsubst $(SRCDIR)/%,$(BUILDDIR)/%,$(SOURCES:.$(SRCEXT)=.o))
LFLAGS := -lSDL2main -lSDL2 -lSDL2_image -lSDL2_ttf -lSDL2_mixer -framework Cocoa
CFLAGS := -std=c++14 -g 
MACFLAGS := -DMACOS `sdl2-config --cflags --libs` -lSDL2_image -lSDL2_ttf
LIBDIR := lib
LIBS := -llua
INC := -I include

all: mac

mac:
	$(CC) $(SOURCES) -I"include" -L"lib" $(LIBS) $(CFLAGS) $(MACFLAGS) -DLUADIR=\"/Users/jadesjar/Source/Echelon\" -o $(TARGET)

clean:
	rm $(TARGET)