#ifndef CAMERA_H_
#define CAMERA_H_

#include <SDL2/SDL.h>
#include <SDL2_image/SDL_image.h>
#include <iostream>
#include <vector>
#include <utility>
#include <unordered_map>
#include <string>

typedef std::pair<double, double> Point;
typedef SDL_Rect Rect;

struct DrawItem
{
	std::string texturename;
	Rect rect;
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

	Rect vp;
	Rect screenrect;

public:
	Camera(SDL_Window *window);

	~Camera();

	void position(const Point &position);
	Point position();

	void dimension(const Point &size);
	Point dimension();

	void viewport(const Rect &vp);
	Rect viewport();

	double getScale();

	friend std::ostream& operator<<(std::ostream& os, const Camera &camera);

	void clear();
	void push();

	void drawRect(const Rect &r);

	void draw(DrawContainer &);

};

#endif