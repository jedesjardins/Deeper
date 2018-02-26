CC := g++
SRCDIR := src
BUILDDIR := build
TARGET := bin/app

all: mac

mac:
	g++ test.cpp -llua -std=c++14 `sdl2-config --cflags --libs` -o $(TARGET)

