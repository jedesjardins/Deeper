#ifndef CAMERA_H_
#define CAMERA_H_

#include <SDL2/SDL.h>
#include <SDL2_image/SDL_image.h>
#include <iostream>
#include <vector>
#include <utility>
#include <unordered_map>
#include <string>
#include <cmath>

#define TILE_SIZE 16

struct Point{
	double x;
	double y;
};

struct Rect{
	double x;
	double y;
	double w;
	double h;

	SDL_Rect convert();
	bool collide(const Rect&);
	void resolve(const Rect&, Point&);
	void resolveBoth(const Rect&, Point&, Point&);
};

struct DRAWITEMTYPE {
	int NONE = 0;
	int RECT = 1;
	int SPRITE = 2;
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
};

struct DrawUnion
{
	Rect rect;
	DrawItemSprite sprite;
};

struct DrawItem
{
	int type;
	DrawUnion data;
};

class DrawContainer
{
public:
	Rect dim;
	std::vector<DrawItem> objs;

	void add(DrawItem);
};

class Camera
{
private:
	SDL_Window *window;
	SDL_Renderer *render;
	std::unordered_map<std::string, SDL_Texture *> textures;

	Rect screenrect;

public:
	Camera(SDL_Window *, SDL_Renderer *);

	~Camera();

	void clear();
	void push();

	void draw(DrawContainer &);

	friend std::ostream& operator<<(std::ostream& os, const Camera &camera);


};

void calculateCollisionOut(const Rect &);

#endif