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

typedef std::pair<double, double> Point;

struct Rect{
	double x;
	double y;
	double w;
	double h;

	SDL_Rect convert();
};

struct DrawItem
{
	std::string texturename;
	unsigned frame;
	unsigned totalframes;
	Rect destrect; //only holds position
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
	Camera(SDL_Window *window);

	~Camera();

	void clear();
	void push();

	void draw(DrawContainer &);

	friend std::ostream& operator<<(std::ostream& os, const Camera &camera);


};

#endif