#ifndef CAMERA_H_
#define CAMERA_H_

#include <SDL2/SDL.h>
#include <SDL2_image/SDL_image.h>
#include <SDL_ttf.h>
#include <iostream>
#include <vector>
#include <utility>
#include <unordered_map>
#include <string>
#include <cmath>

#define TILE_SIZE 16

struct Point
{
	double x;
	double y;
};

struct Rect
{
	double x;
	double y;
	double w;
	double h;
	double r;
};

struct Lua_Texture
{
	SDL_Texture *texture;
	Lua_Texture();
	~Lua_Texture();

	void deleteTexture();
};

class GlyphAtlas
{
private:
	TTF_Font *font;
	std::unordered_map<char, SDL_Texture *> glyphs;

public:
	GlyphAtlas();
	~GlyphAtlas();

	SDL_Texture* getGlyph(SDL_Renderer *, char);
};

class Camera
{
public:
	SDL_Window *window;
	SDL_Renderer *render;

	GlyphAtlas glyphatlas;
	std::vector<SDL_Texture *> layers = {nullptr, nullptr, nullptr};
	std::unordered_map<std::string, SDL_Texture *> textures;

	Rect screenrect;


	Camera(SDL_Window *, SDL_Renderer *);

	~Camera();

	void clear();
	void push();

	void draw_to_texture(SDL_Texture *target,
						const Rect &target_rect,
						const std::string texture_name,
						const Rect &src_rect);

	void draw_texture(SDL_Texture *texture_name, 
						const Rect &viewport,
						const Rect &location);

	void draw_sprite(std::string texture_name, 
						const Rect &viewport,
						const Rect &location,
						int framex, int framey,
						int framesw, int framesy);

	void draw_ui();

	void draw_text();
};

/*
struct DRAWITEMTYPE {
	int NONE = 0;
	int RECT = 1;
	int SPRITE = 2;
	int TEXTBOX = 3;
	int OPTIONBOX = 4;
	//TODO
	int UISPRITE = 5;
};

struct DrawItemSprite
{
	std::string texturename;
	unsigned framex;
	unsigned framey;
	unsigned totalframesx;
	unsigned totalframesy;
	double rotation;
	Rect dest;
	double life;
};

struct DrawItemTextBox
{
	std::string firstline;
	std::string secondline;
	bool showcontinuecursor;
	double x;
	double y;
	double w;
	double h;
};

struct DrawItemOptionBox
{
	double x;
	double y;
	double w;
	double h;
};

struct DrawUISprite
{
	std::string texturename;
	double x;
	double y;
};

struct DrawUnion
{
	Rect rect;
	DrawItemSprite sprite;
	DrawItemTextBox textbox;
	DrawItemOptionBox optionbox;
	DrawUISprite uisprite;

	DrawUnion();
	~DrawUnion();
};

struct DrawItem
{
	int type;
	DrawUnion data;

	DrawItem(int type);
};

class DrawContainer
{
public:
	Rect dim;
	std::vector<DrawItem> objs;

	void add(DrawItem);
};
*/

#endif