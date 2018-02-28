#ifndef CAMERA_H_
#define CAMERA_H_

#include <SDL2/SDL.h>
#include <iostream>
#include <utility>

typedef std::pair<double, double> Point;
typedef SDL_Rect Rect;

class Camera
{
private:
    SDL_Window *window;
    SDL_Renderer *render;
    Rect vp;
    Rect screenrect;

public:
    Camera();
    Camera(SDL_Window *window);

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

};

#endif